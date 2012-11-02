require "com.jessewarden.planeshooter.core.constants"
require "physics"

PlayerMissileHeatSeeking = {}

function PlayerMissileHeatSeeking:new(startX, startY, targetX, targetY)

	if(PlayerMissileHeatSeeking.missileSound == nil) then
		local missleSheet = sprite.newSpriteSheet("missile_heat_seeking_sheet.png", 3, 12)
		local missleSet = sprite.newSpriteSet(missleSheet, 1, 4)
		sprite.add(missleSet, "missile", 1, 4, 400, 0)
		PlayerMissileHeatSeeking.missleSheet = missleSheet
		PlayerMissileHeatSeeking.missleSet = missleSet
	end

	local img = sprite.newSprite(PlayerMissileHeatSeeking.missleSet)
	img.classType = "PlayerMissileHeatSeeking"
	img.name = "Bullet"
  	img:prepare("missile")
  	img:play()
	img.speed = constants.PLAYER_MISSILE_HEAT_SEEKING_SPEED
	img.x = startX
	img.y = startY
	img.targetX = targetX
	img.targetY = targetY
	img.currentLife = 0
	img.lifeTime = 10 * 1000 -- milliseconds

	function onHit(self, event)
		if(event.other == self.player) then
			event.other:onMissileHit()
			self:destroy()
		end
	end



	function img:destroy()
		gameLoop:removeLoop(self)
		self:removeEventListener("collision", img)
		self:dispatchEvent({name="removeFromGameLoop", target=self})
		self:removeSelf()
	end

	function img:init()
		img.collision = onHit
		img:addEventListener("collision", img)
		--[[
		physics.addBody( img, { density = 1.0, friction = 0.3, bounce = 0.2,
									bodyType = "kinematic",
									isBullet = true, isSensor = true, isFixedRotation = true,
									filter = { categoryBits = 4, maskBits = 3 }
								} )
		]]--
		--audio.play(PlayerMissileHeatSeeking.missileSound)
		gameLoop:addLoop(self)
	end

	function img:getRotation()
		--local targetX, targetY = self:localToContent(self.x, self.y)
		local rot = math.atan2(self.targetY - self.y, self.targetX - self.x) / math.pi * 180 - 90
		return rot
	end

	function img:tick(millisecondsPassed)
	-- TODO: make sure using milliseconds vs. hardcoding step speed
		self.currentLife = self.currentLife + millisecondsPassed
		if(self.currentLife >= self.lifeTime) then
			self:destroy()
			return true
		end

		self.rotation = self:getRotation()
		--self.x = self.x + math.cos(self.angle) * self.speed
	   	--self.y = self.y + math.sin(self.angle) * self.speed

		local deltaX = self.x - self.targetX
		local deltaY = self.y - self.targetY
		local dist = math.sqrt((deltaX * deltaX) + (deltaY * deltaY))

		local moveX = self.speed * (deltaX / dist) * millisecondsPassed
		local moveY = self.speed * (deltaY / dist) * millisecondsPassed

		if (math.abs(moveX) > dist or math.abs(moveY) > dist) then
			self.x = self.targetX
			self.y = self.targetY
		else
			self.x = self.x - moveX
			self.y = self.y - moveY
		end
	end

	
	img:init()
	
	return img
end

return PlayerMissileHeatSeeking