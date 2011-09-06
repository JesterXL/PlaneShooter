require "gamegui_ItemRenderer"
require "widget"

InventoryList = {}

function InventoryList:new(width, height)
	local group = display.newGroup()
	local scrollView = widget.newScrollView{ x=0, y=0, width=width, height=height }
    group:insert( scrollView.view )
	group.scrollView = scrollView
	
	function group:removeItems()
		local i = 1
		while scrollView[i] do
			scrollView:remove(i)
		end	
	end
	
	function group:setDataProvider(itemVOList)
		self:removeItems()
		self.itemVOList = itemVOList
		local i = 1
		local w = width
		local h = height
		local scrollView = self.scrollView
		local startY = 0
		while itemVOList[i] do
			local vo = itemVOList[i]
			local itemRenderer = ItemRenderer:new(w, 72)
			scrollView:insert(itemRenderer)
			itemRenderer:setItem(vo)
			itemRenderer.y = startY
			startY = startY + itemRenderer.height
			i = i + 1
		end
	end
	
	function group:destroy()
		display.remove( scrollView )
	    scrollView = nil
	end
	
	return group
end

return InventoryList