SetupAudioCommand = {}

function SetupAudioCommand:new()

	local command = {}

	function command:execute(event, context)
		print("SetupAudioCommand::execute")
		local progressModel = context:getModel("progressModel")
		local levelModel = context:getModel("levelModel")
		local scoreModel = context:getModel("scoreModel")
		local playerModel = context:getModel("playerModel")
		progressModel:saveProgress(levelModel.level.fileName, 
									scoreModel.score, 
									playerModel:getMemento())
	end

	return command

end

return SetupAudioCommand