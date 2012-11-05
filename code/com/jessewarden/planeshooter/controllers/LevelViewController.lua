require "com.jessewarden.planeshooter.sprites.enemies.EnemySmallShip"
require "com.jessewarden.planeshooter.sprites.enemies.EnemyMissile"
require "com.jessewarden.planeshooter.sprites.enemies.UFO"

LevelViewController = {}

function LevelViewController:new(levelView)

	assert(levelView ~= nil, "You must pass a levelView to LevelViewController.")

	local controller = {}
	controller.classType = "LevelViewController"
	controller.eventReady = nil
	controller.levelView = levelView
	

	function controller:init()
		Runtime:addEventListener("LevelModel_onEnemyEvent", self)
		Runtime:addEventListener("LevelModel_onMovieEvent", self)
	end

	function controller:destroy()
		Runtime:removeEventListener("LevelModel_onEnemyEvent", self)
		Runtime:removeEventListener("LevelModel_onMovieEvent", self)
	end

	function controller:LevelModel_onEnemyEvent(event)
		print("LevelViewController::LevelModel_onEnemyEvent")
		local enemyVO = event.event
		local stage = display.getCurrentStage()

		local randomX = stage.width * math.random()
		if(randomX < 20) then
			randomX = 20
		end

		if(randomX > stage.width - 20) then
			randomX = stage.width - 20
		end

		local enemyType = enemyVO.type
		if enemyType == "Plane" then
			enemy = EnemySmallShip:new(randomX, -10, stage.height)
		elseif enemyType == "Missile" then
			enemy = EnemyMissile:new(randomX, -10)
		elseif enemyType == "Jet" then
			enemy = EnemyMissileJet:new(randomX, -10, stage.height)
		elseif enemyType == "Bomber" then
			enemy = BossBigPlane:new()
		elseif enemyType == "UFO" then
			enemy = UFO:new(randomX, 100)
		end

		self.levelView:insert(enemy)
		--mainGroup:insert(enemy)
	end

	function controller:LevelModel_onMovieEvent(event)
		local movieVO = event.event
		self.levelView:onMovie(movieVO)
	end

	controller:init()

	return controller

end

return LevelViewController