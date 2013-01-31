require "com.jessewarden.planeshooter.sprites.enemies.EnemyMissile"
require "com.jessewarden.planeshooter.sprites.enemies.Flak"
require "com.jessewarden.planeshooter.core.constants"
require "com.jessewarden.planeshooter.sounds.SoundManager"
require "com.jessewarden.statemachine.StateMachine"
require "com.jessewarden.planeshooter.sprites.enemies.tankmanclasses.TankManNormalState"
require "com.jessewarden.planeshooter.sprites.enemies.tankmanclasses.TankManDamagedState"
require "com.jessewarden.planeshooter.sprites.enemies.tankmanclasses.TankManCrazyState"
require "com.jessewarden.planeshooter.sprites.enemies.tankmanclasses.TankManDeadState"

TankMan = {}

function TankMan:new()

	local tank = display.newGroup()
	tank.classType = "TankMan"
	tank.startFireMissileTime = nil
	tank.startFireFlakTime = nil
	tank.MISSILE_FIRE_TIME = 500
	tank.firingMissiles = false
	tank.fireMissileSide = "left"
	tank.missileVolleyAmount = 12
	tank.currentMissile = nil
	tank.FLAK_FIRE_TIME = 1000
	tank.firingFlak = false
	tank.fireFlakSide = "left"
	tank.currentFlakPoint = nil
	tank.currentFlakPattern = nil
	tank.flakFirePatternAlpha = {
									{31,197},
									{31,	266},
									{31,	347},
									{31,	442},
									{132,	446},
									{227,	449},
									{299,	441},
									{296,	352},
									{293,	263},
									{290,	196},
									{166,	194},
									{164,	301},
									{164,	380},
									{163,	450},
								}
	tank.flakFirePatternBeta = {
									{292,	171},
									{293,	259},
									{289,	342},
									{297,	443},
									{227,	444},
									{122,	443},
									{31,	446},
									{22,	362},
									{25,	282},
									{30,	192},
									{160,	198},
									{163,	289},
									{164,	370},
									{160,	464},
								}
	
	tank.rotatingFirePosition = false
	tank.targetPosition = nil
	tank.leftShoulderArmJointTarget = nil
	tank.leftForearmLeftElbowJointTarget = nil
	tank.rightShoulderArmJointTarget = nil
	tank.rightForearmRightElbowJointTarget = nil
	tank.lastDiff = nil 

	tank.hitPoints = 200
	tank.leftTurretHitPoints = 65
	tank.rightTurretHitPoints = 65

	tank.stateMachine = nil

	function tank:init()
		if TankMan.bodySheet == nil then
			local FOLDER_PATH = "images/sprites/tank_man/"
			local bodySheet = sprite.newSpriteSheet(FOLDER_PATH .. "tank_man_body_sheet.png", 102, 90)
			local bodySheetSet = sprite.newSpriteSet(bodySheet, 1, 5)
			sprite.add(bodySheetSet, "tankManNormal", 1, 1, 5000, 0)
			sprite.add(bodySheetSet, "tankManDamagedLight", 2, 2, 300, 0)
			sprite.add(bodySheetSet, "tankManDamagedHeavy", 4, 2, 300, 0)
			TankMan.bodySheet = bodySheet
			TankMan.bodySheetSet = bodySheetSet

			local leftTurretSheet = sprite.newSpriteSheet(FOLDER_PATH .. "tank_man_left_turret_sheet.png", 24, 56)
			local leftTurretSheetSet = sprite.newSpriteSet(leftTurretSheet, 1, 5)
			sprite.add(leftTurretSheetSet, "tankManLeftTurretNormal", 1, 1, 5000, 0)
			sprite.add(leftTurretSheetSet, "tankManLeftTurretDamagedLight", 2, 2, 300, 0)
			sprite.add(leftTurretSheetSet, "tankManLeftTurretDamagedHeavy", 4, 2, 300, 0)
			TankMan.leftTurretSheet = leftTurretSheet
			TankMan.leftTurretSheetSet = leftTurretSheetSet

			local rightTurretSheet = sprite.newSpriteSheet(FOLDER_PATH .. "tank_man_right_turret_sheet.png", 24, 48)
			local rightTurretSheetSet = sprite.newSpriteSet(rightTurretSheet, 1, 5)
			sprite.add(rightTurretSheetSet, "tankManRightTurretNormal", 1, 1, 5000, 0)
			sprite.add(rightTurretSheetSet, "tankManRightTurretDamagedLight", 2, 2, 300, 0)
			sprite.add(rightTurretSheetSet, "tankManRightTurretDamagedHeavy", 4, 2, 300, 0)
			TankMan.rightTurretSheet = rightTurretSheet
			TankMan.rightTurretSheetSet = rightTurretSheetSet
		end

		local flakGunLeft = self:makePart("flakGunLeft", "images/sprites/tank_man/tank_man_flak_left.png")
		local flakGunRight = self:makePart("flakGunRight", "images/sprites/tank_man/tank_man_flak_right.png")
		
		local background = sprite.newSprite(TankMan.bodySheetSet)
		background:setReferencePoint(display.TopLeftReferencePoint)
		self:insert(background)
		background.x = 0
		background.y = 0
		self.background = background
		physics.addBody(background, {
								bodyType="kinematic", 
								isSensor=true
								})
		background.isFixedRotation = true

		local leftArm = self:makePart("leftArm", "images/sprites/tank_man/tank_man_left_arm.png")
		local rightArm = self:makePart("rightArm", "images/sprites/tank_man/tank_man_right_arm.png")
		local leftShoulder = self:makePart("leftShoulder", "images/sprites/tank_man/tank_man_left_shoulder.png")
		local rightShoulder = self:makePart("rightShoulder", "images/sprites/tank_man/tank_man_right_shoulder.png")
		local leftForearm = self:makePart("leftForearm", "images/sprites/tank_man/tank_man_left_forearm.png")
		local rightForearm = self:makePart("rightForearm", "images/sprites/tank_man/tank_man_right_forearm.png")
		local rightElbow = self:makePart("rightElbow", "images/sprites/tank_man/tank_man_right_elbow.png")
		local leftElbow = self:makePart("leftElbow", "images/sprites/tank_man/tank_man_left_elbow.png")

		local leftSam = sprite.newSprite(TankMan.leftTurretSheetSet)
		--leftSam:setReferencePoint(display.TopLeftReferencePoint)
		self:insert(leftSam)
		self.leftSam = leftSam
		physics.addBody(leftSam, {
								bodyType="kinematic", 
								isSensor=true
								})
		local rightSam = sprite.newSprite(TankMan.rightTurretSheetSet)
		--rightSam:setReferencePoint(display.TopLeftReferencePoint)
		self:insert(rightSam)
		self.rightSam = rightSam
		physics.addBody(rightSam, {
								bodyType="kinematic", 
								isSensor=true
								})
		

		leftShoulder.x = 4
		leftShoulder.y = 36

		leftShoulder:setReferencePoint(display.TopCenterReferencePoint)
		leftArm.x = leftShoulder.x + leftShoulder.width / 2 - 8
		leftArm.y = leftShoulder.y + 22

		local leftShoulderArmJoint = physics.newJoint("pivot", leftShoulder, leftArm, leftArm.x, leftShoulder.y + 9)
		leftShoulder.bodyType = "static"
		leftShoulder.isFixedRotation = true
		self.leftShoulderArmJoint = leftShoulderArmJoint

		leftShoulderArmJoint.isMotorEnabled = true
		leftShoulderArmJoint.maxMotorTorque = 1000000
		

		leftElbow.x = 2
		leftElbow.y = 66

		local leftElbowLeftArmJoint = physics.newJoint("pivot", leftElbow, leftArm, leftElbow.x, leftElbow.y)
		leftElbow.isFixedRotation = true
		self.leftElbowLeftArmJoint = leftElbowLeftArmJoint

		leftForearm.x = 2
		leftForearm.y = 80

		local leftForearmLeftElbowJoint = physics.newJoint("pivot", leftElbow, leftForearm, leftElbow.x, leftElbow.y)
		leftForearmLeftElbowJoint.isMotorEnabled = true
		leftForearmLeftElbowJoint.maxMotorTorque = 1000000
		
		self.leftForearmLeftElbowJoint = leftForearmLeftElbowJoint

		leftSam.x = 4
		leftSam.y = 80
		leftSam.isFixedRotation = true

		local leftSamLeftForearmJoint = physics.newJoint("pivot", leftSam, leftForearm, leftSam.x, leftSam.y + 12)
		self.leftSamLeftForearmJoint = leftSamLeftForearmJoint

		rightShoulder.x = 99
		rightShoulder.y = 36

		rightShoulder:setReferencePoint(display.TopCenterReferencePoint)
		rightArm.x = rightShoulder.x + rightShoulder.width / 2 - 8
		rightArm.y = rightShoulder.y + 22

		local rightShoulderArmJoint = physics.newJoint("pivot", rightShoulder, rightArm, rightArm.x, rightShoulder.y + 9)
		rightShoulder.bodyType = "static"
		rightShoulder.isFixedRotation = true
		self.rightShoulderArmJoint = rightShoulderArmJoint

		rightShoulderArmJoint.isMotorEnabled = true
		rightShoulderArmJoint.maxMotorTorque = 1000000
		
		rightElbow.x = 99
		rightElbow.y = 66

		local rightElbowRightArmJoint = physics.newJoint("pivot", rightElbow, rightArm, rightElbow.x, rightElbow.y)
		rightElbow.isFixedRotation = true
		self.rightElbowRightArmJoint = rightElbowRightArmJoint

		rightForearm.x = 99
		rightForearm.y = 80

		local rightForearmRightElbowJoint = physics.newJoint("pivot", rightElbow, rightForearm, rightElbow.x, rightElbow.y)
		rightForearmRightElbowJoint.isMotorEnabled = true
		rightForearmRightElbowJoint.maxMotorTorque = 1000000
		
		self.rightForearmRightElbowJoint = rightForearmRightElbowJoint

		rightSam.x = 98
		rightSam.y = 84
		rightSam.isFixedRotation = true

		local rightSamRightForearmJoint = physics.newJoint("pivot", rightSam, rightForearm, rightSam.x, rightSam.y + 12)
		self.rightSamRightForearmJoint = rightSamRightForearmJoint

		SoundManager.inst:playTankManAnnouncement()
		SoundManager.inst:playTankManEngineNormalSound({fadeIn = true})

		self.stateMachine = StateMachine:new(self)
		self.stateMachine:addState2(TankManNormalState:new())
		self.stateMachine:addState2(TankManDamagedState:new())
		self.stateMachine:addState2(TankManCrazyState:new())
		self.stateMachine:addState2(TankManDeadState:new())
		--self.stateMachine:setInitialState("normal")

		--gameLoop:addLoop(self)
	end

	--[[

		Nice closing:
			300.89660644531
			-601.33282470703
			-300.86679077148
			601.28704833984
	
		Spread:
			486.59646606445
			-971.09722900391
			-486.56121826172
			971.07885742188


	]]--


	function tank:startRotateToClosePosition()
		SoundManager.inst:playTankManArmsMove2Sound()

		self.rotatingFirePosition = true
		self.targetPosition = "close"
		self.leftShoulderArmJointTarget = 300
		self.leftForearmLeftElbowJointTarget = -600
		self.rightShoulderArmJointTarget = -300
		self.rightForearmRightElbowJointTarget = 600
		
		self.leftShoulderArmJoint.motorSpeed = self:getJointSpeedFromTarget(self.leftShoulderArmJoint, self.leftShoulderArmJointTarget) * 100
		self.leftForearmLeftElbowJoint.motorSpeed = self:getJointSpeedFromTarget(self.leftForearmLeftElbowJoint, self.leftForearmLeftElbowJointTarget) * 200
		self.rightShoulderArmJoint.motorSpeed = self:getJointSpeedFromTarget(self.rightShoulderArmJoint, self.rightShoulderArmJointTarget) * 100
		self.rightForearmRightElbowJoint.motorSpeed = self:getJointSpeedFromTarget(self.rightForearmRightElbowJoint, self.rightForearmRightElbowJointTarget) * 200 

		--print("self.leftForearmLeftElbowJoint.motorSpeed:", self.leftForearmLeftElbowJoint.motorSpeed)

	end
	
	function tank:stopRotateToClosePosition()
		self.rotatingFirePosition = true
	end

	function tank:getJointSpeedFromTarget(joint, target)
		local currentAngle = joint.jointAngle
		local currentTarget = target
		if currentAngle <= currentTarget then
			return 1
		else
			return -1
		end
	end


	function tank:startRotateToSpreadPosition()
		SoundManager.inst:playTankManArmsMove1Sound()

		self.rotatingFirePosition = true
		self.targetPosition = "spread"
		self.leftShoulderArmJointTarget = 486
		self.leftForearmLeftElbowJointTarget = -971
		self.rightShoulderArmJointTarget = -486
		self.rightForearmRightElbowJointTarget = 971

		self.leftShoulderArmJoint.motorSpeed = self:getJointSpeedFromTarget(self.leftShoulderArmJoint, self.leftShoulderArmJointTarget) * 100
		self.leftForearmLeftElbowJoint.motorSpeed = self:getJointSpeedFromTarget(self.leftForearmLeftElbowJoint, self.leftForearmLeftElbowJointTarget) * 200
		self.rightShoulderArmJoint.motorSpeed = self:getJointSpeedFromTarget(self.rightShoulderArmJoint, self.rightShoulderArmJointTarget) * 100
		self.rightForearmRightElbowJoint.motorSpeed = self:getJointSpeedFromTarget(self.rightForearmRightElbowJoint, self.rightForearmRightElbowJointTarget) * 200 

		--print("self.leftForearmLeftElbowJoint.motorSpeed:", self.leftForearmLeftElbowJoint.motorSpeed)

		
	end

	function tank:stopRotateToSpreadPosition()
		self.rotatingFirePosition = true
	end

	

	function tank:startSpinSAMS()
		--[[
		print("****************")
		print(self.leftShoulderArmJoint.jointAngle)
		print(self.leftForearmLeftElbowJoint.jointAngle)
		print(self.rightShoulderArmJoint.jointAngle)
		print(self.rightForearmRightElbowJoint.jointAngle)
		]]--

		self.rotatingFirePosition = false
		self.leftShoulderArmJoint.motorSpeed = 100
		self.leftForearmLeftElbowJoint.motorSpeed = -200
		self.rightShoulderArmJoint.motorSpeed = -100
		self.rightForearmRightElbowJoint.motorSpeed = 200

	end

	function tank:stopSpinSAMS()
		--[[
		print("****************")
		print(self.leftShoulderArmJoint.jointAngle)
		print(self.leftForearmLeftElbowJoint.jointAngle)
		print(self.rightShoulderArmJoint.jointAngle)
		print(self.rightForearmRightElbowJoint.jointAngle)
		]]--

		self.leftShoulderArmJoint.motorSpeed = 0
		self.leftForearmLeftElbowJoint.motorSpeed = 0
		self.rightShoulderArmJoint.motorSpeed = 0
		self.rightForearmRightElbowJoint.motorSpeed = 0
		
	end

	function tank:startSuperSpinSams()
		self.rotatingFirePosition = false
		self.leftForearmLeftElbowJoint.motorSpeed = -500
		self.rightForearmRightElbowJoint.motorSpeed = 500
	end

	function tank:stopSuperSpinSams()
		self.leftForearmLeftElbowJoint.motorSpeed = 0
		self.rightForearmRightElbowJoint.motorSpeed = 0
	end


	function tank:samsWide()
		self.leftSam.x = -40
		self.leftSam.y = -200

		self.rightSam.x = 120
		self.rightSam.y = self.leftSam.y
	end



	function tank:makePart(name, image)
		local part = display.newImage(image)
		--part:setReferencePoint(display.TopLeftReferencePoint)
		self:insert(part)
		physics.addBody(part, {
								bodyType="kinematic", 
								isSensor=true
								})
		self[name] = part
		return part
	end

	function tank:destroy()
		tank:stopRotateToClosePosition()
		tank:stopRotateToSpreadPosition()
		tank:stopSpinSAMS()
		tank:stopSuperSpinSams()
		tank:stopFiringMissiles()
		tank:stopFiringFlak()

		tank.stateMachine:destroy()
		tank.stateMachine = nil

		gameLoop:removeLoop(self)
		self:removeEventListener("collision", self)

		SoundManager.inst:stopTankManEngineDamagedSound()
		SoundManager.inst:stopTankManEngineNormalSound()

		local t = function()
			local self = tank

			self.leftShoulderArmJoint:removeSelf()
			self.leftElbowLeftArmJoint:removeSelf()
			self.leftForearmLeftElbowJoint:removeSelf()
			self.leftSamLeftForearmJoint:removeSelf()
			self.rightShoulderArmJoint:removeSelf()
			self.rightElbowRightArmJoint:removeSelf()
			self.rightForearmRightElbowJoint:removeSelf()
			self.rightSamRightForearmJoint:removeSelf()

			physics.addBody(self.rightSam)
			physics.addBody(self.leftSam)
			physics.addBody(self.leftElbow)
			physics.addBody(self.rightElbow)
			physics.addBody(self.leftForearm)
			physics.addBody(self.rightForearm)
			physics.addBody(self.rightShoulder)
			physics.addBody(self.leftShoulder)
			physics.addBody(self.leftArm)
			physics.addBody(self.rightArm)
			physics.addBody(self.background)
			physics.addBody(self.flakGunRight)
			physics.addBody(self.flakGunLeft)

			self.rightSam:removeSelf()
			self.leftSam:removeSelf()
			self.leftElbow:removeSelf()
			self.rightElbow:removeSelf()
			self.rightForearm:removeSelf()
			self.leftForearm:removeSelf()
			self.rightShoulder:removeSelf()
			self.leftShoulder:removeSelf()
			self.leftArm:removeSelf()
			self.rightArm:removeSelf()
			self.background:removeSelf()
			self.flakGunRight:removeSelf()
			self.flakGunLeft:removeSelf()

			self:removeSelf()
		end
		timer.performWithDelay(100, t)
	end

	function tank:collision(event)
		SoundManager.inst:playTankManHitSound()
		if(event.other.name == "Bullet") then
			event.other:destroy()
			self:setHitPoints(self.hitPoints - 1)
		elseif(event.other.name == "Player") then
			event.other:onBulletHit()
		end
		Runtime:dispatchEvent({name="onShowFloatingText", 
								x=self.x, y=self.y, target=self, amount=100})
		self:destroy()
	end
	
	function tank:startFiringMissiles()
		self.firingMissiles = true
		self.startFireMissileTime = 0
		self.currentMissile = 0
	end

	function tank:stopFiringMissiles()
		self.firingMissiles = false
	end

	function tank:stopMotorIfAroundTargetAngle(joint, target)
		local currentAngle = math.abs(math.round(joint.jointAngle))
		target = math.abs(math.round(target))
		if self.lastDiff == nil then
			self.lastDiff = {}
		end
		--if self.lastDiff
		if currentAngle == target then
			joint.motorSpeed = 0
		elseif math.abs(currentAngle - target) <= 12 then
			joint.motorSpeed = 0
		end
	end

	function tank:tick(milliseconds)
		self.stateMachine:tick(milliseconds)
		if self.rotatingFirePosition == true then
			--print("------")
			--print(self.leftShoulderArmJoint.jointAngle, ", ", self.leftShoulderArmJoint.jointAngle / 360)
			--print(self.leftForearmLeftElbowJoint.jointAngle, ", ", self.leftForearmLeftElbowJoint.jointAngle / 360)
			self:stopMotorIfAroundTargetAngle(self.leftShoulderArmJoint, self.leftShoulderArmJointTarget)
			self:stopMotorIfAroundTargetAngle(self.leftForearmLeftElbowJoint, self.leftForearmLeftElbowJointTarget)
			self:stopMotorIfAroundTargetAngle(self.rightShoulderArmJoint, self.rightShoulderArmJointTarget)
			self:stopMotorIfAroundTargetAngle(self.rightForearmRightElbowJoint, self.rightForearmRightElbowJointTarget)

			local uno = self.leftShoulderArmJoint.motorSpeed
			local dos = self.leftForearmLeftElbowJoint.motorSpeed
			local tres = self.rightShoulderArmJoint.motorSpeed
			local quatro = self.rightForearmRightElbowJoint.motorSpeed
			if uno == 0 and dos == 0 and tres == 0 and quatro == 0 then
				self:dispatchEvent({name="onReachedFirePosition", target=self})
				self.rotatingFirePosition = false
			end

		end

		if self.firingMissiles == true then
			self.startFireMissileTime = self.startFireMissileTime + milliseconds
			if self.startFireMissileTime >= self.MISSILE_FIRE_TIME then
				self:fireMissile()
				self.startFireMissileTime = 0
			end
		end

		if self.firingFlak == true then
			self.startFireFlakTime = self.startFireFlakTime + milliseconds
			if self.startFireFlakTime >= self.FLAK_FIRE_TIME then
				self:fireFlak()
				self.startFireFlakTime = 0
			end
		end
	end

	function tank:fireMissile()
		--local missile1 = EnemyMissile:new(self.leftSam.x, self.leftSam.y)
		--local missile2 = EnemyMissile:new(self.rightSam.x, self.rightSam.y)
		if self.currentMissile + 1 <= self.missileVolleyAmount then
			self.currentMissile = self.currentMissile + 1
			local targetX, targetY
			if self.fireMissileSide == "left" then
				self.fireMissileSide = "right"
				targetX = self.leftSam.x
				targetY = self.leftSam.y
				targetX, targetY = self:localToContent(targetX, targetY)
			else
				self.fireMissileSide = "left"
				targetX = self.rightSam.x
				targetY = self.rightSam.y
				targetX, targetY = self:localToContent(targetX, targetY)
			end

			local missile = EnemyMissile:new(targetX, targetY)
			missile.speed = constants.ENEMY_MISSLE_TANK_MAN_MISSLE_SPEED
		else
			self:stopFiringMissiles()
			self:dispatchEvent({name="onFireMissilesCompleted", target=self})
		end
	end

	function tank:startFiringFlak()
		self.firingFlak = true
		self:resetFlakFiring()
	end

	function tank:resetFlakFiring()
		self.startFireFlakTime = 0
		self.currentFlakPoint = 0
		if self.currentFlakPattern == nil or self.currentFlakPattern == self.flakFirePatternBeta then
			self.currentFlakPattern = self.flakFirePatternAlpha
		else
			self.currentFlakPattern = self.flakFirePatternBeta
		end
	end

	function tank:stopFiringFlak()
		self.firingFlak = false
	end

	function tank:fireFlak()
		local points = self.currentFlakPattern
		if self.currentFlakPoint + 1 <= #points then
			self.currentFlakPoint = self.currentFlakPoint + 1
			local point = points[self.currentFlakPoint]
			SoundManager.inst:playTankManFlakSound()
			local flak = Flak:new()
			mainGroup:insert(flak)
			flak.x = point[1]
			flak.y = point[2]
		else
			self:stopFiringFlak()
			self:dispatchEvent({name="onFireFlakCompleted", target=self})
		end
	end

	function tank:setHitPoints(value)
		local oldValue = self.hitPoints
		self.hitPoints = value
		local background = self.background
		
		if self.hitPoints <= 0 then
			self.hitPoints = 0
			self:destroy()
			return true
		end
		
		if self.hitPoints <= 50 and oldValue > 50 then
			SoundManager.inst:stopTankManEngineNormalSound()
			SoundManager.inst:playTankManEngineDamagedSound()
		end

		if self.hitPoints > 120 then
			if background.sequence ~= "tankManNormal" then
				background:prepare("tankManNormal")
				background:play()
			end
		elseif self.hitPoints <= 120 and self.hitPoints > 60 then
			if background.sequence ~= "tankManDamagedLight" then
				background:prepare("tankManDamagedLight")
				background:play()
			end
		else
			if background.sequence ~= "tankManDamagedHeavy" then
				background:prepare("tankManDamagedHeavy")
				background:play()
			end
		end
	end

	function tank:setLeftTurretHitPoints(value)
		local leftSam = self.leftSam
		local oldValue = hitPoints
		self.leftTurretHitPoints = value
		local hitPoints = self.leftTurretHitPoints
		
		if hitPoints <= 0 then
			if leftSam.sequence ~= "tankManLeftTurretDamagedHeavy" then
				leftSam:prepare("tankManLeftTurretDamagedHeavy")
				leftSam:play()
			end
			self.leftTurretHitPoints = 0
			self:destroyLeftTurret()
			return true
		end
		
		if hitPoints <= 30 and hitPoints > 0 then
			if leftSam.sequence ~= "tankManLeftTurretDamagedLight" then
				leftSam:prepare("tankManLeftTurretDamagedLight")
				leftSam:play()
			end
		end
	end

	function tank:setRightTurretHitPoints(value)
		local rightSam = self.rightSam
		local oldValue = hitPoints
		self.rightTurretHitPoints = value
		local hitPoints = self.rightTurretHitPoints
		
		if hitPoints <= 0 then
			if rightSam.sequence ~= "tankManRightTurretDamagedHeavy" then
				rightSam:prepare("tankManRightTurretDamagedHeavy")
				rightSam:play()
			end
			self.rightTurretHitPoints = 0
			self:destroyLeftTurret()
			return true
		end
		
		if hitPoints <= 30 and hitPoints > 0 then
			if rightSam.sequence ~= "tankManRightTurretDamagedLight" then
				rightSam:prepare("tankManRightTurretDamagedLight")
				rightSam:play()
			end
		end
	end

	tank:init()

	return tank

end

return TankMan