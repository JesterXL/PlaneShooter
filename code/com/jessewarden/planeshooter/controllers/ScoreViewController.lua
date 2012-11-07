ScoreViewController = {}

function ScoreViewController:new(scoreView, scoreModel)

	local controller = {}
	controller.scoreView = scoreView
	controller.scoreModel = scoreModel

	function controller:init()
		self.scoreView:setScore(self.scoreModel.score)

		Runtime:addEventListener("ScoreModel_scoreChanged", self)
	end

	function controller:ScoreModel_scoreChanged(event)
		self.scoreView:setScore(self.scoreModel.score)
	end

	controller:init()

	return controller
end

return ScoreViewController