
PauseButton = {}

function PauseButton:new(x, y)
	local pauseButton = display.newImage("button_pause.png")
	pauseButton.x = x
	pauseButton.y = y
	return pauseButton
end

return PauseButton