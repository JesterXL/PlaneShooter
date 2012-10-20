

EquipScreenController = {}

function EquipScreenController:new()
	local controller       = {}
	controller.equipModel  = nil
	controller.equipScreen = nil

	function controller:initialize(equipModel, equipScreen)
		self.equipModel  = equipModel
		self.equipScreen = equipScreen
		Runtime:addEventListener("EquipModel_gunsChanged", self)
		self:EquipModel_gunsChanged()
	end
	
	function controller:destroy()
		--Runtime:removeEventListener("EquipModel_gunsChanged", self)
	end

	function controller:EquipModel_gunsChanged(event)
		self.equipScreen.guns = self.equipModel.guns
		self.equipScreen:redrawGuns()
	end
	
	return controller
end
	
return EquipScreenController