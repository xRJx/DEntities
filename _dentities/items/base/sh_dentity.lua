ITEM.name = "Droppable Entity"
ITEM.description = "A base item for being able to drop a Helix item as an entity."
ITEM.model = "models/props_c17/chair02a.mdl"
ITEM.category = "Droppable Entities"
ITEM.width = 2
ITEM.height = 2
ITEM.exRender = true
ITEM.iconCam = {
	pos = Vector(412.97, 339.56, 247.92),
	ang = Angle(25.25, 220.06, 0),
	fov = 5.53
}

function ITEM.postHooks.drop(item, status)
	local client = item.player
	local entity = item:GetEntity()
	local data = {}
		data.start = client:GetShootPos()
		data.endpos = data.start + client:GetAimVector() * 96
		data.filter = client

	local dEntity = scripted_ents.Get(item.dEntity):SpawnFunction(client, util.TraceLine(data))
	dEntity:SetItem(item.id)
	
	entity.ixItemID = nil -- Invalidate old item to maintain DB saving
	
	item:Remove(false, true)
	entity:Remove()
end
