require "com.jessewarden.statemachine.BaseState"
TankManDeadState = {}

function TankManDeadState:new()
	local state = BaseState:new("dead")
	
	function state:onEnterState(event)
		local tank = self.entity
		tank:destroy()
	end
	
	function state:onExitState(event)
	end

	return state
end

return TankManDeadState