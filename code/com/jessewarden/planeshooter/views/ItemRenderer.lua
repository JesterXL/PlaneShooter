require "com.jessewarden.planeshooter.core.constants"
require "com.jessewarden.planeshooter.views.controls.Text"

ItemRenderer = {}

function ItemRenderer:new(width, height)

	local group = display.newGroup()
	
	local text = Text:new(0, 0, width * .8, height)
	local priceText = Text:new(0, 0, width * 8, 20)
	--priceText.
	local platform = system.getInfo("platformName")
	group.isDevice = false
	if platform == "Android" or platform == "iPhone OS" then
		group.isDevice = true
	end
	group:insert(text)
	group:insert(priceText)
	text.isVisible = false
	priceText.isVisible = false
	
	function group:setItem(itemVO)
		self.itemVO = itemVO
		if self.image ~= nil then self.image:removeSelf() end
		local txt = text
		txt.text = ""
		txt.isVisible = false
		local pText = priceText
		pText.text = ""
		pText.isVisible = false
		
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
			pText.text = itemVO.cost .. constants.CREDITS_NAME
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