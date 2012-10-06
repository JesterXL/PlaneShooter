
WeaponVO 				= {}
WeaponVO.TYPE_GUN 		= "gun"
WeaponVO.TYPE_CANNON 	= "cannon"
WeaponVO.TYPE_ROCKET 	= "rocket"

function WeaponVO:new()

	local gun = {}
	
	gun.classType = "WeaponVO"
	gun.fireSpeed = 300
	gun.damage = 1
	gun.type = WeaponVO.TYPE_GUN
	gun.weight = 1

	return gun

end


return WeaponVO