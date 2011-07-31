module (..., package.seeall)

function new(viewInstance)
	
	local mediator = require("Mediator").new(viewInstance)
	mediator.superOnRegister = mediator.onRegister
	
	function mediator:onRegister()
		print("PlayerMediator::onRegister, viewInstance: ", viewInstance)
		self:superOnRegister()
		
		viewInstance:addEventListener("bulletHit", self)
	end
	
	function mediator:bulletHit(event)
		print("PlayerMediator::bulletHit")
		PlayerModel.instance:onBulletHit()
	end
	
	return mediator
	
end