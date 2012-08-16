require "gtween"

NewContinueLevelsScreen = {}


function NewContinueLevelsScreen:new()
	local screen = display.newGroup()
	
	function screen:init()
		if self.newButton ~= nil then return true end

		local newButton = display.newImage(screen, "button_new_game.png", 0, 0)
		function newButton:touch(event)
			if event.phase == "ended" then
				screen:dispatchEvent({name="onNewGameTouched", target=self})
				return true
			end
		end
		newButton:addEventListener("touch", newButton)
		screen.newButton = newButton

		local continueButton = display.newImage(screen, "button_continue.png", 0, 0)
		function continueButton:touch(event)
			if event.phase == "ended" then
				screen:dispatchEvent({name="onContinueTouched", target=self})
				return true
			end
		end
		continueButton:addEventListener("touch", continueButton)
		screen.continueButton = continueButton

		local levelSelectButton = display.newImage(screen, "button_level_select.png", 0, 0)
		function levelSelectButton:touch(event)
			if event.phase == "ended" then
				screen:dispatchEvent({name="onLevelSelectTouched", target=self})
				return true
			end
		end
		screen.levelSelectButton = levelSelectButton
		levelSelectButton:addEventListener("touch", levelSelectButton)
	end

	function screen:destroy()
		if self.newButton == nil then return true end

		screen.newButton:removeSelf()
		screen.continueButton:removeSelf()
		screen.levelSelectButton:removeSelf()

		screen.newButton = nil
		screen.continueButton = nil
		screen.levelSelectButton = nil
	end

	function screen:show(showContinue)
		assert(showContinue ~= nil, "You must set showContinue to true or false.")
		assert(type(showContinue) == "boolean", "showContinue must be a boolean.")
		local stage = display.getCurrentStage()
		local myHeight
		if showContinue == true then
			myHeight = stage.height / 4
		else
			myHeight = stage.height / 3
		end
		local currentY = myHeight

		local continueButton = screen.continueButton
		local newButton = screen.newButton
		local levelSelectButton = screen.levelSelectButton

		continueButton.alpha = 1
		newButton.alpha = 1
		levelSelectButton.alpha = 1

		continueButton.isVisible = showContinue

		if showContinue == true then
			continueButton.targetX = stage.width / 2 - continueButton.width / 2
			continueButton.y = currentY

			currentY = currentY + myHeight
		end

		newButton.targetX = stage.width / 2 - newButton.width / 2
		newButton.y = currentY

		currentY = currentY + myHeight

		levelSelectButton.targetX = stage.width / 2 - newButton.width / 2
		levelSelectButton.y = currentY

		continueButton.x = stage.width + 100
		newButton.x = continueButton.x
		levelSelectButton.x = continueButton.x

		local delay = 0
		local delayIncrement = 0.150
		local time = 0.3
		if showContinue == true then
			TweenUtils.tweenButtonIn(continueButton, continueButton.targetX, time, delay)
			delay = delay + delayIncrement
		end

		TweenUtils.tweenButtonIn(newButton, newButton.targetX, time, delay)
		delay = delay + delayIncrement
		TweenUtils.tweenButtonIn(levelSelectButton, levelSelectButton.targetX, time, delay)
	end

	function screen:hide(target)
		assert(target ~= nil, "Target cannot be nil.")

		local stage = display.getCurrentStage()
		local continueButton = screen.continueButton
		local newButton = screen.newButton
		local levelSelectButton = screen.levelSelectButton

		local buttons = {continueButton, newButton, levelSelectButton}
		if continueButton.isVisible == false or continueButton == target then
			table.remove(buttons, table.indexOf(buttons, continueButton))
		end

		if newButton == target then
			table.remove(buttons, table.indexOf(buttons, newButton))
		end

		if levelSelectButton == target then
			table.remove(buttons, table.indexOf(buttons, levelSelectButton))
		end
		
		local HIT_TIME = 1
		local OUT_TIME = 1
		TweenUtils.tweenButtonHit(target, HIT_TIME)
		local i = 1
		while buttons[i] do
			TweenUtils.tweenButtonOut(buttons[i], OUT_TIME)
			i = i + 1
		end
	end

	screen:init()

	return screen
end

return NewContinueLevelsScreen