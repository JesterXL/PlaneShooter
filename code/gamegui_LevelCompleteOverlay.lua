require "constants"

LevelCompleteOverlay = {}

function LevelCompleteOverlay:new(width, height)
	
	assert(width ~= nil, "You must pass in a non-nil width.")
	assert(height ~= nil, "You must pass in a non-nil height.")
	
	local group = display.newGroup()

	function onTitleCentered(title)
		transition.cancel(title.tween)
		title.tween = nil
		group:dispatchEvent({name="onDone", target=self})
	end

	local title = display.newImage("gamegui_levelcomplete_title.png")
	title:setReferencePoint(display.TopLeftReferencePoint)
	group:insert(title)
	title.x = (width / 2) - (title.width / 2)
	title.y = -(title.height)
	local centerY = height / 2
	title.tween = transition.to(title, {time=constants.LEVEL_COMPLETE_TITLE_SPEED, y=centerY, transition=easing.outExpo, onComplete=onTitleCentered})


	return group

end

return LevelCompleteOverlay
