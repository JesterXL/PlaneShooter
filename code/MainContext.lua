module (..., package.seeall)

local function new()
	local context = require("Context").new()
	context.superStartup = context.startup
	
	function context:startup()
		
		
		
		self:superStartup()
	end

	return context
end