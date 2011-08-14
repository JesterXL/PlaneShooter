module (..., package.seeall)

function new()
	local context = require("robotlegs_Context").new()
	context.superStartup = context.startup
	
	function context:startup()
		print("MainContext::startup, ID: ", self.ID)
		self:superStartup()
		
		self:mapCommand("startThisMug", "commands_BootstrapCommand")
		
		self:mapMediator("player_Player", "mediators_PlayerMediator")
		self:mapMediator("gamegui_DamageHUD", "mediators_DamageHUDMediator")
		
		self:dispatch({name="startThisMug", target=self})
	end

	return context
end
