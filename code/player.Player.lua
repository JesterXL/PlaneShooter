

require "constants"

Player = {}

function Player:new()
	
	if(Player.spriteSheet == nil) then
		local spriteSheet = sprite.newSpriteSheet("player/player.png", 22, 17)
		local spriteSet = sprite.newSpriteSet(spriteSheet, 1, 2)
		sprite.add(spriteSet, "planeFly", 1, 2, 50, 0)
		Player.spriteSheet = spriteSheet
		Player.spriteSet = spriteSet
	end
	
	local img = sprite.newSprite(Player.spriteSet)
	img:prepare("planeFly")
	img:play()
	img.classType = "player.Player"
	img.speed = constants.PLAYER_MOVE_SPEED -- pixels per second
	img.name = "Player"
	img.maxHitPoints = 3
	img.hitPoints = 3
	img.planeXTarget = 0
	img.planeYTarget = 0
	img.playerHitSound = audio.loadSound("player_hit_sound.mp3")
	img.playerDeathSound = audio.loadSound("player_death_sound.mp3")
	

	physics.addBody( img, { density = 1.0, friction = 0.3, bounce = 0.2, 
								bodyType = "kinematic", 
								isBullet = true, isSensor = true, isFixedRotation = true,
								filter = { categoryBits = 1, maskBits = 28 }
							} )

								
	
	function img:move(x, y)
		self.x = x
		self.y = y
	end
	
	function img:onBulletHit(event)
		-- TODO
		------setHealth(self.hitPoints / self.maxHitPoints)
	--	self:setHitPoints(self.hitPoints - 1)
		self:dispatchEvent({name="bulletHit", target=self})
		if(self.hitPoints <= 0) then
			self.isVisible = false
			audio.play(self.playerDeathSound, {loops=0})
			------createPlayerDeath(self.x, self.y)
			------stopPlayerInteraction()
			------endGame()
			self:dispatchEvent({target=self, name="playerDead"})
		else
			audio.play(self.playerHitSound, {loops=0})
		end
	end
	
	function img:tick(millisecondsPassed)
		if(self.x == self.planeXTarget and self.y == self.planeYTarget) then
			return
		else
			local deltaX = self.x - self.planeXTarget
			local deltaY = self.y - self.planeYTarget
			local dist = math.sqrt((deltaX * deltaX) + (deltaY * deltaY))

			local moveX = self.speed * (deltaX / dist)
			local moveY = self.speed * (deltaY / dist)

			if (self.speed >= dist) then
				self.x = self.planeXTarget
				self.y = self.planeYTarget
			else
				self.x = self.x - moveX
				self.y = self.y - moveY
			end
		end	
	end
	
	return img
end

return Player