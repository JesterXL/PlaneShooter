module (..., package.seeall)

require "models_PlayerModel"

function new(viewInstance)
	
	local mediator = require("robotlegs_Mediator").new(viewInstance)
	mediator.superOnRegister = mediator.onRegister
	mediator.name = "DamageHUDMediator"
	
	function mediator:onRegister()
		self:superOnRegister()
		
		PlayerModel.instance:addListener("hitPointsChanged", mediator.hitPointsChanged)
		self:hitPointsChanged()
	end
	
	function mediator:onRemove()
		PlayerModel.instance:removeListener("hitPointsChanged", mediator.hitPointsChanged)
	end
	
	function mediator:hitPointsChanged(event)
		mediator.viewInstance:setHitpoints(PlayerModel.instance.hitPoints, PlayerModel.instance.maxHitPoints)
	end
	
	return mediator
	
end