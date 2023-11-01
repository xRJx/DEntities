ENT.Base = "base_entity"
ENT.Type = "anim"
ENT.PrintName = "Item DEntity"
ENT.Category = "Helix"
ENT.Spawnable = true
ENT.ShowPlayerInteraction = true
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.bNoPersist = true

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "ItemID")
end

function ENT:GetDEntityMenu(client)
	local itemTable = self:GetItemTable()
	local options = {}

	if (!itemTable) then
		return false
	end

	itemTable.player = client
	itemTable.entity = self

	for k, v in SortedPairs(itemTable.functions) do
		if (k == "take" or k == "combine") then
			continue
		end

		if (v.OnCanRun and v.OnCanRun(itemTable) == false) then
			continue
		end

		-- we keep the localized phrase since we aren't using the callbacks - the name won't matter in this case
		options[L(v.name or k)] = function()
			local send = true

			if (v.OnClick) then
				send = v.OnClick(itemTable)
			end

			if (v.sound) then
				surface.PlaySound(v.sound)
			end

			if (send != false) then
				net.Start("ixItemEntityAction")
					net.WriteString(k)
					net.WriteEntity(self)
				net.SendToServer()
			end

			-- don't run callbacks since we're handling it manually
			return false
		end
	end

	itemTable.player = nil
	itemTable.entity = nil

	return options
end

function ENT:GetItemTable()
	return ix.item.list[self:GetItemID()]
end

function ENT:GetData(key, default)
	local data = self:GetNetVar("data", {})

	return data[key] or default
end
