require "com.jessewarden.planeshooter.vo.weapons.WeaponVO"
Gun30CaliberVO = {}

function Gun30CaliberVO:new()

	local gun     = WeaponVO:new()
	gun.classType = "Gun30CaliberVO"
	gun.fireSpeed = 300
	gun.damage    = 1
	gun.weaponType      = WeaponVO.TYPE_GUN
	gun.weight    = 1
	return gun
end


return Gun30CaliberVO