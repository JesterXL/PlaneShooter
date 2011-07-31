require "sprite"
require "physics"

local ufoSpriteSheet = sprite.newSpriteSheet("ufo_sprite_sheet.png", 160, 160)
local ufoSpriteSet = sprite.newSpriteSet(ufoSpriteSheet, 1, 9)
sprite.add(ufoSpriteSet, "ufo", 1, 9, 500, 0)
ufo = sprite.newSprite(ufoSpriteSet)
ufo:setReferencePoint(display.TopLeftReferencePoint)
ufo.x = 0
ufo.y = 0
ufo:prepare("ufo")
ufo:play()

local ufoExposedSpriteSheet = sprite.newSpriteSheet("ufo_exposed.png", 160, 160)
local ufoExposedSpriteSet = sprite.newSpriteSet(ufoExposedSpriteSheet, 1, 5)
sprite.add(ufoExposedSpriteSet, "ufoExposed", 1, 5, 400, 0)
local ufoExposed = sprite.newSprite(ufoExposedSpriteSet)
ufoExposed:setReferencePoint(display.TopLeftReferencePoint)
ufoExposed.x = 40
ufoExposed.y = 300
ufoExposed:prepare("ufoExposed")
ufoExposed:play()

ufoGroup = display.newGroup()
ufoGroup:insert(ufo)

local ufoLaserTurretSpriteSheet = sprite.newSpriteSheet("ufo_laser_turret_sheet.png", 16, 16)
local ufoLaserTurretSpriteSet = sprite.newSpriteSet(ufoLaserTurretSpriteSheet, 1, 5)
sprite.add(ufoLaserTurretSpriteSet, "ufoTurretFire", 1, 5, 300, 1)

local function setupUFOTurret(x, y, name)
	local ufoTurret = sprite.newSprite(ufoLaserTurretSpriteSet)
	--ufoTurret:setReferencePoint(display.TopCenterReferencePoint)
	ufoGroup:insert(ufoTurret)
	ufoGroup[name] = ufoTurret
	ufoTurret.x = x
	ufoTurret.y = y
	ufoTurret.name = name
	ufoTurret:prepare("ufoTurretFire")
	return ufoTurret
end

setupUFOTurret(71, 18, "topTurret")
setupUFOTurret(121, 70, "rightTurret")
setupUFOTurret(71, 123, "bottomTurret")
setupUFOTurret(15, 70, "leftTurret")

local ufoMissleTurret = display.newImage("ufo_missle_turret.png", 0, 0)
ufoGroup:insert(ufoMissleTurret)
ufoMissleTurret.x = 77
ufoMissleTurret.y = 69

local ufoInertialGlueSpriteSheet = sprite.newSpriteSheet("ufo_inertial_glue_sheet.png", 72, 72)
local ufoInertialGlueSpriteSet = sprite.newSpriteSet(ufoInertialGlueSpriteSheet, 1, 30)
sprite.add(ufoInertialGlueSpriteSet, "ufoInertialGlue", 1, 30, 1000, 0)
local ufoIntertialGlue = sprite.newSprite(ufoInertialGlueSpriteSet)
ufoIntertialGlue:setReferencePoint(display.TopLeftReferencePoint)
ufoIntertialGlue.x = 200
ufoIntertialGlue.y = 100
ufoIntertialGlue:prepare("ufoInertialGlue")
ufoIntertialGlue:play()



local function createLaser(startX, startY, targetX, targetY)
	
	local img = display.newImage("laser.png", 0, 0)
	img:setReferencePoint(display.TopLeftReferencePoint)
	img.name = "laser"
	img.speed = 8
	img.x = startX
	img.y = startY
	img.targetX = targetX
	img.targetY = targetY
	img.rot = math.atan2(img.y -  img.targetY,  img.x - img.targetX) / math.pi * 180 -90;
	img.angle = (img.rot -90) * math.pi / 180;
	img.rotation = img.rot
	
	addLoop(img)
	
	function img:destroy()
		removeLoop(self)
		self:removeSelf()
	end
	
	function img:tick(millisecondsPassed)
		self.x = self.x + math.cos(self.angle) * self.speed
	   	self.y = self.y + math.sin(self.angle) * self.speed
	end
	
	return img
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

function animate(event)
	local now = system.getTimer()
	local difference = now - lastTick
	lastTick = now
	
	for i,v in ipairs(tickers) do
		v:tick(difference)
	end
end

tickers = {}
Runtime:addEventListener("enterFrame", animate )


local t = {}
function t:timer(event)
	physics.addBody( ufo, { density = 1.0, friction = 0.3, bounce = 0.2, radius=80	} )
end
timer.performWithDelay(200, t, 0)

physics.start()
physics.setDrawMode( "normal" )
physics.setGravity( 0, 0 )
lastTick = system.getTimer()


local laserT = {}
laserT.current = 0
laserT.max = 5
function laserT:timer(event)
	if(self.current + 1 < self.max) then
		self.current = self.current + 1
	else
		self.current = 1
	end
	
	local targetX, targetY
	if(self.current == 1) then
		targetX = 71
		targetY = 18
		ufoGroup.topTurret:prepare("ufoTurretFire")
		ufoGroup.topTurret:play()
	elseif(self.current == 2) then
		targetX = 121
		targetY = 70
		ufoGroup.rightTurret:prepare("ufoTurretFire")
		ufoGroup.rightTurret:play()
	elseif(self.current == 3) then
		targetX = 71
		targetY = 123
		ufoGroup.bottomTurret:prepare("ufoTurretFire")
		ufoGroup.bottomTurret:play()
	elseif(self.current == 4) then
		targetX = 15
		targetY = 70
		ufoGroup.leftTurret:prepare("ufoTurretFire")
		ufoGroup.leftTurret:play()
	end
	createLaser(targetX, targetY, math.random() * 400, math.random() * 700)
end
gameTimer = timer.performWithDelay(1000, laserT, 0)

						
