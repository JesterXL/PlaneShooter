
PlayerDeath = {}

function PlayerDeath:new(targetX, targetY)
	
	if(playerDeath.playerDeathSheet == nil) then
		playerDeath.playerDeathSheet = sprite.newSpriteSheet("player_death_sheet.png", 18, 18)
		playerDeath.playerDeathSet = sprite.newSpriteSet(playerDeath.playerDeathSet, 1, 10)
		sprite.add(playerDeath.playerDeathSet, "playerDeathSheet", 1, 10, 2000, 1)
	end
	
	local si = sprite.newSprite(playerDeathSet)
	si.name = "playerDeathSetYo"
	si:prepare()
	function onEnd(event)
		if(event.phase == "loop") then
			self:removeEventListener("sprite", self.onEnd)
			event.sprite:removeSelf()
		end
	end
	si:addEventListener("sprite", onEnd)
	si:play()
	si.x = targetX
	si.y = targetY
	
	return si
end

return PlayerDeath