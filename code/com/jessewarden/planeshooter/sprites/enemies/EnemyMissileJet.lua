require "com.jessewarden.planeshooter.core.constants"
require "org.robotlegs.globals"

EnemyMissileJet = {}

function EnemyMissileJet:new(startX, startY, bottom)

	if(EnemyMissileJet.jetSheet == nil) then
		EnemyMissileJet.jetSound = audio.loadSound("enemy_missle_jet.mp3")
	  	local jetSheet = sprite.newSpriteSheet("enemy_missle_jet_sheet.png", 25, 32)
		local jetSet = sprite.newSpriteSet(jetSheet, 1, 2)
		sprite.add(jetSet, "jetFly", 1, 2, 100, 0)
		EnemyMissileJet.jetSheet = jetSheet
		EnemyMissileJet.jetSet = jetSet
	end

	local img = sprite.newSprite(EnemyMissileJet.jetSet)
	img.classType = "enemies_EnemyMissileJet"
	img.name = "EnemyMissileJet"
	img:prepare("jetFly")
	img:play()
	--img.ID = globals.getID()
	img.speed = constants.ENEMY_MISSLE_JET_SPEED
	img.x = startX
	img.y = startY
	img.bottom = bottom
	img.fireTime = constants.ENEMY_MISSLE_JET_FIRE_INTERVAL -- milliseconds
	img.fired = false

--[[
	physics.addBody( img, { density = 1.0, friction = 0.3, bounce = 0.2,
								bodyType = "kinematic",
								isBullet = true, isSensor = true, isFixedRotation = true,
								filter = { categoryBits = 4, maskBits = 3 }
							} )
]]--
	function onHit(self, event)
		-- TODO/FIXME: string names? Really? That's great man..........
	  -- TODO/FIXME: seriously man, you need to re-factor this out or into a base class or
	  -- some non-Robotlegs Mediator pattern... maybe even think about more solutions with more sleep and less alcohol.
	  local dead = false
	  if(event.other.name == "Bullet") then
		  dead = true
		event.other:destroy()
	  elseif(event.other.name == "Player") then
		dead = true
		  event.other:onBulletHit()
	  elseif(event.other.name == "BulletRail") then
		  dead = true
	  end

	  if(dead == true) then
		self:destroy()
		end
	end

	function img:destroy()
		self:dispatchEvent({name="enemyDead", target=self})
		self:removeEventListener("collision", img)
		self:removeSelf()
		self.tick = function()end
	end

	img.collision = onHit
	img:addEventListener("collision", img)

	function img:tick(millisecondsPassed)

		if(self.fired == false) then
			self.fireTime = self.fireTime - millisecondsPassed
			if(self.fireTime <= 0) then
				self.fired = true
				self:dispatchEvent({name="fireZeeMissile", target=self})
			end
		end

		local deltaX = 0
		local deltaY = self.y - bottom
		local dist = math.sqrt((deltaX * deltaX) + (deltaY * deltaY))

		local moveX = self.speed * (deltaX / dist) * millisecondsPassed
		local moveY = self.speed * (deltaY / dist) * millisecondsPassed

		if (math.abs(moveX) > dist or math.abs(moveY) > dist) then
			self.y = self.bottom
			self:destroy()
		else
			self.y = self.y - moveY
		end

	end
	
	--audio.play(EnemyMissileJet.jetSound)

	return img
end

return EnemyMissileJet