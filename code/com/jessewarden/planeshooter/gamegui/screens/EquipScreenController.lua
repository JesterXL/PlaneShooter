

EquipScreenController = {}

function EquipScreenController:new()
	local controller       = {}
	controller.equipModel  = nil
	controller.equipScreen = nil

	function controller:initialize(equipModel, playerModel, equipScreen)
		self.equipModel  = equipModel
		self.playerModel = playerModel
		self.equipScreen = equipScreen
		self.equipScreen:addEventListener("onEquipGun", self)
		self.equipScreen:addEventListener("onRemoveGun", self)

		self.equipScreen:setGuns(self.equipModel.guns)
		self.equipScreen:setEquippedGun(self.playerModel.gun)

		Runtime:addEventListener("PlayerModel_gunChanged", self)
	end
	
	function controller:destroy()
		--Runtime:removeEventListener("EquipModel_gunsChanged", self)
	end

	function controller:PlayerModel_gunChanged(event)
		self.equipScreen:setEquippedGun(self.playerModel.gun)
	end

	function controller:onEquipGun(event)
		-- already have a gun equipped? If so, move it back
		local equippedGun = self.playerModel:removeGun()
		print("equippedGun: ", equippedGun)
		if equippedGun ~= nil then
			self.equipModel.guns:addItem(equippedGun)
		end
		-- take new gun and remove it from equipModel
		local gs = self.equipModel.guns
		local gLen = #gs
		print("equipModel.guns before: " .. gLen)
		self.equipModel.guns:removeItem(event.vo)
		gLen = #gs
		print("equipModel.guns after: " .. gLen)

		-- take new gun and equip it to the player
		print("event.vo: ", event.vo)
		self.playerModel:equipGun(event.vo)
	end

	function controller:onRemoveGun(event)
		self.equipScreen:setEquippedGun(nil)
		-- unequip our gun
		local oldGun = self.playerModel:removeGun()
		-- put back in our inventory
		self.equipModel.guns:addItem(oldGun)
	end
	
	return controller
end
	
return EquipScreenController