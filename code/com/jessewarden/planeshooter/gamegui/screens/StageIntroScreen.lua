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
		local delay = 2
		local left = -200
		if line.tween ~= nil then
			transition.cancel(line.tween)
		end
		line.tween = gtween.new(line, tweenSpeed, {x=left, alpha=0}, 
			{ease=gtween.easing.inExponential, delay=delay})

		delay = delay + .3
		if stageNumberText.tween ~= nil then
			transition.cancel(stageNumberText.tween)
		end
		stageNumberText.tween = gtween.new(stageNumberText, tweenSpeed, {x=-250, alpha=0}, 
			{ease=gtween.easing.inExponential, delay=delay})

		delay = delay + .2
		if titleText.tween ~= nil then
			transition.cancel(titleText.tween)
		end
		titleText.tween = gtween.new(titleText, tweenSpeed, {x=left, alpha=0}, 
			{ease=gtween.easing.inExponential, delay=delay})
		titleText.tween.onComplete = function(e)
			screen:onShowStageComplete()
		end
	end

	function screen:onShowStageComplete()
		local stage = display.getCurrentStage()
		local readyText = self.readyText
		local goText = self.goText
		local tweenSpeed = 0.3
		local startY = -20
		local middle = stage.height / 2 - readyText.height / 2

		readyText.x = stage.width / 2 - readyText.width / 2
		readyText.y = startY
		readyText.isVisible = true
		readyText.alpha = 0

		goText.x = stage.width / 2 - goText.width / 2
		goText.y = startY
		goText.isVisible = true
		goText.alpha = 0

		if readyText.tween ~= nil then
			transition.cancel(readyText.tween)
		end
		readyText.tween = gtween.new(readyText, tweenSpeed, {y=middle, alpha=1}, 
			{ease=gtween.easing.outBack})
		readyText.tween.onComplete = function(e)
			screen:onReadyInMiddle()
		end		
	end

	function screen:onReadyInMiddle()
		local readyText = self.readyText
		local goText = self.goText
		local bottom = stage.height + 20
		local tweenSpeed = 0.3
		local middle = stage.height / 2 - readyText.height / 2
		local delay = 0.5
		local w2 = readyText.width * 2
		local h2 = readyText.height * 2

		if readyText.tween ~= nil then
			transition.cancel(readyText.tween)
		end
		readyText.tween = gtween.new(readyText, tweenSpeed, {y=bottom, alpha=0, width=w2, height=h2}, 
			{ease=gtween.easing.inExponential, delay=1})

		if goText.tween ~= nil then
			transition.cancel(goText.tween)
		end
		goText.tween = gtween.new(goText, tweenSpeed, {y=middle, alpha=1}, 
			{ease=gtween.easing.outExponential, delay=1.2})
		goText.tween.onComplete = function()
			screen:onGoInMiddle()
		end
	end

	function screen:onGoInMiddle()
		local tweenSpeed = 0.5
		local goText = self.goText
		local tweenSpeed = 0.5
		if goText.tween ~= nil then
			transition.cancel(goText.tween)
		end
		goText.tween = gtween.new(goText, tweenSpeed, {rotation=360}, 
			{ease=gtween.easing.inBack, delay=1})
		goText.tween.onComplete = function()
			screen:onFinal()
		end
	end

	function screen:onFinal()
		local goText = self.goText
		local tweenSpeed = 1
		local bottom = stage.height + 20
		local w2 = goText.width * 2
		local h2 = goText.height * 2
		if goText.tween ~= nil then
			transition.cancel(goText.tween)
		end
		goText.tween = gtween.new(goText, tweenSpeed, {y=bottom, alpha=0, width=w2, height=h2}, 
			{ease=gtween.easing.outExponential})
	end

	function screen:stopTween(tween)
		if tween ~= nil then
			if tween.pause then tween.pause() end
			if tween.onComplete then tween.onComplete = nil end
			transition.cancel(tween)
		end
	end

	function screen:hide()
		local stageNumberText = self.stageNumberText
		local line = self.line
		local titleText = self.titleText
		local readyText = self.readyText
		local goText = self.goText

		self:stopTween(stageNumberText)
		self:stopTween(line)
		self:stopTween(titleText)
		self:stopTween(readyText)
		self:stopTween(goText)

		self:hideText(stageNumberText)
		self:hideText(line)
		self:hideText(titleText)
		self:hideText(readyText)
		self:hideText(goText)
	end

	function screen:hideText(text)
		text.isVisible = false
		text.alpha = 0
	end

	screen:init(stageNumber, title)

	return screen
end

return StageIntroScreen