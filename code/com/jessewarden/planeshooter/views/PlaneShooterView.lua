require "com.jessewarden.planeshooter.views.screens.TitleScreen"
require "com.jessewarden.planeshooter.views.LevelView"
require "com.jessewarden.planeshooter.controllers.LevelViewController"

PlaneShooterView = {}

function PlaneShooterView:new()

	local game = display.newGroup()
	game.classType = "PlaneShooterView"
	game.titleScreen = nil
	game.newContinueLevelsScreen = nil
	game.lastButtonPressed = nil
	game.levelView = nil

	function game:init()
		print("PlaneShooterView::init")
		local screen
		if game.titleScreen == nil then
			screen = TitleScreen:new()
			screen:addEventListener("onStartGameTouched", self)
			screen:addEventListener("onTitleScreenHideComplete", self)
			game.titleScreen = screen
			self:insert(screen)
		end
		screen:show()
		Runtime:dispatchEvent({name="PlaneShooterView_init", target=self})
	end

	function game:destroy()
		print("PlaneShooterView::destroyd")
		Runtime:dispatchEvent({name="PlaneShooterView_destroy", target=self})
	end

	function game:onStartGameTouched(event)
		game.titleScreen:hide()
	end

	function game:onTitleScreenHideComplete(event)
		self.titleScreen:destroy()
		self.titleScreen = nil

		if self.levelView == nil then
			print("\tcreating LevelView...")
			local levelView = LevelView:new()
			self:insert(levelView)
			self.levelView = levelView
		end
		self:dispatchEvent({name = "onPlaneShooterNewGame", target = self})
	end

	game:init()

	return game

end

return PlaneShooterView