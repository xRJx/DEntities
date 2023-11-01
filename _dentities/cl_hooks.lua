local PLUGIN = PLUGIN

function PLUGIN:KeyRelease(client, key)
	if (!IsFirstTimePredicted()) then
		return
	end

	if (key == IN_USE) then
		if (!ix.menu.IsOpen()) then
			local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + client:GetAimVector() * 96
			data.filter = client

			local entity = util.TraceLine(data).Entity

			if (IsValid(entity) and isfunction(entity.GetDEntityMenu)) then
				hook.Run("ShowDEntityMenu", entity)
			end
		end

		timer.Remove("ixItemUse")

		client.ixInteractionTarget = nil
		client.ixInteractionStartTime = nil
	end
end

function PLUGIN:ShowDEntityMenu(entity)
	local options = entity:GetDEntityMenu(LocalPlayer())

	if (istable(options) and !table.IsEmpty(options)) then
		ix.menu.Open(options, entity)
	end
end
