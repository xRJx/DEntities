include("shared.lua")

ENT.PopulateEntityInfo = true

local shadeColor = Color(0, 0, 0, 200)
local blockSize = 4
local blockSpacing = 2

function ENT:OnPopulateEntityInfo(tooltip)
	local item = self:GetItemTable()

	if (!item) then
		return
	end

	local oldData = item.data

	item.data = self:GetNetVar("data", {})
	item.entity = self

	ix.hud.PopulateItemTooltip(tooltip, item)

	local name = tooltip:GetRow("name")
	local color = name and name:GetBackgroundColor() or ix.config.Get("color")

	-- set the arrow to be the same colour as the title/name row
	tooltip:SetArrowColor(color)

	if ((item.width > 1 or item.height > 1) and
		hook.Run("ShouldDrawItemSize", item) != false) then

		local sizeHeight = item.height * blockSize + item.height * blockSpacing
		local size = tooltip:Add("Panel")
		size:SetWide(tooltip:GetWide())

		if (tooltip:IsMinimal()) then
			size:SetTall(sizeHeight)
			size:Dock(TOP)
			size:SetZPos(-999)
		else
			size:SetTall(sizeHeight + 8)
			size:Dock(BOTTOM)
		end

		size.Paint = function(sizePanel, width, height)
			if (!tooltip:IsMinimal()) then
				surface.SetDrawColor(ColorAlpha(shadeColor, 60))
				surface.DrawRect(0, 0, width, height)
			end

			local x, y = width * 0.5 - 1, height * 0.5 - 1
			local itemWidth = item.width - 1
			local itemHeight = item.height - 1
			local heightDifference = ((itemHeight + 1) * blockSize + blockSpacing * itemHeight)

			x = x - (itemWidth * blockSize + blockSpacing * itemWidth) * 0.5
			y = y - heightDifference * 0.5

			for i = 0, itemHeight do
				for j = 0, itemWidth do
					local blockX, blockY = x + j * blockSize + j * blockSpacing, y + i * blockSize + i * blockSpacing

					surface.SetDrawColor(shadeColor)
					surface.DrawRect(blockX + 1, blockY + 1, blockSize, blockSize)

					surface.SetDrawColor(color)
					surface.DrawRect(blockX, blockY, blockSize, blockSize)
				end
			end
		end

		tooltip:SizeToContents()
	end

	item.entity = nil
	item.data = oldData
end

function ENT:DrawTranslucent()
	local itemTable = self:GetItemTable()

	if (itemTable and itemTable.DrawEntity) then
		itemTable:DrawEntity(self)
	end
end

function ENT:Draw()
	self:DrawModel()
end