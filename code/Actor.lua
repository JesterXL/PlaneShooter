module (..., package.seeall)

require "globals"
require "MessageBus"

function new()
	local actor = {}
	actor.ID = globals.getID()
	
	function actor:dispatch(eventObj)
		MessageBus:dispatch(eventObj)
	end
	
	function actor:addListener(name, handler)
		MessageBus:addListener(name, handler)
	end
	
	function actor:removeListener(name, handler)
		MessageBus:removeListener(name, handler)
	end
	
	
	return actor
end