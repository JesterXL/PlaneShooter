require "com.jessewarden.planeshooter.views.MoviePlayerView"
require "com.jessewarden.planeshooter.views.screens.StageIntroScreen"
require "com.jessewarden.planeshooter.views.screens.LevelCompleteScreen"
require "com.jessewarden.planeshooter.views.controls.ScrollingTerrain"
require "com.jessewarden.planeshooter.views.ScoreView"
require "com.jessewarden.planeshooter.views.FloatingText"
require "com.jessewarden.planeshooter.views.DebugView"

require "com.jessewarden.planeshooter.sprites.player.Player"

LevelView = {}

function LevelView:new()

	local view = display.newGroup()
	view.classType = "LevelView"
	view.moviePlayer = nil
	view.levelStartView = nil
	view.levelEndView = nil
	view.scrollingTerrainView = nil
	view.scoreView = nil
	view.playerView = nil
	view.floatingText = nil
	view.debugView = nil

	function view:init()
		self.scrollingTerrainView = ScrollingTerrain:new("Level1Background.jpg")
		self:insert(self.scrollingTerrainView)
		--self.scrollingTerrainView.isVisible = false

		self.scoreView = ScoreView:new()
		self:insert(self.scoreView)

		self.moviePlayer = MoviePlayerView:new()
		self:insert(self.moviePlayer)
		self.moviePlayer:addEventListener("onMovieEnded", self)

		self.floatingText = FloatingText:new()
		self:insert(self.floatingText)

		self.debugView = DebugView:new()
		self:insert(self.debugView)
		self.debugView.x = display.getCurrentStage().contentWidth - 100

		self.playerView = Player:new()

		Runtime:dispatchEvent({name = "LevelView_init", target=self})
	end

	function view:destroy()
		self.scrollingTerrainView:removeSelf()

		self.moviePlayer:removeEventListener("onMovieEnded", self)
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
			self.levelEndView:addEventListener("onNextLevelTouched", function(e)
				self.levelEndView:hide()
			end)
			self.levelEndView:addEventListener("onHideAnimationCompleted", function()
				view:dispatchEvent({name="onNextLevel", target=view})
			end)
		end
		self.levelEndView:show()

		self.scrollingTerrainView:stop()
	end

	view:init()
	

	return view
end

return LevelView