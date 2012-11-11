--com.jessewarden.planeshooter.factories.WeaponFactory
require "com.jessewarden.planeshooter.utils.Collection"
WeaponFactory = {}

function WeaponFactory.getWeaponFromMemento(memento)
	local weapon = _G[memento.classType]:new()
	WeaponFactory.setWeaponMemento(weapon, memento)
	return weapon
end

function WeaponFactory.setWeaponMemento(weapon, memento)
	local key,value
	for key,value in pairs(weapon) do
		weapon[key] = memento[key]
	end
end

function WeaponFactory.getMementoFromWeapon(weapon)
	if weapon == nil then return nil end
	local json = require "json"
	return json:encode(weapon)
end

function WeaponFactory.getMementoArrayFromWeaponCollection(collection)
	local json = require("json")
	local list = {}
	local items = collection.items
	local len = #items
	local i = 1
	while items[i] do
		local vo = items[i]
		local mementoVO = json:encode(vo)
		table.insert(list, i, vo)
		i = i + 1
	end
	return list
end

function WeaponFactory.setCollectionFromMementoArray(list)
	local json = require("json")
	local collection = Collection:new()
	local len = #list
	local i = 1
	while list[i] do
		local memento = list[i]
		local weapon = WeaponFactory.getWeaponFromMemento(memento)
		collection:addItem(weapon)
		i = i + 1
	end
	return collection
end



return WeaponFactory