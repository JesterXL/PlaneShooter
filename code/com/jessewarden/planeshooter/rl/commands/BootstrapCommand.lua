
require "org.robotlegs.Actor"

require "com.jessewarden.planeshooter.core.constants"
require "com.jessewarden.planeshooter.services.AchievementsProxy"

BootstrapCommand = {}

function BootstrapCommand:new()
	
	local command = Actor:new()
	
	function command:execute(event)
		print("BootstrapCommand::execute")
		AchievementsProxy:init(constants.gameNetworkType, constants.achievements)
	end
	
	return command
	
end

return BootstrapCommand