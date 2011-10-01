require "com.jessewarden.planeshooter.core.constants"

PlayerBulletSpread = {}

function PlayerBulletSpread:new(startX, startY)

	local centerImage = display.newImage("player_bullet_2.png")
	local leftImage = display.newImage("player_bullet_1.png")
	local rightImage = display.newImage("player_bullet_1.png")
	centerImage.name = "Bullet"
	leftImage.name = "Bullet"
	rightImage.name = "Bullet"
	centerImage.speed = constants.PLAYER_BULLET_SPEED
	leftImage.speed = constants.PLAYER_BULLET_SPEED
	rightImage.speed = constants.PLAYER_BULLET_SPEED
	leftImage.x = startX
	leftImage.y = startY
	rightImage.x = startX
	rightImage.y = startY
	centerImage.x = startX
	centerImage.y = startY
	leftImage.rotation = -45
	rightImage.rotation = 45
	
	physics.addBody( centerImage, { density = 1.0, friction = 0.3, bounce = 0.2, 
								bodyType = "kinematic", 
								isBullet = true, isSensor = true, isFixedRotation = true,
								filter = { categoryBits = 2, maskBits = 4 }
							} )
	physics.addBody( leftImage, { density = 1.0, friction = 0.3, bounce = 0.2, 
								bodyType = "kinematic", 
								isBullet = true, isSensor = true, isFixedRotation = true,
								filter = { categoryBits = 2, maskBits = 4 }
							} )						
	
	physics.addBody( rightImage, { density = 1.0, friction = 0.3, bounce = 0.2, 
								bodyType = "kinematic", 
								isBullet = true, isSensor = true, isFixedRotation = true,
								filter = { categoryBits = 2, maskBits = 4 }
							} )						
								

	function leftImage:destroy()
		self:dispatchEvent({name="removeFromGameLoop", target=self})
		self:removeSelf()
	end
	
	function rightImage:destroy()
		self:dispatchEvent({name="removeFromGameLoop", target=self})
		self:removeSelf()
	end
	
	function centerImage:destroy()
		self:dispatchEvent({name="removeFromGameLoop", target=self})
		self:removeSelf()
	end
	
	function onHit(self, event)
		if(event.other.name == "Bullet") then
			self:destroy()
			event.other:destroy()
		end
	end
	
	leftImage.collision = onHit
	leftImage:addEventListener("collision", leftImage)
	
	rightImage.collision = onHit
	rightImage:addEventListener("collision", rightImage)
	
	centerImage.collision = onHit
	centerImage:addEventListener("collision", centerImage)
	
	function centerImage:tick(millisecondsPassed)
		if(self.y < 0) then
			self:destroy()
			return
		else
			local deltaX = 0
			local deltaY = self.y - 0
			local dist = math.sqrt((deltaX * deltaX) + (deltaY * deltaY))

			local moveX = self.speed * (deltaX / dist) * millisecondsPassed
			local moveY = self.speed * (deltaY / dist) * millisecondsPassed
			
			if (math.abs(moveX) > dist or math.abs(moveY) > dist) then
				self:destroy()
			else
				self.y = self.y - moveY
			end
		end
	end
	
	leftImage.rot = math.atan2(leftImage.y -  -800,  leftImage.x - -800) / math.pi * 180 -90;
	leftImage.angle = (leftImage.rot -90) * math.pi / 180;
	
	rightImage.rot = math.atan2(rightImage.y -  -800,  rightImage.x - 800) / math.pi * 180 -90;
	rightImage.angle = (rightImage.rot -90) * math.pi / 180;
	
	function leftImage:tick(millisecondsPassed)
		self.x = self.x + math.cos(self.angle) * self.speed * millisecondsPassed
	   	self.y = self.y + math.sin(self.angle) * self.speed * millisecondsPassed
	end
	
	function rightImage:tick(millisecondsPassed)
		self.x = self.x + math.cos(self.angle) * self.speed * millisecondsPassed
	   	self.y = self.y + math.sin(self.angle) * self.speed * millisecondsPassed
	end
	
	return centerImage, leftImage, rightImage
end

return PlayerBulletSpread