
EngineVO 				= {}

function EngineVO:new()

	local engine 			= {}
	
	engine.classType 		= "EngineVO"
	engine.power 			= 1
	engine.weight 			= 1
	engine.type 			= constants.ENGINE

	return engine

end


return EngineVO