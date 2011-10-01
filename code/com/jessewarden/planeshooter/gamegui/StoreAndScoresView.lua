require "gtween"

StoreAndScoresView = {}

function StoreAndScoresView:new(width, height)
	
	local ANIMATION_SPEED = 200
	
	local group = display.newGroup()
	
	local leaveButton = display.newImage("button_leave.png")
	leaveButton:setReferencePoint(display.TopLeftReferencePoint)
	
	function leaveButton:touch(event)
		if event.phase == "ended" then
			self:dispatchEvent({name="onLeave", target=self})
			return true
		end
	end
	
	leaveButton:addEventListener("touch", leaveButton)
	group:insert(leaveButton)
	leaveButton.x = 0
	leaveButton.y = 0
	leaveButton.isVisible = false
	
	
	local storeButton = display.newImage("button_store.png")
	storeButton:setReferencePoint(display.TopLeftReferencePoint)
	
	function storeButton:touch(event)
		if event.phase == "ended" then
			local g = group
			g:dispatchEvent({name="onStore", target=g})
			return true
		end
	end
	
	storeButton:addEventListener("touch", storeButton)
	group:insert(storeButton)
	storeButton.x = (width / 2) - (storeButton.width / 2)
	storeButton.y = leaveButton.y + leaveButton.height
	storeButton.isVisible = false
	
	
	local highscoreButton = display.newImage("button_highscores.png")
	highscoreButton.name = "highscoreButton"
	highscoreButton:setReferencePoint(display.TopLeftReferencePoint)
	
	function highscoreButton:touch(event)
		if event.phase == "ended" then
			local g = group
			g:dispatchEvent({name="onHighscores", target=g})
			return true
		end	
	end
	
	highscoreButton:addEventListener("touch", highscoreButton)
	group:insert(highscoreButton)
	highscoreButton.x = (width / 2) - (highscoreButton.width / 2)
	highscoreButton.y = storeButton.y + storeButton.height
	highscoreButton.isVisible = false
	
	function group:destroy()
		self:hide()
		
		leaveButton:removeEventListener("touch", leaveButton)
		leaveButton:removeSelf()
		
		storeButton:removeEventListener("touch", storeButton)
		storeButton:removeSelf()
		
		highscoreButton:removeEventListener("touch", highscoreButton)
		highscoreButton:removeSelf()
	end
	
	function group:hide()
		if leaveButton.tween then transition.cancel(leaveButton.tween) end
		if storeButton.tween then transition.cancel(storeButton.tween) end
		if highscoreButton.tween then transition.cancel(highscoreButton.tween) end
		
		leaveButton.isVisible = false
		storeButton.isVisible = false
		highscoreButton.isVisible = false
	end
	
	function group:show()
		leaveButton.isVisible = true
		storeButton.isVisible = true
		highscoreButton.isVisible = true
		
		leaveButton.tween = transition.from(leaveButton, {time=ANIMATION_SPEED, x=width, transition=easing.outExpo})
		storeButton.tween = transition.from(storeButton, {time=ANIMATION_SPEED, x=width, delay=ANIMATION_SPEED, transition=easing.outExpo})
		highscoreButton.tween = transition.from(highscoreButton, {time=ANIMATION_SPEED, x=width, delay=ANIMATION_SPEED * 2, transition=easing.outExpo})
	end
	
	return group
end

return StoreAndScoresView