require "com.jessewarden.planeshooter.gamegui.MoviePlayerView"
LevelView = {}

function LevelView:new()

	local view = display.newGroup()
	view.moviePlayer = nil

	function view:init()
		self.moviePlayer = MoviePlayerView:new()
		self:insert(self.moviePlayer)
	end

	function view:onMovie(movieVO)
		self.moviePlayer:startMovie(movieVO)
	end

	view:init()
	

	return view
end

return LevelView