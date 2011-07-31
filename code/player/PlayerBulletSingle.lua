require "constants"

function new(startX, startY)
	-- TODO: add the max bullets elsewhere
	--[[
	if(bullets + 1 > MAX_BULLET_COUNT) then
		return
	else
		bullets = bullets + 1
	end
	--]]
	
	local img = display.newImage("player_bullet_1.png")
	img.name = "Bullet"
	img.speed = constants.PLAYER_BULLET_SPEED
	img.x = startX
	img.y = startY
	
	physics.addBody( img, { density = 1.0, friction = 0.3, bounce = 0.2, 
								bodyType = "kinematic", 
								isBullet = true, isSensor = true, isFixedRotation = true,
								filter = { categoryBits = 2, maskBits = 4 }
							} )
								
	-- TODO: add this to the game loop
	--addLoop(img)
	
	function img:destroy()
		-- TODO: remove from game loop and ensure bullet count is lowered
		--[[
		bullets = bullets - 1
		removeLoop(self)
		--]]
		self:removeSelf()
	end
	
	function onHit(self, event)
		if(event.other.name == "Bullet") then
			self:destroy()
			event.other:destroy()
		end
	end
	
	img.collision = onHit
	img:addEventListener("collision", img)
	
	function img:tick(millisecondsPassed)
		if(self.y < 0) then
			self:destroy()
			return
		else
			local deltaX = 0
			local deltaY = self.y - 0
			local dist = math.sqrt((deltaX * deltaX) + (deltaY * deltaY))

			local moveX = self.speed * (deltaX / dist)
			local moveY = self.speed * (deltaY / dist)
			
			if (self.speed >= dist) then
				self:destroy()
			else
				self.y = self.y - moveY
			end
		end
	end
	
	return img
end