require "constants"

EnemyBulletSingle = {}

function EnemyBulletSingle:new(startX, startY, targetPoint)
	local img = display.newImage("bullet.png")
	img.name = "Bullet"
	img.speed = constants.ENEMY_1_BULLET_SPEED
	img.x = startX
	img.y = startY
	img.targetX = targetPoint.x
	img.targetY = targetPoint.y
	-- TODO: use math.deg vs. manual conversion
	img.rot = math.atan2(img.y -  img.targetY,  img.x - img.targetX) / math.pi * 180 -90;
	img.angle = (img.rot -90) * math.pi / 180;
	
	physics.addBody( img, { density = 1.0, friction = 0.3, bounce = 0.2, 
								bodyType = "kinematic", 
								isBullet = true, isSensor = true, isFixedRotation = true,
								filter = { categoryBits = 8, maskBits = 1 }
							} )
								
	
	function onHit(self, event)
		if(event.other.name == "Player") then
			-- TODO: watch this; not sure which instance it's talking too
			event.other:onBulletHit()
			self:destroy()
		end
	end

	img.collision = onHit
	img:addEventListener("collision", img)
	
	function img:destroy()
		self:dispatchEvent({name="removeFromGameLoop", target=self})
		self:removeSelf()
	end
	
	function img:tick(millisecondsPassed)
		
		-- TODO: make sure using milliseconds vs. hardcoding step speed
		
		--print("angle: ", self.angle, ", math.cos(self.angle): ", math.cos(self.angle))
		self.x = self.x + math.cos(self.angle) * self.speed * millisecondsPassed
	   	self.y = self.y + math.sin(self.angle) * self.speed * millisecondsPassed
		
		--[[
		local deltaX = self.x + math.cos(self.angle)
		local deltaY = self.y + math.sin(self.angle)
		local dist = math.sqrt((deltaX * deltaX) + (deltaY * deltaY))

		local moveX = self.speed * (deltaX / dist)
		local moveY = self.speed * (deltaY / dist)
		
		if (self.speed >= dist) then
			self:destroy()
		else
			self.x = self.x + moveX
			self.y = self.y + moveY
		end
		]]--
	end
	
	return img
end

return EnemyBulletSingle