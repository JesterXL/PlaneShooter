module (..., package.seeall)

local function new()
	local actor = {}
	--local bus = require("MessageBus").new()
	
	function actor:dispatch(eventObj)
		MessageBus:dispatchEvent(eventObj)
	end
	
	function actor:addListener(name, handler)
		MessageBus:addEventListener(name, handler)
	end
	
	function actor:removeListener(name, handler)
		MessageBus:removeEventListener(name, handler)
	end
	
	return actor
end