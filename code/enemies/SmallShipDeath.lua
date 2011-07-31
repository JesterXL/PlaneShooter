smallShipDeath = {}
function new(targetX, targetY)
	
	if(smallShipDeath.smallShipDeathSheet == nil) then
		smallShipDeath.smallShipDeathSheet = sprite.newSpriteSheet("enemy_death_sheet_1.png", 24, 24)
		smallShipDeath.smallShipDeathSet = sprite.newSpriteSet(smallShipDeath.smallShipDeathSet, 1, 4)
		sprite.add(smallShipDeath.smallShipDeathSet, "smallShipDeath", 1, 5, 1000, 1)
	end
	
	local si = sprite.newSprite(smallShipDeath.smallShipDeathSet)
	si.name = "smallShipDeath"
	si.classType = "SmallShipDeath"
	si:prepare("smallShipDeath")
	
	function onEnd(event)
		if(event.phase == "loop") then
			self:removeEventListener("sprite", self.onEnd)
			event.sprite:removeSelf()
			return true
		end
	end
	
	si:addEventListener("sprite", onEnd)
	si:play()
	si.x = targetX
	si.y = targetY
	return si
end