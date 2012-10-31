require "com.jessewarden.planeshooter.vo.weapons.WeaponVO"
MisslesVO = {}

function MisslesVO:new()

	local rocket     = WeaponVO:new()
	rocket.classType = "MisslesVO"
	rocket.fireSpeed = 1500
	rocket.damage    = 7
	rocket.weaponType      = WeaponVO.TYPE_MISSILE
	rocket.weight    = 5

	return rocket
end


return MisslesVO