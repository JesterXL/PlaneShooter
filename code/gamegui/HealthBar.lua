

function new()
	local healthBarGroup = display.newGroup()
	
	local healthBarBackground = display.newImage("health_bar_background.png", 0, 0)
	healthBarGroup:insert(healthBarBackground)
	--[[
	healthBarBackground.x = stage.width - healthBarBackground.width - 8
	healthBarBackground.y = 8
	--]]
	
	healthBarForeground = display.newImage("health_bar_foreground.png", 0, 0)
	healthBarGroup:insert(healthBarForeground)
	healthBarForeground.x = healthBarBackground.x
	healthBarForeground.y = healthBarBackground.y
	healthBarForeground:setReferencePoint(display.TopLeftReferencePoint)
	
	-- from 0 to 1
	function healthBarGroup:setHealth(value)
		if(value <= 0) then
			value = 0.1
		end

		self.healthBarForeground.xScale = value
		-- NOTE: Makah-no-sense, ese. Basically, setting width is bugged, and Case #677 is documented.
		-- Meaning, no matter what reference point you set, it ALWAYS resizes from center when setting width/height.
		-- So, we just increment based on the negative xReference of "how far my left is from my left origin".
		-- Wow, that was a fun hour.
		self.healthBarForeground.x = healthBarBackground.x + healthBarForeground.xReference
	end
	
	return healthBarGroup
end