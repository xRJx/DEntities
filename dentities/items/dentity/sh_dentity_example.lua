ITEM.name = "Example DEntity"
ITEM.description = "An example Droppable Entity."
ITEM.model = "models/props_c17/chair02a.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.dEntity = "ix_dentity_example"
ITEM.exRender = true
ITEM.iconCam = {
	pos = Vector(412.97, 339.56, 247.92),
	ang = Angle(25.25, 220.06, 0),
	fov = 5.53
}

ITEM.functions.Activate = {
	OnRun = function(item)
		return false
	end
}
