EnemyVO = {}

function EnemyVO:new()
	local enemy = {}
	
    enemy.when = 0
    enemy.pause = false
    enemy.classType = "enemy"
    enemy.type = "Plane"
    enemy.configurations = {}

    -- Transient, set via LevelModel
    enemy.unpauseCallback = nil

	return enemy
end

return EnemyVO 