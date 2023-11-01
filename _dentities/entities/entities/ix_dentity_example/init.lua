include("shared.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

DEFINE_BASECLASS(ENT.Base)

function ENT:SpawnFunction(client, trace)
	spawnPosition = trace.HitPos + trace.HitNormal * 40
	spawnAngles = client:EyeAngles()
	spawnAngles.p = 0

	local entity = ents.Create("ix_dentity_example")
	entity:SetPos(trace.HitPos + Vector(0, 0, 10))
	entity:SetAngles(spawnAngles)
	entity:Spawn()
	entity:Activate()

	return entity
end

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	
	self:SetModel("models/props_interiors/Furniture_Couch02a.mdl")
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
	self:EmitSound("buttons/button3.wav", 80)
	self.BaseClass.Use(self, activator, caller)
end
