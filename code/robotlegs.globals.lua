globals = {}
globals.ID = 1
globals.counter = 2

function globals:getID()
	globals.counter = globals.counter + 1
	return globals.counter
end

return globals