require "com.jessewarden.planeshooter.core.constants"
require "com.jessewarden.planeshooter.controllers.PlayerMovementController"
require "com.jessewarden.planeshooter.controllers.PlayerWeaponsController"
require "com.jessewarden.planeshooter.sounds.SoundManager"

Player = {}

function Player:new()
	if(Player.spriteSheet == nil) then
		local spriteSheet = sprite.newSpriteSheet("player.png", 22, 17)
		local spriteSet = sprite.newSpriteSet(spriteSheet, 1, 2)
		sprite.add(spriteSet, "planeFly", 1, 2, 50, 0)
		Player.spriteSheet = spriteSheet
		Player.spriteSet = spriteSet
	end
	
	local img = sprite.newSprite(Player.spriteSet)
	img.classType = "Player"
	img:prepare("planeFly")
	img:play()
	img.speed = constants.PLAYER_MOVE_SPEED -- pixels per second
	img.name = "Player"
	img.maxHitPoints = 3
	img.hitPoints = 3
	img.reachedDestination = true
	img.planeXTarget = 200
	img.planeYTarget = 200
	--img.playerHitSound = audio.loadSound("player_hit_sound.mp3")
	--img.playerDeathSound = audio.loadSound("player_death_sound.mp3")

	img.movementController = nil
	img.weaponsController = nil
	
	function img:init()
		self.movementController = PlayerMovementController:new(self)
		self.movementController:start()

		self.weaponsController = PlayerWeaponsController:new(self)
		self.weaponsController:start()
		self.weaponsController:setPowerLevel(1)

		physics.addBody( img, { density = 1.0, friction = 0.3, bounce = 0.2, 
									bodyType = "kinematic", 
									isBullet = true, isSensor = true, isFixedRotation = true,
									filter = { categoryBits = 1, maskBits = 28 }
								} )

		gameLoop:addLoop(self)
	end

	function img:destroy()

	end

						
	function img:move(x, y)
		self.x = x
		self.y = y
		playerView.x = x
		playerView.y = y
	end
	function img:setDestination(x, y)
		self.planeXTarget = x
		self.planeYTarget = y
		self.reachedDestination = false
	end
	
	function img:onBulletHit(event)
		-- TODO
		------setHealth(self.hitPoints / self.maxHitPoints)
	--	self:setHitPoints(self.hitPoints - 1)
		self:dispatchEvent({name="bulletHit", target=self})
		if(self.hitPoints <= 0) then
			self.isVisible = false
			--audio.play(self.playerDeathSound, {loops=0})
			SoundManager.inst:playPlayerDeathSound()
			------createPlayerDeath(self.x, self.y)
			------stopPlayerInteraction()
			------endGame()
			self:dispatchEvent({target=self, name="playerDead"})
		else
			--audio.play(self.playerHitSound, {loops=0})
			SoundManager.inst:playPlayerHitSound()
		end
	end

	function img:onMissileHit(event)
		self:dispatchEvent({name="missileHit", target=self})
		if(self.hitPoints <= 0) then
			self.isVisible = false
			--audio.play(self.playerDeathSound, {loops=0})
			SoundManager.inst:playPlayerDeathSound()
			self:dispatchEvent({target=self, name="playerDead"})
		else
			--audio.play(self.playerHitSound, {loops=0})
			SoundManager.inst:playPlayerHitSound()
			AchievementsProxy:unlock(constants.achievements.zeeMissile)
		end
	end
	
	function img:tick(millisecondsPassed)
		if self.reachedDestination == true then return true end
		
		if(self.x == self.planeXTarget and self.y == self.planeYTarget) then
			return
		else
			local deltaX = self.x - self.planeXTarget
			local deltaY = self.y - self.planeYTarget
			local dist = math.sqrt((deltaX * deltaX) + (deltaY * deltaY))
			local moveX = self.speed * (deltaX / dist) * millisecondsPassed
			local moveY = self.speed * (deltaY / dist) * millisecondsPassed
				
			if (math.abs(moveX) > dist or math.abs(moveY) > dist) then
				self:move(self.planeXTarget, self.planeYTarget)
				self.reachedDestination = true
			else
				self:move(self.x - moveX, self.y - moveY)
			end
		end	
	end
	
	img:init()

	return img
end

return Player