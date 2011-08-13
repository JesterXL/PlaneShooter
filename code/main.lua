require "sprite"
require "physics"
require "constants"
require "ScrollingTerrain"
require "player_Player"
require "player_PlayerBulletSingle"
require "player_PlayerRailGun"
require "enemies_EnemySmallShip"
require "enemies_EnemySmallShipDeath"
require "enemies_EnemyBulletSingle"
require "gamegui_HealthBar"
require "enemies_BossBigPlane"
require "enemies_EnemyMissileJet"
require "enemies_EnemyMissile"

require "gamegui_animations_HeadNormalAnime"
require "gamegui_buttons_PauseButton"


local function initSounds()
	planeShootSound = audio.loadSound("plane_shoot.wav")

end

function addLoop(o)
	assert(o ~= nil, "You cannot pass nil values to the game loop")
	local index = table.indexOf(tickers, o)
	if(index == nil) then
		return table.insert(tickers, o)
	else
		error(o .. " is already added to the game loop.")
	end
end

function removeLoop(o)
	print("removeLoop")
	for i,v in ipairs(tickers) do
		if(v == o) then
			table.remove(tickers, i)
			return true
		end	
	end
	print("!! item not found !!")
	return false
end

function onRemoveFromGameLoop(event)
	event.target:removeEventListener("removeFromGameLoop", onRemoveFromGameLoop)
	removeLoop(event.target)
end

function animate(event)
	local now = system.getTimer()
	local difference = now - lastTick
	lastTick = now
	
	for i,v in ipairs(tickers) do
		--[[
		if(v.y == nil) then
			print("v: ", v)
			print("v.ID: ", v.ID)
			error("zomg")
			return
		end
		--]]
		v:tick(difference)
	end
end

function startScrollingTerrain()
	--addLoop(terrainScroller)
end

function stopScrollingTerrain()
	--removeLoop(terrainScroller)
end

function addPowerUp()
	setPowerUpLevel(powerUpLevel + 1)
end

function removePowerUp()
	if(powerUpLevel > 1) then
		setPowerUpLevel(powerUpLevel - 1)
	end
end

local function startFiringBullets()
	addLoop(bulletRegulator)
	bulletRegulator:tick(333)
end

local function stopFiringBullets()
	removeLoop(bulletRegulator)
end

function onTouch(event)
	if(event.phase == "began") then
		startFiringBullets()
		if(bulletRegulator.fireFunc ~= createRailGun) then
			if(planeShootSoundChannel == nil) then
				planeShootSoundChannel = audio.play(planeShootSound, {loops=-1, fadein=100})
			else
				audio.play(planeShootSound, {channel=planeShootSoundChannel, loops=-1, fadein=100})
			end
		end
	end
	
	if(event.phase == "began" or event.phase == "moved") then
		player.planeXTarget = event.x
		player.planeYTarget = event.y
	end
	
	if(event.phase == "ended" or event.phase == "cancelled") then
		stopPlayerInteraction()
	end
end

function stopPlayerInteraction()
	stopFiringBullets()
	--audio.fadeOut({channel=1, time=100})
	audio.pause(planeShootSoundChannel)
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

function onCreateEnemyBullet(event)
	local bullet = EnemyBulletSingle:new(event.target.x, event.target.y, player)
	mainGroup:insert(bullet)
	bullet:addEventListener("removeFromGameLoop", onRemoveFromGameLoop)
	addLoop(bullet)
end

function onFireZeeMissile(event)
	local missile = EnemyMissile:new(event.target.x, event.target.y, player)
	mainGroup:insert(missile)
	missile:addEventListener("removeFromGameLoop", onRemoveFromGameLoop)
	addLoop(missile)
end

function createBullet1()
	local bullet = PlayerBulletSingle:new(player.x, player.y)
	mainGroup:insert(bullet)
	bullet:addEventListener("removeFromGameLoop", onRemoveFromGameLoop)
	addLoop(bullet)
end

function createRailGun()
	if(rail == nil) then
		rail = PlayerRailGun:new(player.x, player.y)
		rail:addEventListener("animeFinished", onRailGunComplete)
		mainGroup:insert(rail)
	end
end

function onRailGunComplete(event)
	rail:removeEventListener("animeFinished", onRailGunComplete)
	rail = nil
end

function createBullet2()
	
end

function createBullet3()
	
end

function setPowerUpLevel(level)
	if(level > 3) then
		level = 3
	end
	
	powerUpLevel = level
	if(powerUpLevel <= 3) then
		PLAYER_BULLET_SPEED = 10
		--PLAYER_MOVE_SPEED = 7
		--player.speed = constants.PLAYER_MOVE_SPEED
	end
	

	if(powerUpLevel == 1) then
		bulletRegulator.fireFunc = createBullet1
	elseif(powerUpLevel == 2) then
		bulletRegulator.fireFunc = createBullet2
	elseif(powerUpLevel == 3) then
		bulletRegulator.fireFunc = createBullet3
	end

		--bulletRegulator.fireFunc = createRailGun
	
	
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
		removeLoop(gameTicker)
		gameTimer = nil
		local delayTable = {}
		function delayTable:timer(event)
		   createBoss()
        end
        timer.performWithDelay(200, delayTable)
	end
end

function createBoss()
	local boss = BossBigPlane:new(player)
	boss:addEventListener("removeFromGameLoop", onBossDead)
	boss:addEventListener("fireShots", onFireBossShots)
	mainGroup:insert(boss)
	addLoop(boss)
end

function onFireBossShots(event)
	for i,point in ipairs(event.points) do
		local bullet = EnemyBulletSingle:new(point.x, point.y, player)
		mainGroup:insert(bullet)
		bullet:addEventListener("removeFromGameLoop", onRemoveFromGameLoop)
		addLoop(bullet)
	end
end

function onBossDead(event)
	local boss = event.target
	boss:removeEventListener("removeFromGameLoop", onBossDead)
	boss:removeEventListener("fireShots", onFireBossShots)
	removeLoop(boss)
	-- TODO: use correct animation, sucka! In fact, make an epic one!
	local death = EnemySmallShipDeath:new(boss.x, boss.y)
	mainGroup:insert(death)
end

function initKeys()

	local function onKeyEvent( event )
	        local phase = event.phase
	        local keyName = event.keyName
	        print("phase: ", phase, ", keyName: ", keyName)

	        -- we handled the event, so return true.
	        -- for default behavior, return false.
	        return true
	end

	-- Add the key callback
	Runtime:addEventListener( "key", onKeyEvent );
		
end


function startGame()
	gamePaused = false
	Runtime:addEventListener("enterFrame", animate )
	Runtime:addEventListener("touch", onTouch)
	if(gameTicker == nil) then
		gameTicker = {}
		gameTicker.milliseconds = 0
		gameTicker.counter = 0
		function gameTicker:tick(millisecondsPassed)
			
			gameTicker.milliseconds = gameTicker.milliseconds + millisecondsPassed
			if(gameTicker.milliseconds < 500) then
				return
			else
				-- TODO/FIXME: I'm tired, fix this
				gameTicker.milliseconds = 0
			end
			gameTicker.counter = gameTicker.counter + 1
			--event.time
			-- timer.cancel( event.source ) 
			local randomX = stage.width * math.random()
			if(randomX < 20) then
				randomX = 20
			end
		
			if(randomX > stage.width - 20) then
				randomX = stage.width - 20
			end

			local enemy
			if(self.counter == 3 or self.counter == 5 or self.counter == 7 or self.counter == 9) then
				enemy = EnemyMissileJet:new(randomX, 0, stage.height)
				enemy:addEventListener("fireZeeMissile", onFireZeeMissile)
			else
				enemy = EnemySmallShip:new(randomX, 0, stage.height)
				enemy:addEventListener("createEnemyBullet", onCreateEnemyBullet)
			end

			function onDead(event)
				assert(removeLoop(event.target), "Failed to remove enemy plane from game loop.")
				if(event.target.classType ~= nil and event.target.classType == "enemies.EnemyMissleJet") then
					enemy:removeEventListener("fireZeeMissile", onFireZeeMissile)
				elseif(event.target.classType ~= nil and event.target.classType == "enemies.EnemySmallShip") then
					enemy:removeEventListener("createEnemyBullet", onCreateEnemyBullet)
				end

				local shipDeath = EnemySmallShipDeath:new(event.target.x, event.target.y)
				mainGroup:insert(shipDeath)
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
						-- TODO: re-implement
					    --createPowerUp(self.x, self.y)
			        end
			        timer.performWithDelay(200, delayTable)
				end
			end
			enemy:addEventListener("enemyDead", onDead)
			mainGroup:insert(enemy)
			addLoop(enemy)
		end
	end
	
	addLoop(gameTicker)
		
	
	startScrollingTerrain()
end

function pauseGame()
	gamePaused = true
	Runtime:removeEventListener("enterFrame", animate )
	Runtime:removeEventListener("touch", onTouch)
end

function unpauseGame()
	gamePaused = false
	Runtime:addEventListener("enterFrame", animate )
	Runtime:addEventListener("touch", onTouch)
end

function togglePause()
	if(gamePaused == true) then
		unpauseGame()
	else
		pauseGame()
	end
end



function initializeGame()
	
	physics.start()
	--physics.setDrawMode( "hybrid" )
	physics.setGravity( 0, 0 )
	
	context = require("MainContext").new()
	context:init()
	
	mainGroup 						= display.newGroup()

	tickers 						= {}
	powerUpLevel 					= 1
	enemies 						= 10
	fightingBoss 					= false
	powerCount 						= 3
	POWER_MAX_COUNT 				= 3

	bullets 						= 0
	bulletRegulator 				= {} -- Mount up!
	bulletRegulator.fireSpeed 		= 400
	bulletRegulator.lastFire 		= 0
	bulletRegulator.fireFunc 		= nil
	
	function bulletRegulator:tick(millisecondsPassed)
		self.lastFire = self.lastFire + millisecondsPassed
		if(self.lastFire >= self.fireSpeed) then
			self.fireFunc(player.x, player.y)
			self.lastFire = 0
		end
	end


	stage = display.getCurrentStage()
	
	--initTerrain()
	--initEnemeyDeath()
	healthBar = HealthBar:new()
	context:createMediator(healthBar)
	initSounds()
	--initPlayerDeath()
	
	player = Player.new()
	mainGroup:insert(player)
	context:createMediator(player)
	--plane:addEventListener("hitPointsChanged", )

	setPowerUpLevel(powerUpLevel)

	lastTick = system.getTimer()

	addLoop(player)

	player.planeXTarget = stage.width / 2
	player.planeYTarget = stage.height / 2
	player:move(player.planeXTarget, player.planeYTarget)
	--[[
	
	headAnime = HeadNormalAnime:new(4, stage.height - 104)
	mainGroup:insert(headAnime)
	--]]
	
	local pauseButton = PauseButton:new(4, stage.height - 40)
	pauseButton:addEventListener("touch", onPauseTouch)
	
	initKeys()
	
	startGame()
end

function onPauseTouch(event)
	if(event.phase == "began") then
		togglePause()
		return true
	end
end

function onKeyEvent( event )
	if(event.keyName == "menu") then
		if(gamePaused == true) then
			unpauseGame()
		else
			pauseGame()
		end
	end
end
 
-- Add the key callback
Runtime:addEventListener( "key", onKeyEvent );

initializeGame()


