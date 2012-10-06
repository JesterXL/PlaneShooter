require "com.jessewarden.planeshooter.vo.weapons.WeaponVO"
RockMisslesVO = {}

function RockMisslesVO:new()

	local rocket     = WeaponVO:new()
	rocket.classType = "RockMisslesVO"
	rocket.fireSpeed = 1500
	rocket.damage    = 7
	rocket.type      = WeaponVO.TYPE_ROCKET
	rocket.weight    = 5

	return rocket
end


return RockMisslesVO