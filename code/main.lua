require "sprite"
require "physics"
require "gameNetwork"

require "com.jessewarden.planeshooter.core.constants"

require "com.jessewarden.planeshooter.gamegui.controls.ScrollingTerrain"
require "com.jessewarden.planeshooter.core.GameLoop"
require "com.jessewarden.planeshooter.core.LevelDirector"

require "com.jessewarden.planeshooter.sprites.player.Player"
require "com.jessewarden.planeshooter.sprites.player.PlayerBulletSingle"
require "com.jessewarden.planeshooter.sprites.player.PlayerRailGun"

require "com.jessewarden.planeshooter.sprites.enemies.EnemySmallShip"
require "com.jessewarden.planeshooter.sprites.enemies.EnemySmallShipDeath"
require "com.jessewarden.planeshooter.sprites.enemies.EnemyBulletSingle"
require "com.jessewarden.planeshooter.sprites.enemies.BossBigPlane"
require "com.jessewarden.planeshooter.sprites.enemies.EnemyMissileJet"
require "com.jessewarden.planeshooter.sprites.enemies.EnemyMissile"

require "com.jessewarden.planeshooter.gamegui.DamageHUD"

require "com.jessewarden.planeshooter.gamegui.animations.HeadNormalAnime"
require "com.jessewarden.planeshooter.gamegui.controls.PauseButton"
require "com.jessewarden.planeshooter.gamegui.ScoreView"
require "com.jessewarden.planeshooter.gamegui.DialogueView"
require "com.jessewarden.planeshooter.gamegui.MoviePlayerView"
require "com.jessewarden.planeshooter.gamegui.FlightPathCheckpoint"
require "com.jessewarden.planeshooter.gamegui.FlightPath"
require "com.jessewarden.planeshooter.gamegui.LevelCompleteOverlay"

require "com.jessewarden.planeshooter.services.LoadLevelService"
require "com.jessewarden.planeshooter.services.AchievementsProxy"

require "com.jessewarden.planeshooter.gamegui.screens.TitleScreen"

require "com.jessewarden.planeshooter.rl.MainContext"
require "com.jessewarden.planeshooter.rl.mediators.PlayerMediator"

local function setupGlobals()
	_G.gameLoop = GameLoop:new()
	gameLoop:start()

	_G.mainGroup = display.newGroup()

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
AchievementsProxy.useMock = false

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
	require "com.jessewarden.planeshooter.gamegui.screens.TitleScreen"
	stage = display.getCurrentStage()
	local screen = TitleScreen:new(stage.width, stage.height)
	screen:show()
	screen:addEventListener("onStartGameTouched", function(e)
		screen:hide()
		end
	)
end

local function testNewContinueLevelsScreen()
	require "com.jessewarden.planeshooter.gamegui.screens.NewContinueLevelsScreen"
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
	require "com.jessewarden.planeshooter.gamegui.screens.StageIntroScreen"
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

	require "com.jessewarden.planeshooter.gamegui.StoreAndScoresView"
	require "com.jessewarden.planeshooter.gamegui.BuySellEquipView"
	require "com.jessewarden.planeshooter.gamegui.StoreInventory"


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
	require "com.jessewarden.planeshooter.gamegui.screens.LevelCompleteScreen"
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
	require "com.jessewarden.planeshooter.vo.DialogueVO"
	require "com.jessewarden.planeshooter.vo.MovieVO"
	local player = MoviePlayerView:new()
	local movie = MovieVO:new()
	local getDia = function(name, message)
		local dia = DialogueVO:new()
		dia.characterName = name
		dia.message = message
		return dia
	end
	table.insert(movie.dialogues, getDia("Sydney", "Hello!"))
	table.insert(movie.dialogues, getDia("Dad", "Wazzzzuuup!"))
	table.insert(movie.dialogues, getDia("Sydney", "How are you?"))
	table.insert(movie.dialogues, getDia("Dad", "I'm great, thanks for asking."))

	player:startMovie(movie)
end

local function testScrollingTerrain()
	local loop = GameLoop:new()
	loop:start()

	local terrain = ScrollingTerrain:new("debug_terrain_2.jpg")
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
	local player = {x=200, y=display.getCurrentStage().height}
	local missile = EnemyMissile:new(40, 0, player)
	local loop = GameLoop:new()
	loop:start()
	loop:addLoop(missile)

	local t = {}
	function t:timer()
		player.x = player.x + 1
		player.y = player.y - 20
	end
	timer.performWithDelay(50, t, 0)
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
	local player = display.newGroup()
	player.x = 200
	player.y = 300

	local boss = BossBigPlane:new(player)
	local loop = GameLoop:new()
	loop:start()
	loop:addLoop(boss)
end

local function testPlayerWeapons()
	require "com.jessewarden.planeshooter.sprites.player.Player"
	require "com.jessewarden.planeshooter.controllers.PlayerMovementController"
	require "com.jessewarden.planeshooter.controllers.PlayerWeaponsController"

	startPhysics()

	local player = Player:new()
	gameLoop:addLoop(player)
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
	require "com.jessewarden.planeshooter.gamegui.screens.EquipScreen"
	local screen = EquipScreen:new()
	screen:init()
end

local function testEquipScreenAndController()
	require "com.jessewarden.planeshooter.gamegui.screens.EquipScreen"
	local screen = EquipScreen:new()
	screen:init()

	require "com.jessewarden.planeshooter.models.EquipModel"
	local model = EquipModel:new()
	model:init()

	require "com.jessewarden.planeshooter.vo.weapons.guns.Gun30CaliberVO"
	local gunVO = Gun30CaliberVO:new()
	model.guns:add(gunVO)
	local allGuns = model.guns
	print("allGuns: ", #allGuns)

	require "com.jessewarden.planeshooter.gamegui.screens.EquipScreenController"
	local controller = EquipScreenController:new()
	controller:initialize(model, screen)

end

local function testProgressBar()
	require "com.jessewarden.planeshooter.gamegui.controls.ProgressBar"
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

local stage = display.getCurrentStage()
local rect = display.newRect(0, 0, stage.width, stage.height)
rect:setFillColor(255, 255, 255)




setupGlobals()
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
--testFlightPath()
--testScrollingTerrain()
--testPlayerMovement()
--testEnemySmallShip()
--testEnemyBulletSingle()
--testEnemyJet()
--testEnemyMissile()
--testGenericGunTurret()
--testFlak()
--bunchOfFlak()
--testBoss()
--testPlayerWeapons()
--testRailGun()
--testTypeOf()

--testEquipScreen()
testEquipScreenAndController()
--testProgressBar()
--testColonEvents() --lol
--testILoop()
--testCollection()

--require "testsmain"
