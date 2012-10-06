require "com.jessewarden.planeshooter.vo.bodies.BodyVO"
BodyAlumniumVO 				= {}

function BodyAlumniumVO:new()

	local engine 			= BodyVO:new()
	
	engine.classType 		= "BodyAlumniumVO"
	engine.weight 			= 2
	engine.defense 			= 2

	return engine

end

return BodyAlumniumVO