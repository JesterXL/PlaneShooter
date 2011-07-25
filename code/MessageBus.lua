module (..., package.seeall)

local function new()
	if(MessageBus is nil) then
		MessageBus = {}
	end
	
	return MessageBus
	
end