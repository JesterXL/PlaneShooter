module(..., package.seeall)

function suite_setup()
	require "com.jessewarden.planeshooter.core.constants"
	require "com.jessewarden.planeshooter.models.PlayerModel"
end

function setup()
	model = PlayerModel:new()
end

function teardown()
	model = nil
end

function test_defaultHitPointsAre10()
	assert_true(model.hitPoints == 10, "Default hitPoints for PlayerModel are not 10.")
end

function test_bounds0Check()
	model:setHitPoints(-5)
	assert_true(model.hitPoints == 0, "HitPoints bounds are not being respected for lows.")
end

function test_boundsMaxCheck()
	model:setHitPoints(9001)
	assert_true(model.hitPoints == model.maxHitPoints, "HitPoints bounds are not being respected for highs.")
end

function test_defaultValidWeight()
	assert_true(model.weight <= model.maxWeight)
end

function test_equipWoodBodyWeight()
	local startWeight = model.weight
	startWeight = startWeight + 1
	require "com.jessewarden.planeshooter.vo.bodies.BodyWoodVO"
	local body = BodyWoodVO:new()
	model:equipBody(body)
	assert_equal(startWeight, model.weight, 0, "Model weight does not equal adjusted weight.")
end

function test_equipWoodBodyDefense()
	local startDefense = model.weight
	startDefense = startDefense + 1
	require "com.jessewarden.planeshooter.vo.bodies.BodyWoodVO"
	local body = BodyWoodVO:new()
	model:equipBody(body)
	assert_equal(startDefense, model.defense, 0, "Model defense does not equal adjusted defense.")
end

function test_equipEnginePowerUp()
	local startPower = model.power
	startPower = startPower + 2
	require "com.jessewarden.planeshooter.vo.engines.EngineDualAllisonsVO"
	local engine = EngineDualAllisonsVO:new()
	model:equipEngine(engine)
	assert_equal(startPower, model.power, 0, "Model power does not equal adjusted power.")
end

function test_equipGunWeight()
	local startWeight = model.weight
	startWeight = startWeight + 1
	require "com.jessewarden.planeshooter.vo.weapons.guns.Gun30CaliberVO"
	local gun = Gun30CaliberVO:new()
	model:equipGun(gun)
	assert_equal(startWeight, model.weight, 0, "Model weight does not equal adjusted weight.")
end

function test_gunAndEngineWeight()
	local startWeight = model.weight
	startWeight = startWeight + 3
	require "com.jessewarden.planeshooter.vo.weapons.guns.Gun30CaliberVO"
	local gun = Gun30CaliberVO:new()
	require "com.jessewarden.planeshooter.vo.engines.EngineDualAllisonsVO"
	local engine = EngineDualAllisonsVO:new()
	model:equipGun(gun)
	model:equipEngine(engine)
	assert_equal(startWeight, model.weight, 0, "Model weight does not equal adjusted weight.")
end

function test_equipOnlyOneGun()
	require "com.jessewarden.planeshooter.vo.weapons.guns.Gun30CaliberVO"
	require "com.jessewarden.planeshooter.vo.weapons.guns.Gun50CaliberVO"
	local gun = Gun30CaliberVO:new()
	local gun2 = Gun50CaliberVO:new()
	model:equipGun(gun)
	model:equipGun(gun2)
	assert_true(gun2 == model.gun, "The setting of gun2 didn't work.")
end
