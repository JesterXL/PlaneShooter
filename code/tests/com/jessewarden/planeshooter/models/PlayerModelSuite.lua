module(..., package.seeall)

function test_defaultHitPointsAre10()
	require "com.jessewarden.planeshooter.models.PlayerModel"

	local model = PlayerModel:new()
	assert_true(model.hitPoints == 10, "Default hitPoints for PlayerModel are not 10.")
end

function test_bounds0Check()
	require "com.jessewarden.planeshooter.models.PlayerModel"

	local model = PlayerModel:new()
	model:setHitPoints(-5)
	assert_true(model.hitPoints == 0, "HitPoints bounds are not being respected for lows.")
end

function test_boundsMaxCheck()
	require "com.jessewarden.planeshooter.models.PlayerModel"

	local model = PlayerModel:new()
	model:setHitPoints(9001)
	assert_true(model.hitPoints == model.maxHitPoints, "HitPoints bounds are not being respected for highs.")
end