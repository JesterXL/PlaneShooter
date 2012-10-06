require "com.jessewarden.planeshooter.vo.engines.EngineVO"

EngineGravitronVO 			= {}

function EngineGravitronVO:new()

	local engine 			= EngineVO:new()
	
	engine.classType 		= "EngineGravitronVO"
	engine.power 			= 10
	engine.weight 			= 4

	return engine

end


return EngineGravitronVO