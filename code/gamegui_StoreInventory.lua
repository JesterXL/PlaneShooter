StoreInventory = {}

function StoreInventory:new(width, height)

	local ANIMATION_SPEED = 200

	local group = display.newGroup()
	
	local backButton = display.newImage("button_back.png")
	backButton:setReferencePoint(display.TopLeftReferencePoint)
	function backButton:touch(event)
		local g = group
		g:dispatchEvent({name="onBack", target=g})
		return true
	end
	backButton:addEventListener("touch", backButton)
	group:insert(backButton)
	backButton.x = 0
	backButton.y = 0
	backButton.tween = transition.from(backButton, {time=ANIMATION_SPEED, x=width, transitionEase=easing.outExpo})
	
	
	local function initTab(tab, name, x, y, delay)
		tab:setReferencePoint(display.TopLeftReferencePoint)
		function tab:touch(event)
			local g = group
		end
		tab:addEventListener("touch", tab)
		group:insert(tab)
		tab.x = x
		tab.y = y
		tab.tween = transition.from(tab, {time=ANIMATION_SPEED, x=width, transitionEase=easing.outExpo, delay=delay})
		return true
	end
	
	local targetY = backButton.y + backButton.height
	local targetX = -8
	
	local enginesTab = display.newImage("button_tab_engines.png")
	initTab(enginesTab, "engines", targetX, targetY + 6, ANIMATION_SPEED * 3)
	
	local armorTab = display.newImage("button_tab_armor.png")
	initTab(armorTab, "armor", targetX, targetY + 7, ANIMATION_SPEED * 2)
	
	local weaponTab = display.newImage("button_tab_weapons.png")
	initTab(weaponTab, "weapons", targetX, targetY, ANIMATION_SPEED)
	
	return group
end

return StoreInventory