require "com.jessewarden.statemachine.BaseState"
TankManCrazyState = {}

function TankManCrazyState:new()
	local state = BaseState:new("crazy")
	
	function state:onEnterState(event)
		print("TankManCrazyState::enter")
		self.entity:addEventListener("onFireMissilesCompleted", self)
		self.entity:addEventListener("onFireFlakCompleted", self)
		self.entity:startSuperSpinSams()
		self.entity:startFiringMissiles()
		self.entity:startFiringFlak()
	end
	
	function state:onExitState(event)
		print("TankManCrazyState::onExitState")
		self.entity:removeEventListener("onFireMissilesCompleted", self)
		self.entity:removeEventListener("onFireFlakCompleted", self)
	end

	function state:onFireMissilesCompleted(event)
		print("TankManCrazyState::onFireMissilesCompleted")
		self.entity:startFiringMissiles()
	end

	function state:onFireFlakCompleted(event)
		print("TankManCrazyState::onFireFlakCompleted")
		self.entity:startFiringFlak()
	end

	return state
end

return TankManCrazyState