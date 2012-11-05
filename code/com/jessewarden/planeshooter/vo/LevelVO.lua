LevelVO = {}

function LevelVO:new()
	local level = {}

	level.events = {} -- MovieVO or EnemyVO's
	level.totalTime = 0
	level.classType = "LevelVO"

	return level
end

return LevelVO