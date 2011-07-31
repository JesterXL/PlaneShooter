module (..., package.seeall)

require "robotlegs/globals"
require "robotlegs/MessageBus"

function new(viewInstance)
	assert(viewInstance ~= nil, "A Mediator class requires a viewInstance.")
	local mediator = require("robotlegs/Actor").new()
	mediator.ID = globals.getID()
	mediator.viewInstance = viewInstance
	
	function mediator:onRegister()
	end
	
	function mediator:onRemove()
	end
	
	function mediator:destroy()
		self.viewInstance = nil
	end
	
	return mediator
end