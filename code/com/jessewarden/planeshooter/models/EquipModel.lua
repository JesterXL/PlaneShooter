require "com.jessewarden.planeshooter.utils.Collection"
EquipModel = {}

function EquipModel:new()
	local model   = {}
	
	model.guns    = nil
	model.cannons = nil
	model.rockets = nil
	model.bodies  = nil
	model.engines = nil

	function model:init()
		self.guns    = self:getCollection()
		self.cannons = self:getCollection()
		self.rockets = self:getCollection()
		self.bodies   = self:getCollection()
		self.engines = self:getCollection()
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
		elseif collection == self.rockets then
			self:sendChange("EquipModel_rocketsChanged", collection, event.kind)
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