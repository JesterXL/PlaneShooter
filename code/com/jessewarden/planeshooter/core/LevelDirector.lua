LevelDirector = {}

function LevelDirector:new(level, player, mainGroup, gameLoop)

	assert(level ~= nil, "level cannot be nil")
	assert(player ~= nil, "player cannot be nil")
	assert(mainGroup ~= nil, "mainGroup cannot be nil")
	assert(gameLoop ~= nil, "gameLoop cannot be nil")

	-- TODO: make just a table, making group now so I can use events w/o using MessageBus
	--local director = {}
	local director = display.newGroup()

	director.level = level
	director.player = player
	director.mainGroup = mainGroup
	director.gameLoop = gameLoop

	director.classType = "LevelDirector"
	director.oldEvents = nil
	director.milliseconds = nil
	director.stage = display.getCurrentStage()
	director.currentEvent = nil
	director.powerCount = nil
	director.powerCountMax = nil
	director.initialized = false
	director.paused = true

	local delayTable = {}
	director.delayTable = delayTable -- used for adding to physics engine later to avoid bug (adding objects during collision == crash)

	function delayTable:timer(event)
		-- TODO: re-implement
		timer.cancel(self.timerHandle)
		--createPowerUp(self.x, self.y)
	end

	function director:initialize()

		local oldEvents = self.oldEvents
		local events = self.level.events
		if oldEvents ~= nil then
			local i = #oldEvents
			while oldEvents[i] do
				local event = oldEvents[i]
				table.remove(oldEvents, i)
				table.insert(events, event)
				i = i - 1
			end
		end

		self.milliseconds = 0
		self.powerCount = 0
		self.powerCountMax = constants.POWER_UP_COUNT_MAX
		self.oldEvents = {}
		self.initialized = true
	end

	function director:start()
		if self.paused == true then
			self.paused = false
			self.gameLoop:addLoop(self)
		end
	end

	function director:pause()
		if self.paused == false then
			self.paused = true
			self.gameLoop:removeLoop(self)
		end
	end

	function director:tick(millisecondsPassed)
		if self.paused == true then
			return true
		end
		
		self.milliseconds = self.milliseconds + millisecondsPassed
		local progress = self.milliseconds / (self.level.totalTime * 1000)
		self:dispatchEvent({name="onLevelProgress", target=self, progress=progress})
		
		local events = self.level.events
		local index = #events
		local seconds = self.milliseconds / 1000
		--print("index: ", index, ", index2: ", index2)
		
		if seconds >= self.level.totalTime and index == 0 then
			print("DONE")
			self:pause()
			self:dispatchEvent({name="onLevelComplete", target=self})
			return true
		end
		
		
		local oldEvents = self.oldEvents
		local milliseconds = self.milliseconds
		local i = 1
		while events[i] do
			local event = events[i]
			--print("\tseconds: ", seconds, ", when: ", event.when, ", type: ", event.classType)
			if event.when <= seconds then
				table.remove(events, i)
				table.insert(oldEvents, event)
				
				print("event.pause: ", event.pause)
				if event.pause == true then
					self:pause()
				end
				
				if event.classType == "enemy" then
					self:processEnemey(event)
				elseif event.classType == "movie" then
					self:processMovie(event)
					return true
				end
			end
			i = i + 1
		end
	end

	function director:processMovie(movie)
		print("LevelDirector::processMovie")
		self:pause()
		self:dispatchEvent({name="onMovie", target=self, movie=movie})
	end

	function director:processEnemey(event)
		print("LevelDirector::processEnemy")
		local stage = director.stage

		local randomX = stage.width * math.random()
		if(randomX < 20) then
			randomX = 20
		end

		if(randomX > stage.width - 20) then
			randomX = stage.width - 20
		end

		local enemyType = event.type
		local enemy
		local player = director.player
		print("enemyType: ", enemyType)
		if enemyType == "Plane" then
			enemy = EnemySmallShip:new(randomX, -10, stage.height)
			enemy:addEventListener("createEnemyBullet", self)
		elseif enemyType == "Missile" then
			enemy = EnemyMissile:new(randomX, -10, player)
			enemy:addEventListener("fireZeeMissile", self)
		elseif enemyType == "Jet" then
			enemy = EnemyMissileJet:new(randomX, -10, stage.height)
		elseif enemyType == "Bomber" then
			print("creating big bomber boss")
			enemy = BossBigPlane:new(player)
			enemy:addEventListener("fireShots", onFireBossShots)
		elseif enemyType == "UFO" then
			return true
		end

		enemy.levelDirectorEvent = event
		enemy:addEventListener("enemyDead", self)
		self.mainGroup:insert(enemy)
		self.gameLoop:addLoop(enemy)
	end
	
	function onFireBossShots(event)
		local self = director
		local i = 1
		local points = event.points
		while points[i] do
			local point = event.points[i]
			local bullet = EnemyBulletSingle:new(point.x, point.y, player)
			self.mainGroup:insert(bullet)
			bullet:addEventListener("removeFromGameLoop", self)
			self.gameLoop:addLoop(bullet)
			i = i + 1
		end
	end

	function director:enemyDead(event)
		-- TODO: use a Command/Controller you bad developer you
		PlayerModel.instance:addToScore(100)

		local enemy = event.target
		if(enemy.classType ~= nil and enemy.classType == "enemies_EnemyMissleJet") then
			enemy:removeEventListener("fireZeeMissile", self)
		elseif(enemy.classType ~= nil and enemy.classType == "enemies_EnemySmallShip") then
			enemy:removeEventListener("createEnemyBullet", self)
			local smallShipDeath = EnemySmallShipDeath:new(enemy.x, enemy.y)
			director.mainGroup:insert(smallShipDeath)
		elseif(enemy.classType ~= nil and enemy.classType == "BossBigPlane") then
			AchievementsProxy:unlock(constants.achievements.verteranPilot)
		end
		
		if enemy.levelDirectorEvent.pause == true then
			enemy.levelDirectorEvent = nil
			self:start()
		end
		
		assert(director.gameLoop:removeLoop(enemy), "Failed to remove enemy from game loop.")

		self.powerCount = self.powerCount + 1
		if self.powerCount >= self.powerCountMax then
			self.powerCount = 0
			-- NOTE: You have to set a delay; adding physics bodies during a collision event (within the stack)
			-- will cause a hard crash
			local delayTable = director.delayTable
			delayTable.x = enemy.x
			delayTable.y = enemy.y
			if delayTable.timerHandle then timer.cancel(delayTable.timerHandle) end
			delayTable.timerHandle = timer.performWithDelay(200, delayTable)
		end
	end

	function director:removeFromGameLoop(event)
		self.gameLoop:removeLoop(event.target)
	end

	function director:createEnemyBullet(event)
		local bullet = EnemyBulletSingle:new(event.target.x, event.target.y, self.player)
		self.mainGroup:insert(bullet)
		bullet:addEventListener("removeFromGameLoop", self)
		self.gameLoop:addLoop(bullet)
	end

	function director:fireZeeMissile(event)
		local missile = EnemyMissile:new(event.target.x, event.target.y, self.player)
		self.mainGroup:insert(missile)
		missile:addEventListener("removeFromGameLoop", self)
		self.gameLoop:addLoop(missile)
	end

	return director

end

return LevelDirector
