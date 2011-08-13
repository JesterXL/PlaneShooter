require "constants"
require "robotlegs_globals"

EnemySmallShip = {}
function EnemySmallShip:new(startX, startY, bottom)
	print("EnemySmallShip::new, bottom: ", bottom)
	if(EnemySmallShip.soundsInited == false) then
		EnemySmallShip.soundsInited = true
		EnemySmallShip.smallShipDeathSound = audio.loadSound("enemy_death_1.mp3")
	end
	
	local img = display.newImage("enemy_1.png")
	img.classType = "enemies_EnemySmallShip"
	img.name = "Enemy1"
	img.ID = globals.getID()
	img.speed = constants.SMALL_SHIP_SPEED
	img.x = startX
	--img.y = startY
	
	img.bottom = bottom
	img.fireTime = constants.SMALL_SHIP_FIRE_INTERVAL -- milliseconds
	img.fired = false
	
	function img:setY(value)
		assert(value ~= nil, "Setting Y to nil, are we?")
		self.y = value
	end
	
	img:setY(startY)
	
	
	physics.addBody( img, { density = 1.0, friction = 0.3, bounce = 0.2, 
								bodyType = "kinematic", 
								isBullet = true, isSensor = true, isFixedRotation = true,
								filter = { categoryBits = 4, maskBits = 3 }
							} )
	
	function onHit(self, event)
		-- TODO/FIXME: string names? Really? That's great man..........
		if(event.other.name == "Bullet") then
			-- TODO: create enemy death
			--createEnemyDeath(self.x, self.y)
			local smallShipDeathSoundChannel = audio.play(EnemySmallShip.smallShipDeathSound, {loops=0})
			--audio.setVolume(.25, {channel = smallShipDeathSoundChannel})
			print("ship is dead, ID: ", self.ID)
			event.other:destroy()
			self:destroy()
		elseif(event.other.name == "Player") then
			local smallShipDeathSoundChannel = audio.play(EnemySmallShip.smallShipDeathSound, {loops=0})
			--audio.setVolume(.25, {channel = smallShipDeathSoundChannel})
			event.other:onBulletHit()
			self:destroy()
		elseif(event.other.name == "BulletRail") then
			local smallShipDeathSoundChannel = audio.play(EnemySmallShip.smallShipDeathSound, {loops=0})
			--audio.setVolume(.25, {channel = smallShipDeathSoundChannel})
			self:destroy()
		end
	end
	
	function img:destroy()
		self:dispatchEvent({name="enemyDead", target=self})
		self:removeEventListener("collision", img)
		self:removeSelf()
	end
	
	img.collision = onHit
	img:addEventListener("collision", img)
	
	function img:tick(millisecondsPassed)
		if(self.y == nil) then
			error("wtf")
			return
		end
		
		if(self.fired == false) then
			self.fireTime = self.fireTime - millisecondsPassed
			if(self.fireTime <= 0) then
				self.fired = true
				-- TODO: make sure this works
				self:dispatchEvent({name="createEnemyBullet", target=self})
				--createEnemyBullet(self.x, self.y, plane)
			end
		end
		
		if(self.y > bottom) then
			return
		else
			local deltaX = 0
			local deltaY = self.y - bottom
			local dist = math.sqrt((deltaX * deltaX) + (deltaY * deltaY))

			local moveX = self.speed * (deltaX / dist)
			local moveY = self.speed * (deltaY / dist)

			if (self.speed >= dist) then
				--self.y = bottom
				self:setY(bottom)
				self:destroy()
			else
				--self.y = self.y - moveY
				self:setY(self.y - moveY)
			end
		end
			
	end
	
	return img	
end

return EnemySmallShip