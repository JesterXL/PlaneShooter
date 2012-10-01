require "com.jessewarden.planeshooter.core.constants"
require "org.robotlegs.globals"

PlayerBulletAngle = {}

function PlayerBulletAngle:new(startX, startY, targetX, targetY)
	assert(startX ~= nil, "Must pass in a startX value")
	assert(startY ~= nil, "Must pass in a startY value")

	local img = display.newImage("player_bullet_1.png")
	img.classType = "PlayerBulletAngle"
	img.name = "Bullet"
	img.speed = constants.PLAYER_BULLET_SPEED
	--img.id = globals:getID()
	img.x = startX
	img.y = startY
	img.targetX = targetX
	img.targetY = targetY
	img.rot = math.atan2(img.y -  img.targetY,  img.x - img.targetX) / math.pi * 180 -90;
	img.angle = (img.rot -90) * math.pi / 180;
	
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
	end
	
	function img:tick(millisecondsPassed)
		self.x = self.x + math.cos(self.angle) * self.speed * millisecondsPassed
	   	self.y = self.y + math.sin(self.angle) * self.speed * millisecondsPassed

	   	--if self.x < stage.x or self.y < stage.y or stage.x > stage.width or stage.y + stage.height then
		--	self:destroy()
		--end
	end
	
	img:init()
	
	return img
end

return PlayerBulletAngle