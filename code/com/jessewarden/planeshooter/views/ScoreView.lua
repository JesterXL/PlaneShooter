require "com.jessewarden.planeshooter.utils.TweenUtils"
gtween = require("gtween")
ScoreView = {}

function ScoreView:new()
	local view = display.newGroup()
	view.classType = "ScoreView"

	local img = display.newImage("gamegui_score_text.png")
	view:insert(img)
	img:setReferencePoint(display.TopLeftReferencePoint)
	--img.x = 15

	local text = display.newText("0", 0, 0, native.systemFont, 14)
	--text:setReferencePoint(display.TopLeftReferencePoint)
	text:setTextColor(255, 255, 0)
	view:insert(text)
	view.field = text
	text.y = 20

	view.score = 0
	view.newScore = 0
	view.scoreTween = nil

	function view:comma_value(n) -- credit http://richard.warburton.it
		local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
		return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
	end
	
	function view:setScore(value)
		assert(value, "you must pass a valid value.")
		self.newScore = self.score
		self.score = value
		local str
		if type(value) == "number" then
			str = tostring(value)
		else
			str = value
		end
		--text.text = self:comma_value(str)
		--text.x = text.width / 2 + 4 -- <-- gee, that doesn't look like Flash...
		
		-- TODO: figure out how to tween this like you do in Flash; 
		-- I forget how to do getter/setters in Lua

		TweenUtils.stopTween(self.tween)
		self.tween = gtween.new(self, 1, 
			{newScore=value})
		self.tween.onChange = function(tween)
		--print("score: ", self.newScore)
			view.field.text = self:comma_value(tostring(math.round(self.newScore)))
			view.field.x = view.field.width / 2 + 4
		end
		self.tween.onComplete = function()
			--self.text.text = self:comma_value(tostring(math.round(self.newValue)))
			--self.text.x = self.text.width / 2 + 4
		end
	end

	function view:init()
		Runtime:dispatchEvent({name="ScoreView_init", target=self})
	end

	function view:destroy()
		Runtime:dispatchEvent({name="ScoreView_destroy", target=self})
		img:removeSelf()
		text:removeSelf()
		self:removeSelf()
	end

	view:init()

	return view
end

return ScoreView
