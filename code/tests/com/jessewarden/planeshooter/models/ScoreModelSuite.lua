module(..., package.seeall)

function suite_setup()
	require "com.jessewarden.planeshooter.models.ScoreModel"
end

function setup()
	model = ScoreModel:new()
end

function teardown()
	model = nil
end

function test_defaultScore()
	assert_true(model.score == 0, "Default score for ScoreVlue is not 0.")
end

--[[
function test_bounds0Check()
	local response, err = pcall(model:setScore(-5))
	assert_true(model.score == 0, "score bounds are not being respected for lows.")
end
]]--

function test_setOne()
	model:setScore(1)
	assert_true(model.score == 1, "score does not equal 1.")
end

function test_addOne()
	model:addToScore(1)
	assert_true(model.score == 1, "score does not equal 1 after adding 1 to default of 0.")
end

function test_setToTwoAndAddOne()
	model:setScore(2)
	model:addToScore(1)
	assert_true(model.score == 3, "score does not equal 3.")
end

function test_setToTwoAndAddThree()
	model:setScore(2)
	model:addToScore(3)
	assert_true(model.score == 5, "score does not equal 5.")
end


