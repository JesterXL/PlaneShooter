require "com.jessewarden.planeshooter.vo.weapons.WeaponVO"
Gun30CaliberVO = {}

function Gun30CaliberVO:new()

	local gun = WeaponVO:new()
	gun.fireSpeed = 300
	gun.damage = 1
	return gun
end


return Gun30CaliberVO