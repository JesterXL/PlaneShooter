DraggableTile = {}

function DraggableTile:new()

	local tile = display.newGroup()
	tile.classType = "DraggableTile"
	--tile:setReferencePoint(display.TopLeftReferencePoint)
	tile.vo = nil
	tile.dragSource = nil
	tile.iconImage = nil

	function tile:destroy()
		self:killTween()
		self.vo = nil
		self:removeEventListener("touch", self)
		self:removeSelf()
	end

	function tile:setVO(vo)
		self.vo = vo
		self:redrawIcon()
	end

	function tile:redrawIcon()
		local img
		local vo = self.vo
		if vo ~= nil and vo.icon ~= nil then
			img = display.newImage(vo.icon)
		else
			img = display.newImage("__temp.png")
		end
		img:setReferencePoint(display.TopLeftReferencePoint)

		if tile.iconImage ~= nil then
			tile.iconImage:removeSelf()
		end
		self.iconImage = img
		self:insert(img)
	end

	function tile:killTween()
		if self.tween ~= nil then
			transition.cancel(self.tween)
		end
		self.tween = nil
	end

	function tile:returnToStartingPosition()
		self:killTween()
		self.tween = transition.to(self, {time=500, x=self.startX, y=self.startY, transition=easing.outExpo})
	end

	function tile:touch(event)
		local phase = event.phase
		if phase == "began" then
			display.getCurrentStage():setFocus(self)
			self:toFront()
			self.startX = self.x
			self.startY = self.y
			self.isFocus = true
			self.x0 = event.x - self.x
			self.y0 = event.y - self.y
			self:dispatchEvent({name="onStartDragging", target=self})
		elseif self.isFocus == true then
			if phase == "moved" then
				self.x = event.x - self.x0
				self.y = event.y - self.y0
			elseif phase == "ended" or phase == "cancelled" then
				display.getCurrentStage():setFocus(nil)
				self.isFocus = false
				self:returnToStartingPosition()
				self:dispatchEvent({name="onStopDragging", target=self})
			end
		end
		--return true
	end

	tile:addEventListener("touch", tile)

	return tile

end

return DraggableTile

