
BodyVO 						= {}

function BodyVO:new()

	local engine 			= {}
	
	engine.classType 		= "BodyVO"
	engine.weight 			= 1
	engine.defense 			= 1
	engine.type 			= constants.BODY

	return engine

end


return BodyVO