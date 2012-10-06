require "com.jessewarden.planeshooter.vo.weapons.WeaponVO"
RocketHVARVO = {}

function RocketHVARVO:new()

	local gun     = WeaponVO:new()
	gun.classType = "RocketHVARVO"
	gun.fireSpeed = 2000
	gun.damage    = 6
	gun.type      = WeaponVO.TYPE_ROCKET
	gun.weight    = 4

	return gun
end


return RocketHVARVO