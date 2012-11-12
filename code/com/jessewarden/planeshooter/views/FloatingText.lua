require "com.jessewarden.planeshooter.core.constants"

FloatingText = {}

function FloatingText:new()
	local floating = display.newGroup()
	floating.textPool = {}

	function floating:getField()
		local field
		if table.maxn(self.textPool) > 0 then
			field = self.textPool[1]
			assert(field ~= nil, "Failed to get item from pool")
			table.remove(self.textPool, table.indexOf(self.textPool, field))
			assert(field ~= nil, "After cleanup, field got nil.")
		else
			field = display.newText("", 0, 0, 60, 60, native.systemFont, constants.FLOATING_TEXT_FONT_SIZE)
			function field:onComplete(obj)
				if self.tween then
					transition.cancel(field.tween)
					field.tween = nil
				end
				if self.alphaTween then
					transition.cancel(field.alphaTween)
					field.alphaTween = nil
				end
				table.insert(floating.textPool, field)
			end
		end
		assert(field ~= nil, "After if statement, field is nil.")
		field:setReferencePoint(display.TopLeftReferencePoint)
		self:insert(field)
		return field
	end

	function floating:showText(targetX, targetY, amount)
		local field = self:getField()
		field:setTextColor(255, 255, 255)
		
		field.x = targetX
		field.y = targetY
		field.alpha = 1
		
		local amountText = tostring(amount)

		field.text = amountText
		local newTargetY = targetY - 40
		field.tween = transition.to(field, {y=newTargetY, time=500, transition=easing.outExpo})
		field.alphaTween = transition.to(field, {alpha=0, time=200, delay=700, onComplete=field})

		local delay = 0
		local incrementDelay = function()
			delay = delay + 50
			return delay
		end
		local range = 2
		local incrementRange = function()
			--range = range + 1
			return range
		end
		self:showYellowText(field, targetX, targetY, newTargetY, amount, incrementDelay(), incrementRange())
		self:showYellowText(field, targetX, targetY, newTargetY, amount, incrementDelay(), incrementRange())
		self:showYellowText(field, targetX, targetY, newTargetY, amount, incrementDelay(), incrementRange())
		self:showYellowText(field, targetX, targetY, newTargetY, amount, incrementDelay(), incrementRange())
		self:showYellowText(field, targetX, targetY, newTargetY, amount, incrementDelay(), incrementRange())

	end

	function floating:showYellowText(field, targetX, targetY, newTargetY, amount, delay, range)
		local yellowField = self:getField()
		yellowField:setTextColor(255, 255, 0)
		yellowField.x = targetX
		local amountText = tostring(amount)
		yellowField.text = amountText

		yellowField.alpha = 0
		yellowField.x = targetX
		yellowField.y = newTargetY
		--local range = 2
		local yellowTargetX = targetX + math.random(-range, range)
		local yellowTargetY = newTargetY + math.random(-range, range)
		local tweenDelay = 500 + delay
		local alphaDelay = 700 + delay
		yellowField.tween = transition.to(yellowField, {alpha=1, x=yellowTargetX, y=yellowTargetY, time=100, delay=tweenDelay, transition=easing.outExpo})
		yellowField.alphaTween = transition.to(yellowField, {alpha=0, time=100, delay=alphaDelay, onComplete=yellowField})
	end

	function floating:onShowFloatingText(event)
		-- convert from local to global coordinates, and back again
		--local targetX, targetY = event.target:localToContent(event.x, event.y)
		--targetX, targetY = self:contentToLocal(targetX, targetY)
		local targetX = event.x
		local targetY = event.y
		self:showText(targetX, targetY, event.amount)
	end


	function floating:init()
		self:destroy()
		self.textPool = {}
		Runtime:addEventListener("onShowFloatingText", self)
	end

	function floating:destroy()
		Runtime:removeEventListener("onShowFloatingText", self)
		local len = self.numChildren
		for i=len,1,-1 do
			self:remove(i)
		end

		local pool = self.textPool
		len = #pool
		for i=len,1,-1 do
			table.remove(pool, i)
		end
	end

	floating:init()

	return floating
end

return FloatingText