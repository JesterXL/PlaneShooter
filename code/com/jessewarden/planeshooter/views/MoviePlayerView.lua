require "com.jessewarden.planeshooter.views.DialogueView"
require "com.jessewarden.planeshooter.sounds.SoundManager"
local gtween = require("gtween")

MoviePlayerView = {}


function MoviePlayerView:new()
	local group = display.newGroup()
	group.classType = "MoviePlayerView"
	group.currentDialogue = 0
	group.movie = nil
	group.dialogueView1 = nil
	group.dialogueView2 = nil
	group.lastCharacter = nil
	group.lastDialogueView = nil
	group.tweenIn = nil
	group.tweenOut = nil
	group.firstTime = false
	group.totalTimePassed = nil
	--group:addEventListener("touch", function() return true end)
	--group:addEventListener("tap", function() return true end)
	--group.lastSoundChannel = nil
	--group.staticStartSound = nil
	--group.staticEndSound = nil
	--group.staticStartSoundChannel = nil
	--group.staticEndSoundChannel = nil
	group.playingMovie = false

	function group:startMovie(movie)
		assert(movie ~= nil, "Movie cannot be nil.")
		--assert(movie.classType == "movie", "Movie has an unrecognized classType.")
		self.playingMovie = true
		self.movie = movie
		self.currentDialogue =  0
		self.firstTime = true
		self.currentView = 1
		self.lastDialogueView = nil
		group:nextDialogue()
		gameLoop:addLoop(self)
	end

	function group:getDialogueView(right)
		local dialogueView = DialogueView:new(right)
		self:insert(dialogueView)
		--dialogueView:addEventListener("touch", self)
		dialogueView.isHitTestable = false
		dialogueView.alpha = 0
		return dialogueView
	end
	
	function group:hideDialogue(dialogueView)
		assert(dialogueView ~= nil, "You cannot pass in a nil dialogue view.")
		self:cancelTweenOut()
		local targetY = dialogueView.y
		targetY = targetY - (dialogueView.height / 2)
		dialogueView.alpha = 1
		self.tweenOut = transition.to(dialogueView, 
									{time=constants.DIALOGUE_MOVE_OUT_TIME, 
									y=targetY, alpha=0, 
									transition=easing.inExpo, 
									onComplete=onHideDialogueComplete
									})
		return true
	end

	function group:cancelTweenOut()
		if self.tweenOut ~= nil then
			transition.cancel(self.tweenOut)
			self.tweenOut = nil
		end
	end

	function group:cancelTweenIn()
		if self.tweenIn ~= nil then
			transition.cancel(self.tweenIn)
			self.tweenIn = nil
		end
	end
	
	function group:showDialogue(dialogueView)
		self:cancelTweenIn()
		local stage = display.getCurrentStage()

		local targetY = stage.height - dialogueView.height
		dialogueView.y = targetY + (dialogueView.height / 2)
		dialogueView.alpha = 0
		dialogueView.isVisible = true
		self.tweenIn = transition.to(dialogueView, 
										{
											time=constants.DIALOGUE_MOVE_IN_TIME, 
											y=targetY, 
											alpha=1, 
											transition=easing.outExpo, 
											onComplete=onShowDialogueComplete
										})
	end
	
	function onShowDialogueComplete(dialogueView)
		dialogueView:showLights()
	end
	
	function onHideDialogueComplete(dialogueView)
		dialogueView.isVisible = false
	end

	function group:nextDialogue()
		--print("MoviePlayerView::nextDialogue", system.getTimer())
		if self.playingMovie == false then return false end

		self.currentDialogue = group.currentDialogue + 1
		local movie = self.movie
		local currentIndex = self.currentDialogue
		local dialogue = movie.dialogues[currentIndex]
		self.currentDialogueVO = dialogue
		if dialogue ~= nil then
			if self.firstTime == true then
				self.dialogueView1 = self:getDialogueView(false)
				self.dialogueView2 = self:getDialogueView(true)
			end
			
			local lastCharacter = self.lastCharacter
			--print("lastCharacter: ", lastCharacter, ", dialogue.characterName: ", dialogue.characterName)
			local dialogueView
			local switch = false
			local viewToHide = nil
			local viewToShow = nil
			if lastCharacter ~= dialogue.characterName and self.firstTime == false then
				switch = true
				if self.currentView == 1 then
					self.currentView = 2
					viewToHide = self.dialogueView1
					dialogueView = self.dialogueView2
				else
					self.currentView = 1
					viewToHide = self.dialogueView2
					dialogueView = self.dialogueView1
				end
				self.lastDialogueView = dialogueView
				viewToShow = dialogueView
			else
				if self.lastDialogueView ~= nil then
					dialogueView = self.lastDialogueView
				else
					dialogueView = self.dialogueView1
					self.lastDialogueView = dialogueView
				end
			end
			
			self.lastCharacter = dialogue.characterName
			
			dialogueView:setCharacter(dialogue.characterName, dialogue.emotion)
			dialogueView:setText(dialogue.message)
			if self.firstTime == true then
				self:showDialogue(dialogueView)
				self.firstTime = false
			end
			
			if switch == true then
				self:hideDialogue(viewToHide)
				self:showDialogue(viewToShow)
			end
			
			if dialogue.autoPlay == true and dialogue.advanceOnAudioEnd == false then
				if dialogue.dialogueTime ~= nil then
					self.totalTimePassed = 0
				else
					self.totalTimePassed = nil
				end
			else
				self.totalTimePassed = nil
			end

			self:destroyAudioFile()
			if dialogue.audioFile ~= nil then
				self:playAudio(dialogue)
			end
		else
			-- end of conversation
			--print("MoviePlayerView::end of conversation")
			self.playingMovie = false
			self:hideDialogue(self.lastDialogueView)
			gameLoop:removeLoop(self)
			self:destroyAudioFile()
			self:dispatchEvent({name="onMovieEnded", target=self})
		end

	end

	function group:playAudio(dialogueVO)
		--print("MoviePlayerView::playAudio, name: ", dialogueVO.audioFile)
		if dialogueVO.radio == true then
			SoundManager.inst:playStaticStartSound(function() group:onStaticStartSoundComplete() end)
		else
			self:playCurrentDialogueVO()
		end
	end

	function group:onStaticStartSoundComplete()
		self:playCurrentDialogueVO()
	end

	function group:playCurrentDialogueVO()
		--print("MoviePlayerView::playCurrentDialogueVO", system.getTimer())
		local dialogueVO = self.currentDialogueVO
		--self.audioFile = audio.loadSound(dialogueVO.audioFile)
		local callback
		if dialogueVO.radio == true then
			callback = function()
				group:playStaticEnd()
			end
		else
			callback = function()
				group:onDialogueComplete()
			end
		end
		--self.lastSoundChannel = audio.play(self.audioFile, {onComplete=callback})
		SoundManager.inst:playDialogue(dialogueVO.audioFile, callback)
	end

	function group:playStaticEnd()
		--print("MoviePlayerView::playStaticEnd", system.getTimer())
		local callback = function()
			group:onDialogueComplete()
		end
		--self.staticEndSoundChannel = audio.play(self.staticEndSound, {onComplete=callback})
		SoundManager.inst:playStaticEndSound(callback)
	end

	function group:destroyAudioFile()
		--print("MoviePlayerView::destroyAudioFile")
		--self:stopAllStaticAudio()
		SoundManager.inst:stopAllStaticSounds()
		SoundManager.inst:destroyDialogue()
		--if self.audioFile ~= nil then
			--audio.stop(self.lastSoundChannel)
			--self.lastSoundChannel = nil
			--audio.dispose(self.audioFile)
			--self.audioFile = nil
		--end
	end

	function group:onDialogueComplete()
		--print("MoviePlayerView::onDialogueComplete", system.getTimer())
		-- FIXME: I believe this is because nextDialogue runs, nilling out the VO.
		-- maybe we should put it into the event instead?
		if self.currentDialogueVO == nil then
			SoundManager.inst:destroyDialogue()
			return true
		end

		if self.currentDialogueVO.advanceOnAudioEnd == true then
			--self:destroyAudioFile()
			SoundManager.inst:destroyDialogue()
			self:nextDialogue()
		end
	end
	
	--[[
	function group:touch(event)
		Runtime:dispatchEvent({name="MoviePlayerView_onTouch", target=self})
		if event.phase == "ended" then
			--print("MoviePlayerView::touch")
			--self:destroyAudioFile()
			SoundManager.inst:destroyDialogue()
			self:nextDialogue()
			return true
		end
	end
	]]--

	function group:tick(milliseconds)
		--print("self.totalTimePassed: ", self.totalTimePassed)
		if self.movie == nil then return true end
		--if self.movie.autoPlay == false then return true end
		if self.totalTimePassed == nil then return true end

		self.totalTimePassed = self.totalTimePassed + milliseconds
		if self.totalTimePassed >= self.currentDialogueVO.dialogueTime then
			self.totalTimePassed = nil
			self:nextDialogue()
		end
	end

	return group
end

return MoviePlayerView