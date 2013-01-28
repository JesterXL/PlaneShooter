require "com.jessewarden.statemachine.BaseState"
TankManDamagedState = {}

function TankManDamagedState:new()
	local state = BaseState:new("damaged")
	
	function state:onEnterState(event)
		self.entity:addEventListener("onFireMissilesCompleted", self)
		self.entity:addEventListener("onFireFlakCompleted", self)
		self.entity:startSpinSAMS()
		self.entity:startFiringMissiles()
	end
	
	function state:onExitState(event)
		self.entity:removeEventListener("onFireMissilesCompleted", self)
		self.entity:removeEventListener("onFireFlakCompleted", self)
	end

	function state:onFireMissilesCompleted(event)
		self.entity:stopSpinSAMS()
		self.entity:startFiringFlak()
	end

	function state:onFireFlakCompleted(event)
		self.entity:startSpinSAMS()
		self.entity:startFiringMissiles()
	end

	return state
end

return TankManDamagedState