require "gamegui_DialogueView"
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
	group:addEventListener("touch", function() return true end)
	group:addEventListener("tap", function() return true end)

	function group:startMovie(movie)
		assert(movie ~= nil, "Movie cannot be nil.")
		assert(movie.classType == "movie", "Movie has an unrecognized classType.")
		self.movie = movie
		self.currentDialogue =  0
		self.firstTime = true
		self.currentView = 1
		self.lastDialogueView = nil
		group:nextDialogue()
	end

	function group:getDialogueView(right)
		local dialogueView = DialogueView:new(right)
		self:insert(dialogueView)
		dialogueView:addEventListener("touch", self)
		dialogueView.alpha = 0
		return dialogueView
	end
	
	function group:hideDialogue(dialogueView)
		assert(dialogueView ~= nil, "You cannot pass in a nil dialogue view.")
		if self.tweenOut ~= nil then
			transition.cancel(self.tweenOut)
			self.tweenOut = nil
		end
		local targetY = dialogueView.y
		targetY = targetY - (dialogueView.height / 2)
		dialogueView.alpha = 1
		self.tweenOut = transition.to(dialogueView, {time=constants.DIALOGUE_MOVE_OUT_TIME, y=targetY, alpha=0, transition=easing.inExpo})
		return true
	end
	
	function group:showDialogue(dialogueView)
		if self.tweenIn ~= nil then
			transition.cancel(self.tweenIn)
			self.tweenIn = nil
		end

		local stage = display.getCurrentStage()

		local targetY = stage.height - dialogueView.height
		dialogueView.y = targetY + (dialogueView.height / 2)
		dialogueView.alpha = 0
		self.tweenIn = transition.to(dialogueView, {time=constants.DIALOGUE_MOVE_IN_TIME, y=targetY, alpha=1, transition=easing.outExpo, onComplete=onShowDialogueComplete})
	end
	
	function onShowDialogueComplete(dialogueView)
		dialogueView:showLights()
	end

	function group:nextDialogue()
		self.currentDialogue = group.currentDialogue + 1
		local movie = self.movie
		local currentIndex = self.currentDialogue
		local dialogue = movie.dialogues[currentIndex]
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
			
			
		else
			-- end of conversation
			self:hideDialogue(self.lastDialogueView)
			print("MoviePlayerView::dispatching movieEnded")
			self:dispatchEvent({name="movieEnded", target=self})
		end

	end
	
	function group:touch(event)
		if event.phase == "ended" then
			self:nextDialogue()
			return true
		end
	end

	return group
end

return MoviePlayerView