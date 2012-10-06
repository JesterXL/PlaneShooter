require "com.jessewarden.planeshooter.vo.bodies.BodyVO"
BodyCarbonFibreVO 				= {}

function BodyCarbonFibreVO:new()

	local engine 			= BodyVO:new()
	
	engine.classType 		= "BodyCarbonFibreVO"
	engine.weight 			= 2
	engine.defense 			= 3

	return engine

end

return BodyCarbonFibreVO