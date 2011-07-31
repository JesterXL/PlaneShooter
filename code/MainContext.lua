module (..., package.seeall)

function new()
	local context = require("Context").new()
	context.superStartup = context.startup
	
	function context:startup()
		print("MainContext::startup, ID: ", self.ID)
		self:superStartup()
		
		self:mapCommand("startThisMug", "BootstrapCommand")
		
		self:mapMediator("Player", "PlayerMediator")
		
		self:dispatch({name="startThisMug", target=self})
	end

	return context
end