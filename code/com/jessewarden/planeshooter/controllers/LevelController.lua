LevelController = {}

function LevelController:new()

	local controller = {}
	controller.eventReady = nil

	function controller:start()
		Runtime:addEventListener("LevelModel_eventReady", self)
	end

	function controller:stop()
		Runtime:removeEventListener("LevelModel_eventReady", self)
	end

	function controller:LevelModel_eventReady(event)
		
	end

	return controller

end

return LevelController