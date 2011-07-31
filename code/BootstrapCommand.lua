module (..., package.seeall)

function new()
	local command = require("Command").new()
	
	function command:execute(event)
		print("BootstrapCommand::execute, event: ", event)
		require("PlayerModel")
		return true
	end

	return command
end