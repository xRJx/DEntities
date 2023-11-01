include("shared.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

local invalidBoundsMin = Vector(-8, -8, -8)
local invalidBoundsMax = Vector(8, 8, 8)

util.AddNetworkString("ixItemEntityAction")

function ENT:Initialize()
	self:SetModel("models/props_junk/watermelon01.mdl")
	self:SetSolid(SOLID_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self.health = 50

	local physObj = self:GetPhysicsObject()

	if (IsValid(physObj)) then
		physObj:EnableMotion(true)
		physObj:Wake()
	end
end

function ENT:Use(activator, caller)
	local itemTable = self:GetItemTable()

	if (IsValid(caller) and caller:IsPlayer() and caller:GetCharacter() and itemTable) then
		itemTable.player = caller
		itemTable.entity = self

		if (itemTable.functions.take.OnCanRun(itemTable)) then
			caller:PerformInteraction(ix.config.Get("itemPickupTime", 0.5), self, function(client)
				if (!ix.item.PerformInventoryAction(client, "take", self)) then
					return false -- do not mark dirty if interaction fails
				end
			end)
		end

		itemTable.player = nil
		itemTable.entity = nil
	end
end

function ENT:SetItem(itemID)
	local itemTable = ix.item.instances[itemID]

	if (itemTable) then
		self:SetItemID(itemTable.uniqueID)
		self.ixItemID = itemID
		
		if (!table.IsEmpty(itemTable.data)) then
			self:SetNetVar("data", itemTable.data)
		end
		
		if (itemTable.OnEntityCreated) then
			itemTable:OnEntityCreated(self)
		end
	end
end

function ENT:OnDuplicated(entTable)
	local itemID = entTable.ixItemID
	local itemTable = ix.item.instances[itemID]

	ix.item.Instance(0, itemTable.uniqueID, itemTable.data, 1, 1, function(item)
		self:SetItem(item:GetID())
	end)
end

function ENT:OnTakeDamage(damageInfo)
	local itemTable = ix.item.instances[self.ixItemID]

	if (itemTable.OnEntityTakeDamage
	and itemTable:OnEntityTakeDamage(self, damageInfo) == false) then
		return
	end

	local damage = damageInfo:GetDamage()
	self:SetHealth(self:Health() - damage)

	if (self:Health() <= 0 and !self.ixIsDestroying) then
		self.ixIsDestroying = true
		self.ixDamageInfo = {damageInfo:GetAttacker(), damage, damageInfo:GetInflictor()}
		self:Remove()
	end
end

function ENT:OnRemove()
	if (!ix.shuttingDown and !self.ixIsSafe and self.ixItemID) then
		local itemTable = ix.item.instances[self.ixItemID]

		if (itemTable) then
			if (self.ixIsDestroying) then
				self:EmitSound("physics/cardboard/cardboard_box_break"..math.random(1, 3)..".wav")
				local position = self:LocalToWorld(self:OBBCenter())

				local effect = EffectData()
					effect:SetStart(position)
					effect:SetOrigin(position)
					effect:SetScale(3)
				util.Effect("GlassImpact", effect)

				if (itemTable.OnDestroyed) then
					itemTable:OnDestroyed(self)
				end

				ix.log.Add(self.ixDamageInfo[1], "itemDestroy", itemTable:GetName(), itemTable:GetID())
			end

			if (itemTable.OnRemoved) then
				itemTable:OnRemoved()
			end

			local query = mysql:Delete("ix_items")
				query:Where("item_id", self.ixItemID)
			query:Execute()
		end
	end
end

function ENT:Think()
	local itemTable = self:GetItemTable()

	if (!itemTable) then
		self:Remove()
	end

	if (itemTable.Think) then
		itemTable:Think(self)
	end

	return true
end

function ENT:UpdateTransmitState()
	return TRANSMIT_PVS
end

net.Receive("ixItemEntityAction", function(length, client)
	ix.item.PerformInventoryAction(client, net.ReadString(), net.ReadEntity())
end)