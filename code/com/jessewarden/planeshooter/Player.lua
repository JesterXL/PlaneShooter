Player = {}

function Player:new()
	local cow = display.newGroup()
	cow.classType = "NormalPlayer"
	
	return cow
end

return Player