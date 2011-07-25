module (..., package.seeall)

local function new()
	local context = {}
	context.commands = {}
	
	function context:startup()
		-- abstract
	end
	
	function context:onHandleEvent(event)
		local commandClassName = self.commands[event.name]
		if(commandClassName ~= nil) then
			local command = require(commandClassName).new()
			command:execute(event)
		end
	end
	
	function context:mapCommand(eventName, commandClass)
		self.commands[eventName] = commandClass
		MessageBus:addEventListener(eventName, onHandleEvent)
	end
	
	function context:mapMediator(view)
	
	function context:init()
		self:startup()
	end
	
	context:init()

	return context
end