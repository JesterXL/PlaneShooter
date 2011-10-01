
BuySellEquipView = {}

function BuySellEquipView:new(width, height)
	
	local ANIMATION_SPEED = 200
	
	local group = display.newGroup()
	
	local function initButton(button, x, y, eventName)
		button:setReferencePoint(display.TopLeftReferencePoint)
		button:addEventListener("touch", button)
		group:insert(button)
		button.x = x
		button.y = y
		function button:touch(event)
			if event.phase == "ended" then
				local g = group
				g:dispatchEvent({name=eventName, target=g})
				return true
			end
		end
		button.isVisible = false
		return true
	end
	
	local backButton = display.newImage("button_back.png")
	initButton(backButton, 0, 0, 0, "onBack")
	
	local buyButton = display.newImage("button_buy.png")
	initButton(buyButton, 
				(width / 2) - (buyButton.width / 2), 
				backButton.y + backButton.height + 8, 
				"onBuy")
	
	local sellButton = display.newImage("button_sell.png")
	initButton(sellButton, 
				(width / 2) - (sellButton.width / 2), 
				buyButton.y + buyButton.height + 8, 
				"onSell")
				
	local equipButton = display.newImage("button_equip.png")
	initButton(equipButton,
				(width / 2) - (equipButton.width / 2),
				sellButton.y + sellButton.height + 8,
				"onEquip")
	
	local function destroyButton(button)
		endTween(button)
		button:removeEventListener("touch", button)
		button:removeSelf()
		return true
	end
	
	function group:destroy()
		destroyButton(backButton)
		destroyButton(buyButton)
		destroyButton(sellButton)
		destroyButton(equipButton)
		group:removeSelf()
		return true
	end
	
	local function endTween(button)
		if button.tween then transition.cancel(button.tween) end
		return true
	end
	
	local function setupTween(button, delay)
		button.isVisible = true
		button.tween = transition.from(button, {time=ANIMATION_SPEED, delay=delay, x=width, transitionEase=easing.outExpo})
	end
	
	function group:hide()
		endTween(backButton)
		endTween(buyButton)
		endTween(sellButton)
		endTween(equipButton)
		
		backButton.isVisible = false
		buyButton.isVisible = false
		sellButton.isVisible = false
		equipButton.isVisible = false
	end
	
	function group:show()
		local speed = ANIMATION_SPEED
		setupTween(backButton, 0)
		setupTween(buyButton, speed)
		setupTween(sellButton, speed * 2)
		setupTween(equipButton, speed * 3)
	end
	
	return group
end	

return BuySellEquipView