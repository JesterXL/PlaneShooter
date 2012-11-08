ScoreViewController = {}

function ScoreViewController:new(scoreView, scoreModel)

	local controller = {}
	controller.scoreView = scoreView
	controller.scoreModel = scoreModel

	function controller:init()
		self.scoreView:setScore(self.scoreModel.score)

		Runtime:addEventListener("ScoreModel_scoreChanged", self)

		Runtime:addEventListener("onAddToScore", self)
	end

	function controller:ScoreModel_scoreChanged(event)
		self.scoreView:setScore(self.scoreModel.score)
	end

	function controller:onAddToScore(event)
		self.scoreModel:addToScore(event.value)
	end

	controller:init()

	return controller
end

return ScoreViewController