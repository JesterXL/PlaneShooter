require "sprite"
local physics = require "physics"


local function initEnemeyDeath()
	enemyDeathSheet = sprite.newSpriteSheet("enemy-death-sheet-1.png", 24, 24)
	enemyDeathSet = sprite.newSpriteSet(enemyDeathSheet, 1, 4)
	sprite.add(enemyDeathSet, "enemyDeathSheet1", 1, 5, 1000, 1)
end

local function initHealthBar()
	healthBarBackground = display.newImage("health-bar-background.png", 0, 0)
	healthBarBackground.x = stage.width - healthBarBackground.width - 8
	healthBarBackground.y = 8
	
	healthBarForeground = display.newImage("health-bar-foreground.png", 0, 0)
	healthBarForeground.x = healthBarBackground.x
	healthBarForeground.y = healthBarBackground.y
	healthBarForeground:setReferencePoint(display.TopLeftReferencePoint)
end

local function initSounds()
	planeShootSound = audio.loadSound("plane-shoot.wav")
	enemyDeath1Sound = audio.loadSound("enemy-death-1.mp3")
end

-- from 0 to 1
function setHealth(value)
	healthBarForeground.xScale = value
	-- NOTE: Makah-no-sense, ese. Basically, setting width is bugged, and Case #677 is documented.
	-- Meaning, no matter what reference point you set, it ALWAYS resizes from center when setting width/height.
	-- So, we just increment based on the negative xReference of "how far my left is from my left origin".
	-- Wow, that was a fun hour.
	healthBarForeground.x = healthBarBackground.x + healthBarForeground.xReference
end

function createEnemyDeath(targetX, targetY)
	local si = sprite.newSprite(enemyDeathSet)
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

local function createPlayer()
	local img = display.newImage("plane.png")
	
	img.speed = PLAYER_MOVE_SPEED -- pixels per second
	img.name = "Player"
	img.maxHitPoints = 3
	img.hitPoints = 3
	
	physics.addBody( img, { density = 1.0, friction = 0.3, bounce = 0.2, 
								bodyType = "kinematic", 
								isBullet = true, isSensor = true, isFixedRotation = true,
								filter = { categoryBits = 1, maskBits = 12 }
							} )
								
	function img:move(x, y)
		self.x = x
		self.y = y
	end
	
	function img:onBulletHit(event)
		self.hitPoints = self.hitPoints - 1
		setHealth(self.hitPoints / self.maxHitPoints)
		if(self.hitPoints <= 0) then
			endGame()
		end
	end
	
	function img:tick(millisecondsPassed)
		if(self.x == planeXTarget) then
			return
		else
			local deltaX = self.x - planeXTarget
			local deltaY = self.y - planeYTarget
			local dist = math.sqrt((deltaX * deltaX) + (deltaY * deltaY))

			local moveX = self.speed * (deltaX / dist)
			local moveY = self.speed * (deltaY / dist)

			if (self.speed >= dist) then
				self.x = planeXTarget
				self.y = planeYTarget
			else
				self.x = self.x - moveX
				self.y = self.y - moveY
			end
		end
			
	end
	
	return img
end

local function createEnemyPlane(filename, name, startX, startY, bottom)
	local img = display.newImage(filename)
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

local function createBullet(startX, startY)
	if(bullets + 1 > MAX_BULLET_COUNT) then
		return
	else
		bullets = bullets + 1
	end
	
	local img = display.newImage("bullet.png")
	
	img.name = "Bullet"
	img.speed = 10 -- pixels per second
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

function createEnemyBullet(startX, startY, target)
	local img = display.newImage("bullet.png")
	
	img.name = "Bullet"
	img.speed = ENEMY_1_BULLET_SPEED
	img.x = startX
	img.y = startY
	img.targetX = target.x
	img.targetY = target.y
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

local function startFiringBullets()
	addLoop(bulletRegulator)
	bulletRegulator:tick(333)
end

local function stopFiringBullets()
	removeLoop(bulletRegulator)
end


function addLoop(o)
	table.insert(tickers, o)
end

function removeLoop(o)
	for i,v in ipairs(tickers) do
		if(v == o) then
			table.remove(tickers, i)
			return
		end	
	end
	print("!! item not found !!")
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
		stopFiringBullets()
		audio.fadeOut({channel=1, time=100})
		planeShootSoundChannel = nil
	end
end

function endGame()
	print("endGame")
	Runtime:removeEventListener("enterFrame", animate )
	Runtime:removeEventListener("touch", onTouch)
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
			
		createEnemyPlane("enemy-1.png", "Enemy1", randomX, 0, stage.height)
	end
	
	timer.performWithDelay(500, t, 0)
	
end


physics.start()
physics.setDrawMode( "hybrid" )
physics.setGravity( 0, 0 )

ENEMY_1_SPEED = 4
ENEMY_1_BULLET_SPEED = 7
MAX_BULLET_COUNT = 6
PLAYER_MOVE_SPEED = 7


tickers = {}
bullets = 0
bulletRegulator = {} -- Mount up!
bulletRegulator.fireSpeed = 200
bulletRegulator.lastFire = 0
function bulletRegulator:tick(millisecondsPassed)
	self.lastFire = self.lastFire + millisecondsPassed
	if(self.lastFire >= self.fireSpeed) then
		createBullet(plane.x, plane.y)
		self.lastFire = 0
	end
end

stage = display.getCurrentStage()
initEnemeyDeath()
initHealthBar()
initSounds()
plane = createPlayer()

lastTick = system.getTimer()

addLoop(plane)

planeXTarget = stage.width / 2
planeYTarget = stage.height / 2
plane:move(planeXTarget, planeYTarget)

startGame()


