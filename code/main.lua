require "sprite"
require "physics"
require "constants"
require "ScrollingTerrain"
require "game_GameLoop"
require "game_LevelDirector"

require "player_PlayerWeapons"
require "player_Player"
require "player_PlayerBulletSingle"
require "player_PlayerRailGun"
require "enemies_EnemySmallShip"
require "enemies_EnemySmallShipDeath"
require "enemies_EnemyBulletSingle"
require "gamegui_DamageHUD"
require "enemies_BossBigPlane"
require "enemies_EnemyMissileJet"
require "enemies_EnemyMissile"

require "gamegui_animations_HeadNormalAnime"
require "gamegui_buttons_PauseButton"
require "gamegui_ScoreView"
require "gamegui_DialogueView"
require "gamegui_MoviePlayerView"
require "gamegui_FlightPathCheckpoint"
require "gamegui_FlightPath"

require "services_LoadLevelService"

require "screen_title"



local function initSounds()
	planeShootSound = {}
	--[[
	audio.reserveChannels(2)
	planeShootSound = audio.loadSound("plane_shoot.wav")
	planeShootSoundChannel = 1
	audio.setVolume(.2, {channel=planeShootSoundChannel})
	]]--
end

function startScrollingTerrain()
	--addLoop(terrainScroller)
end

function stopScrollingTerrain()
	--removeLoop(terrainScroller)
end

function onTouch(event)
	--print("onTouch, event.phase: ", event.phase)
	local handled = false
	if(event.phase == "began" or event.phase == "moved") then
		player:setDestination(event.x, event.y - 40)
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
	        local phase = event.phase
	        local keyName = event.keyName
	        print("phase: ", phase, ", keyName: ", keyName)

	        -- we handled the event, so return true.
	        -- for default behavior, return false.
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
end

function onMovieStarted(event)
	Runtime:removeEventListener("touch", onTouch)
	stopScrollingTerrain()
	moviePlayer:startMovie(event.movie)
	return true
end

function onMovieEnded(event)
	Runtime:addEventListener("touch", onTouch)
	startScrollingTerrain()
	levelDirector:start()
	return true
end

function onLevelProgress(event)
	flightPath:setProgress(event.progress, 1)
end

function onLevelComplete(event)
	stopGame()
	return true
end

function pauseGame()
	print("pauseGame")
	gameLoop:pause()
	Runtime:removeEventListener("touch", onTouch)
	levelDirector:pause()
	return true
end

function unpauseGame()
	print("unpauseGame")
	gameLoop:start()
	Runtime:addEventListener("touch", onTouch)
	levelDirector:start()
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

function onKeyEvent( event )
	if(event.keyName == "menu") then
		if(gameLoop.paused == true) then
			unpauseGame()
		else
			pauseGame()
		end
	end
end

function onStartGameTouched(event)
	screenTitle:hide()
end

function onTitleScreenHideComplete()
	screenTitle:removeEventListener("screenTitle", onStartGameTouched)
	screenTitle:removeEventListener("hideComplete", onTitleScreenHideComplete)
	screenTitle:destroy()
	initializeGame()
	--startGame()
end

function step1()
	print("\tstarting physics")
	physics.start()
	--physics.setDrawMode( "hybrid" )
	physics.setGravity( 0, 0 )
end

function step2()
	print("\initializing MainContext")
	context = require("MainContext").new()
	context:init()
end

function step3()	
	print("\tmain group")
	mainGroup 						= display.newGroup()
	stage = display.getCurrentStage()
end

function step4()
	print("\tdamaged hud")
	damageHUD = DamageHUD:new()
	context:createMediator(damageHUD)
	damageHUD.x = stage.width - 30
	damageHUD.y = 0
end

function step5()
	print("\tscore view")
	scoreView = ScoreView:new()
	context:createMediator(scoreView)
	scoreView.x = scoreView.width / 2
	scoreView.y = damageHUD.y
end

function step6()
	print("\tflight path")
	flightPath = FlightPath:new()
	flightPath:setProgress(1, 10)
	flightPath.x = (stage.width / 2) - (flightPath.width / 2)
end

function step7()
	print("\tinit sounds")
	initSounds()
end

function step8()
	print("\tPlayer")
	player = Player.new()
	mainGroup:insert(player)
	context:createMediator(player)
	--plane:addEventListener("hitPointsChanged", )
end

function step9()
	print("\tgame loop")
	gameLoop = GameLoop:new()
	gameLoop:addLoop(player)
end

function step10()
	print("\tbullet regulator")
	playerWeapons = PlayerWeapons:new(player, mainGroup, gameLoop)
	playerWeapons:setPowerLevel(1)
end

function step11()
	print("\tplane targeting")
	player.planeXTarget = stage.width / 2
	player.planeYTarget = stage.height / 2
	player:move(player.planeXTarget, player.planeYTarget)
	--[[
	
	headAnime = HeadNormalAnime:new(4, stage.height - 104)
	mainGroup:insert(headAnime)
	--]]
end

function step12()
	print("\tpause button")
	local pauseButton = PauseButton:new(4, stage.height - 40)
	pauseButton:addEventListener("touch", onPauseTouch)
end

function step13()
	print("\tparsing level")
	level = LoadLevelService:new("level.json")
end

function step14()
	print("\tdrawing flight path checkpoints")
	flightPath:drawCheckpoints(level)
end

function step15()
	print("\tlevel director")
	levelDirector = LevelDirector:new(level, player, mainGroup, gameLoop)
	assert(levelDirector ~= nil, "Level Director is null, yo!")
	levelDirector:initialize()
	print("levelDirector: ", levelDirector)
	print("levelDirector.addEventListener: ", levelDirector.addEventListener)
	levelDirector:addEventListener("onMovie", onMovieStarted)
	levelDirector:addEventListener("onLevelProgress", onLevelProgress)
	levelDirector:addEventListener("onLevelComplete", onLevelComplete)
end

function step16()
	print("\tmovie player")
	moviePlayer = MoviePlayerView:new()
	moviePlayer:addEventListener("movieEnded", onMovieEnded)
end

function step17()
	print("\thiding status bar")
	display.setStatusBar( display.HiddenStatusBar )
end

function step18()
	print("\tinitializing keys")
	initKeys()
end

function initializeGame()
	print("initializeGame")
	
	--[[
	step1()
	
	step2()
	
	step3()
	
	--initTerrain()

	step4()
	
	step5()
	
	step6()

	step7()
	
	step8()

	step9()
	
	step10()
	
	step11()

	step12()
	
	step13()

	step14()

	step15()
	
	step16()
	
	step17()

	step18()
	
	]]--
	
	

	
	
	--print("\tdone initializeGame!")
	startSteps()
end

currentStep = 0
delayTime = 100
local delayTable = {}
function delayTable:timer(event)
	currentStep = currentStep + 1
	if currentStep < 19 then
		local functionName = "step" .. currentStep
		debug("running step " .. currentStep)
	   	_G[functionName]()
		timer.performWithDelay(delayTime, delayTable)
	else
		startGame()
	end
end

function startSteps()
	print("startSteps")
	debugText = display.newText("", 0, 0, native.systemFont, 16)
	debugText:setTextColor(255, 0, 0)
	debugText.y = 400
	debugText.x = 150
    timer.performWithDelay(delayTime, delayTable)	
end

function debug(o)
	print(o)
	debugText.text = o
end


--initializeGame()
--startGame()

local stage = display.getCurrentStage()
screenTitle = ScreenTitle:new(stage.width, stage.height)
screenTitle:addEventListener("startGame", onStartGameTouched)
screenTitle:addEventListener("hideComplete", onTitleScreenHideComplete)
screenTitle:show()

-- tests
--[[
local dialogue = DialogueView:new()
dialogue:setText("Hello, G funk era!")
dialogue:setCharacter(constants.CHARACTER_JESTERXL)
dialogue:show()
]]--



--moviePlayer:addEventListener("movieEnded", t)
--moviePlayer:startMovie(movie)



--point = FlightPathCheckpoint:new()
--[[
path = FlightPath:new()
path:drawCheckpoints(level)
print("level.totalTime: ", level.totalTime)
path:setProgress(10, 10)
local stage = display.getCurrentStage()
path.x = (stage.width / 2) - (path.width / 2)
  ]]--

--[[
local group = display.newGroup()
--group:setReferencePoint(display.TopLeftReferencePoint)
group.x = 100
group.y = 100

--local subGroup = display.newGroup()


local rect = display.newRect(0, 0, 100, 100)
rect:setReferencePoint(display.TopLeftReferencePoint)
rect:setFillColor(255, 255, 255, 100) 
rect:setStrokeColor(255, 0, 0) 
rect.strokeWidth = 4
rect.x = group.x
rect.y = group.y
rect.isVisible = false

local greenRect = display.newRect(50, 50, 100, 100)
greenRect:setReferencePoint(display.TopLeftReferencePoint)
greenRect:setFillColor(255, 255, 255, 100) 
greenRect:setStrokeColor(0, 255, 0) 
greenRect.strokeWidth = 4
group:insert(greenRect)
]]--


