module(..., package.seeall)

function test_firstAlgo()
	-- add comma to separate thousands
	-- 
	local function comma_value(amount)
		local formatted = amount
		while true do  
			formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
			if k == 0 then
				break
			end
		end
		return formatted
	end
	local startTime = system.getTimer()
	comma_value(9)
	comma_value(999)
	comma_value(1000)
	comma_value('1333444.10')
	comma_value('US$1333400')
	comma_value('-$22333444.56')
	comma_value('($22333444.56)')
	comma_value('NEG $22333444.563')
	local endTime = system.getTimer() - startTime
	print("firstAlgo endTime: ", endTime)

	assert_true(true)
end

function test_secondAlgo()

	local function comma_value(n) -- credit http://richard.warburton.it
		local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
		return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
	end

	local startTime = system.getTimer()
	comma_value(9)
	comma_value(999)
	comma_value(1000)
	comma_value('1333444.10')
	comma_value('US$1333400')
	comma_value('-$22333444.56')
	comma_value('($22333444.56)')
	comma_value('NEG $22333444.563')
	local endTime = system.getTimer() - startTime
	print("secondAlgo endTime: ", endTime)

	assert_true(true)
end
