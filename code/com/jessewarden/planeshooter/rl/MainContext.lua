require "org.robotlegs.Context"


MainContext = {}

function MainContext:new()
	print("MainContext::new")
	local context = Context:new()
	print("\tcontext: ", context)
	
	function context:startup()
		print("MainContext::startup, ID: ", self.ID)
		
		print("\tmapping commands...")
		self:mapCommand("startThisMug", "com.jessewarden.planeshooter.rl.commands.BootstrapCommand")
		
		print("\tmapping mediators...")
		self:mapMediator("com.jessewarden.planeshooter.sprites.player.Player", "com.jessewarden.planeshooter.rl.mediators.PlayerMediator")
		self:mapMediator("com.jessewarden.planeshooter.gamegui.DamageHUD", "com.jessewarden.planeshooter.rl.mediators.DamageHUDMediator")
		self:mapMediator("com.jessewarden.planeshooter.gamegui.ScoreView", "com.jessewarden.planeshooter.rl.mediators.ScoreViewMediator")
		
		print("\tdone, dispatching start event...")
		self:dispatch({name="startThisMug", target=self})
		
		return true
	end

	return context
end

return MainContext