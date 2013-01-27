require "com.jessewarden.planeshooter.sprites.enemies.EnemyMissile"
require "com.jessewarden.planeshooter.sprites.enemies.Flak"
require "com.jessewarden.planeshooter.core.constants"

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
	tank.leftShoulderArmJointTarget = nil
	tank.leftForearmLeftElbowJointTarget = nil
	tank.rightShoulderArmJointTarget = nil
	tank.rightForearmRightElbowJointTarget = nil
	tank.lastDiff = nil 

	tank.hitPoints = 200

	function tank:init()

		if TankMan.spriteSheet == nil then
			local spriteSheet = sprite.newSpriteSheet("tank_man_sheet.png", 248, 163)
			local spriteSet = sprite.newSpriteSet(spriteSheet, 1, 1)
			sprite.add(spriteSet, "tankman", 1, 1, 500, 0)
			TankMan.spriteSheet = spriteSheet
			TankMan.spriteSet = spriteSet
		end

		local flakGunLeft = self:makePart("flakGunLeft", "images/sprites/tank_man/tank_man_flak_left.png")
		local flakGunRight = self:makePart("flakGunLeft", "images/sprites/tank_man/tank_man_flak_right.png")
		local background = self:makePart("background", "images/sprites/tank_man/tank_man_background.png")
		background.isFixedRotation = true
		local window = self:makePart("window", "images/sprites/tank_man/tank_man_window.png")
		local leftArm = self:makePart("leftArm", "images/sprites/tank_man/tank_man_left_arm.png")
		local rightArm = self:makePart("rightArm", "images/sprites/tank_man/tank_man_right_arm.png")
		local leftShoulder = self:makePart("leftShoulder", "images/sprites/tank_man/tank_man_left_shoulder.png")
		local rightShoulder = self:makePart("rightShoulder", "images/sprites/tank_man/tank_man_right_shoulder.png")
		local leftForearm = self:makePart("leftForearm", "images/sprites/tank_man/tank_man_left_forearm.png")
		local rightForearm = self:makePart("rightForearm", "images/sprites/tank_man/tank_man_right_forearm.png")
		local rightElbow = self:makePart("rightElbow", "images/sprites/tank_man/tank_man_right_elbow.png")
		local leftElbow = self:makePart("leftElbow", "images/sprites/tank_man/tank_man_left_elbow.png")
		local leftSam = self:makePart("leftSam", "images/sprites/tank_man/tank_man_left_sam.png")
		local rightSam = self:makePart("rightSam", "images/sprites/tank_man/tank_man_right_sam.png")
		

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

		leftSam.x = 2
		leftSam.y = 90
		leftSam.isFixedRotation = true

		local leftSamLeftForearmJoint = physics.newJoint("pivot", leftSam, leftForearm, leftSam.x, leftSam.y)
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

		rightSam.x = 99
		rightSam.y = 90
		rightSam.isFixedRotation = true

		local rightSamRightForearmJoint = physics.newJoint("pivot", rightSam, rightForearm, rightSam.x, rightSam.y)
		self.rightSamRightForearmJoint = rightSamRightForearmJoint

		window.x = 51
		window.y = 40

		gameLoop:addLoop(self)
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
		self.rotatingFirePosition = true
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
		self.rotatingFirePosition = true
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
		gameLoop:removeLoop(self)
		self:removeEventListener("collision", self)
		self:removeSelf()
	end

	function tank:collision(event)
		if(event.other.name == "Bullet") then
			event.other:destroy()
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

		if self.rotatingFirePosition == true then
			print("------")
			print(self.leftShoulderArmJoint.jointAngle, ", ", self.leftShoulderArmJoint.jointAngle / 360)
			print(self.leftForearmLeftElbowJoint.jointAngle, ", ", self.leftForearmLeftElbowJoint.jointAngle / 360)
			self:stopMotorIfAroundTargetAngle(self.leftShoulderArmJoint, self.leftShoulderArmJointTarget)
			self:stopMotorIfAroundTargetAngle(self.leftForearmLeftElbowJoint, self.leftForearmLeftElbowJointTarget)
			self:stopMotorIfAroundTargetAngle(self.rightShoulderArmJoint, self.rightShoulderArmJointTarget)
			self:stopMotorIfAroundTargetAngle(self.rightForearmRightElbowJoint, self.rightForearmRightElbowJointTarget)

			local uno = self.leftShoulderArmJoint.motorSpeed
			local dos = self.leftForearmLeftElbowJoint.motorSpeed
			local tres = self.rightShoulderArmJoint.motorSpeed
			local quatro = self.rightForearmRightElbowJoint.motorSpeed
			if uno == 0 and dos == 0 and tres == 0 and quatro == 0 then
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
			self:dispatchEvent({name="onFireMissilesCompleted", target=self})
			self:stopFiringMissiles()
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
			local flak = Flak:new()
			mainGroup:insert(flak)
			flak.x = point[1]
			flak.y = point[2]
		else
			self:dispatchEvent({name="onFireFlakCompleted", target=self})
			self:stopFiringFlak()
		end
	end

	tank:init()

	return tank

end

return TankMan