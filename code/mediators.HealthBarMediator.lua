module (..., package.seeall)

require "models.PlayerModel"

function new(viewInstance)
	
	local mediator = require("robotlegs.Mediator").new(viewInstance)
	print("viewInstance: ", viewInstance, ", vs. mediator.viewInstance: ", mediator.viewInstance)
	mediator.superOnRegister = mediator.onRegister
	mediator.name = "HealthBarMediator"
	
	function mediator:onRegister()
		print("HealthBarMediator::onRegister, viewInstance: ", viewInstance)
		self:superOnRegister()
		
		PlayerModel.instance:addListener("hitPointsChanged", mediator.hitPointsChanged)
	end
	
	function mediator:onRemove()
		PlayerModel.instance:removeListener("hitPointsChanged", mediator.hitPointsChanged)
	end
	
	function mediator:hitPointsChanged(event)
		print("HealthBarMediator::hitPointsChanged")
		mediator.viewInstance:setHealth(PlayerModel.instance:getHitpointsPercentage())
	end
	
	return mediator
	
end