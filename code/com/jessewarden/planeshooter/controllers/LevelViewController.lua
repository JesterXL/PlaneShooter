require "com.jessewarden.planeshooter.sprites.enemies.EnemySmallShip"
require "com.jessewarden.planeshooter.sprites.enemies.EnemyMissile"
require "com.jessewarden.planeshooter.sprites.enemies.UFO"
require "com.jessewarden.planeshooter.services.UserProgressService"
require "com.jessewarden.planeshooter.vo.UserProgressVO"

LevelViewController = {}

function LevelViewController:new()

	local controller = {}
	controller.classType = "LevelViewController"
	controller.view = nil
	controller.levelModel = nil
	

	function controller:onRegister()
		print("LevelViewController::onRegister")
		self.levelModel = self.context:getModel("levelModel")
		Runtime:addEventListener("LevelModel_onEnemyEvent", self)
		Runtime:addEventListener("LevelModel_onMovieEvent", self)
		Runtime:addEventListener("LevelModel_levelStart", self)
		Runtime:addEventListener("LevelModel_levelComplete", self)

		self.view:addEventListener("onMovieEnded", self)
	end

	function controller:onRemove()
		print("LevelViewController::onRemove")
		Runtime:removeEventListener("LevelModel_onEnemyEvent", self)
		Runtime:removeEventListener("LevelModel_onMovieEvent", self)
		Runtime:removeEventListener("LevelModel_levelStart", self)
		Runtime:removeEventListener("LevelModel_levelComplete", self)

		self.view:removeEventListener("onMovieEnded", self)
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

		if enemyVO.unpauseCallback ~= nil then
			enemy.vo = enemyVO
			enemy:addEventListener("onDestroy", self)
		end
		self.view:insert(enemy)
		--mainGroup:insert(enemy)
	end

	function controller:LevelModel_onMovieEvent(event)
		local movieVO = event.event
		self.view:onMovie(movieVO)
	end

	function controller:LevelModel_levelStart(event)
		self.view:onLevelStart()
	end
	
	function controller:LevelModel_levelComplete(event)
		self.view:onLevelEnd()
		local context = self.context
		-- TODO: move to Commands, shit's only going to get worse from here
		local progressModel = context:getModel("progressModel")
		local levelModel = context:getModel("levelModel")
		local scoreModel = context:getModel("scoreModel")
		local playerModel = context:getModel("playerModel")
		progressModel:saveProgress(levelModel.level.fileName, scoreModel.score, playerModel:getMemento())
	end

	function controller:onMovieEnded(event)
		self.levelModel:start()
	end

	function controller:onDestroy(event)
		local target = event.target
		target:removeEventListener("onDestroy", self)
		local enemyVO = target.vo
		target.vo = nil
		enemyVO.unpauseCallback()
	end

	return controller

end

return viewController