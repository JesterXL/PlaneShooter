module (..., package.seeall)

function new(viewInstance)
	
	local mediator = require("robotlegs/Mediator").new(viewInstance)
	mediator.superOnRegister = mediator.onRegister
	
	function mediator:onRegister()
		print("PlayerMediator::onRegister, viewInstance: ", viewInstance)
		self:superOnRegister()
		
		viewInstance.hitPoints = PlayerModel.instance.hitPoints
		viewInstance.maxHitPoints = PlayerModel.instance.maxHitPoints
		viewInstance:addEventListener("bulletHit", self)
	end
	
	function mediator:onRemove()
		viewInstance:removeEventListener("bulletHit", self)
	end
	
	function mediator:bulletHit(event)
		print("PlayerMediator::bulletHit")
		PlayerModel.instance:onBulletHit()
	end
	
	return mediator
	
end