require "com.jessewarden.planeshooter.utils.Collection"
require "com.jessewarden.planeshooter.factories.WeaponFactory"
EquipModel = {}

function EquipModel:new()
	local model   = {}
	model.classType = "EquipModel"
	
	model.guns    = nil
	model.cannons = nil
	model.missiles = nil
	model.bodies  = nil
	model.engines = nil

	function model:init()
		self.guns    = self:getCollection()
		self.cannons = self:getCollection()
		self.missiles = self:getCollection()
		self.bodies   = self:getCollection()
		self.engines = self:getCollection()
	end

	function model:getMemento()
		return {
			guns = WeaponFactory.getMementoArrayFromWeaponCollection(self.guns),
			cannons = WeaponFactory.getMementoArrayFromWeaponCollection(self.cannons),
			missiles = WeaponFactory.getMementoArrayFromWeaponCollection(self.missiles),
			bodies = WeaponFactory.getMementoArrayFromWeaponCollection(self.bodies),
			engines = WeaponFactory.getMementoArrayFromWeaponCollection(self.engines)
		}
	end

	function model:setMemento(memento)
		self.guns = WeaponFactory.setCollectionFromMementoArray(memento.guns)
		self.cannons = WeaponFactory.setCollectionFromMementoArray(memento.cannons)
		self.missiles = WeaponFactory.setCollectionFromMementoArray(memento.missiles)
		self.bodies = WeaponFactory.setCollectionFromMementoArray(memento.bodies)
		self.engines = WeaponFactory.setCollectionFromMementoArray(memento.engines)
	end

	function model:getCollection()
		local collection = Collection:new()
		--collection:addEventListener("onChange", function(e)self:onCollectionChanged(e)end)
		return collection
	end

	function model:onCollectionChanged(event)
		local collection = event.target
		if collection == self.guns then
			self:sendChange("EquipModel_gunsChanged", collection, event.kind)
		elseif collection == self.cannons then
			self:sendChange("EquipModel_cannonsChanged", collection, event.kind)
		elseif collection == self.missiles then
			self:sendChange("EquipModel_missilesChanged", collection, event.kind)
		elseif collection == self.bodies then
			self:sendChange("EquipModel_bodiesChanged", collection, event.kind)
		elseif collection == self.engines then
			self:sendChange("EquipModel_enginesChanged", collection, event.kind)
		end
	end

	function model:sendChange(name, collection, kind)
		--Runtime:dispatchEvent({name=name, collection=collection, kind=kind})
	end

	return model
end

return EquipModel