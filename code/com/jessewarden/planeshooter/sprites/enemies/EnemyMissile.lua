require "com.jessewarden.planeshooter.core.constants"
require "physics"

EnemyMissile = {}

function EnemyMissile:new(startX, startY, player)

	if(EnemyMissile.missileSound == nil) then
		EnemyMissile.missileSound = audio.loadSound("enemy_missle_jet_missle.mp3")
		local missleSheet = sprite.newSpriteSheet("enemy_missle_jet_missle_sheet.png", 6, 15)
		local missleSet = sprite.newSpriteSet(missleSheet, 1, 3)
		sprite.add(missleSet, "missleFlare", 1, 3, 100, 0)
		EnemyMissile.missleSheet = missleSheet
		EnemyMissile.missleSet = missleSet
	end

	local img = sprite.newSprite(EnemyMissile.missleSet)
	img.classType = "EnemyMissile"
	img.name = "Bullet"
  	img:prepare("missleFlare")
  	img:play()
	img.speed = constants.ENEMY_MISSLE_JET_MISSLE_SPEED
	img.x = startX
	img.y = startY
	img.player = player
	img.currentLife = 0
	img.lifeTime = 3000 -- milliseconds

--[[
	physics.addBody( img, { density = 1.0, friction = 0.3, bounce = 0.2,
								bodyType = "kinematic",
								isBullet = true, isSensor = true, isFixedRotation = true,
								filter = { categoryBits = 4, maskBits = 3 }
							} )
]]--

	function onHit(self, event)
		if(event.other == self.player) then
			event.other:onMissileHit()
			self:destroy()
		end
	end

	img.collision = onHit
	img:addEventListener("collision", img)

	function img:destroy()
		self:removeEventListener("collision", img)
		self:dispatchEvent({name="removeFromGameLoop", target=self})
		self:removeSelf()
		self.tick = function()end
	end

	function img:getRotation()
		--local targetX, targetY = self:localToContent(self.x, self.y)
		local targetX = self.x
		local targetY = self.y
		local rot = math.atan2(img.player.y - targetY, img.player.x - targetX) / math.pi * 180 - 90
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

		local deltaX = self.x - self.player.x
		local deltaY = self.y - self.player.y
		local dist = math.sqrt((deltaX * deltaX) + (deltaY * deltaY))

		local moveX = self.speed * (deltaX / dist) * millisecondsPassed
		local moveY = self.speed * (deltaY / dist) * millisecondsPassed

		if (math.abs(moveX) > dist or math.abs(moveY) > dist) then
			self.x = self.player.x
			self.y = self.player.y
		else
			self.x = self.x - moveX
			self.y = self.y - moveY
		end
	end

	--audio.play(EnemyMissile.missileSound)
	
	return img
end

return EnemyMissile