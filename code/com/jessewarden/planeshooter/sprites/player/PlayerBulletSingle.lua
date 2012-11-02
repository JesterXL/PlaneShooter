require "com.jessewarden.planeshooter.core.constants"
require "org.robotlegs.globals"

PlayerBulletSingle = {}

function PlayerBulletSingle:new(startX, startY)
	assert(startX ~= nil, "Must pass in a startX value")
	assert(startY ~= nil, "Must pass in a startY value")

	local img = display.newImage("player_bullet_1.png")
	img.classType = "PlayerBulletAngle"
	img.name = "Bullet"
	img.speed = constants.PLAYER_BULLET_SPEED
	--img.id = globals:getID()
	img.x = startX
	img.y = startY
	
	function img:destroy()
		gameLoop:removeLoop(self)
		self:removeEventListener("collision", img)
		self:removeSelf()
	end
	
	function img:collision(event)
		if(event.other.name == "Bullet") then
			self:destroy()
			event.other:destroy()
			return true
		end
	end
	
	
	
	function img:init()
		img:addEventListener("collision", img)
		
		physics.addBody( img, { density = 1.0, friction = 0.3, bounce = 0.2, 
									bodyType = "kinematic", 
									isBullet = true, isSensor = true, isFixedRotation = true,
									filter = { categoryBits = 2, maskBits = 4 }
								} )
		gameLoop:addLoop(self)
	end
	
	function img:tick(millisecondsPassed)
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

			--if self.x < stage.x or self.y < stage.y or stage.x > stage.width or stage.y + stage.height then
			--	self:destroy()
			--end
		end
	end
	
	img:init()
	
	return img
end

return PlayerBulletSingle