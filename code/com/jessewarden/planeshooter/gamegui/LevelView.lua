require "com.jessewarden.planeshooter.gamegui.MoviePlayerView"
require "com.jessewarden.planeshooter.gamegui.screens.StageIntroScreen"
require "com.jessewarden.planeshooter.gamegui.screens.LevelCompleteScreen"
require "com.jessewarden.planeshooter.gamegui.controls.ScrollingTerrain"

LevelView = {}

function LevelView:new()

	local view = display.newGroup()
	view.moviePlayer = nil
	view.levelStartView = nil
	view.levelEndView = nil
	view.scrollingTerrainView = nil

	function view:init()
		self.scrollingTerrainView = ScrollingTerrain:new("debug_terrain_2.jpg")
		self:insert(self.scrollingTerrainView)

		self.moviePlayer = MoviePlayerView:new()
		self:insert(self.moviePlayer)
	end

	function view:onMovie(movieVO)
		self.moviePlayer:startMovie(movieVO)
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