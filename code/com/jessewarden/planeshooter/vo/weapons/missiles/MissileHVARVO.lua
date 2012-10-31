require "com.jessewarden.planeshooter.vo.weapons.WeaponVO"
MissileHVARVO = {}

function MissileHVARVO:new()

	local gun     = WeaponVO:new()
	gun.classType = "MissileHVARVO"
	gun.fireSpeed = 2000
	gun.damage    = 6
	gun.weaponType      = WeaponVO.TYPE_MISSILE
	gun.weight    = 4

	return gun
end


return MissileHVARVO