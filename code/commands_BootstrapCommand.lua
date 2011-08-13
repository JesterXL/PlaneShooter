module (..., package.seeall)

function new()
	local command = require("robotlegs_Command").new()
	
	function command:execute(event)
		print("BootstrapCommand::execute, event: ", event)
		require("models_PlayerModel")
		return true
	end

	return command
end