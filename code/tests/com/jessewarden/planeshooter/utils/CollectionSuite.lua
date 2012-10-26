module(..., package.seeall)

function suite_setup()
	require "com.jessewarden.planeshooter.utils.Collection"
end

function setup()
	collection = Collection:new()
end

function teardown()
	collection = nil
end

function test_CollectionIsntNil()
	assert_not_nil(collection)
end

function test_DefaultLengthIsZero()
	local len = table.maxn(collection)
	assert_equal(0, len)
end

function test_AddingOneObjectMeansLengthIsOne()
	collection:addItem("cow")
	local len = table.maxn(collection)
	assert_equal(1, len)
end

function test_AddingAndRemovingOneItemEqualsLengthOfZero()
	local t = {}
	collection:addItem(t)
	collection:removeItem(t)
	local len = table.maxn(collection)
	assert_equal(0, len)
end

function test_RemovingADifferentItemFailureDoesntAffectLength()
	collection:addItem("cow")
	collection:removeItem("cow2")
	local len = table.maxn(collection)
	assert_equal(1, len)
end

function test_AddingTwoItemsIsTwoLength()
	collection:addItem("cow")
	collection:addItem("cow")
	local len = table.maxn(collection)
	assert_equal(2, len)
end

function test_AddingTwoItemsIsTwoLength2()
	collection:addItem("cow")
	collection:addItem("cow2")
	local len = table.maxn(collection)
	assert_equal(2, len)
end

function test_AddingTwoSingleObjectReferencesIsStillLengthOfTwo()
	local t = {}
	collection:addItem(t)
	collection:addItem(t)
	local len = table.maxn(collection)
	assert_equal(2, len)
end

function test_AddingATableTwiceAndThenRemovingItMakesLengthEqualOne()
	local t = {}
	collection:addItem(t)
	collection:addItem(t)
	collection:removeItem(t)
	local len = table.maxn(collection)
	assert_equal(1, len)
end


