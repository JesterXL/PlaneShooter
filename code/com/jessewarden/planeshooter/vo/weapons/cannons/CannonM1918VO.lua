require "com.jessewarden.planeshooter.vo.weapons.WeaponVO"
CannonM1918VO = {}

function CannonM1918VO:new()

	local gun     = WeaponVO:new()
	gun.classType = "CannonM1918VO"
	gun.fireSpeed = 3000
	gun.damage    = 4
	gun.type      = WeaponVO.TYPE_CANNON
	gun.weight    = 5
	return gun
end


return CannonM1918VO