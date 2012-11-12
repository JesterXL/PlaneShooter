LevelCompleteScreen = {}

function LevelCompleteScreen:new(levelNumber, totalScore)

	local screen = display.newGroup()
	screen.levelNumber = nil
	screen.startScore = nil
	screen.totalScore = nil

	function screen:init(levelNumber, totalScore)
		self.levelNumber = levelNumber
		self.totalScore = totalScore

		local levelText = display.newText(screen, "Level " .. levelNumber, 0, 0, native.systemFont, 32)
		screen:initChild("levelText", levelText)

		--local completeText = display.newText(screen, "Complete!", 0, 0, native.systemFont, 32)
		local completeText = display.newImage(screen, "text_complete.png", 0, 0)
		screen:initChild("completeText", completeText)

		local scoreTitleText = display.newImage(screen, "text_score.png", 0, 0)
		scoreTitleText:setReferencePoint(display.TopLeftReferencePoint)
		screen:initChild("scoreTitleText", scoreTitleText)

		local scoreText = display.newText(screen, "000", 0, 0, native.systemFont, 18)
		--scoreText:setReferencePoint(display.TopLeftReferencePoint)
		screen:initChild("scoreText", scoreText)

		local achievementsTitleText = display.newImage(screen, "text_achievements.png", 0, 0)
		achievementsTitleText:setReferencePoint(display.TopLeftReferencePoint)
		screen:initChild("achievementsTitleText", achievementsTitleText)

		local submitHighscoresButton = display.newImage(screen, "button_submit_highscores.png", 0, 0)
		screen:initChild("submitHighscoresButton", submitHighscoresButton)
		function submitHighscoresButton:touch(event)
			if event.phase == "ended" then
				screen:dispatchEvent({name="onSubmitHighscoresTouched", target=screen})
				return true
			end
		end
		submitHighscoresButton:addEventListener("touch", submitHighscoresButton)

		local planeUpgradesButton = display.newImage(screen, "button_plane_upgrades.png", 0, 0)
		screen:initChild("planeUpgradesButton", planeUpgradesButton)
		function planeUpgradesButton:touch(event)
			if event.phase == "ended" then
				screen:dispatchEvent({name="onPlaneUpgradesButtonTouched", target=screen})
				return true
			end
		end
		planeUpgradesButton:addEventListener("touch", planeUpgradesButton)


		local nextLevelButton = display.newImage(screen, "button_next_level.png", 0, 0)
		screen:initChild("nextLevelButton", nextLevelButton)
		function nextLevelButton:touch(event)
			if event.phase == "ended" then
				screen:dispatchEvent({name="onNextLevelTouched", target=screen})
				return true
			end
		end
		nextLevelButton:addEventListener("touch", nextLevelButton)

	end

	function screen:initChild(name, child)
		screen:insert(child)
		screen[name] = child
		child.isVisible = false
	end

	function screen:show()
		local stage = display.getCurrentStage()

		local levelText = self.levelText
		local completeText = self.completeText
		local scoreTitleText = self.scoreTitleText
		local scoreText = self.scoreText
		
		TweenUtils.stopTween(levelText.tween)
		TweenUtils.stopTween(completeText.tween)
		TweenUtils.stopTween(scoreTitleText.tween)
		TweenUtils.stopTween(scoreText.tween)

		local centerX = stage.width / 2 - levelText.width / 2
		levelText.isVisible = true
		levelText.alpha = 0
		levelText.x = centerX
		levelText.y = -20
		local delay = 0.5

		levelText.tween = gtween.new(levelText, 0.5, {x=centerX, y=20, alpha=1}, 
			{ease=gtween.easing.outBack})

		completeText.isVisible = true
		completeText.alpha = 0
		
		local startW = completeText.width
		local startH = completeText.height
		completeText.width = completeText.width / 4
		completeText.height = completeText.height / 4
		completeText.x = stage.width / 2 - completeText.width / 2

		local targetY = 20 + levelText.y + levelText.height + 20
		completeText.y = targetY
		completeText.tween = gtween.new(completeText, 0.5, 
			{x=centerX, y=targetY, width=startW, height=startH, alpha=1}, 
			{ease=gtween.easing.outBounce, delay=delay})

		delay = delay + 1
		targetY = targetY + completeText.height + 16
		centerX = scoreTitleText.width
		scoreTitleText.x = -scoreTitleText.width
		scoreTitleText.y = targetY
		scoreTitleText.isVisible = true
		scoreTitleText.alpha = 0
		scoreTitleText.tween = gtween.new(scoreTitleText, 0.3, 
			{x=centerX, alpha=1}, 
			{ease=gtween.easing.outExponential, delay=delay})

		delay = delay + 0.15
		scoreText.isVisible = true
		scoreText.alpha = 0
		scoreText.x = stage.width
		scoreText.y = targetY + scoreTitleText.height / 2 - 5
		local targetX = centerX + scoreTitleText.width + 4
		scoreText.tween = gtween.new(scoreText, 0.3, 
			{x=targetX, alpha=1}, 
			{ease=gtween.easing.outExponential, delay=delay})

		scoreText.tween.onComplete = function()
			screen:onScoreTweenComplete()
		end
	end

	function screen:onScoreTweenComplete()
		self.startScore = 0
		local scoreText = self.scoreText
		local scoreTitleText = self.scoreTitleText
		TweenUtils.stopTween(scoreText.tween)
		scoreText.tween = gtween.new(self, 2, 
			{startScore=self.totalScore})
		scoreText.tween.onChange = function(tween)
			scoreText.text = tostring(math.round(screen.startScore))
			scoreText.x = scoreTitleText.x + scoreTitleText.width + 20
		end
		scoreText.tween.onComplete = function()
			scoreText.x = scoreTitleText.x + scoreTitleText.width + 20
			screen:onScoreUpCountComplete()
		end
	end

	function screen:onScoreUpCountComplete()
		local achievementsTitleText = self.achievementsTitleText
		local submitHighscoresButton = self.submitHighscoresButton
		local planeUpgradesButton = self.planeUpgradesButton
		local nextLevelButton = self.nextLevelButton
		local scoreTitleText = self.scoreTitleText

		TweenUtils.stopTween(achievementsTitleText.tween)
		TweenUtils.stopTween(submitHighscoresButton.tween)
		TweenUtils.stopTween(planeUpgradesButton.tween)
		TweenUtils.stopTween(nextLevelButton.tween)

		local stage = display.getCurrentStage()
		--local centerX = stage.width / 2 - achievementsTitleText.width / 2
		local centerX = (scoreTitleText.x + scoreTitleText.width) + 8 - achievementsTitleText.width

		local tweenTime = 0.3
		local delay = tweenTime + 1
		achievementsTitleText.x = -achievementsTitleText.width
		achievementsTitleText.y = self.scoreText.y + self.scoreText.height + 8
		achievementsTitleText.isVisible = true
		achievementsTitleText.alpha = 0
		achievementsTitleText.tween = gtween.new(achievementsTitleText, tweenTime, 
			{x=centerX, alpha=1}, 
			{ease=gtween.easing.outExponential, delay=delay})

		delay = delay + tweenTime + 1
		centerX = stage.width / 2 - submitHighscoresButton.width / 2
		submitHighscoresButton.x = stage.width
		submitHighscoresButton.y = achievementsTitleText.y + achievementsTitleText.height + 60
		submitHighscoresButton.isVisible = true
		submitHighscoresButton.alpha = 0

		submitHighscoresButton.tween = gtween.new(submitHighscoresButton, tweenTime, 
			{x=centerX, alpha=1}, 
			{ease=gtween.easing.outBack, delay=delay})

		centerX = stage.width / 2 - planeUpgradesButton.width / 2
		planeUpgradesButton.x = stage.width
		planeUpgradesButton.y = submitHighscoresButton.y + submitHighscoresButton.height + 8
		planeUpgradesButton.alpha = 0
		planeUpgradesButton.isVisible = true

		delay = delay + tweenTime
		planeUpgradesButton.tween = gtween.new(planeUpgradesButton, tweenTime, 
			{x=centerX, alpha=1}, 
			{ease=gtween.easing.outBack, delay=delay})

		centerX = stage.width / 2 - nextLevelButton.width / 2
		nextLevelButton.x = stage.width
		nextLevelButton.y = planeUpgradesButton.y + planeUpgradesButton.height + 8
		nextLevelButton.alpha = 0
		nextLevelButton.isVisible = true

		delay = delay + tweenTime
		nextLevelButton.tween = gtween.new(nextLevelButton, tweenTime, 
			{x=centerX, alpha=1}, 
			{ease=gtween.easing.outBack, delay=delay})
		nextLevelButton.tween.onComplete = function()
			screen:dispatchEvent({name="onAnimationCompleted", target=screen})
		end
	end

	function screen:hide()

		local stage = display.getCurrentStage()

		local levelText = self.levelText
		local completeText = self.completeText
		local scoreTitleText = self.scoreTitleText
		local scoreText = self.scoreText
		local achievementsTitleText = self.achievementsTitleText
		local submitHighscoresButton = self.submitHighscoresButton
		local planeUpgradesButton = self.planeUpgradesButton
		local nextLevelButton = self.nextLevelButton
		
		TweenUtils.stopTween(levelText.tween)
		TweenUtils.stopTween(completeText.tween)
		TweenUtils.stopTween(scoreTitleText.tween)
		TweenUtils.stopTween(scoreText.tween)
		TweenUtils.stopTween(achievementsTitleText.tween)
		TweenUtils.stopTween(submitHighscoresButton.tween)
		TweenUtils.stopTween(planeUpgradesButton.tween)
		TweenUtils.stopTween(nextLevelButton.tween)

		local targetX = -nextLevelButton.width
		local tweenTime = 0.3
		nextLevelButton.tween = gtween.new(nextLevelButton, tweenTime, 
			{x=targetX, alpha=0}, 
			{ease=gtween.easing.inBack})

		local delay = tweenTime
		planeUpgradesButton.tween = gtween.new(planeUpgradesButton, tweenTime, 
			{x=targetX, alpha=0}, 
			{ease=gtween.easing.inBack, delay=delay})

		delay = delay + tweenTime
		submitHighscoresButton.tween = gtween.new(submitHighscoresButton, tweenTime, 
			{x=targetX, alpha=0}, 
			{ease=gtween.easing.inBack, delay=delay})

		tweenTime = 0.3
		delay = delay + tweenTime
		achievementsTitleText.tween = gtween.new(achievementsTitleText, tweenTime, 
			{x=targetX, alpha=0}, 
			{ease=gtween.easing.inBack, delay=delay})

		delay = delay + tweenTime
		scoreText.tween = gtween.new(scoreText, tweenTime, 
			{x=targetX, alpha=0}, 
			{ease=gtween.easing.inBack, delay=delay})

		scoreTitleText.tween = gtween.new(scoreTitleText, tweenTime, 
			{x=targetX, alpha=0}, 
			{ease=gtween.easing.inBack, delay=delay})

		delay = delay + tweenTime
		completeText.tween = gtween.new(completeText, tweenTime, 
			{x=targetX, alpha=0}, 
			{ease=gtween.easing.inExponential, delay=delay})

		delay = delay + tweenTime
		levelText.tween = gtween.new(levelText, tweenTime, 
			{x=targetX, alpha=0}, 
			{ease=gtween.easing.inExponential, delay=delay})

		levelText.tween.onComplete = function()
			screen:dispatchEvent({name="onHideAnimationCompleted", target=screen})
		end
	end

	screen:init(levelNumber, totalScore)

	return screen

end

return LevelCompleteScreen
