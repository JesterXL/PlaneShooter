require "sprite"

EnemySmallShipDeath = {}

function EnemySmallShipDeath:new(targetX, targetY)
	
	if(EnemySmallShipDeath.smallShipDeathSheet == nil) then
		EnemySmallShipDeath.smallShipDeathSheet = sprite.newSpriteSheet("enemy_death_sheet_1.png", 24, 24)
		EnemySmallShipDeath.smallShipDeathSet = sprite.newSpriteSet(EnemySmallShipDeath.smallShipDeathSheet, 1, 5)
		sprite.add(EnemySmallShipDeath.smallShipDeathSet, "smallShipDeath", 1, 5, 300, 1)
	end
	
	local si = sprite.newSprite(EnemySmallShipDeath.smallShipDeathSet)
	si.name = "smallShipDeath"
	si.classType = "enemies_SmallShipDeath"
	si:prepare("smallShipDeath")
	
	function onEnd(event)
		if(event.phase == "end") then
			event.target:destroy()
			return true
		end
	end
	
	function si:destroy()
		self:removeEventListener("sprite", onEnd)
		self:removeSelf()
	end
	
	si:addEventListener("sprite", onEnd)
	si:play()
	si.x = targetX
	si.y = targetY
	return si
end

return EnemySmallShipDeath