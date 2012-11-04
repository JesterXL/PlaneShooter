UFO = {}

function UFO:new(startX, startY)

	if startX == nil then startX = 0 end
	if startY == nil then startY = 0 end

	if UFO.ufoSpriteSheet == nil then
		local ufoSpriteSheet = sprite.newSpriteSheet("ufo/ufo_sprite_sheet.png", 160, 160)
		local ufoSpriteSet = sprite.newSpriteSet(ufoSpriteSheet, 1, 9)
		sprite.add(ufoSpriteSet, "ufo", 1, 9, 500, 0)
		UFO.ufoSpriteSheet = ufoSpriteSheet
		UFO.ufoSpriteSet = ufoSpriteSet

		local ufoExposedSpriteSheet = sprite.newSpriteSheet("ufo/ufo_exposed.png", 160, 160)
		local ufoExposedSpriteSet = sprite.newSpriteSet(ufoExposedSpriteSheet, 1, 5)
		sprite.add(ufoExposedSpriteSet, "ufoExposed", 1, 5, 400, 0)
		UFO.ufoExposedSpriteSheet = ufoExposedSpriteSheet
		UFO.ufoExposedSpriteSet = ufoExposedSpriteSet

		local ufoLaserTurretSpriteSheet = sprite.newSpriteSheet("ufo/ufo_laser_turret_sheet.png", 16, 16)
		local ufoLaserTurretSpriteSet = sprite.newSpriteSet(ufoLaserTurretSpriteSheet, 1, 5)
		sprite.add(ufoLaserTurretSpriteSet, "ufoTurretFire", 1, 5, 300, 1)
		UFO.ufoLaserTurretSpriteSheet = ufoLaserTurretSpriteSheet
		UFO.ufoLaserTurretSpriteSet = ufoLaserTurretSpriteSet
	end

	local ufo = display.newGroup()
	local ufoSprite = sprite.newSprite(UFO.ufoSpriteSet)
	ufo.ufoSprite = ufoSprite
	ufoSprite:setReferencePoint(display.TopLeftReferencePoint)
	ufo:insert(ufoSprite)
	ufo.x = startX
	ufo.y = startY
	ufoSprite:prepare("ufo")
	ufoSprite:play()

	function ufo:init()
		-- HACK until I figure out why it's not centering
		ufoSprite.x = 0
		ufoSprite.y = 0
		self:setupTurret(80, 28, "topTurret")
		self:setupTurret(132, 80, "rightTurret")
		self:setupTurret(80, 132, "bottomTurret")
		self:setupTurret(28, 80, "leftTurret")

		local ufoMissleTurret = display.newImage("ufo/ufo_missle_turret.png", 0, 0)
		self:insert(ufoMissleTurret)
		ufoMissleTurret.x = 80
		ufoMissleTurret.y = 80
		self.ufoMissleTurret = ufoMissleTurret

		physics.addBody( ufo, { density = 1.0, friction = 0.3, bounce = 0.2, radius=80	} )
		
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
				targetX = ufo.topTurret.x + ufo.x
				targetY = ufo.topTurret.y + ufo.y
				ufo.topTurret:prepare("ufoTurretFire")
				ufo.topTurret:play()
			elseif(self.current == 2) then
				targetX = ufo.rightTurret.x + ufo.x
				targetY = ufo.rightTurret.y + ufo.y
				ufo.rightTurret:prepare("ufoTurretFire")
				ufo.rightTurret:play()
			elseif(self.current == 3) then
				targetX = ufo.bottomTurret.x + ufo.x
				targetY = ufo.bottomTurret.y + ufo.y
				ufo.bottomTurret:prepare("ufoTurretFire")
				ufo.bottomTurret:play()
			elseif(self.current == 4) then
				targetX = ufo.leftTurret.x + ufo.x
				targetY = ufo.leftTurret.y + ufo.y
				ufo.leftTurret:prepare("ufoTurretFire")
				ufo.leftTurret:play()
			end
			ufo:createLaser(targetX, targetY, math.random() * 400, math.random() * 700)
		end
		timer.performWithDelay(1000, laserT, 0)

		local glueT = {}
		function glueT:timer(e)
			ufo:fireInertialGlue(80 + ufo.x, 80 + ufo.y)
		end
		timer.performWithDelay(100, glueT, 1)

		gameLoop:addLoop(self)
	end

	function ufo:tick(milliseconds)
		local turret = self.ufoMissleTurret
		turret.rotation = math.atan2(playerView.y - turret.y, playerView.x - turret.x) / math.pi * 180 - 90
	end

	function ufo:setupTurret(x, y, name)
		local ufoTurret = sprite.newSprite(UFO.ufoLaserTurretSpriteSet)
		--ufoTurret:setReferencePoint(display.TopCenterReferencePoint)
		ufoTurret:prepare("ufoTurretFire")
		self:insert(ufoTurret)
		ufoTurret.x = x
		ufoTurret.y = y
		ufoTurret.name = name
		self[name] = ufoTurret
		return ufoTurret
	end

	function ufo:fireInertialGlue(startX, startY)
		if UFO.ufoInertialGlueSpriteSheet == nil then
			local ufoInertialGlueSpriteSheet = sprite.newSpriteSheet("ufo/ufo_inertial_glue_sheet.png", 72, 72)
			local ufoInertialGlueSpriteSet = sprite.newSpriteSet(ufoInertialGlueSpriteSheet, 1, 30)
			sprite.add(ufoInertialGlueSpriteSet, "ufoInertialGlue", 1, 30, 1000, 0)
			UFO.ufoInertialGlueSpriteSheet = ufoInertialGlueSpriteSheet
			UFO.ufoInertialGlueSpriteSet = ufoInertialGlueSpriteSet
		end

		local ufoIntertialGlue = sprite.newSprite(UFO.ufoInertialGlueSpriteSet)
		--ufoIntertialGlue:setReferencePoint(display.TopLeftReferencePoint)
		mainGroup:insert(ufoIntertialGlue)
		ufoIntertialGlue:prepare("ufoInertialGlue")
		ufoIntertialGlue:play()
		ufoIntertialGlue.x = startX
		ufoIntertialGlue.y = startY
		ufoIntertialGlue.speed = 0.1
		function ufoIntertialGlue:destroy()
			gameLoop:removeLoop(self)
			self:removeSelf()
		end

		ufoIntertialGlue.rad = 80
		ufoIntertialGlue.t = 0


		function ufoIntertialGlue:tick(millisecondsPassed)

			--self.t = self.t + 5
			--self.x = ufo.x + ufo.width / 2 + self.rad * math.cos(math.pi * self.t / 180)
			--self.y = ufo.y + ufo.height / 2 + self.rad * math.sin(math.pi * self.t / 180)

			--if true then return true end

			local deltaX = self.x - playerView.x
			local deltaY = self.y - playerView.y
			local dist = math.sqrt((deltaX * deltaX) + (deltaY * deltaY))

			local moveX = self.speed * (deltaX / dist) * millisecondsPassed
			local moveY = self.speed * (deltaY / dist) * millisecondsPassed

			if (math.abs(moveX) > dist or math.abs(moveY) > dist) then
				self.x = playerView.x
				self.y = playerView.y
				self:destroy()
			else
				self.x = self.x - moveX
				self.y = self.y - moveY
			end
		end
		gameLoop:addLoop(ufoIntertialGlue)
	end

	function ufo:createLaser(startX, startY, targetX, targetY)
		local img = display.newImage("ufo/laser.png", 0, 0)
		img:setReferencePoint(display.TopLeftReferencePoint)
		img.name = "laser"
		mainGroup:insert(img)
		img.speed = 8
		img.x = startX
		img.y = startY
		img.targetX = targetX
		img.targetY = targetY
		img.rot = math.atan2(img.y -  img.targetY,  img.x - img.targetX) / math.pi * 180 -90;
		img.angle = (img.rot -90) * math.pi / 180;
		img.rotation = img.rot
		function img:destroy()
			gameLoop:removeLoop(self)
			self:removeSelf()
		end
		function img:tick(millisecondsPassed)
			self.x = self.x + math.cos(self.angle) * self.speed
		   	self.y = self.y + math.sin(self.angle) * self.speed
		end
		
		gameLoop:addLoop(img)

		
		img:toFront()
	end

	ufo:init()

	return ufo
end

return UFO