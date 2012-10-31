require "com.jessewarden.planeshooter.vo.weapons.WeaponVO"
MissileHeatSeekingVO = {}

function MissileHeatSeekingVO:new()

	local rocket     = WeaponVO:new()
	rocket.classType = "MissileHeatSeekingVO"
	rocket.fireSpeed = 1250
	rocket.damage    = 5
	rocket.weaponType      = WeaponVO.TYPE_MISSILE
	rocket.weight    = 5

	return rocket
end


return MissileHeatSeekingVO