require "com.jessewarden.statemachine.State"

BaseState = {}

function BaseState:new(name, parent, from)

	assert(name ~= nil, "You cannot pass a nil name.")
	
	if from == nil or from == "" then
		from = "*"
	end
	
	local state = State:new({name = name, parent = parent, from = from})
	state.ready = false
	
	state.enter = function(event)
		state.ready = true
		state.stateMachine = event.target
		state.entity = event.entity
		assert(state.onEnterState ~= nil, "Your state class does not define an onEnterState method.")
		return state:onEnterState(event)
	end
	state.exit = function(event)
		assert(state.onExitState ~= nil, "Your state class does not define an onExitState method.")
		local result = state:onExitState(event)
		state.ready = false
		state.stateMachine = nil
		state.entity = nil
		return result
	end
	
	
	function state:onEnterState(event)
		--print(self.name .. " BaseState::onEnterState, from: ", event.fromState, ", to: ", event.toState, ", current: ", event.currentState)
	end
	
	function state:onExitState(event)
		--print(self.name .. " BaseState::onExitState, from: ", event.fromState, ", to: ", event.toState, ", current: ", event.currentState)
	end
	
	function state:onTransitionComplete(event)
		--print(self.name .. " BaseState::onTransitionComplete, from: ", event.fromState, ", to: ", event.toState, ", current: ", event.currentState)
	end
	
	function state:onTransitionDenied(event)
		--print(self.name .. " BaseState::onTransitionDenied, from: ", event.fromState, ", to: ", event.toState, ", current: ", event.currentState)
	end
	
	function state:tick(time)
	end
	
	Runtime:addEventListener("onTransitionComplete", function(event)
														if event.toState == state.name then
															return state:onTransitionComplete(event)
														end
													end
							)
							
	Runtime:addEventListener("onTransitionDenied", function(event)
														if event.toState == state.name then
															return state:onTransitionDenied(event)
														end
													end
							)
	
	return state
	
end

return BaseState