require "gtween"

StageIntroScreen = {}

function StageIntroScreen:new(width, height, stageNumber, title)

	local screen = display.newGroup()
	
	function screen:init(stageNumber, title)
		local stageNumberText = display.newText(screen, "Stage " .. stageNumber, 0, 0, native.systemFont, 32)
		screen:initChild("stageNumberText", stageNumberText)

		local line = display.newLine(screen, 0, 0, 100, 0)
		screen:initChild("line", line)

		local titleText = display.newText(screen, title, 0, 0, native.systemFont, 18)
		screen:initChild("titleText", titleText)

		local readyText = display.newText(screen, "Ready?", 0, 0, native.systemFont, 14)
		screen:initChild("readyText", readyText)

		local goText = display.newText(screen, "GO!", 0, 0, native.systemFont, 14)
		screen:initChild("goText", goText)
	end

	function screen:initChild(name, child)
		screen:insert(child)
		screen[name] = child
		child.isVisible = false
	end

	function screen:show()
		local stage = display.getCurrentStage()

		local stageNumberText = self.stageNumberText
		local line = self.line
		local titleText = self.titleText

		stageNumberText.isVisible = true
		local sideX = stage.width + 100
		stageNumberText.x = sideX
		stageNumberText.alpha = 0
		local centerX = stage.width / 2
		local startY = stage.height * 0.2

		stageNumberText.y = startY
		startY = startY + stageNumberText.height + 2

		line.isVisible = true
		line.x = sideX
		line.y = startY
		line.alpha = 0
		startY = startY + line.height + 20

		titleText.isVisible = true
		titleText.x = sideX
		titleText.y = startY
		titleText.alpha = 0

		local tweenSpeed = 0.5

		if line.tween ~= nil then
			transition.cancel(line.tween)
		end
		local lineCenter = centerX - 50
		line.tween = gtween.new(line, tweenSpeed, {x=lineCenter, alpha=1}, 
			{ease=gtween.easing.outBack})

		if stageNumberText.tween ~= nil then
			transition.cancel(stageNumberText.tween)
		end
		stageNumberText.tween = gtween.new(stageNumberText, tweenSpeed, {x=centerX, alpha=1}, 
			{ease=gtween.easing.outBack, delay=0.2})

		if titleText.tween ~= nil then
			transition.cancel(titleText.tween)
		end
		titleText.tween = gtween.new(titleText, tweenSpeed, {x=centerX, alpha=1}, 
			{ease=gtween.easing.outBack, delay=1.5})	
		titleText.tween.onComplete = function(e)
			screen:onShowComplete()
		end
	end

	function screen:onShowComplete()
		local stageNumberText = self.stageNumberText
		local line = self.line
		local titleText = self.titleText
		local tweenSpeed = 0.3
		local left = -200
		if line.tween ~= nil then
			transition.cancel(line.tween)
		end
		line.tween = gtween.new(line, tweenSpeed, {x=left, alpha=0}, 
			{ease=gtween.easing.inExponential, delay=3})

		if stageNumberText.tween ~= nil then
			transition.cancel(stageNumberText.tween)
		end
		stageNumberText.tween = gtween.new(stageNumberText, tweenSpeed, {x=-250, alpha=0}, 
			{ease=gtween.easing.inExponential, delay=3.3})

		if titleText.tween ~= nil then
			transition.cancel(titleText.tween)
		end
		titleText.tween = gtween.new(titleText, tweenSpeed, {x=left, alpha=0}, 
			{ease=gtween.easing.inExponential, delay=3.5})
		titleText.tween.onComplete = function(e)
			--screen:onShowComplete()
		end
	end


	function screen:hide()

	end

	screen:init(stageNumber, title)

	return screen
end

return StageIntroScreen