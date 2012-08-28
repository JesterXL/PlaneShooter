require "gtween"
-- com.jessewarden.planetshooter.utils.TweenUtils
TweenUtils = {}

TweenUtils.tweenButtonHit = function(button, time)
	if button.tween ~= nil then
		transition.cancel(button.tween)
	end
	local w = button.width * 2
	local h = button.height * 2
	button.tween = gtween.new(button, time, {width=w, height=h, alpha=0}, {ease=gtween.easing.outExponential})
end

TweenUtils.tweenButtonIn = function(button, targetX, time, delay)
	if button.tween ~= nil then
		transition.cancel(button.tween)
	end
	button.tween = gtween.new(button, time, {x=targetX}, {ease=gtween.easing.outBack, delay=delay})
end

TweenUtils.tweenButtonOut = function(button, time)
	if button.tween ~= nil then
		transition.cancel(button.tween)
	end
	local stage = display.getCurrentStage()
	local targetX = math.random(0, stage.width)
	local targetY = math.random(0, stage.height)
	local rot = math.random(0, 180)
	local w = button.width / 2
	local h = button.height / 2
	button.tween = gtween.new(button, time, {x=targetX, y=targetY, width=w, height=h, alpha=0, rotation=rot}, {ease=gtween.easing.outExponential})
end

TweenUtils.stopTween = function(tween)
	if tween ~= nil then
		if tween.pause then tween:pause() end
		if tween.onComplete then tween.onComplete = nil end
		transition.cancel(tween)
	end
end



return TweenUtils