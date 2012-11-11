require "com.jessewarden.planeshooter.controllers.LevelViewController"
require "com.jessewarden.planeshooter.models.LevelModel"
require "com.jessewarden.planeshooter.services.LoadLevelService"

PlaneShooterController = {}

function PlaneShooterController:new()

	local controller = {}
	controller.view = nil
	controller.levelModel = nil

	function controller:onRegister()
		print("PlaneShooterController::onRegister")
		self.view:addEventListener("onPlaneShooterNewGame", self)
		self.levelModel = self.context:getModel("levelModel")
	end

	function controller:onRemove()
		print("PlaneShooterController::onRemove")
		self.view:removeEventListener("onPlaneShooterNewGame", self)
	end

	function controller:onPlaneShooterNewGame(event)
		print("PlaneShooterController::onPlaneShooterNewGame")
		local level = LoadLevelService:new("level3.json")
		print("level: ", level)
		local model = self.levelModel
		model:init(level)
		model:start()
	end

	return controller

end

return PlaneShooterController