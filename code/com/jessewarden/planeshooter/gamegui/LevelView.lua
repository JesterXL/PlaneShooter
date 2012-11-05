require "com.jessewarden.planeshooter.gamegui.MoviePlayerView"
require "com.jessewarden.planeshooter.gamegui.screens.StageIntroScreen"
require "com.jessewarden.planeshooter.gamegui.screens.LevelCompleteScreen"

LevelView = {}

function LevelView:new()

	local view = display.newGroup()
	view.moviePlayer = nil
	view.levelStartView = nil
	view.levelEndView = nil

	function view:init()
		self.moviePlayer = MoviePlayerView:new()
		self:insert(self.moviePlayer)
	end

	function view:onMovie(movieVO)
		self.moviePlayer:startMovie(movieVO)
	end

	function view:onLevelStart()
		if self.levelStartView == nil then
			self.levelStartView = StageIntroScreen:new(1, "Default Test")
			self.levelStartView:addEventListener("onScreenAnimationCompleted", function()
				print("onLevelStart animation completed")
				self.levelStartView:hide()
			end)
		end
		self.levelStartView:show()
	end

	function view:onLevelEnd()
		if self.levelEndView == nil then
			self.levelEndView = LevelCompleteScreen:new(1, 3000)
			self.levelEndView:addEventListener("onAnimationCompleted", function()
				self.levelEndView:hide()
			end)
		end
		self.levelEndView:show()
	end

	view:init()
	

	return view
end

return LevelView