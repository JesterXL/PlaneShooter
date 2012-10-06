require "com.jessewarden.planeshooter.vo.weapons.WeaponVO"
RocketHeatSeeekingMissleVO = {}

function RocketHeatSeeekingMissleVO:new()

	local rocket     = WeaponVO:new()
	rocket.classType = "RocketHeatSeeekingMissleVO"
	rocket.fireSpeed = 1250
	rocket.damage    = 5
	rocket.type      = WeaponVO.TYPE_ROCKET
	rocket.weight    = 5

	return rocket
end


return RocketHeatSeeekingMissleVO