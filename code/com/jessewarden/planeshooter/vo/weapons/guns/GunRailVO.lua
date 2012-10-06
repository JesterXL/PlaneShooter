require "com.jessewarden.planeshooter.vo.weapons.WeaponVO"
GunRailVO = {}

function GunRailVO:new()

	local gun     = WeaponVO:new()
	gun.classType = "GunRailVO"
	gun.fireSpeed = 3000
	gun.damage    = 15
	gun.type      = WeaponVO.TYPE_GUN
	gun.weight    = 3
	
	return gun

end


return GunRailVO