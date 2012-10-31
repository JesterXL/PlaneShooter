require "com.jessewarden.planeshooter.vo.weapons.WeaponVO"
Cannon9mmM1VO = {}

function Cannon9mmM1VO:new()

	local gun     = WeaponVO:new()
	gun.classType = "Cannon90mmM1VO"
	gun.fireSpeed = 2500
	gun.damage    = 5
	gun.weaponType      = WeaponVO.TYPE_CANNON
	gun.weight    = 4
	return gun
end


return Cannon9mmM1VO