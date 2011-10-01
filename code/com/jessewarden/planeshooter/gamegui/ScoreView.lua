ScoreView = {}
ScoreView.classType = "ScoreView"

function ScoreView:new()
	local view = display.newGroup()
	view.classType = "ScoreView"

	local img = display.newImage("gamegui_score_text.png")
	view:insert(img)
	img.x = 15

	local text = display.newText("0", 0, 0, native.systemFont, 14)
	text:setTextColor(255, 255, 0)
	view:insert(text)
	text.y = 20

	view.score = 0
	view.newScore = 0
	view.scoreTween = nil

	function view:setScore(value)
		text.text = value
		-- TODO: figure out how to tween this like you do in Flash; I forget how to do getter/setters in Lua
		--[[
		self.newScore = value
		if(view.scoreTween ~= nil) then
			transition.cancel(view.scoreTween)
		end
		view.scoreTween = transition.to(self.score, {score = value, time=1000, transition = easing.outExpo})
		]]--
	end

	function view:destroy()
		img:removeSelf()
		text:removeSelf()
		self:removeSelf()
	end

	return view
end

return ScoreView
