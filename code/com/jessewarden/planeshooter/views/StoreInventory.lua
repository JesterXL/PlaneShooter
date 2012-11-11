require "com.jessewarden.planeshooter.views.InventoryList"

StoreInventory = {}

function StoreInventory:new(width, height)

	local ANIMATION_SPEED = 200

	local group = display.newGroup()
	local tabsGroup = display.newGroup()
	group:insert(tabsGroup)
	
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
		tab.name = name
		function tab:touch(event)
			if event.phase == "ended" then
				local name = event.target.name
				local g = group
				if name == "weapons" then
					g:showWeapons()
				elseif name == "armor" then
					g:showArmor()
				elseif name == "engines" then
					g:showEngines()
				end
				return true
			end
		end
		tab:addEventListener("touch", tab)
		tabsGroup:insert(tab)
		tab.x = x
		tab.y = y
		tab.tween = transition.from(tab, {time=ANIMATION_SPEED, x=width, transitionEase=easing.outExpo, delay=delay})
		return true
	end
	
	local targetY = backButton.y + backButton.height
	local targetX = 0
	
	local tabBackground = display.newImage("button_tab_bottom.png")
	tabBackground.isHitTestable = false
	tabsGroup:insert(tabBackground)
	
	local weaponTab = display.newImage("button_tab_weapons.png")
	initTab(weaponTab, "weapons", targetX, targetY + 3, ANIMATION_SPEED)
	
	local armorTab = display.newImage("button_tab_armor.png")
	initTab(armorTab, "armor", targetX + 110, targetY + 7, ANIMATION_SPEED * 2)
	
	local enginesTab = display.newImage("button_tab_engines.png")
	initTab(enginesTab, "engines", targetX + 210, targetY + 6, ANIMATION_SPEED * 3)
	
	tabBackground.y = weaponTab.y + weaponTab.height
	
	local inventoryList = InventoryList:new(width, height - tabBackground.y - tabBackground.height)
	inventoryList:addEventListener("onItemTouched", onItemTouched)
	group:insert(inventoryList)
	inventoryList.y = tabBackground.y + (tabBackground.height / 2)
	
	function group:showWeapons()
		print("show weapons")
		local items = {}
		local i
		local max = 20
		for i=1,max,1 do
			local des = "Weapon " .. i
			local vo = {icon="jxl_logo.png", description=des}
			table.insert(items, vo)
		end
		inventoryList:setDataProvider(items)
		
		enginesTab:toBack()
		armorTab:toBack()
		weaponTab:toFront()
	end
	
	function group:showArmor()
		print("show armor")
		local items = {}
		local i
		local max = 20
		for i=1,max,1 do
			local des = "Armor " .. i
			local vo = {icon="jxl_logo.png", description=des}
			table.insert(items, vo)
		end
		inventoryList:setDataProvider(items)
		
		weaponTab:toBack()
		enginesTab:toBack()
		armorTab:toFront()
	end
	
	function group:showEngines()
		print("show engines")
		local items = {}
		local i
		local max = 20
		for i=1,max,1 do
			local des = "Engine " .. i
			local vo = {icon="jxl_logo.png", description=des}
			table.insert(items, vo)
		end
		inventoryList:setDataProvider(items)
		
		weaponTab:toBack()
		armorTab:toBack()
		enginesTab:toFront()
	end
	
	group:showWeapons()
	
	return group
end

return StoreInventory