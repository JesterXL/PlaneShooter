require "com.jessewarden.planeshooter.vo.bodies.BodyVO"
BodyWoodVO 				= {}

function BodyWoodVO:new()

	local engine 			= BodyVO:new()
	
	engine.classType 		= "BodyWoodVO"
	engine.weight 			= 1
	engine.defense 			= 1

	return engine

end

return BodyWoodVO