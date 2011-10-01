require "org.robotlegs.Mediator"

require "com.jessewarden.planeshooter.rl.models.PlayerModel"

ScoreViewMediator = {}

function ScoreViewMediator:new(viewInstance)

	local mediator = Mediator:new(viewInstance)
	mediator.superOnRegister = mediator.onRegister
	mediator.name = "ScoreViewMediator"

	function mediator:onRegister()
		self:superOnRegister()

		PlayerModel.instance:addListener("scoreChanged", mediator.scoreChanged)
		self:scoreChanged()
	end

	function mediator:onRemove()
		PlayerModel.instance:removeListener("scoreChanged", mediator.scoreChanged)
	end

	function mediator:scoreChanged(event)
		mediator.viewInstance:setScore(PlayerModel.instance.score)
	end

	return mediator

end

return ScoreViewMediator