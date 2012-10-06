require "com.jessewarden.planeshooter.vo.bodies.BodyVO"
BodySteelVO 				= {}

function BodySteelVO:new()

	local engine 			= BodyVO:new()
	
	engine.classType 		= "BodySteelVO"
	engine.weight 			= 4
	engine.defense 			= 4

	return engine

end

return BodySteelVO