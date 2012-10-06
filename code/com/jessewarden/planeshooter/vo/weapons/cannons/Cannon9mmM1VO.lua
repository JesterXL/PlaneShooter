require "com.jessewarden.planeshooter.vo.weapons.WeaponVO"
Cannon90mmM1VO = {}

function Cannon90mmM1VO:new()

	local gun     = WeaponVO:new()
	gun.classType = "Cannon90mmM1VO"
	gun.fireSpeed = 2500
	gun.damage    = 5
	gun.type      = WeaponVO.TYPE_CANNON
	gun.weight    = 4
	return gun
end


return Cannon90mmM1VO