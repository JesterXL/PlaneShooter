require "constants"

bossBigPlane = {}

function new()
	if(bossBigPlane.bossSheet == nil) then
		local bossSheet = sprite.newSpriteSheet("boss_sheet_1.png", 143, 96)
		local bossSet = sprite.newSpriteSet(bossSheet, 1, 2)
		--sprite.add(bossSet, "bossSheetSet1", 1, 3, 500, 0)
		bossBigPlane.bossSheet = bossSheet
		bossBigPlane.bossSet = bossSet
		bossBigPlane.hitSound = audio.loadSound("boss_hit_sound.mp3")
		bossBigPlane.deathSound = 
	end
	
	local boss = sprite.newSprite(bossSet)
	boss:setReferencePoint(display.TopLeftReferencePoint)
	boss.name = "Boss"
	boss:prepare()
	boss:play()
	-- TODO: maybe require sprite; not sure
	local middle = (stage.width / 2) - (boss.width / 2)
	boss.x = middle
	boss.y = -boss.height
	boss.speed = 1
	boss.targetX = stage.width / 2 - boss.width / 2
	boss.targetY = boss.height
	boss.gunPoint1 = {x = 71, y = 23}
	boss.gunPoint2 = {x = 71, y = 44}
	boss.gunPoint3 = {x = 71, y = 68}
	boss.leftGunPoint = {x = 71, y = 68}
	boss.rightGunPoint = {x = 71, y = 68}
	boss.fireSpeed = 1600
	boss.lastTick = 0
	boss.hitPoints = 100
	
	
	local halfWidth = boss.width / 2
	local halfHeight = boss.height / 2
	local bossShape = {82-halfWidth,48-halfHeight, 98-halfWidth,94-halfHeight, 45-halfWidth,94-halfHeight, 62-halfWidth,48-halfHeight, 0-halfWidth,30-halfHeight, 0-halfWidth,0-halfHeight, 143-halfWidth,0-halfHeight, 143-halfWidth,30-halfHeight} 
	
	physics.addBody( boss, { density = 1.0, friction = 0.3, bounce = 0.2, 
								bodyType = "kinematic", 
								isBullet = false, isSensor = true, isFixedRotation = false,
								shape=bossShape,
								filter = { categoryBits = 4, maskBits = 3 }
							} )
								
	-- TODO: add to game loop
	--addLoop(boss)
	
	
	function boss:destroy()
		-- TODO: remove from game loop and handle death dispatch
		--removeLoop(self)
		--createEnemyDeath(self.x, self.y)
		
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
	
	function insanityFiringMode(self, millisecondsPassed)
		self.lastTick = self.lastTick + millisecondsPassed
		if(self.lastTick >= self.fireSpeed) then
			-- TODO: making this harder for player would be to have fire at delayed times vs. all at once
			createEnemyBullet(self.gunPoint1.x + self.x, self.gunPoint1.y + self.y, plane)
			createEnemyBullet(self.gunPoint2.x + self.x, self.gunPoint2.y + self.y, plane)
			createEnemyBullet(self.gunPoint3.x + self.x, self.gunPoint3.y + self.y, plane)
			createEnemyBullet(self.leftGunPoint.x + self.x, self.leftGunPoint.y + self.y, {x = -30, y = self.leftGunPoint.y + self.y})
			createEnemyBullet(self.rightGunPoint.x + self.x, self.rightGunPoint.y + self.y, {x = stage.width + 30, y = self.rightGunPoint.y + self.y})
			self.lastTick = 0
		else
			self.lastTick = self.lastTick + millisecondsPassed
		end
	end
	
	boss.tick = moveToFiringPosition
	
	function onHit(self, event)
		-- TODO: ensure bullet name is same
		if(event.other.name == "Bullet") then
			self.hitPoints = self.hitPoints - 1
			if(self.hitPoints <= 0) then
				self:destroy()
			else
				-- TODO: fix sound
				--local hitSoundChannel = audio.play(playerHitSound)
				--audio.setVolume(.5, {channel=hitSoundChannel})
				-- TODO: handle new event
				--createEnemyDeath(event.other.x, event.other.y)
				self:dispatchEvent({name="death", target=self})
				event.other:destroy()
			end
		end
	end
	
	boss.collision = onHit
	boss:addEventListener("collision", boss)
	
	return boss
end