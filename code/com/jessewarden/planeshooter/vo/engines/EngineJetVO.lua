require "com.jessewarden.planeshooter.vo.engines.EngineVO"

EngineJetVO 				= {}

function EngineJetVO:new()

	local engine 			= EngineVO:new()
	
	engine.classType 		= "EngineJetVO"
	engine.power 			= 6
	engine.weight 			= 4

	return engine

end


return EngineJetVO