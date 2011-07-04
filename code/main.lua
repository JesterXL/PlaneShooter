require "sprite"
local physics = require "physics"
physics.start()
physics.setDrawMode( "hybrid" )
physics.setGravity( 0, 0 )

local function initEnemeyDeath()
	enemyDeathSheet = sprite.newSpriteSheet("enemy-death-sheet-1.png", 24, 24)
	enemyDeathSet = sprite.newSpriteSet(enemyDeathSheet, 1, 4)
	sprite.add(enemyDeathSet, "enemyDeathSheet1", 1, 5, 1000, 1)
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
	
	img.speed = 6 -- pixels per second
	img.name = "Player"
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
		self.hitPionts = self.hitPoints - 1
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


local function onRunComplete(event)
	table.remove(event.target)
	event.target:removeSelf()
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

ENEMY_1_SPEED = 4
ENEMY_1_BULLET_SPEED = 7

MAX_BULLET_COUNT = 4

tickers = {}
bullets = 0
enemyRoster = {
	
	
	
}

stage = display.getCurrentStage()
initEnemeyDeath()
plane = createPlayer()

local lastTick = system.getTimer()

addLoop(plane)

planeXTarget = stage.width / 2
planeYTarget = stage.height / 2
plane:move(planeXTarget, planeYTarget)

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
		createBullet(plane.x, plane.y)
	end
		
		
	if(event.phase == "began" or event.phase == "moved") then
		planeXTarget = event.x
		planeYTarget = event.y
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
	
	timer.performWithDelay(3000, t, 0)
	
end

startGame()


