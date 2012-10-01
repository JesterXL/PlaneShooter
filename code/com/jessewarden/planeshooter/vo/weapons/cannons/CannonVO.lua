require "com.jessewarden.planeshooter.vo.weapons.WeaponVO"
GunCannonVO = {}

function GunCannonVO:new()

	local gun = WeaponVO:new()
	gun.fireSpeed = 1000
	gun.damage = 5
	return gun
end


return GunCannonVO