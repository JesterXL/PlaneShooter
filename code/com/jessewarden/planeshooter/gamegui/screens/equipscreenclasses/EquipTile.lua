EquipTile = {}

function EquipTile:new()

	local tile = display.newGroup()
	local tileImage = display.newImage("equip_tile.png")
	tile.image = tileImage
	tile:insert(tileImage)
	local tileRect = display.newRect(tile, 0, 0, tileImage.width, tileImage.height)
	tile:insert(tileRect)
	tileRect:setStrokeColor(255, 255, 0)
	tileRect.strokeWidth = 4
	tileRect.alpha = 0
	tileRect:setFillColor(255, 255, 255)
	tile.rect = tileRect

	tile.showingBorder = false

	function tile:touch(event)
		local p = event.phase
		local ex = event.x
		local ey = event.y

		if p == "began" or p == "moved" then
			--print("x: ", ex, ", y: ", ey, ", my x: ", self.x, ", my y: ", self.y, ", w: ", self.width, ", h: ", self.height)
			if ex >= self.x and ex <= self.x + self.width then
				if ey >= self.y and ey <= self.y + self.height then
					self:drawBorder(true)
					return true
				end
			end
			self:drawBorder(false)
		else
			self:drawBorder(false)
		end
	end


	function tile:drawBorder(show)
		if show == self.showingBorder then return true end
		self.showingBorder = show
		if self.tween ~= nil then
			transition.cancel(self.tween)
		end

		if show == true then
			--self.tween = transition.to(self.rect, {time = 300, alpha = 1})
			tile.rect.alpha = 1
		else
			--self.tween = transition.to(self.rect, {time = 300, alpha = 0})
			tile.rect.alpha = 0
		end
	end

	Runtime:addEventListener("touch", tile)

	return tile

end

return EquipTile