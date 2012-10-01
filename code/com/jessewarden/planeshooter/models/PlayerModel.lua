PlayerModel = {}

function PlayerModel:new()
	local model = {}

	model.hitPoints = 10
	model.maxHitPoints = 10
	--model.score = 0

	function model:setHitPoints(value)
		--print("PlayerModel::setHitPoints, value: ", value)
		value = math.max(value, 0)
		if value > self.maxHitPoints then value = self.maxHitPoints end
		self.hitPoints = value
		Runtime:dispatchEvent({target=self, name="PlayerModel:hitPointsChanged"})
	end

	function model:getHitpointsPercentage()
		return self.hitPoints / self.maxHitPoints
	end

	--[[
	function model:setScore(value)
		assert(value, "You must pass in a valid score value.")
		if value < 0 then value = 0 end
		self.score = value
		Runtime:dispatch({target=self, name="PlayerModel:scoreChanged"})
	end
	

	function model:addToScore(value)
		assert(value ~= nil, "You must pass in a valid score value to add.")
		if(value > 0) then
			self:setScore(self.score + value)
		end
	end
	]]--

	return model
end

return PlayerModel