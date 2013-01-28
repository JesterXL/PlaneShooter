require "com.jessewarden.statemachine.BaseState"
TankManNormalState = {}

function TankManNormalState:new()
	local state = BaseState:new("normal")
	
	function state:onEnterState(event)
		self.entity:addEventListener("onReachedFirePosition", self)
		self.entity:addEventListener("onFireMissilesCompleted", self)
		self.entity:addEventListener("onFireFlakCompleted", self)
		self.entity:startRotateToSpreadPosition()
	end
	
	function state:onExitState(event)
		self.entity:removeEventListener("onReachedFirePosition", self)
		self.entity:removeEventListener("onFireMissilesCompleted", self)
		self.entity:removeEventListener("onFireFlakCompleted", self)
	end
	
	function state:onReachedFirePosition(event)
		if self.entity.targetPosition == "spread" then
			self.entity:startFiringMissiles()
		else
			self.entity:startFiringFlak()
		end
	end

	function state:onFireMissilesCompleted(event)
		self.entity:startRotateToClosePosition()
	end

	function state:onFireFlakCompleted(event)
		self.entity:startRotateToSpreadPosition()
	end

	return state
end

return TankManNormalState