require "com.jessewarden.planeshooter.vo.weapons.WeaponVO"
GunRailVO = {}

function GunRailVO:new()

	local gun = WeaponVO:new()

	gun.fireSpeed = 3000
	gun.damage = 15

	return gun

end


return GunRailVO