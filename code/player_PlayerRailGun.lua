require "constants"
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
		BossBigPlane.spriteSheet = spriteSheet
		BossBigPlane.spriteSet = spriteSet
		BossBigPlane.fireSound = audio.loadSound("player_railgun.wav")
	end
	
	local img = sprite.newSprite(BossBigPlane.spriteSet)
	img:setReferencePoint(display.BottomCenterReferencePoint)
	img:prepare("railGun1")
	img:play()
	img.name = "BulletRail"
	img.x = startX - 12
	img.y = startY
	--[[
	
	function onSpriteAnimation(event)
		--print("event.phase: ", event.phase)
		if(event.phase == "loop") then
			img:destroy()
		end
	end
	
	img:addEventListener("sprite", onSpriteAnimation)
	--]]
	
	physics.addBody( img, { density = 1.0, friction = 0.3, bounce = 0.2, 
								bodyType = "kinematic", 
								isBullet = true, isSensor = true, isFixedRotation = true,
								shape={ 0,0, 26,0, 26,700, 0,700 },
								filter = { categoryBits = 2, maskBits = 4 }
							} )
	
	function img:destroy()
		-- TODO: remove from game loop and ensure bullet count is lowered
		--[[
		bullets = bullets - 1
		removeLoop(self)
		--]]
		audio.stop(BossBigPlane.fireSoundChannel)
		audio.rewind(BossBigPlane.fireSoundChannel)
		--self:removeEventListener("sprite", onSpriteAnimation)
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
	
	if(BossBigPlane.fireSoundChannel == nil) then
		BossBigPlane.fireSoundChannel = audio.play(BossBigPlane.fireSound)
	else
		
		audio.play(BossBigPlane.fireSound, {channel=BossBigPlane.fireSoundChannel})
	end
	
	function onReady()
		timer.cancel(img.timerHandle)
		img:destroy()
	end
	
	img.timerHandle = timer.performWithDelay(1000, onReady)
	
	return img
end

return PlayerRailGun