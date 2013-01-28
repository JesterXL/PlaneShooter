require "com.jessewarden.statemachine.State"
StateMachine = {}

function StateMachine:new(entity)
	
	--if entity == nil then error("entity cannot be nil.") end
	--if entity.classType == nil then error("entity.classType cannot be nil.") end
	
	--print("StateMachine::new, entity.classType: ", entity.classType)
	
	-- option: If you want to just use self to dispatch events,
	-- have stateMachine extend a table instead.
	--local stateMachine = {}
	local stateMachine = display.newGroup()
	stateMachine.states = {}
	stateMachine.id = nil
	stateMachine.state = nil
	stateMachine.states = {}
	stateMachine.parentState = nil
	stateMachine.parentStates = {}
	stateMachine.path = {}
	stateMachine.previousState = nil
	stateMachine.entity = entity
	stateMachine.lastTickTime = nil
	stateMachine.stateToChangeTo = nil
	stateMachine.changeStateAtTick = false
	stateMachine.entity = entity
	
	-- NOTE: if the user supplies a parent state and does not include in the from name/table,
	-- that's ok, the State class checks to ensure.
	function stateMachine:addState(stateName, stateData)
		if self.states[stateName] ~= nil then
			print("WARNING: StateMachine::addedState, overriding existing state: " .. stateName)
		end
		
		if stateData == nil then stateData = {} end
		
		local newStatesParent = nil
		if stateData.parent then
			newStatesParent = self.states[stateData.parent]
		end

		local state = State:new({name = stateName,
									from = stateData.from,
									enter = stateData.enter,
									exit = stateData.exit,
									parent = newStatesParent})
		self.states[stateName] = state
	end
	
	function stateMachine:addState2(state)
		if state == nil then error("You cannot add a nil state.") end
		--print("StateMachine::addState2, state: ", state.name)
		if self.states[state.name] ~= nil then
			print("WARNING: StateMachne::addedState2, overriding existing state: " .. state.name)
		end
		
		local newStatesParent = nil
		if state.parent then
			newStatesParent = self.states[state.parent]
		end
		self.states[state.name] = state
	end
	
	function stateMachine:setInitialState(stateName)
		local initial = self.states[stateName]
		if initial == nil then error("State: '" .. tostring(stateName) .. "' cannot be found.") end
		--print("StateMachine::setInitialState, stateName: ", stateName)
		--print("state: ", self.state, ", initial: ", initial)
		if self.state == nil and initial ~= nil then
			self:setState(stateName)
			
			local event = {name = "onEnterState", target = self, toState = stateName, entity = self.entity}
			
			local root = initial:getRoot()
			--print("root: ", root)
			if root ~= nil then
				local newParentStates = initial:getParents()
				self.parentStates = newParentStates
				local i = 1
				while newParentStates[i] do
					if newParentStates[i].enter ~= nil then
						event.currentState = newParentStates[i].name
						newParentStates[i].enter(event)
					end
					i = i + 1
				end
			end
			
			if initial.enter ~= nil then
				event.currentState = stateName
				initial.enter(event)
			end
			
			local outEvent = {name = "onTransitionComplete", target = self, toState = stateName}
			self:dispatchEvent(outEvent)
		end
	end
	
	function stateMachine:getStateByName(stateName)
		local i = 1
		local states = self.states
		for i,v in ipairs(states) do
			if(v ~= nil and v.name == stateName) then
				return v
			end
		end
		return false
	end
	
	function stateMachine:canChangeStateTo(stateName)
		--print("StateMachine::canChageStateTo for " .. self.entity.classType .. " stateName: ", stateName)
		--print("StateMachine::canChangeStateTo: ", stateName, ", currentState: ", self.state)
		local theState = self.states[stateName]
		local score = 0
		local win = 2
		
		if stateName ~= self.state then
			--print("score 1")
			score = score + 1
		end
		
		if theState:inFrom(self.state) == true then
			--print("score 2")
			score = score + 1
		else
			local childState = self.states[self.state]
			if childState and childState.parent then
				if childState.parent.name == stateName then
					score = score + 1
				end
			end
		end
		
		if theState.from == "*" then
			--print("score 3")
			score = score + 1
		end
		
		--print("score: ", score, ", vs win: ", win)
		if score >= win then
			return true
		else
			return false
		end
		
		--[[
		if stateName ~= self.state and (theState:inFrom(self.state) == false or theState.from == "*") then
			return true
		else
			return false
		end
		]]--
	end
	
	function stateMachine:findPath(stateFrom, stateTo)
		--print("-- findPath, stateFrom: ", stateFrom, ", stateTo: ", stateTo)
		local states = self.states
		local fromState = states[stateFrom]
		local c = 0
		local d = 0
		local stackOverflowCounter = 0
		while fromState do
			stackOverflowCounter = stackOverflowCounter + 1
			if stackOverflowCounter > 255 then error("Stack Overflow in findPath.") end
			d = 0
			local toState = states[stateTo]
			--print("\ttoState: ", toState, ", name: ", toState.name)
			while toState do
				--print("\t\tc: ", c, ", d: ", d)
				if fromState == toState then
					--print("\t\t\we done, fromState.name: " .. fromState.name .. " is the same as toState.name: " .. toState.name)
					return {c, d}
				end
				d = d + 1
				--print("toState.parent: ", toState.parent)
				toState = toState.parent
				--if toState ~= nil then print("\t\ttoState is now: ", toState.name) end
			end
			c = c + 1
			fromState = fromState.parent
		end
		return {c, d}
	end
	
	function stateMachine:changeStateToAtNextTick(stateTo)
		assert(stateTo ~= nil, "stateTo must be a String and not nil.")
		assert(type(stateTo) == "string", "stateTo is supposed to be a String.")
		self:setStateToChangeTo(stateTo)
		self.changeStateAtTick = true
	end
	
	function stateMachine:setStateToChangeTo(value)
		--print("StateMachine::setStateToChangeTo, value: ", value)
		self.stateToChangeTo = value
	end
	
	function stateMachine:setState(value)
		self.previousState = self.state
		self.state = value
		self:dispatchEvent({name="onStateMachineStateChanged", target=self})
	end
	
	function stateMachine:changeState(stateTo)
		--print("StateMachine::changeState, stateTo: ", stateTo)
		assert(type(stateTo) == "string", "stateTo is supposed to be a String, not: ", stateTo)
		--print("after assert")
		local state = self.state
		local states = self.states
		local toState = states[stateTo]
		if toState == nil then
			print("ERROR: StateMachine::changeState, Cannot make transition: State " .. stateTo .. " is not defined.")
			return false
		end
		--print("before canChange")
		--print("btw, can we change?: ", self:canChangeStateTo(stateTo))
		if self:canChangeStateTo(stateTo) == false then
			print("ERROR: StateMachine::changestate, Transition to " .. stateTo .. " denied.")
			local outEvent = {name = "onTransitionDenied",
								target = self,
								fromState = state,
								toState = stateTo,
								allowedStates = states[stateTo].from}
			self:dispatchEvent(outEvent)
			return false
		end
		--print("before find path")
		local path = self:findPath(state, stateTo)
		--print("after path")
		--print("path, 1: ", path[1], ", 2: ", path[2])
		if path[1] > 0 then
			local exitCallback = {name = "onExitState",
									target = self,
									toState = stateTo,
									fromState = state}
			
			if states[state].exit ~= nil then
				exitCallback.currentState = state
				states[state].exit(exitCallback)
			end
			
			-- TODO: optimize via locals
			self.parentState = states[state]
			
			local p = 1
			local firstPath = path[1]
			local len = firstPath
			--print("len: ", len)
			while p < len do
				self.parentState = self.parentState.parent
				if self.parentState.exit ~= nil then
					exitCallback.currentState = self.parentState.name
					self.parentState.exit(exitCallback)
				end
			end
		end
		
		local oldState = state
		self:setState(stateTo)
		state = stateTo
		--print("path[2]: ", path[2]);
		if path[2] > 0 then
			local enterCallback = {name = "onEnterState",
									target = self,
									toState = stateTo,
									fromState = oldState,
									entity = self.entity}
			--print("root: ", states[stateTo]:getRoot().name)
			if states[stateTo]:getRoot() ~= nil then
				self.parentStates = states[stateTo]:getParents()
				--print("self.parentStates: ", self.parentStates)
				--print("parentStates len: ", table.maxn(self.parentStates))
				local secondPath = path[2]
				local k = secondPath - 1
				----print("len 2: ", (path[2] - 1))
				while k >= 0 do
					local theCurrentParentState = self.parentStates[k]
					----print("k: ", k, ", theCurrentParentState: ", theCurrentParentState)
					if theCurrentParentState and theCurrentParentState.enter then
						enterCallback.currentState = theCurrentParentState.name
						theCurrentParentState.enter(enterCallback)
					end
					k = k - 1
				end
			end
			
			if states[state].enter ~= nil then
				enterCallback.currentState = state
				--print("StateMachine::calling enter callback, event.data: ", enterCallback.data)
				states[state].enter(enterCallback)
			end
		end
		
		--print("StateMachine::changeState, State changed to " .. state)
		
		local outEvent = {name = "onTransitionComplete",
							target = self,
							fromState = oldState,
							toState = stateTo}
		self:dispatchEvent(outEvent)
		return true
	end
	
	function stateMachine:tick(time)
		self.lastTickTime = time
		if self.changeStateAtTick == true then
			self.changeStateAtTick = false
			--print("StateMachine::tick, self.stateToChangeTo: ", self.stateToChangeTo)
			self:changeState(self.stateToChangeTo)
			--self:setStateToChangeTo(nil)
		end
		
		local state = self.state
		if state ~= nil then
			local currentState = self.states[state]
			if currentState.ready == true then
				currentState:tick(time)
			end
		end	
	end
	
	return stateMachine
	
end

return StateMachine