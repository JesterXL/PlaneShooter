require "sprite"
require "physics"
require "constants"
require "Player"


local function initEnemeyDeath()
	enemyDeathSheet = sprite.newSpriteSheet("enemy_death_sheet_1.png", 24, 24)
	enemyDeathSet = sprite.newSpriteSet(enemyDeathSheet, 1, 4)
	sprite.add(enemyDeathSet, "enemyDeathSheet1", 1, 5, 1000, 1)
end

local function initPlayerDeath()
	playerDeathSheet = sprite.newSpriteSheet("player_death_sheet.png", 18, 18)
	playerDeathSet = sprite.newSpriteSet(playerDeathSheet, 1, 10)
	sprite.add(playerDeathSet, "playerDeathSheet", 1, 10, 2000, 1)
end

local function initTerrain()
	-- NOTE: getting emulator bug with images; hard to tell wtf, so aborting for now
	if(true) then
		return
	end
	
	terrain1 = display.newImage("debug_terrain.png", 0, 0)
	mainGroup:insert(terrain1)
	terrain2 = display.newImage("debug_terrain.png", 0, 0)
	mainGroup:insert(terrain2)
	terrain1.x = 0
	terrain1.y = 0
--	terrain2.isVisible = false
--	terrain2.x = 0
	--terrain2.y = terrain1.y + terrain1.height + 4
	
	print("terrain1.y: ", terrain1.y, ", stage.y: ", stage.y)
	
	terrainScroller = {}
	terrainScroller.speed = TERRAIN_SCROLL_SPEED
	terrainScroller.onTerrain = terrain1
	terrainScroller.offTerrain = terrain2
	terrainScroller.targetY = -terrain1.height
	
	function terrainScroller:tick(millisecondsPassed)
		local deltaX = self.onTerrain.x
		local deltaY = self.onTerrain.y - self.targetY
		local dist = math.sqrt((deltaX * deltaX) + (deltaY * deltaY))

		local moveX = self.speed * (deltaX / dist)
		local moveY = self.speed * (deltaY / dist)
		print("self.onTerrain.y: ", self.onTerrain.y)

		if (self.speed >= dist) then
			self.y = self.targetY
			self.onTerrain.y = self.offTerrain.y + self.offTerrain.height
			local oldOn = self.onTerrain
			self.onTerrain = self.offTerrain
			self.offTerrain = oldOn
		else
			self.onTerrain.x = self.onTerrain.x - moveX
			self.onTerrain.y = self.onTerrain.y - moveY
			self.offTerrain.x = self.onTerrain.x
			self.offTerrain.y = self.onTerrain.y + self.onTerrain.height + 2
		end
	end
end

function startScrollingTerrain()
	--addLoop(terrainScroller)
end

function stopScrollingTerrain()
	--removeLoop(terrainScroller)
end

local function initHealthBar()
	healthBarBackground = display.newImage("health_bar_background.png", 0, 0)
	mainGroup:insert(healthBarBackground)
	healthBarBackground.x = stage.width - healthBarBackground.width - 8
	healthBarBackground.y = 8
	
	healthBarForeground = display.newImage("health_bar_foreground.png", 0, 0)
	mainGroup:insert(healthBarForeground)
	healthBarForeground.x = healthBarBackground.x
	healthBarForeground.y = healthBarBackground.y
	healthBarForeground:setReferencePoint(display.TopLeftReferencePoint)
end

local function initSounds()
	planeShootSound = audio.loadSound("plane_shoot.wav")
	enemyDeath1Sound = audio.loadSound("enemy_death_1.mp3")
	playerHitSound = audio.loadSound("player_hit_sound.mp3")
	playerDeathSound = audio.loadSound("player_death_sound.mp3")
end

-- from 0 to 1
function setHealth(value)
	if(value <= 0) then
		value = 0.1
	end
	
	healthBarForeground.xScale = value
	-- NOTE: Makah-no-sense, ese. Basically, setting width is bugged, and Case #677 is documented.
	-- Meaning, no matter what reference point you set, it ALWAYS resizes from center when setting width/height.
	-- So, we just increment based on the negative xReference of "how far my left is from my left origin".
	-- Wow, that was a fun hour.
	healthBarForeground.x = healthBarBackground.x + healthBarForeground.xReference
end

function createEnemyDeath(targetX, targetY)
	local si = sprite.newSprite(enemyDeathSet)
	mainGroup:insert(si)
	si.name = "enemyDeathSetYo"
	si:prepare()
	function onEnd(event)
		if(event.phase == "loop") then
			event.sprite:removeSelf()
		end
	end
	si:addEventListener("sprite", onEnd)
	si:play()
	si.x = targetX
	si.y = targetY
	return si
end

function createPlayerDeath(targetX, targetY)
	local si = sprite.newSprite(playerDeathSet)
	mainGroup:insert(si)
	si.name = "playerDeathSetYo"
	si:prepare()
	function onEnd(event)
		if(event.phase == "loop") then
			event.sprite:removeSelf()
		end
	end
	si:addEventListener("sprite", onEnd)
	si:play()
	si.x = targetX
	si.y = targetY
	return si
end



local function createEnemyPlane(filename, name, startX, startY, bottom)
	local img = display.newImage(filename)
	mainGroup:insert(img)
	img.name = name
	img.speed = ENEMY_1_SPEED
	img.x = startX
	img.y = startY
	img.bottom = bottom
	img.fireTime = 1500 -- milliseconds
	img.fired = false
	
	
	physics.addBody( img, { density = 1.0, friction = 0.3, bounce = 0.2, 
								bodyType = "kinematic", 
								isBullet = true, isSensor = true, isFixedRotation = true,
								filter = { categoryBits = 4, maskBits = 3 }
							} )
								
	addLoop(img)
	
	function img:destroy()
		removeLoop(self)
		self:removeSelf()
	end
	
	function onHit(self, event)
		if(event.other.name == "Bullet") then
			createEnemyDeath(self.x, self.y)
			local enemyDeath1SoundChannel = audio.play(enemyDeath1Sound, {loops=0})
			audio.setVolume(.25, {channel = enemyDeath1SoundChannel})
			self:dispatchEvent({name="enemyDead", target=self})
			self:destroy()
			event.other:destroy()
		end
	end
	
	img.collision = onHit
	img:addEventListener("collision", img)
	
	function img:tick(millisecondsPassed)
		
		if(self.fired == false) then
			self.fireTime = self.fireTime - millisecondsPassed
			if(self.fireTime <= 0) then
				self.fired = true
				createEnemyBullet(self.x, self.y, plane)
			end
		end
			
		
		if(self.y > bottom) then
			return
		else
			local deltaX = 0
			local deltaY = self.y - bottom
			local dist = math.sqrt((deltaX * deltaX) + (deltaY * deltaY))

			local moveX = self.speed * (deltaX / dist)
			local moveY = self.speed * (deltaY / dist)

			if (self.speed >= dist) then
				self.y = bottom
				self:destroy()
			else
				self.y = self.y - moveY
			end
		end
			
	end
	
	return img	
end

local function createBullet1(startX, startY)
	if(bullets + 1 > MAX_BULLET_COUNT) then
		return
	else
		bullets = bullets + 1
	end
	
	local img = display.newImage("player_bullet_1.png")
	mainGroup:insert(img)
	img.name = "Bullet"
	img.speed = PLAYER_BULLET_SPEED
	img.x = startX
	img.y = startY
	
	physics.addBody( img, { density = 1.0, friction = 0.3, bounce = 0.2, 
								bodyType = "kinematic", 
								isBullet = true, isSensor = true, isFixedRotation = true,
								filter = { categoryBits = 2, maskBits = 4 }
							} )
								
	addLoop(img)
	
	function img:destroy()
		bullets = bullets - 1
		removeLoop(self)
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

local function createBullet2(startX, startY)
	if(bullets + 1 > MAX_BULLET_COUNT) then
		return
	else
		bullets = bullets + 1
	end
	
	local img = display.newImage("player_bullet_2.png")
	mainGroup:insert(img)
	img.name = "Bullet"
	img.speed = PLAYER_BULLET_SPEED
	img.x = startX
	img.y = startY
	
	physics.addBody( img, { density = 1.0, friction = 0.3, bounce = 0.2, 
								bodyType = "kinematic", 
								isBullet = true, isSensor = true, isFixedRotation = true,
								filter = { categoryBits = 2, maskBits = 4 }
							} )
								
	addLoop(img)
	
	function img:destroy()
		bullets = bullets - 1
		removeLoop(self)
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

local function createBullet3(startX, startY)
	if(bullets + 1 > MAX_BULLET_COUNT) then
		return
	else
		bullets = bullets + 1
	end
	
	local centerImage = display.newImage("player_bullet_2.png")
	local leftImage = display.newImage("player_bullet_1.png")
	local rightImage = display.newImage("player_bullet_1.png") 
	mainGroup:insert(centerImage)
	mainGroup:insert(leftImage)
	mainGroup:insert(rightImage)
	centerImage.name = "Bullet"
	leftImage.name = "Bullet"
	rightImage.name = "Bullet"
	centerImage.speed = PLAYER_BULLET_SPEED
	leftImage.speed = PLAYER_BULLET_SPEED
	rightImage.speed = PLAYER_BULLET_SPEED
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
								
	addLoop(leftImage)
	addLoop(rightImage)
	addLoop(centerImage)
	
	function leftImage:destroy()
		bullets = bullets - 1
		removeLoop(self)
		self:removeSelf()
	end
	
	function rightImage:destroy()
		bullets = bullets - 1
		removeLoop(self)
		self:removeSelf()
	end
	
	function centerImage:destroy()
		bullets = bullets - 1
		removeLoop(self)
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

			local moveX = self.speed * (deltaX / dist)
			local moveY = self.speed * (deltaY / dist)
			
			if (self.speed >= dist) then
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
		self.x = self.x + math.cos(self.angle) * self.speed
	   	self.y = self.y + math.sin(self.angle) * self.speed
	end
	
	function rightImage:tick(millisecondsPassed)
		self.x = self.x + math.cos(self.angle) * self.speed
	   	self.y = self.y + math.sin(self.angle) * self.speed
	end
	
	return centerImage, leftImage, rightImage
end

function createEnemyBullet(startX, startY, targetPoint)
	local img = display.newImage("bullet.png")
	mainGroup:insert(img)
	img.name = "Bullet"
	img.speed = ENEMY_1_BULLET_SPEED
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
								
	addLoop(img)
	
	function onHit(self, event)
		if(event.other.name == "Player") then
			event.other:onBulletHit()
			self:destroy()
		end
	end

	img.collision = onHit
	img:addEventListener("collision", img)
	
	function img:destroy()
		removeLoop(self)
		self:removeSelf()
	end
	
	function img:tick(millisecondsPassed)
		
		-- TODO: make sure using milliseconds vs. hardcoding step speed
		
		--print("angle: ", self.angle, ", math.cos(self.angle): ", math.cos(self.angle))
		self.x = self.x + math.cos(self.angle) * self.speed
	   	self.y = self.y + math.sin(self.angle) * self.speed
		
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

function createPowerUp(x, y)
	local img = display.newImage("icon_power_up.png")
	img.x = x
	img.y = y
	img.lifetime = 5000 -- milliseconds
	

	
	physics.addBody( img, { density = 1.0, friction = 0.3, bounce = 0.2, 
								bodyType = "kinematic", 
								isBullet = false, isSensor = true, isFixedRotation = true,
								filter = { categoryBits = 16, maskBits = 1 }
							} )
				
	addLoop(img)
			
	function onHit(self, event)
		if(event.other.name == "Player") then
			addPowerUp()
			local result = removeLoop(img)
			print("result of removing myself upon a collision: ", result)
			img:removeSelf()
			img = nil
			return true
		end
	end
	
	function img:tick(millisecondsPassed)
		-- TODO/FIXME/BUG: this is weird; it's a non-nil reference, but it's jsut a table
		if(img.removeSelf ~= nil) then
			img.lifetime = img.lifetime - millisecondsPassed
			if(img.lifetime <= 0) then
				img:removeSelf()
			end
		end
	end
	
	img.collision = onHit
	img:addEventListener("collision", img)
	
	return img
end


function createBoss()
	local bossSheet = sprite.newSpriteSheet("boss_sheet_1.png", 143, 96)
	local bossSet = sprite.newSpriteSet(bossSheet, 1, 2)
	--sprite.add(bossSet, "bossSheetSet1", 1, 3, 500, 0)
	local boss = sprite.newSprite(bossSet)
	boss:setReferencePoint(display.TopLeftReferencePoint)
	mainGroup:insert(boss)
	boss.name = "Boss"
	boss:prepare()
	boss:play()
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
	boss.hitSound = audio.loadSound("boss_hit_sound.mp3")
	
	local halfWidth = boss.width / 2
	local halfHeight = boss.height / 2
	local bossShape = {82-halfWidth,48-halfHeight, 98-halfWidth,94-halfHeight, 45-halfWidth,94-halfHeight, 62-halfWidth,48-halfHeight, 0-halfWidth,30-halfHeight, 0-halfWidth,0-halfHeight, 143-halfWidth,0-halfHeight, 143-halfWidth,30-halfHeight} 
	
	physics.addBody( boss, { density = 1.0, friction = 0.3, bounce = 0.2, 
								bodyType = "kinematic", 
								isBullet = false, isSensor = true, isFixedRotation = false,
								shape=bossShape,
								filter = { categoryBits = 4, maskBits = 3 }
							} )
								
	addLoop(boss)
	
	
	function boss:destroy()
		removeLoop(self)
		createEnemyDeath(self.x, self.y)
		local enemyDeath1SoundChannel = audio.play(enemyDeath1Sound)
		audio.setVolume(1, {channel = enemyDeath1SoundChannel})
		self:dispatchEvent({name="enemyDead", target=self})
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
		if(event.other.name == "Bullet") then
			self.hitPoints = self.hitPoints - 1
			if(self.hitPoints <= 0) then
				self:destroy()
			else
				--local hitSoundChannel = audio.play(self.hitSound)
				local hitSoundChannel = audio.play(playerHitSound)
				audio.setVolume(.5, {channel=hitSoundChannel})
				createEnemyDeath(event.other.x, event.other.y)
				event.other:destroy()
			end
		end
	end
	
	boss.collision = onHit
	boss:addEventListener("collision", boss)
	
	return boss
end

function addPowerUp()
	setPowerUpLevel(powerUpLevel + 1)
end

function removePowerUp()
	if(powerUpLevel > 1) then
		setPowerUpLevel(powerUpLevel - 1)
	end
end

function addLoop(o)
	table.insert(tickers, o)
end

function removeLoop(o)
	for i,v in ipairs(tickers) do
		if(v == o) then
			table.remove(tickers, i)
			return true
		end	
	end
	print("!! item not found !!")
	return false
end

local function startFiringBullets()
	addLoop(bulletRegulator)
	bulletRegulator:tick(333)
end

local function stopFiringBullets()
	removeLoop(bulletRegulator)
end

function animate(event)
	local now = system.getTimer()
	local difference = now - lastTick
	lastTick = now
	
	for i,v in ipairs(tickers) do
		v:tick(difference)
	end
end

function onTouch(event)
	if(event.phase == "began") then
		startFiringBullets()
		if(planeShootSoundChannel == nil) then
			audio.setVolume( .25, { channel=1 } )
			planeShootSoundChannel = audio.play(planeShootSound, {channel=1, loops=-1, fadein=100})
		end
	end
		
		
	if(event.phase == "began" or event.phase == "moved") then
		planeXTarget = event.x
		planeYTarget = event.y
	end
	
	if(event.phase == "ended" or event.phase == "cancelled") then
		stopPlayerInteraction()
	end
end

function stopPlayerInteraction()
	stopFiringBullets()
	audio.fadeOut({channel=1, time=100})
	planeShootSoundChannel = nil
end

function endGame()
	print("endGame")
	Runtime:removeEventListener("enterFrame", animate )
	Runtime:removeEventListener("touch", onTouch)
	timer.cancel(gameTimer)
	gameTimer = nil
	stopScrollingTerrain()
end

function setPowerUpLevel(level)
	if(level > 3) then
		level = 3
	end
	
	powerUpLevel = level
	if(powerUpLevel <= 3) then
		PLAYER_BULLET_SPEED = 10
		--PLAYER_MOVE_SPEED = 7
		plane.speed = PLAYER_MOVE_SPEED
	end
	
	if(powerUpLevel == 1) then
		bulletRegulator.fireFunc = createBullet1
	elseif(powerUpLevel == 2) then
		bulletRegulator.fireFunc = createBullet2
	elseif(powerUpLevel == 3) then
		bulletRegulator.fireFunc = createBullet3
	end
	--[[
	elseif(powerUpLevel == 4) then
		return
		PLAYER_BULLET_SPEED = 14
		PLAYER_MOVE_SPEED = 11
		plane.speed = PLAYER_MOVE_SPEED
	end
	]]--
end

function startBossFight()
	print("-- startBossFight --")
	if(fightingBoss == false) then
		fightingBoss = true
		timer.cancel(gameTimer)
		gameTimer = nil
		local delayTable = {}
		function delayTable:timer(event)
		    createBoss()
        end
        timer.performWithDelay(200, delayTable)
	end
end

function startGame()
	Runtime:addEventListener("enterFrame", animate )
	Runtime:addEventListener("touch", onTouch)
	local t = {}
	function t:timer(event)
		--event.time
		-- timer.cancel( event.source ) 
		local randomX = stage.width * math.random()
		if(randomX < 20) then
			randomX = 20
		end
		
		if(randomX > stage.width - 20) then
			randomX = stage.width - 20
		end
			
		local enemyPlane = createEnemyPlane("enemy_1.png", "Enemy1", randomX, 0, stage.height)
		function onDead(event)
			
			enemies = enemies - 1
			if(enemies <= 0) then
				startBossFight()
			end
			
			powerCount = powerCount - 1
			if(powerCount <= 0) then
				powerCount = POWER_MAX_COUNT
				-- NOTE: You have to set a delay; adding physics bodies during a collision event (within the stack)
				-- will cause a hard crash
				local delayTable = {}
				delayTable.x = event.target.x
				delayTable.y = event.target.y
				function delayTable:timer(event)
				    createPowerUp(self.x, self.y)
		        end
		        timer.performWithDelay(200, delayTable)
				
			end
		end
		enemyPlane:addEventListener("enemyDead", onDead)
	end
	
	gameTimer = timer.performWithDelay(500, t, 0)
	
	startScrollingTerrain()
end




physics.start()
physics.setDrawMode( "hybrid" )
physics.setGravity( 0, 0 )

--[[

ENEMY_1_SPEED = 4
ENEMY_1_BULLET_SPEED = 7
MAX_BULLET_COUNT = 6
PLAYER_MOVE_SPEED = 7
PLAYER_BULLET_SPEED = 10
TERRAIN_SCROLL_SPEED = 1


--]]
mainGroup = display.newGroup()

tickers = {}
powerUpLevel = 1
enemies = 10
fightingBoss = false
powerCount = 3
POWER_MAX_COUNT = 3

bullets = 0
bulletRegulator = {} -- Mount up!
bulletRegulator.fireSpeed = 400
bulletRegulator.lastFire = 0
bulletRegulator.fireFunc = nil
function bulletRegulator:tick(millisecondsPassed)
	self.lastFire = self.lastFire + millisecondsPassed
	if(self.lastFire >= self.fireSpeed) then
		self.fireFunc(plane.x, plane.y)
		self.lastFire = 0
	end
end


stage = display.getCurrentStage()
initTerrain()
initEnemeyDeath()
initHealthBar()
initSounds()
initPlayerDeath()


plane = Player.new()
--plane:addEventListener("hitPointsChanged", )

setPowerUpLevel(powerUpLevel)

lastTick = system.getTimer()

addLoop(plane)

planeXTarget = stage.width / 2
planeYTarget = stage.height / 2
plane:move(planeXTarget, planeYTarget)

startGame()
