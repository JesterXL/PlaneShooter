
require "org.robotlegs.Mediator"
require "com.jessewarden.planeshooter.rl.models.PlayerModel"

DamageHUDMediator = {}

function DamageHUDMediator:new(viewInstance)
	
	local mediator = Mediator:new(viewInstance)
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

return DamageHUDMediator