ScoreViewController = {}

function ScoreViewController:new()

	local controller = {}
	controller.view = nil
	controller.scoreModel = nil

	function controller:onRegister()
		self.scoreModel = self.context.getModel("scoreMode")
		self.scoreView:setScore(self.scoreModel.score)

		Runtime:addEventListener("ScoreModel_scoreChanged", self)
		Runtime:addEventListener("onAddToScore", self)
	end

	function controller:onRemove()
		Runtime:removeEventListener("ScoreModel_scoreChanged", self)
		Runtime:removeEventListener("onAddToScore", self)
	end

	function controller:ScoreModel_scoreChanged(event)
		self.scoreView:setScore(self.scoreModel.score)
	end

	function controller:onAddToScore(event)
		self.scoreModel:addToScore(event.value)
	end

	return controller
end

return ScoreViewController