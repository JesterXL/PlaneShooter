require "com.jessewarden.planeshooter.views.MoviePlayerView"
require "com.jessewarden.planeshooter.views.screens.StageIntroScreen"
require "com.jessewarden.planeshooter.views.screens.LevelCompleteScreen"
require "com.jessewarden.planeshooter.views.controls.ScrollingTerrain"
require "com.jessewarden.planeshooter.views.ScoreView"

LevelView = {}

function LevelView:new()

	local view = display.newGroup()
	view.classType = "LevelView"
	view.moviePlayer = nil
	view.levelStartView = nil
	view.levelEndView = nil
	view.scrollingTerrainView = nil
	view.scoreView = nil

	function view:init()
		self.scrollingTerrainView = ScrollingTerrain:new("debug_terrain_2.jpg")
		self:insert(self.scrollingTerrainView)

		self.moviePlayer = MoviePlayerView:new()
		self:insert(self.moviePlayer)
		self.moviePlayer:addEventListener("onMovieEnded", self)

		Runtime:dispatchEvent({name = "LevelView_init", target=self})
	end

	function view:destroy()
		self.scrollingTerrainView:removeSelf()

		self.moviePlayer:addEventListener("onMovieEnded", self)
		self.moviePlayer:removeSelf()

		Runtime:dispatchEvent({name = "LevelView_destroy", target=self})
	end

	function view:onMovie(movieVO)
		self.moviePlayer:startMovie(movieVO)
	end

	function view:onMovieEnded(event)
		self:dispatchEvent({name="onMovieEnded", target=self})
	end

	function view:onLevelStart()
		if self.levelStartView == nil then
			self.levelStartView = StageIntroScreen:new(1, "Default Test")
			self:insert(self.levelStartView)
			self.levelStartView:addEventListener("onScreenAnimationCompleted", function()
				self.levelStartView:hide()
			end)
		end
		self.levelStartView:show()

		self.scrollingTerrainView:start()
	end

	function view:onLevelEnd()
		if self.levelEndView == nil then
			self.levelEndView = LevelCompleteScreen:new(1, 3000)
			self:insert(self.levelEndView)
			self.levelEndView:addEventListener("onAnimationCompleted", function()
				self.levelEndView:hide()
			end)
		end
		self.levelEndView:show()

		self.scrollingTerrainView:stop()
	end

	view:init()
	

	return view
end

return LevelView