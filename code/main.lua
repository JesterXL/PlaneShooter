require "sprite"
require "physics"
require "gameNetwork"

require "com.jessewarden.planeshooter.core.GameLoop"

function showProps(o)
	print("-- showProps --")
	print("o: ", o)
	for key,value in pairs(o) do
		print("key: ", key, ", value: ", value);
	end
	print("-- end showProps --")
end

local function setupGlobals()
	_G.gameLoop = GameLoop:new()
	gameLoop:start()

	_G.mainGroup = display.newGroup()
	mainGroup.name = "mainGroup"
	mainGroup.classType = "mainGroup"
	_G.setMainGroup = function(newGroup)
		_G.mainGroup = newGroup
	end
	_G.playerView = {x = 100, y = 400}
	_G.stage = display.getCurrentStage()
end


local function initSounds()
--	planeShootSound = {}
	audio.reserveChannels(2)
	planeShootSound = audio.loadSound("plane_shoot.mp3")
	planeShootSoundChannel = 1
	audio.setVolume(.1, {channel=planeShootSoundChannel})
end

function startScrollingTerrain()
	--addLoop(terrainScroller)

end

function stopScrollingTerrain()
	--removeLoop(terrainScroller)
	return 1, 2, 3
end

function showMenu()
	gameNetwork.show()
end

function onTouch(event)
	--print("onTouch, event.phase: ", event.phase)
	local handled = false
	if(event.phase == "began" or event.phase == "moved") then
		player:setDestination(event.x, event.y - 40)
		AchievementsProxy:unlock(constants.achievements.liftOff)
		handled = true
	end

	if(event.phase == "began") then
		playerWeapons.enabled = true
		audio.play(planeShootSound, {channel=planeShootSoundChannel, loops=-1})
		handled = true
	end

	if(event.phase == "ended" or event.phase == "cancelled") then
		playerWeapons.enabled = false
		if planeShootSoundChannel ~= nil then
			audio.stop(planeShootSoundChannel)
		end
		handled = true
	end
	
	return handled
end

function startBossFight()
	if(fightingBoss == false) then
		fightingBoss = true
		local delayTable = {}
		function delayTable:timer(event)
		   createBoss()
        end
        timer.performWithDelay(200, delayTable)
	end
end

function initKeys()

	local function onKeyEvent( event )
		Runtime:removeEventListener( "key", onKeyEvent );
		showMenu()
		return true
	end

	Runtime:addEventListener( "key", onKeyEvent );
end


function startGame()
	-- TOOD: use director, pause it
	gameLoop:reset()
	gameLoop:start()
	Runtime:addEventListener("touch", onTouch)
	startScrollingTerrain()
	levelDirector:start()
end

function stopGame()
	gameLoop:pause()
	Runtime:removeEventListener("touch", onTouch)
	stopScrollingTerrain()
	levelDirector:pause()
	playerWeapons.enabled = false
	if planeShootSoundChannel ~= nil then
		audio.stop(planeShootSoundChannel)
	end
end

function onMovieStarted(event)
	pauseGame()
	moviePlayer:startMovie(event.movie)
	return true
end

function onMovieEnded(event)
	unpauseGame()
	return true
end

function onLevelProgress(event)
	flightPath:setProgress(event.progress, 1)
end

function onLevelComplete(event)
	--gameLoop:pause()
	Runtime:removeEventListener("touch", onTouch)
	stopScrollingTerrain()
	levelDirector:pause()
	playerWeapons.enabled = false
	if planeShootSoundChannel ~= nil then
		audio.stop(planeShootSoundChannel)
	end
	
	levelCompleteOverlay = LevelCompleteOverlay:new(stage.width, stage.height)
	levelCompleteOverlay:addEventListener("onDone", onDone)
	return true
end

function onDone(event)
	
end

function pauseGame()
	print("pauseGame")
	gameLoop:pause()
	Runtime:removeEventListener("touch", onTouch)
	levelDirector:pause()
	playerWeapons.enabled = false
	if planeShootSoundChannel ~= nil then
		audio.stop(planeShootSoundChannel)
	end
	return true
end

function unpauseGame()
	print("unpauseGame")
	gameLoop:reset()
	gameLoop:start()
	Runtime:addEventListener("touch", onTouch)
	levelDirector:start()
	playerWeapons.enabled = true
	return true
end

function togglePause()
	if(gameLoop.paused == true) then
		return unpauseGame()
	else
		return pauseGame()
	end
end

function onPauseTouch(event)
	print("onPauseTouch")
	if(event.phase == "began") then
		togglePause()
	end
	
	return true
end

--[[
function onKeyEvent( event )
	if(event.keyName == "menu") then
		if(gameLoop.paused == true) then
			unpauseGame()
		else
			pauseGame()
		end
	end
end
]]--

function onStartGameTouched(event)
	screenTitle:hide()
end

function onTitleScreenHideComplete()
	screenTitle:removeEventListener("screenTitle", onStartGameTouched)
	screenTitle:removeEventListener("hideComplete", onTitleScreenHideComplete)
	screenTitle:destroy()
	--assert(initializeGame(), "Failed to initialze game");
	local status, err = pcall(initializeGame)
	if status == false then
		print("error: ", err)
		return false
	end
	startGame()
end

function onSystemEvent(event)
	if event.type == "applicationExit" or event.type == "applicationSuspend" then
		os.exit()
	end

	--elseif event.type == "applicationResume"
end

function initializeGame()
	print("initializeGame")
	print("\tstarting physics")
	startPhysics()

	print("\tinitializing MainContext")
	print("\tMainContext: ", MainContext)
	context = assert(MainContext:new(), "Failed to create MainContext")
	print("\tcontext: ", context, ", context.init: ", context.init)
	assert(context:startup(), "Failed to boot Robotlegs.")

	print("\tmain group")
	mainGroup 						= display.newGroup()
	stage = display.getCurrentStage()

	print("\tdamaged hud")
	damageHUD = DamageHUD:new()
	context:createMediator(damageHUD)
	damageHUD.x = stage.width - 30
	damageHUD.y = 0

	print("\tscore view")
	scoreView = ScoreView:new()
	context:createMediator(scoreView)
	scoreView.x = scoreView.width / 2
	scoreView.y = damageHUD.y

	print("\tflight path")
	flightPath = FlightPath:new()
	flightPath:setProgress(1, 10)
	flightPath.x = (stage.width / 2) - (flightPath.width / 2)

	print("\tinit sounds")
	initSounds()

	print("\tPlayer")
	player = Player.new()
	mainGroup:insert(player)
	context:createMediator(player)
	--plane:addEventListener("hitPointsChanged", )

	print("\tgame loop")
	gameLoop = GameLoop:new()
	gameLoop:addLoop(player)

	print("\tbullet regulator")
	playerWeapons = PlayerWeapons:new(player, mainGroup, gameLoop)
	playerWeapons:setPowerLevel(1)


	print("\tplane targeting")
	player.planeXTarget = stage.width / 2
	player.planeYTarget = stage.height / 2
	player:move(player.planeXTarget, player.planeYTarget)
	--[[

	headAnime = HeadNormalAnime:new(4, stage.height - 104)
	mainGroup:insert(headAnime)
	--]]

	print("\tpause button")
	--local pauseButton = PauseButton:new(4, stage.height - 40)
--	pauseButton:addEventListener("touch", onPauseTouch)

	print("\tparsing level")
	level = LoadLevelService:new("level2.json")

	print("\tdrawing flight path checkpoints")
	flightPath:drawCheckpoints(level)

	print("\tlevel director")
	levelDirector = LevelDirector:new(level, player, mainGroup, gameLoop)
	assert(levelDirector ~= nil, "Level Director is null, yo!")
	levelDirector:initialize()
	print("levelDirector: ", levelDirector)
	print("levelDirector.addEventListener: ", levelDirector.addEventListener)
	levelDirector:addEventListener("onMovie", onMovieStarted)
	levelDirector:addEventListener("onLevelProgress", onLevelProgress)
	levelDirector:addEventListener("onLevelComplete", onLevelComplete)

	print("\tmovie player")
	moviePlayer = MoviePlayerView:new()
	moviePlayer:addEventListener("movieEnded", onMovieEnded)

	print("\thiding status bar")
	display.setStatusBar( display.HiddenStatusBar )

	print("\tinitializing keys")
	initKeys()
	
	Runtime:addEventListener("system", onSystemEvent)

	print("\tdone initializeGame!")
	return true
end

function startPhysics()
	physics.start()
	physics.setDrawMode( "normal" )
	physics.setGravity( 0, 0 )

	Runtime:addEventListener("GameLoop_onPauseChanged", GameLoop_onPauseChanged)
end

function GameLoop_onPauseChanged(event)
	if gameLoop.paused == true then
		physics.pause()
	else
		physics.start()
	end
end

function startThisMug()
	local stage = display.getCurrentStage()
	screenTitle = TitleScreen:new(stage.width, stage.height)
	screenTitle.x = 0
	screenTitle.y = 0
	screenTitle:addEventListener("onStartGameTouched", onStartGameTouched)
	screenTitle:addEventListener("onHideComplete", onTitleScreenHideComplete)
	screenTitle:show()
end

display.setStatusBar( display.HiddenStatusBar )

--startThisMug()
--AchievementsProxy.useMock = false

-----------------------------------------------------------------
-- tests ---

local function testingMainContext()
	print("testingMainContext")
	local context = assert(MainContext:new(), "Failed to instantiate MainContext.")
	print("context: ", context)
end


local function testingMainContextInit()
	print("testingMainContext")
	local context = assert(MainContext:new(), "Failed to instantiate MainContext.")
	print("context: ", context)
	assert(context:startup(), "Failed to startup MainContext.")
end


local function reflectionTest()
	for key,value in pairs(_G["Player"]) do
	    print("found member " .. key);
	end
end


local function packageParseTest()
	local first = "Player"
	local startIndex = 1
	local endIndex = 1
	local lastStartIndex = 1
	local lastEndIndex = 1
	while startIndex do
		startIndex,endIndex = first:find(".", startIndex, true)
		if startIndex ~= nil and endIndex ~= nil then
			lastStartIndex = startIndex
			lastEndIndex = endIndex
			startIndex = startIndex + 1
			endIndex = endIndex + 1
		end
	end
	local className = first:sub(lastStartIndex + 1)
	print("className: ", className)
end


local function mapTest()
	local context = Context:new()
	assert(context:mapMediator("com.jessewarden.planeshooter.sprites.player.Player", 
								"com.jessewarden.planeshooter.rl.mediators.PlayerMediator"), "Could not map mediators.")
end


local function testPlayer()
	startPhysics()
	local player = assert(Player:new(), "Failed to create player.")
end


local function mapAndCreateTest()
	startPhysics()
	local context = Context:new()
	assert(context:mapMediator("com.jessewarden.planeshooter.sprites.player.Player", 
								"com.jessewarden.planeshooter.rl.mediators.PlayerMediator"), "Could not map mediators.")
	local player = assert(Player:new(), "Failed to create Player.")
	assert(context:createMediator(player))
end


local function testAchievementConstants()
	print("constants.achievements.verteranPilot: ", constants.achievements.verteranPilot)
	AchievementsProxy:init(constants.gameNetworkType, constants.achievements)
	AchievementsProxy:unlock(constants.achievements.verteranPilot)
end


require "com.jessewarden.mock.openfeint.MockOpenFeint"

local function testMockOpenFeint()
	local mock = MockOpenFeint:new()
	--mock:showInit("Welcome Back Player 2093i4akljsdj")
	--mock:showAchievement("achievement_First_Blood.png", "First Blood")
	mock:showAchievement("achievement_Dogfighter.png", "Dogfighter")
end


local function testTitleScreen()
	require "com.jessewarden.planeshooter.views.screens.TitleScreen"
	stage = display.getCurrentStage()
	local screen = TitleScreen:new(stage.width, stage.height)
	screen:show()
	screen:addEventListener("onStartGameTouched", function(e)
		screen:hide()
		end
	)
end

local function testNewContinueLevelsScreen()
	require "com.jessewarden.planeshooter.views.screens.NewContinueLevelsScreen"
	stage = display.getCurrentStage()
	local screen = NewContinueLevelsScreen:new(stage.width, stage.height)
	screen:show(true)
	local t = function(e)
		screen:hide(e.target)
	end
	screen:addEventListener("onNewGameTouched", t)
	screen:addEventListener("onContinueTouched", t)
	screen:addEventListener("onLevelSelectTouched", t)
end

function testStageIntroScreen()
	require "com.jessewarden.planeshooter.views.screens.StageIntroScreen"
	stage = display.getCurrentStage()
	local screen = StageIntroScreen:new(1, "Delivery")
	screen:show()
	screen:addEventListener("onScreenAnimationCompleted", function()
		screen:show()
	end)
end

function testFlyingFortress()
	local fortressSheet = sprite.newSpriteSheet("npc_FlyingFortress_sheet.png", 295, 352)
	local fortressSheetSet = sprite.newSpriteSet(fortressSheet, 1, 6)
	sprite.add(fortressSheetSet, "fortress", 1, 6, 700, 0)
	local fortress = sprite.newSprite(fortressSheetSet)
	fortress:setReferencePoint(display.TopLeftReferencePoint)
	fortress:prepare("fortress")
	fortress:play()
	fortress.x = 0
	fortress.y = 0

	local t = function(e)
		fortress.y = fortress.y + 0.1
	end
	Runtime:addEventListener("enterFrame", t)
end

function testDialogue()
	local dialogue = DialogueView:new()
	dialogue:setText("Hello, G funk era!")
	dialogue:setCharacter(constants.CHARACTER_JESTERXL)
	dialogue:show()
end

function testFlightPath()
	local level = LoadLevelService:new("level2.json")
	--point = FlightPathCheckpoint:new()
	path = FlightPath:new()
	path:drawCheckpoints(level)
	print("level.totalTime: ", level.totalTime)
	path:setProgress(7, 10)
	local stage = display.getCurrentStage()
	path.x = (stage.width / 2) - (path.width / 2)
end

function testHighScores()
	require "gameNetwork"

	require "com.jessewarden.planeshooter.views.StoreAndScoresView"
	require "com.jessewarden.planeshooter.views.BuySellEquipView"
	require "com.jessewarden.planeshooter.views.StoreInventory"


	function onHighscores()
		print("onHighscore")
		local platform = system.getInfo("platformName")
		
		showOpenFeint()
		
		--if platform == "Android" then
			-- Papaya for Android
		--	showPapaya()
		--elseif platform == "iPhone OS" then
			-- OpenFeint for iOS
		--	showOpenFeint()
		--end
		
		return true
	end

	function showPapaya()
		gameNetwork.init("papaya", "asdf")
		gameNetwork.show("leaderboards")
	end

	function showOpenFeint()
		gameNetwork.init("openfeint", "asdf", "asdf", "JesterXL: Invaded Skies", "1337")
		gameNetwork.show("leaderboards")
	end

	function onStore()
		storeAndScoresView:hide()
		
		buySellEquipView = BuySellEquipView:new(stage.width, stage.height)
		print("buySellEquipView: ", buySellEquipView)
		local t = {}
		function t:onBack(event)
			print("onBack")
		end
		function t:onBuy(event)
			buySellEquipView:hide()
			if storeInventory == nil then
				storeInventory = StoreInventory:new(stage.width, stage.height)
			end
			
		end
		function t:onSell(event)
			print("onSell")
		end
		function t:onEquip(event)
			print("onEquip")
		end
		buySellEquipView:addEventListener("onBack", t)
		buySellEquipView:addEventListener("onBuy", t)
		buySellEquipView:addEventListener("onSell", t)
		buySellEquipView:addEventListener("onEquip", t)
		buySellEquipView:show()
	end

	stage = display.getCurrentStage()
	storeAndScoresView = StoreAndScoresView:new(stage.width, stage.height)
	--storeAndScoresView:addEventListener("onLeave", onLeave)
	storeAndScoresView:addEventListener("onStore", onStore)
	storeAndScoresView:addEventListener("onHighscores", onHighscores)
	storeAndScoresView:show()
end

function testGtween()
	require "gtween"
	local img = display.newImage("player.png")
	img.x = 400
	gtween.new(img, .5, {x=0}, {ease=gtween.easing.outBounce})
end

function testLevelCompleteScreen()
	require "com.jessewarden.planeshooter.views.screens.LevelCompleteScreen"
	local screen = LevelCompleteScreen:new(1, 3000)
	screen:show()
	screen:addEventListener("onAnimationCompleted", function()
		screen:hide()
	end)
end

local function testDialogue()
	local dia = DialogueView:new()
	dia:setText("Hello World!")

	local other = DialogueView:new(true)
	other:setText("Yet some more text that eats cheese.")
	other.y = 200
end

local function testMoviePlayer()
	require "com.jessewarden.planeshooter.services.LoadLevelService"
	require "com.jessewarden.planeshooter.views.MoviePlayerView"

	local level = LoadLevelService:new("level1.json")
	local events = level.events
	local movie
	local i = 1
	while events[i] do
		local event = events[i]
		if event.classType == "MovieVO" or event.classType == "movie" then
			movie = event
			break
		end
	end

	local player = MoviePlayerView:new()
	print("*******************************************")
	print("*******************************************")
	print("*******************************************")
	print("*******************************************")
	player:startMovie(movie)
end

local function testMoviePlayerAutoPlay()
	require "com.jessewarden.planeshooter.vo.DialogueVO"
	require "com.jessewarden.planeshooter.vo.MovieVO"
	require "com.jessewarden.planeshooter.views.MoviePlayerView"
	local player = MoviePlayerView:new()
	local movie = MovieVO:new()
	movie.autoPlay = true
	local getDia = function(name, message)
		local dia = DialogueVO:new()
		dia.characterName = name
		dia.message = message
		dia.autoPlay = true
		dia.dialogueTime = 3 * 1000
		return dia
	end
	table.insert(movie.dialogues, getDia("Sydney", "Hello!"))
	table.insert(movie.dialogues, getDia("Dad", "Wazzzzuuup!"))
	table.insert(movie.dialogues, getDia("Sydney", "How are you?"))
	table.insert(movie.dialogues, getDia("Dad", "I'm great, thanks for asking."))

	player:startMovie(movie)
end

local function testMoviePlayerAutoPlayAudio()
	require "com.jessewarden.planeshooter.vo.DialogueVO"
	require "com.jessewarden.planeshooter.vo.MovieVO"
	require "com.jessewarden.planeshooter.views.MoviePlayerView"
	local player = MoviePlayerView:new()
	local movie = MovieVO:new()
	movie.autoPlay = true
	local getDia = function(name, message, audioFile)
		local dia = DialogueVO:new()
		dia.characterName = name
		dia.message = message
		dia.autoPlay = true
		dia.audioFile = audioFile
		dia.advanceOnAudioEnd = true
		return dia
	end
	table.insert(movie.dialogues, getDia("Sydney", "Hello!", "01.mp3"))
	table.insert(movie.dialogues, getDia("Dad", "Wazzzzuuup!", "02.mp3"))
	table.insert(movie.dialogues, getDia("Sydney", "How are you?", "03.mp3"))
	local lastDia = getDia("Dad", "I'm great, thanks for asking.", "04.mp3")
	lastDia.advanceOnAudioEnd = false
	table.insert(movie.dialogues, lastDia)

	player:startMovie(movie)
end

local function testScrollingTerrain()
	require "com.jessewarden.planeshooter.core.GameLoop"
	require "com.jessewarden.planeshooter.views.controls.ScrollingTerrain"
	local loop = GameLoop:new()
	loop:start()

	local terrain = ScrollingTerrain:new("Level1Background.jpg")
	--terrain.alpha = 0.7

	loop:addLoop(terrain)
end

local function testPlayerMovement()
	require "com.jessewarden.planeshooter.sprites.player.Player"
	require "com.jessewarden.planeshooter.controllers.PlayerMovementController"
	local loop = GameLoop:new()
	loop:start()
	local player = Player:new()
	loop:addLoop(player)
	local controller = PlayerMovementController:new(player)
	controller:start()
end

local function testEnemySmallShip()
	local ship = EnemySmallShip:new(40, 0, display.getCurrentStage().height)
	local loop = GameLoop:new()
	loop:start()
	loop:addLoop(ship)
end

local function testEnemyBulletSingle()
	local bullet = EnemyBulletSingle:new(40, 0, {x=60, y=200})
	local loop = GameLoop:new()
	loop:start()
	loop:addLoop(bullet)
end

local function testEnemyJet()
	local jet = EnemyMissileJet:new(40, 0, display.getCurrentStage().height)
	local loop = GameLoop:new()
	loop:start()
	loop:addLoop(jet)
end

local function testEnemyMissile()
	require "com.jessewarden.planeshooter.sprites.enemies.EnemyMissile"
	local missile = EnemyMissile:new(40, 0)
	local loop = GameLoop:new()
	loop:start()
	loop:addLoop(missile)

	local tTouch = {}
	function tTouch:touch(event)
		playerView.x = event.x
		playerView.y = event.y
	end
	Runtime:addEventListener("touch", tTouch)

	local t = {}
	function t:timer()
		
	end
	--timer.performWithDelay(50, t, 0)
end

local function testEnemyMissileSimple()
	startPhysics()
	local missile = display.newImage("enemy_missle_jet_missle_sheet.png")
	physics.addBody( missile, { density = .7, friction = 0.3, bounce = 0.2,
								bodyType = "kinematic",
								isBullet = true, isSensor = true, isFixedRotation = true
							} )
	function missile:tick(m)
		local xForce, yForce
		local power = 0.03
		if missile.x > playerView.x then
			xForce = -power
		else
			xForce = power
		end
		if missile.y > playerView.y then
			yForce = -power
		else
			yForce = power
		end
		print(xForce, yForce)
		missile:applyLinearImpulse(xForce, yForce, missile.x, missile.y)
	end

	local loop = GameLoop:new()
	loop:start()
	loop:addLoop(missile)

	local tTouch = {}
	function tTouch:touch(event)
		playerView.x = event.x
		playerView.y = event.y
		print(event.phase)
		if event.phase == "began" then
			gameLoop:pause()
			physics.pause()
		else
			gameLoop:start()
			physics.start()
		end
	end
	Runtime:addEventListener("touch", tTouch)
end


local function testGenericGunTurret()
	local player = display.newGroup()
	player.x = 200
	player.y = 300

	require "com.jessewarden.planeshooter.sprites.enemies.GenericGunTurret"
	local turret = GenericGunTurret:new(player)
	turret.x = 40
	turret.y = 40

	local touched = function(e)
		player.x = e.x
		player.y = e.y
	end
	Runtime:addEventListener("touch", touched)

	local loop = GameLoop:new()
	loop:start()
	loop:addLoop(turret)
end

local function testFlak()
	require "com.jessewarden.planeshooter.sprites.enemies.Flak"
	local flak = Flak:new()
	flak.x = 60
	flak.y = 60
end

local function bunchOfFlak()
	require "com.jessewarden.planeshooter.sprites.enemies.Flak"

	local stage = display.getCurrentStage()
	local t = {}
	function t:timer(event)
		print("test")
		local flak = Flak:new()
		flak.x = math.random() * stage.width
		flak.y = math.random() * stage.height
	end
	timer.performWithDelay(200, t, 0)

	
end

local function testBoss()

	require "com.jessewarden.planeshooter.sprites.enemies.BossBigPlane"


	local boss = BossBigPlane:new(player)

	local touchList = function(e)
		if e.phase == "began" then
			boss.hitPoints = 0
		end
		--[[
		if e.phase == "began" then
			if boss.hitPoints == 20 then
				boss.hitPoints = 14
			elseif boss.hitPoints == 14 then
				boss.hitPoints = 6
			elseif boss.hitPoints == 6 then
				boss.hitPoints = 20
			end
		end
		]]--
	end
	Runtime:addEventListener("touch", touchList)
	--[[
	local t = {}
	function t:timer()
		boss.hitPoints = boss.hitPoints - 1
		print(boss.hitPoints)
	end
	timer.performWithDelay(1000, t, 0)
	]]--
end

local function testBossDeath()
	require "com.jessewarden.planeshooter.sprites.enemies.BossBigPlaneDeath"
	local touchList = function(e)
		if e.phase == "began" then
			print("gameLoop:", gameLoop.paused)
			if gameLoop.paused == false then
				gameLoop:pause()
			else
				gameLoop:start()
			end
		end
	end
	Runtime:addEventListener("touch", touchList)
	local death = BossBigPlaneDeath:new(200, 300)
end


local function testPlayerWeapons()
	require "com.jessewarden.planeshooter.sprites.player.Player"
	require "com.jessewarden.planeshooter.controllers.PlayerMovementController"
	require "com.jessewarden.planeshooter.controllers.PlayerWeaponsController"

	startPhysics()

	local player = Player:new()
	--gameLoop:addLoop(player)
	local controller = PlayerMovementController:new(player)
	controller:start()
	local weapons = PlayerWeaponsController:new(player)
	weapons:start()
	weapons:setPowerLevel(1)

	local t = {}
	function t:timer(e)
		--[[
		if weapons.powerLevel == 1 then
			weapons:setPowerLevel(2)
		elseif weapons.powerLevel == 2 then
			weapons:setPowerLevel(3)
		elseif weapons.powerLevel == 3 then
			weapons:setPowerLevel(4)
		elseif weapons.powerLevel == 4 then
			weapons:setPowerLevel(1)
		end
		]]--

		--if weapons.fireSpeed > 0 then
		--	weapons.fireSpeed = weapons.fireSpeed - 25
		--end
		--print("weapons.fireSpeed: ", weapons.fireSpeed)
	end

	timer.performWithDelay(2000, t, 0)
end

local function testRailGun()
	require "com.jessewarden.planeshooter.sprites.player.PlayerRailGun"
	local gun = PlayerRailGun:new(200, 200)
end

local function testTypeOf()
	function typeof(var)
	    local _type = type(var);
	    if(_type ~= "table" and _type ~= "userdata") then
	        return _type;
	    end
	    local _meta = getmetatable(var);
	    if(_meta ~= nil and _meta._NAME ~= nil) then
	        return _meta._NAME;
	    else
	        return _type;
    	end
	end

	require "com.jessewarden.planeshooter.vo.weapons.guns.GunRailVO"
	local gun = GunRailVO:new()
	print("type: ", type(gun))
	print("typeof: ", typeof(gun))
end

local function testEquipScreen()
	require "com.jessewarden.planeshooter.views.screens.EquipScreen"
	local screen = EquipScreen:new()
	screen:init()
end

local function testEquipScreenAndController()
	require "com.jessewarden.planeshooter.views.screens.EquipScreen"
	local screen = EquipScreen:new()
	screen:init()

	require "com.jessewarden.planeshooter.models.EquipModel"
	local model = EquipModel:new()
	model:init()

	require "com.jessewarden.planeshooter.models.PlayerModel"
	local playerModel = PlayerModel:new()

	require "com.jessewarden.planeshooter.vo.weapons.guns.Gun30CaliberVO"
	local gunVO = Gun30CaliberVO:new()
	model.guns:addItem(gunVO)
	local allGuns = model.guns

	require "com.jessewarden.planeshooter.vo.weapons.guns.Gun50CaliberVO"
	local gun50 = Gun50CaliberVO:new()
	model.guns:addItem(gun50)

	require "com.jessewarden.planeshooter.vo.weapons.guns.GunRailVO"
	local gunRail = GunRailVO:new()
	model.guns:addItem(gunRail)

	require "com.jessewarden.planeshooter.vo.engines.EngineDualAllisonsVO"
	local allison = EngineDualAllisonsVO:new()
	model.engines:addItem(allison)

	require "com.jessewarden.planeshooter.vo.engines.EngineJetVO"
	local jet = EngineJetVO:new()
	model.engines:addItem(jet)

	require "com.jessewarden.planeshooter.vo.bodies.BodyWoodVO"
	require "com.jessewarden.planeshooter.vo.bodies.BodySteelVO"
	require "com.jessewarden.planeshooter.vo.bodies.BodyAlumniumVO"

	local wood = BodyWoodVO:new()
	local steel = BodySteelVO:new()
	local alum = BodyAlumniumVO:new()

	model.bodies:addItem(wood)
	model.bodies:addItem(steel)
	model.bodies:addItem(alum)

	require "com.jessewarden.planeshooter.vo.weapons.cannons.Cannon9mmM1VO"
	require "com.jessewarden.planeshooter.vo.weapons.cannons.CannonM1918VO"
	local cannon9mm = Cannon9mmM1VO:new()
	local cannonM1 = CannonM1918VO:new()

	model.cannons:addItem(cannon9mm)
	model.cannons:addItem(cannonM1)

	require "com.jessewarden.planeshooter.vo.weapons.missiles.MissileHVARVO"
	require "com.jessewarden.planeshooter.vo.weapons.missiles.MissileHeatSeekingVO"

	local rocket1 = MissileHVARVO:new()
	local rocket2 = MissileHeatSeekingVO:new()

	model.missiles:addItem(rocket1)
	model.missiles:addItem(rocket2)

	require "com.jessewarden.planeshooter.views.screens.EquipScreenController"
	local controller = EquipScreenController:new()
	controller:initialize(model, playerModel, screen)

end

local function testProgressBar()
	require "com.jessewarden.planeshooter.views.controls.ProgressBar"
	local bar = ProgressBar:new(0, 0, 0, 255, 242, 0, 200, 40)
	bar.x = 30
	bar.y = 30
	bar:setProgress(5, 10)
	bar:showProgressAdjusted(5, 4, 10)
	bar:showProgressAdjusted(5, 7, 10)
end

local function testColonEvents()
	local cow = {}
	function cow:Sup_man()
		print("whoa it worked")
	end
	Runtime:addEventListener("Sup_man", cow)
	Runtime:dispatchEvent({name="Sup_man", target=nil})
end

local function testCollection()
	require "com.jessewarden.planeshooter.utils.Collection"
	local collection = Collection:new()
	print("before: ", #collection)
	collection:add("cow")
	print("after: ", #collection)
end

local function testILoop()
	local i = 1
	local max = 4
	while i <= max do
		print(i)
		i = i + 1
	end
end

local function testFunWithScope()
	local t = {}
	function t:test(firstArg)
		print("self: ", self)
		local result = t == self
		print("result: ", result)
		print("firstArg: ", firstArg)
	end
	t:test()
	t.test(t)
end

local function testUpperCaseFirstStringCharacter()
	local s = "body"
	s = s:sub(1,1):upper() .. s:sub(2)
	print(s)
end

local function testAllWeapons()
	require "com.jessewarden.planeshooter.sprites.player.PlayerBulletSingle"
	require "com.jessewarden.planeshooter.sprites.player.PlayerBulletDual"
	require "com.jessewarden.planeshooter.sprites.player.PlayerRailGun"

	require "com.jessewarden.planeshooter.sprites.player.PlayerCannon9mmM1"
	require "com.jessewarden.planeshooter.sprites.player.PlayerCannonM1918"

	require "com.jessewarden.planeshooter.sprites.player.PlayerMissileHVAR"
	require "com.jessewarden.planeshooter.sprites.player.PlayerMissileHeatSeeking"

	startPhysics()
	
	local bottom      = 400
	
	local bullet1     = PlayerBulletSingle:new(100, bottom)
	local bullet2     = PlayerBulletDual:new(150, bottom)
	local rail        = PlayerRailGun:new(170, bottom)
	
	local cannon1     = PlayerCannon9mmM1:new(200, bottom)
	local cannon2     = PlayerCannonM1918:new(220, bottom)
	
	local hvar        = PlayerMissileHVAR:new(240, bottom, 20, 0)
	local heatMissile = PlayerMissileHeatSeeking:new(260, bottom, 40, 40)

	--gameLoop:pause()
end

local function testLevelModel()
	require "com.jessewarden.planeshooter.services.LoadLevelService"
	level = LoadLevelService:new("level2.json")
	require "com.jessewarden.planeshooter.models.LevelModel"
	local model = LevelModel:new()
	model:init(level)
	model:start()
	local t = {}
	function t:LevelModel_onMovieEvent(e)
		model:start()
	end
	Runtime:addEventListener("LevelModel_onMovieEvent", t)
end

local function testLevelViewAndController()

	require "com.jessewarden.planeshooter.views.LevelView"
	require "com.jessewarden.planeshooter.controllers.LevelViewController"
	local view = LevelView:new()
	local controller = LevelViewController:new(view)

end

local function testMonsterGeneration()
	require "com.jessewarden.planeshooter.views.LevelView"
	require "com.jessewarden.planeshooter.controllers.LevelViewController"
	local view = LevelView:new()
	local controller = LevelViewController:new(view)
	
	local fakeEvents = {}
	local i = 1
	local max = 100
	local time = 0
	--local types = {"Plane", "Missile", "Jet", "Bomber", "UFO"}
	local types = {"Plane", "Missile"}
	local typeIndex = nil
	while i < max do
		typeIndex = math.random(1, 2)
		table.insert(fakeEvents, {type = types[typeIndex]})
		i = i + 1
	end

	local t = {}
	function t:timer(e)
		if #fakeEvents > 0 then
			local item = table.remove(fakeEvents, 1)
			Runtime:dispatchEvent({name="LevelModel_onEnemyEvent", type=item.type})
		end	
	end
	timer.performWithDelay(100, t, 0)
end

local function testMoviePlayerInLevelView()
	require "com.jessewarden.planeshooter.views.LevelView"
	require "com.jessewarden.planeshooter.controllers.LevelViewController"
	local view = LevelView:new()
	local controller = LevelViewController:new(view)

	require "com.jessewarden.planeshooter.vo.DialogueVO"
	require "com.jessewarden.planeshooter.vo.MovieVO"
	require "com.jessewarden.planeshooter.vo.LevelVO"
	require "com.jessewarden.planeshooter.vo.EnemyVO"
	local movie = MovieVO:new()
	movie.autoPlay = true
	local getDia = function(name, message, audioFile)
		local dia = DialogueVO:new()
		dia.characterName = name
		dia.message = message
		dia.autoPlay = true
		dia.audioFile = audioFile
		dia.advanceOnAudioEnd = true
		return dia
	end
	table.insert(movie.dialogues, getDia("Sydney", "Hello!", "01.mp3"))
	table.insert(movie.dialogues, getDia("Dad", "Wazzzzuuup!", "02.mp3"))
	table.insert(movie.dialogues, getDia("Sydney", "How are you?", "03.mp3"))
	table.insert(movie.dialogues, getDia("Dad", "I'm great, thanks for asking.", "04.mp3"))
	movie.when = 15

	local time = 10
	local getPlane = function()
		local plane = EnemyVO:new()
		plane.when = time
		time = time + math.random(1, 4)
		return plane
	end
	local level = LevelVO:new()
	table.insert(level.events, movie)
	table.insert(level.events, getPlane())
	table.insert(level.events, getPlane())
	table.insert(level.events, getPlane())
	table.insert(level.events, getPlane())
	table.insert(level.events, getPlane())

	require "com.jessewarden.planeshooter.models.LevelModel"
	local model = LevelModel:new()
	model:init(level)
	model:start()

end

local function testMoviePlayerInLevelViewWithDynamicLevel()
	require "com.jessewarden.planeshooter.services.LoadLevelService"
	local level = LoadLevelService:new("level.json")
	
	require "com.jessewarden.planeshooter.models.LevelModel"
	local model = LevelModel:new()
	model:init(level)
	model:start()

	require "com.jessewarden.planeshooter.views.LevelView"
	require "com.jessewarden.planeshooter.controllers.LevelViewController"
	local view = LevelView:new()
	local controller = LevelViewController:new(view, model)
end

local function testScoreView()
	require "com.jessewarden.planeshooter.views.ScoreView"
	local view = ScoreView:new()
	view.x = 100
	view.y = 100
	view:setScore(1000)
	view:setScore(1234)

	local t = {}
	t.score = 0
	t.increment = 1
	function t:timer(e)
		self.score = self.score + self.increment
		view:setScore(self.score)
		self.increment = self.increment + 1
	end
	--timer.performWithDelay(10, t, 0)
end

local function testMementoSet()
	local t = {}
	t.name = "cheese"
	t.age = 21
	local memento = {}
	memento.name = "boo"
	memento.age = 46
	for key,value in pairs(t) do
		print("before: ", key, value)
		t[key] = memento[key]
		print("after: ", key, t[key])
	end
end

local function testPlaneShooter()
	require "com.jessewarden.planeshooter.PlaneShooterContext"
	require "com.jessewarden.planeshooter.views.PlaneShooterView"
	local context = PlaneShooterContext:new()
	context:mapSingletonModel("equipModel", "com.jessewarden.planeshooter.models.EquipModel")
	context:mapSingletonModel("levelModel", "com.jessewarden.planeshooter.models.LevelModel")
	context:mapSingletonModel("playerModel", "com.jessewarden.planeshooter.models.PlayerModel")
	context:mapSingletonModel("scoreModel", "com.jessewarden.planeshooter.models.ScoreModel")
	context:mapSingletonModel("progressModel", "com.jessewarden.planeshooter.models.ProgressModel")

	context:mapController("com.jessewarden.planeshooter.views.PlaneShooterView", 
							"com.jessewarden.planeshooter.controllers.PlaneShooterController")

	context:mapController("com.jessewarden.planeshooter.views.LevelView", 
							"com.jessewarden.planeshooter.controllers.LevelViewController")

	context:mapController("com.jessewarden.planeshooter.views.ScoreView", 
							"com.jessewarden.planeshooter.controllers.ScoreViewController")

	context:mapController("com.jessewarden.planeshooter.views.DebugView", 
							"com.jessewarden.planeshooter.controllers.DebugViewController")


	context:mapCommand("LevelViewController_levelComplete",
						"com.jessewarden.planeshooter.commands.LevelCompleteCommand")

	context:mapCommand("LevelViewController_nextLevel",
						"com.jessewarden.planeshooter.commands.LoadNextLevelCommand")

	context:mapCommand("PlaneShooterController_newGame",
						"com.jessewarden.planeshooter.commands.LoadNextLevelCommand")

	local game = PlaneShooterView:new()
end

local function testInsertOverrides()
	local t = {}
	function t:insert(item)
		print("yo, self: ", self, ", item: ", item)
		t.oldInsert(t, item)
	end
	local cow = display.newGroup()
	--setmetatable(cow, t)
	t.oldInsert = cow.insert
	print("t.oldInsert: ", t.oldInsert)
	cow.insert = t.insert
	print("cow: ", cow, ", cow.insert: ", cow.insert)
	local cheese = display.newGroup()
	cow:insert(cheese)

end

local function testUserProgressSaveAndRead()
	require "com.jessewarden.planeshooter.services.UserProgressService"
	require "com.jessewarden.planeshooter.vo.UserProgressVO"
	local service = UserProgressService:new()
	service:delete()
	local nilVO = service:read()
	assert(nilVO == nil, "We've got an old file laying around.")

	local vo = UserProgressVO:new()
	vo.level = 3
	vo.weaponsConfig = {gun="something", cannon={left="yep", right=2}}
	vo.score = 200000
	assert(service:save(vo))

	local newVO = service:read()
	assert(newVO ~= nil, "Couldn't get VO out of file.")
	print(newVO.level, newVO.score, newVO.weaponsConfig.cannon.right)

end

local function testDateStrings()
	local time = os.date()
	print(time)
	print(time.year)
	print(os.date( "%c" ))
end

local function testingNewFloatingText()
	require "com.jessewarden.planeshooter.views.FloatingText"
	local float = FloatingText:new()
	function onTouch(event)
		--if event.phase == "began" then
			float:showText(event.x, event.y, 1)
		--end
	end
	Runtime:addEventListener("touch", onTouch)
end

local function testNegativeRandoms()
	print(math.random(10, 20))
	print(math.random(-10, 2))
end

local function testLevel1MoviePlayer()
	require "com.jessewarden.planeshooter.vo.DialogueVO"
	require "com.jessewarden.planeshooter.vo.MovieVO"
	require "com.jessewarden.planeshooter.views.MoviePlayerView"
	require "com.jessewarden.planeshooter.services.LoadLevelService"
	local player = MoviePlayerView:new()
	local level = LoadLevelService:new("level1.json")
	local firstMovie = level.events[1]
	local secondMovie = level.events[2]
	player:startMovie(firstMovie)
	local t = {}
	function t:onMovieEnded()
		player:startMovie(secondMovie)
	end
	player:addEventListener("onMovieEnded", t)
end

local function testUberJet()
	require "com.jessewarden.planeshooter.sprites.enemies.UberJet"

	local uberJet = UberJet:new()
end

local function testFindSoundChannels()
	print("total channels:", audio.totalChannels)
	print("free channels:", audio.freeChannels)
	print("free channel:", audio.findFreeChannel())
	print("max volume:", audio.getMaxVolume())
	print("min volume:", audio.getMinVolume())
	print("channel active 0:", audio.isChannelActive(0))
	print("before reserved channels:", audio.reservedChannels)
	print("before unreserved before:", audio.unreservedFreeChannels)
	print("reserve 2:", audio.reserveChannels(2))
	print("after reserved channels:", audio.reservedChannels)
	print("after unreserved before:", audio.unreservedFreeChannels)
end

local function testTankMan()
	require "com.jessewarden.planeshooter.sprites.enemies.TankMan"
	local tankMan = TankMan:new()
	tankMan.x = 40
	tankMan.y = 30

--[[
	local dot = display.newRect(0, 0, 10, 10)
	dot:setFillColor(255, 0, 0)
	dot.x = 55
	dot.y = 90
	]]--

	Runtime:addEventListener("touch", function(e)
		if e.phase == "began" then
			--tankMan:startSpinSAMS()
			--tankMan:startSuperSpinSams()
			playerView.x = e.x
			playerView.y = e.y
			--tankMan:startFiringMissiles()
			--tankMan:startFiringFlak()
			tankMan:startRotateToSpreadPosition()
		elseif e.phase == "ended" then
			--tankMan:stopSpinSAMS()
			--tankMan:stopSuperSpinSams()
			--tankMan:stopFiringMissiles()
			--tankMan:stopFiringFlak()
			--tankMan:rotateToClosePosition()
			tankMan:startRotateToClosePosition()
		end
	end)
end

local function testPivotJoint()

	physics.setGravity( 0, 9.8 )

	local getPart = function(image)
		local part = display.newImage(image)
		--part:setReferencePoint(display.TopLeftReferencePoint)
		physics.addBody(part, {
								bodyType="kinematic", 
								isSensor=true
								})
		return part
	end

	local connectX = 15
	local connectY = 15
	local shoulder = getPart("images/sprites/tank_man/tank_man_left_shoulder.png")
	shoulder.bodyType = "static"
	shoulder.isFixedRotation = true
	local arm = getPart("images/sprites/tank_man/tank_man_left_arm.png")
	arm.x = 15
	arm.y = 42
	local joint = physics.newJoint("pivot", shoulder, arm, connectX, connectY)
	--joint.isLimitEnabled = true
	--joint:setRotationLimits( -45, 45 )
	joint.isMotorEnabled = true
	joint.maxMotorTorque = 1000000
	joint.motorSpeed = 1000

--[[
	local dot = display.newCircle(10, 10, 3)
	dot:setFillColor(255, 0, 0)
	dot.x = connectX
	dot.y = connectY
	]]--
end

--[[
local stage = display.getCurrentStage()
local rect = display.newRect(0, 0, stage.width, stage.height)
rect:setFillColor(0, 0, 0)
]]--

setupGlobals()
startPhysics()
--startThisMug()

--testAchievementConstants()
--testMockOpenFeint()	
--mapAndCreateTest()
--testPlayer()
--mapTest()
--packageParseTest()
--reflectionTest()
--testingMainContextInit()
--testingMainContext()

--testFlyingFortress()
--testDialogue()
--testFlightPath()
--testHighScores()
--testGTween()

--testTitleScreen()
--testNewContinueLevelsScreen()
--testStageIntroScreen()
--testLevelCompleteScreen()

--testDialogue()
--testMoviePlayer()
--testMoviePlayerAutoPlay()
--testMoviePlayerAutoPlayAudio()
--testFlightPath()
--testScrollingTerrain()
--testPlayerMovement()
--testEnemySmallShip()
--testEnemyBulletSingle()
--testEnemyJet()
--testEnemyMissile()
--testEnemyMissileSimple()
--testGenericGunTurret()
--testFlak()
--bunchOfFlak()
--testBoss()
--testBossDeath()
--testPlayerWeapons()
--testRailGun()
--testTypeOf()

--testEquipScreen()
--testEquipScreenAndController()

--testProgressBar()
--testColonEvents() --lol
--testILoop()
--testCollection()

--testFunWithScope()
--testUpperCaseFirstStringCharacter()

--testAllWeapons()

--testLevelModel()
--testLevelViewAndController()
--testMonsterGeneration()
--testMoviePlayerInLevelView()
--testMoviePlayerInLevelViewWithDynamicLevel()

--testScoreView()
--testMementoSet()
--testInsertOverrides()
--testUserProgressSaveAndRead()
--testDateStrings()
--testingNewFloatingText()
--testNegativeRandoms()

--testLevel1MoviePlayer()
--testUberJet()

--testFindSoundChannels()

testTankMan()
--testPivotJoint()

--testPlaneShooter()



--require "testsmain"
