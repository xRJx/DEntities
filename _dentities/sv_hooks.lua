local PLUGIN = PLUGIN
local ITEM = ix.meta.item or {}

--- Spawn an item entity based off the item table.
-- @realm server
-- @param[type=vector] position The position in which the item's entity will be spawned
-- @param[type=angle] angles The angles at which the item's entity will spawn
-- @treturn entity The spawned entity
function ITEM:SpawnDEntity(position, angles, class)
	-- Check if the item has been created before.
	if (ix.item.instances[self.id]) then
		local client

		-- Spawn the actual item entity.
		local entity = ents.Create(class)
		entity:Spawn()
		entity:SetAngles(angles or Angle(0, 0, 0))
		entity:SetItem(self.id)

		-- If the first argument is a player, then we will find a position to drop
		-- the item based off their aim.
		if (type(position) == "Player") then
			client = position
			position = position:GetItemDropPos(entity)
		end

		entity:SetPos(position)

		if (IsValid(client)) then
			entity.ixSteamID = client:SteamID()
			entity.ixCharID = client:GetCharacter():GetID()
			entity:SetNetVar("owner", entity.ixCharID)
		end

		hook.Run("OnItemSpawned", entity)
		return entity
	end
end

function PLUGIN:LoadData()
	local items = self:GetData()

	if (items) then
		local idRange = {}
		local info = {}

		for _, v in ipairs(items) do
			idRange[#idRange + 1] = v[1]
			info[v[1]] = {v[2], v[3], v[4], v[5]}
		end

		if (#idRange > 0) then
			if (hook.Run("ShouldDeleteSavedItems") == true) then
				-- don't spawn saved item and just delete them.
				local query = mysql:Delete("ix_items")
					query:WhereIn("item_id", idRange)
				query:Execute()

				print("Server Deleted Server Items (does not includes Logical Items)")
			else
				local query = mysql:Select("ix_items")
					query:Select("item_id")
					query:Select("unique_id")
					query:Select("data")
					query:WhereIn("item_id", idRange)
					query:Callback(function(result)
						if (istable(result)) then
							local loadedItems = {}
							local bagInventories = {}

							for _, v in ipairs(result) do
								local itemID = tonumber(v.item_id)
								local data = util.JSONToTable(v.data or "[]")
								local uniqueID = v.unique_id
								local itemTable = ix.item.list[uniqueID]

								if (itemTable and itemID) then
									local item = ix.item.New(uniqueID, itemID)
									item.data = data or {}

									local itemInfo = info[itemID]
									local position, angles, bMovable = itemInfo[1], itemInfo[2], true

									if (isbool(itemInfo[3])) then
										bMovable = itemInfo[3]
									end

									local itemEntity = item:SpawnDEntity(position, angles, itemInfo[4])
									itemEntity.ixItemID = itemID

									local physicsObject = itemEntity:GetPhysicsObject()

									if (IsValid(physicsObject)) then
										physicsObject:EnableMotion(bMovable)
									end

									item.invID = 0
									loadedItems[#loadedItems + 1] = item

									if (item.isBag) then
										local invType = ix.item.inventoryTypes[uniqueID]
										bagInventories[item:GetData("id")] = {invType.w, invType.h}
									end
								end
							end

							-- we need to manually restore bag inventories in the world since they don't have a current owner
							-- that it can automatically restore along with the character when it's loaded
							if (!table.IsEmpty(bagInventories)) then
								ix.inventory.Restore(bagInventories)
							end

							hook.Run("OnSavedItemLoaded", loadedItems) -- when you have something in the dropped item.
						end
					end)
				query:Execute()
			end
		end
	end
end

function PLUGIN:SaveData()
	local items = {}

	for _, v in ipairs(ents.GetAll()) do
		if (scripted_ents.IsBasedOn(v:GetClass(), "ix_item_dentity")) then
			if (v.ixItemID and !v.bTemporary) then
				local physicsObject = v:GetPhysicsObject()
				local bMovable = nil
				local class = v:GetClass()

				if (IsValid(physicsObject)) then
					bMovable = physicsObject:IsMoveable()
				end

				items[#items + 1] = {
					v.ixItemID, v:GetPos(), v:GetAngles(), bMovable, class
				}
			end
		end
	end

	self:SetData(items)
end
