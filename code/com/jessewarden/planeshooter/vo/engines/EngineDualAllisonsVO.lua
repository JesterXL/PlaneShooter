require "com.jessewarden.planeshooter.vo.engines.EngineVO"
EngineDualAllisonsVO 				= {}

function EngineDualAllisonsVO:new()

	local engine 			= EngineVO:new()
	
	engine.classType 		= "EngineDualAllisonsVO"
	engine.power 			= 2
	engine.weight 			= 2

	return engine

end


return EngineDualAllisonsVO