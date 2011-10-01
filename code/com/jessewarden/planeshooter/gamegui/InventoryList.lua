require "com.jessewarden.planeshooter.gamegui.ItemRenderer"

require "widget"

InventoryList = {}

function InventoryList:new(width, height)
	
	local group = display.newGroup()
	
	function group:removeItems()
		print("removeItems")
		
		--[[
		if self.itemVOList == nil then return true end
		local i = 1
		local items = self.itemVOList
		while items[i] do
			scrollView:remove(i)
			--table.remove(scrollView, i)
		end	
		]]--
		
		local g = group
		if g.scrollView ~= nil then
			g.scrollView:removeSelf()
			g.scrollView = nil
		end
		local mask = graphics.newMask("mask.png")
		g.scrollView = widget.newScrollView{ x=0, y=0, width=width, height=height, mask="mask.png"}
		g:insert(g.scrollView.view)
		--g:setMask(mask)
		--g:setReferencePoint( display.CenterReferencePoint )
		--g.maskX = g.x
		--g.maskY = g.y
		
	end
	
	function group:onItemTouched(event)
		if event.phase == "ended" then
			self:dispatchEvent({name="onItemTouched", target=self, item=event.target.itemVO})
			return true
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
			itemRenderer:addEventListener("touch", onItemTouched)
			scrollView:insert(itemRenderer)
			itemRenderer:setItem(vo)
			itemRenderer.y = startY
			startY = startY + itemRenderer.height
			i = i + 1
		end
	end
	
	function group:destroy()
		display.remove( group.scrollView )
	    group.scrollView = nil
	end
	
	return group
end

return InventoryList