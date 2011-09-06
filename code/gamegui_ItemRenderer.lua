ItemRenderer = {}

function ItemRenderer:new(width, height)

	local group = display.newGroup()
	
	local text
	local platform = system.getInfo("platformName")
	group.isDevice = false
	if platform == "Android" or platform == "iPhone OS" then
		group.isDevice = true
		text = native.newTextBox( 0, 0, width * .8, height )
		text.hasBackground = false
		text.isEditable = false
		text.align = "left"
		text.font = native.newFont( native.systemFont, 16 )
	else
		text = display.newText("", 0, 0, native.systemFont, 16)
	end
	text:setReferencePoint(display.TopLeftReferencePoint)
	text:setTextColor(255, 255, 255)
	text.size = 16
	group:insert(text)
	text.isVisible = false
	
	function group:setItem(itemVO)
		if self.image ~= nil then self.image:removeSelf() end
		local txt = text
		txt.text = ""
		txt.isVisible = false
		
		if itemVO ~= nil then
			local image = display.newImage(itemVO.icon)
			self.image = image
			image:setReferencePoint(display.TopLeftReferencePoint)
			self:insert(image)
			image.x = 4
			image.y = 4
			image.width = width * .2 - 8
			image.height = image.height
			
			txt.text = itemVO.description
			if self.isDevice == true then
				txt.x = image.x + image.width + 8
			else
				txt.x = image.x + image.width + (txt.width / 2) + 8
			end
			txt.y = image.y + (image.height / 2) - (txt.height / 2)
			txt.isVisible = true
		end
	end

	return group
end

return ItemRenderer