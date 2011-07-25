module (..., package.seeall)

local function new()
	local img = display.newImage("plane.png")
	img.speed = PLAYER_MOVE_SPEED -- pixels per second
	img.name = "Player"
	img.maxHitPoints = 3
	img.hitPoints = 3
	
	physics.addBody( img, { density = 1.0, friction = 0.3, bounce = 0.2, 
								bodyType = "kinematic", 
								isBullet = true, isSensor = true, isFixedRotation = true,
								filter = { categoryBits = 1, maskBits = 28 }
							} )
								
	function img:setHitPoints(value)
		self.hitPoints = value
		self:dispatchEvent({target=self, name="hitPointsChanged"})
	end
	
	function img:move(x, y)
		self.x = x
		self.y = y
	end
	
	function img:onBulletHit(event)
		self.hitPoints = self.hitPoints - 1
		------setHealth(self.hitPoints / self.maxHitPoints)
		if(self.hitPoints <= 0) then
			self.isVisible = false
			audio.play(playerDeathSound, {loops=0})
			------createPlayerDeath(self.x, self.y)
			------stopPlayerInteraction()
			------endGame()
			self:dispatchEvent({target=self, name="playerDead"})
		else
			audio.play(playerHitSound, {loops=0})
		end
	end
	
	function img:tick(millisecondsPassed)
		if(self.x == planeXTarget) then
			return
		else
			local deltaX = self.x - planeXTarget
			local deltaY = self.y - planeYTarget
			local dist = math.sqrt((deltaX * deltaX) + (deltaY * deltaY))

			local moveX = self.speed * (deltaX / dist)
			local moveY = self.speed * (deltaY / dist)

			if (self.speed >= dist) then
				self.x = planeXTarget
				self.y = planeYTarget
			else
				self.x = self.x - moveX
				self.y = self.y - moveY
			end
		end	
	end
	
	return img
end