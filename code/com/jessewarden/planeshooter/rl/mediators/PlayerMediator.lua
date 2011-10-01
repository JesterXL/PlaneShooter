require "org.robotlegs.Mediator"

require "com.jessewarden.planeshooter.rl.models.PlayerModel"

PlayerMediator = {}
PlayerMediator.classType = "PlayerMediator"

function PlayerMediator:new(viewInstance)
	
	local mediator = Mediator:new(viewInstance)
	mediator.superOnRegister = mediator.onRegister
	
	function mediator:onRegister()
		--print("PlayerMediator::onRegister, viewInstance: ", viewInstance)
		self:superOnRegister()
		
		viewInstance.hitPoints = PlayerModel.instance.hitPoints
		viewInstance.maxHitPoints = PlayerModel.instance.maxHitPoints
		viewInstance:addEventListener("bulletHit", self)
		viewInstance:addEventListener("missileHit", self)
	end
	
	function mediator:onRemove()
		viewInstance:removeEventListener("bulletHit", self)
		viewInstance:removeEventListener("missileHit", self)
	end
	
	function mediator:bulletHit(event)
		PlayerModel.instance:onBulletHit()
	end

	function mediator:missileHit(event)
		PlayerModel.instance:onMissileHit()
	end
	
	return mediator
	
end

return PlayerMediator