require "com.jessewarden.planeshooter.core.constants"

PlayerMissileHVAR = {}

function PlayerMissileHVAR:new(startX, startY, targetX, targetY)
	assert(startX ~= nil, "Must pass in a startX value")
	assert(startY ~= nil, "Must pass in a startY value")

	if(PlayerMissileHVAR.spriteSheet == nil) then
		local spriteSheet = sprite.newSpriteSheet("missile_hvar_sheet.png", 5, 15)
		local spriteSet = sprite.newSpriteSet(spriteSheet, 1, 3)
		sprite.add(spriteSet, "missile", 1, 3, 300, 0)
		PlayerMissileHVAR.spriteSheet = spriteSheet
		PlayerMissileHVAR.spriteSet = spriteSet
	end

	local img = sprite.newSprite(PlayerMissileHVAR.spriteSet)
	--img:setReferencePoint(display.BottomCenterReferencePoint)
	img.classType = "PlayerMissileHVAR"
	img.name = "Bullet"
	img:prepare("missile")
	img:play()
	-- TODO: change to cannon speed
	img.speed = constants.PLAYER_MISSILE_HVAR_SPEED
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
		gameLoop:addLoop(self)
	end
	
	function img:tick(millisecondsPassed)
		self.rotation = math.atan2(targetY - self.y, targetX - self.x) / math.pi * 180 - 90
		self.x = self.x + math.cos(self.angle) * self.speed * millisecondsPassed
	   	self.y = self.y + math.sin(self.angle) * self.speed * millisecondsPassed
	end
	
	img:init()
	
	return img
end

return PlayerMissileHVAR