require "com.jessewarden.planeshooter.core.constants"
require "sprite"

PlayerRailGun = {}

function PlayerRailGun:new(startX, startY)
	assert(startX ~= nil, "Must pass in a startX value")
	assert(startY ~= nil, "Must pass in a startY value")
	-- TODO: add the max bullets elsewhere
	--[[
	if(bullets + 1 > MAX_BULLET_COUNT) then
		return
	else
		bullets = bullets + 1
	end
	--]]
	
	if(PlayerRailGun.spriteSheet == nil) then
		local spriteSheet = sprite.newSpriteSheet("player_rail_gun_anime_1_sheet.png", 300, 700)
		local spriteSet = sprite.newSpriteSet(spriteSheet, 1, 7)
		sprite.add(spriteSet, "railGun1", 1, 7, 400, 1)
		PlayerRailGun.spriteSheet = spriteSheet
		PlayerRailGun.spriteSet = spriteSet
		PlayerRailGun.fireSound = audio.loadSound("player_railgun.wav")
	end
	
	local img = sprite.newSprite(PlayerRailGun.spriteSet)
	img.classType = "PlayerRailGun"
	img:setReferencePoint(display.BottomCenterReferencePoint)
	img:prepare("railGun1")
	img:play()
	img.name = "BulletRail"
	img.x = startX - 12
	img.y = startY
	
	
	function img:sprite(event)
		--print("event.phase: ", event.phase)
		if(event.phase == "end") then
			img:destroyInABit()
		end
	end

	function img:destroyInABit()
		if img.timerHandle ~= nil then
			timer.cancel(img.timerHandle)
		end
		img.timerHandle = timer.performWithDelay(100, img)
	end

	function img:timer(event)
		self:destroy()
	end

	
	
	function img:destroy()
		-- TODO: remove from game loop and ensure bullet count is lowered
		--[[
		bullets = bullets - 1
		removeLoop(self)
		--]]
		--audio.stop(PlayerRailGun.fireSoundChannel)
		--audio.rewind(PlayerRailGun.fireSoundChannel)
		--self:removeEventListener("sprite", onSpriteAnimation)

		if img.timerHandle ~= nil then
			timer.cancel(img.timerHandle)
		end
		self:dispatchEvent({name="animeFinished", target=self})
		--self:dispatchEvent({name="removeFromGameLoop", target=self})
		--self:removeEventListener("collision", img)
		self:removeSelf()
	end
	
	--[[
	function onHit(self, event)
		if(event.other.name == "Bullet") then
			self:destroy()
			event.other:destroy()
		end
	end
	
	img.collision = onHit
	img:addEventListener("collision", img)
	
	--]]
	
	

	
	function onReady()
		timer.cancel(img.timerHandle)
		img:destroy()
	end


	function img:init()
		img:addEventListener("sprite", img)
		
		physics.addBody( img, { density = 1.0, friction = 0.3, bounce = 0.2, 
									bodyType = "kinematic", 
									isBullet = true, isSensor = true, isFixedRotation = true,
									shape={ 0,0, 26,0, 26,700, 0,700 },
									filter = { categoryBits = 2, maskBits = 4 }
								} )
		--audio.play(PlayerRailGun.fireSound)
	end
	
	--img.timerHandle = timer.performWithDelay(1000, onReady)

	img:init()
	
	return img
end

return PlayerRailGun