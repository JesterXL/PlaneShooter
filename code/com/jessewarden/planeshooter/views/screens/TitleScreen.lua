require("gtween")

require "com.jessewarden.planeshooter.utils.TweenUtils"

TitleScreen = {}

function TitleScreen:new()
	local screen = display.newGroup()

	local img = display.newImage("screen_title.png")
	img:setReferencePoint(display.TopLeftReferencePoint)
	screen:insert(img)
	img.width = stage.contentWidth
	img.height = stage.contentHeight

	local startButton = display.newImage("button_start.png")
	function startButton:touch(event)
		if(event.phase == "ended") then
			screen:dispatchEvent({name="onStartGameTouched", target=self})
			return true
		end
	end
	startButton:addEventListener("touch", startButton)
	startButton.width = 1
	startButton.height = 1
	
	startButton.y = display.getCurrentStage().height - (134 / 2)
	
	local cover = display.newRect(0, 0, stage.contentWidth, stage.contentHeight)
	cover:setReferencePoint(display.TopLeftReferencePoint)
	cover:setFillColor(0, 0, 0)
	screen:insert(cover)
	cover.width = width
	cover.height = height
	cover.x = 0
	cover.y = 0
	

	function screen:destroy()
		img:removeSelf()
		startButton:removeEventListener("touch", startButton)
		startButton.tween:pause()
		startButton:removeSelf()
		cover:removeSelf()
		self:removeSelf()
		return true
	end

	function hideComplete()
		screen:dispatchEvent({name="onTitleScreenHideComplete", target=screen})
	end

	function screen:show()
		if(startButton.tween == nil) then
			startButton.tween = gtween.new(startButton, 1,
			{
				width=317,
				height=134
			},
			{
				ease = gtween.easing.outBounce,
				delay=2
			})
		else
			startButton.tween:play()
		end
		
		transition.to( cover, {time=1500, alpha=0, transition=easing.inExpo})
	end
	
	function screen:hide()
		if startButton.tween then startButton.tween:pause() end
		TweenUtils.tweenButtonHit(startButton, 1)
		transition.to(cover, {time=500, alpha=1, transition=easing.inExpo, onComplete=hideComplete})
	end

	return screen
end

return TitleScreen