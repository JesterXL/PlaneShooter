ProgressBar = {}
 
function ProgressBar:new(backRed, backGreen, backBlue, frontRed, frontGreen, frontBlue, startWidth, startHeight)
	local group = display.newGroup()

	function group:setProgress(current, max)
		if current == nil then
			error("parameter 'current' cannot be nil.")
		end

		if max == nil then
			error("parameter 'max' cannot be nil")
		end
		
		local percent = current / max
		local desiredWidth = startWidth * percent
		
		if self.back ~= nil then
			self.back:removeSelf()
		end

		local back = display.newRect(0, 0, startWidth, startHeight)
		back:setReferencePoint(display.TopLeftReferencePoint)
		back:setFillColor(backRed, backGreen, backBlue)
		self:insert(back)
		self.back = back
		back.strokeWidth = 3
		back:setStrokeColor(0, 0, 0)

		if self.front ~= nil then
			self.front:removeSelf()
		end

		local front = display.newRect(0, 0, desiredWidth, startHeight)
		front:setReferencePoint(display.TopLeftReferencePoint)
		front:setFillColor(frontRed, frontGreen, frontBlue)
		self:insert(front)
		self.front = front

		if self.preview ~= nil then
			self.preview:removeSelf()
		end
	end

	function group:showProgressAdjusted(current, preview, max)
		self:setProgress(current, max)

		local less = current - preview
		local percent = math.abs(less) / max
		local desiredWidth = startWidth * percent
		local previewWidth = desiredWidth


		local preview = display.newRect(0, 0, desiredWidth, startHeight)
		preview:setReferencePoint(display.TopLeftReferencePoint)
		
		--preview:setStrokeColor(0, 255, 0)
		--preview.strokeWidth = 3
		--self.front:setStrokeColor(0, 0, 255)
		--self.front.strokeWidth = 3

		if less >= 0 then
			preview:setFillColor(255, 0, 0)
		else
			preview:setFillColor(0, 255, 0)
		end
		self:insert(preview)
		self.preview = preview
		--self.front:toFront()

		percent = current / max
		desiredWidth = startWidth * percent
		if less >= 0 then
			preview.x = self.front.x + self.front.width - preview.width
		else
			preview.x = desiredWidth
		end
	end


 
	return group
end
 
return ProgressBar