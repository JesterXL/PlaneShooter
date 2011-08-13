require "constants"

BossBigPlane = {}

function BossBigPlane:new(player)
	if(BossBigPlane.bossSheet == nil) then
		local bossSheet = sprite.newSpriteSheet("boss_big_plane_sheet.png", 142, 98)
		local bossSet = sprite.newSpriteSet(bossSheet, 1, 2)
		sprite.add(bossSet, "bossSheetSet1", 1, 2, 100, 0)
		BossBigPlane.bossSheet = bossSheet
		BossBigPlane.bossSet = bossSet
		BossBigPlane.hitSound = audio.loadSound("boss_hit_sound.mp3")
		BossBigPlane.railHitSound = audio.loadSound("boss_rail_hit.wav")
		BossBigPlane.fireSound = audio.loadSound("boss_big_plane_fire.wav")
		-- TODO/FIXME: wrong sound yo
		--BossBigPlane.deathSound = audio.loadSound("enemies/boss_hit_sound.mp3")
	end
	
	local boss = display.newGroup()
	local bossSpriteSheet = sprite.newSprite(BossBigPlane.bossSet)
	boss:insert(bossSpriteSheet)
	--bossSpriteSheet:setReferencePoint(display.TopLeftReferencePoint)
	boss.name = "Boss"
	bossSpriteSheet:prepare("bossSheetSet1")
	bossSpriteSheet:play()
	-- TODO: maybe require sprite; not sure
	local middle = (stage.width / 2) - (boss.width / 2)
	boss.x = middle
	boss.y = -boss.height
	boss.speed = 1
	boss.targetX = stage.width / 2 - boss.width / 2
	boss.targetY = boss.height
	--[[
	boss.gunPoint1 = {x = 71, y = 23}
	boss.gunPoint2 = {x = 71, y = 44}
	boss.gunPoint3 = {x = 71, y = 68}
	--]]
	boss.gunPoint1 = {x = 0, y = -33}
	boss.gunPoint2 = {x = 0, y = 0}
	boss.gunPoint3 = {x = 0, y = 34}
	boss.gunPoint1Image = display.newImage("boss_big_plane_turret.png")
	boss.gunPoint2Image = display.newImage("boss_big_plane_turret.png")
	boss.gunPoint3Image = display.newImage("boss_big_plane_turret.png")
	boss:insert(boss.gunPoint1Image)
	boss:insert(boss.gunPoint2Image)
	boss:insert(boss.gunPoint3Image)
	boss.gunPoint1Image.x = boss.gunPoint1.x
	boss.gunPoint1Image.y = boss.gunPoint1.y
	boss.gunPoint2Image.x = boss.gunPoint2.x
	boss.gunPoint2Image.y = boss.gunPoint2.y
	boss.gunPoint3Image.x = boss.gunPoint3.x
	boss.gunPoint3Image.y = boss.gunPoint3.y
	boss.leftGunPoint = {x = -2, y = 0}
	boss.rightGunPoint = {x = 2, y = 0}
	boss.fireSpeed = 1600
	boss.fireCount = 0 -- which gun is firing, cycle through 5
	boss.fireCountMax = 5
	boss.lastTick = 0
	boss.hitPoints = 100
	boss.player = player
	boss.rot = math.atan2(boss.y -  boss.player.x,  boss.x - boss.player.y) / math.pi * 180 -90;
	boss.angle = (boss.rot -90) * math.pi / 180;
	
	
	local halfWidth = boss.width / 2
	local halfHeight = boss.height / 2
	local bossShape = {82-halfWidth,48-halfHeight, 98-halfWidth,94-halfHeight, 45-halfWidth,94-halfHeight, 62-halfWidth,48-halfHeight, 0-halfWidth,30-halfHeight, 0-halfWidth,0-halfHeight, 143-halfWidth,0-halfHeight, 143-halfWidth,30-halfHeight} 
	
	physics.addBody( boss, { density = 1.0, friction = 0.3, bounce = 0.2, 
								bodyType = "kinematic", 
								isBullet = false, isSensor = true, isFixedRotation = false,
								shape=bossShape,
								filter = { categoryBits = 4, maskBits = 3 }
							} )
							
	function boss:destroy()
		-- TODO: remove from game loop and handle death dispatch
		self:dispatchEvent({name="removeFromGameLoop", target=self})
		
		-- TODO: fix sound
		--local enemyDeath1SoundChannel = audio.play(enemyDeath1Sound)
		--audio.setVolume(1, {channel = enemyDeath1SoundChannel})
		self:removeSelf()
	end
	
	function moveToFiringPosition(self, millisecondsPassed)
		local deltaX = self.x - self.targetX
		local deltaY = self.y - self.targetY
		local dist = math.sqrt((deltaX * deltaX) + (deltaY * deltaY))

		local moveX = self.speed * (deltaX / dist)
		local moveY = self.speed * (deltaY / dist)
		
		if (self.speed >= dist) then
			boss.tick = insanityFiringMode
		else
			self.x = self.x - moveX
			self.y = self.y - moveY
		end
	end
	
	function boss:getRotation(target)
		local targetX, targetY = target:localToContent(target.x, target.y)
		local rot = math.atan2(boss.player.y - targetY, boss.player.x - targetX) / math.pi * 180 - 90
		return rot
	end
	
	function insanityFiringMode(self, millisecondsPassed)
		self.lastTick = self.lastTick + millisecondsPassed
		--[[
		if(BossBigPlane.fireSoundChannel == nil) then
			print("------------ Playing fire sound ----------")
			BossBigPlane.fireSoundChannel = audio.play(BossBigPlane.fireSound, {loops=-1})
		end
		--]]
		
		boss.gunPoint1Image.rotation = boss:getRotation(boss.gunPoint1Image)
		boss.gunPoint2Image.rotation = boss:getRotation(boss.gunPoint2Image)
		boss.gunPoint3Image.rotation = boss:getRotation(boss.gunPoint3Image)
		
		if(self.lastTick >= self.fireSpeed) then
			if(boss.fireCount + 1 <= boss.fireCountMax) then
				boss.fireCount = boss.fireCount + 1
			else
				boss.fireCount = 1
			end
			
			
			local points = {
				{x=self.gunPoint1.x + self.x, y=self.gunPoint1.y + self.y},
				{x=self.gunPoint2.x + self.x, y=self.gunPoint2.y + self.y},
				{x=self.gunPoint3.x + self.x, y=self.gunPoint3.y + self.y},
				{x=self.leftGunPoint.x + self.x, y=self.leftGunPoint.y + self.y}, 
				{x=self.rightGunPoint.x + self.x, y=self.rightGunPoint.y + self.y}
			}
			
			--[[
			
			local points
			if(boss.fireCount == 1) then points = {{x=self.gunPoint1.x + self.x, y=self.gunPoint1.y + self.y}}
			elseif(boss.fireCount == 1) then points = {{x=self.gunPoint2.x + self.x, y=self.gunPoint2.y + self.y}}
			elseif(boss.fireCount == 1) then points = {{x=self.gunPoint3.x + self.x, y=self.gunPoint3.y + self.y}}
			elseif(boss.fireCount == 1) then points = {{x=self.leftGunPoint.x + self.x, y=self.leftGunPoint.y + self.y}}
			elseif(boss.fireCount == 1) then points = {{x=self.rightGunPoint.x + self.x, y=self.rightGunPoint.y + self.y}}
			end
			--]]
			
			self:dispatchEvent({name="fireShots", target=self, points=points})
			self.lastTick = 0
		else
			self.lastTick = self.lastTick + millisecondsPassed
		end
	end
	
	boss.tick = moveToFiringPosition
	
	function onHit(self, event)
		-- TODO: ensure bullet name is same
		if(event.other.name == "Bullet" or event.other.name == "BulletRail") then
			self.hitPoints = self.hitPoints - 1
			if(event.other.name ~= "BulletRail") then
				event.other:destroy();
			end
			
			if(self.hitPoints <= 0) then
				self:dispatchEvent({name="death", target=self})
				self:destroy()
			else
				
				if(event.other.name ~= "BulletRail") then
					if(BossBigPlane.hitSoundChannel ~= nil) then
						audio.stop(BossBigPlane.hitSoundChannel)
						audio.rewind(BossBigPlane.hitSound)
						audio.play(BossBigPlane.hitSound, {channel=BossBigPlane.hitSoundChannel})
					else
						BossBigPlane.hitSoundChannel = audio.play(BossBigPlane.hitSound)
					end
				else
					if(BossBigPlane.railHitSoundChannel ~= nil) then
						audio.stop(BossBigPlane.railHitSoundChannel)
						audio.rewind(BossBigPlane.railHitSound)
						audio.play(BossBigPlane.railHitSound, {channel=BossBigPlane.railHitSoundChannel})
					else
						BossBigPlane.railHitSoundChannel = audio.play(BossBigPlane.railHitSound)
					end
				end
				
					
					
				
				-- TODO: handle new event
				--createEnemyDeath(event.other.x, event.other.y)
				
			end
		end
	end
	
	boss.collision = onHit
	boss:addEventListener("collision", boss)
	
	return boss
end

return BossBigPlane