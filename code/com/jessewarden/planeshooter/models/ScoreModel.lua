ScoreModel = {}

function ScoreModel:new()

	local model = {}
	model.score = 0

	function model:setScore(value)
		assert(value, "You must pass in a valid score value.")
		assert(value > 0, "You cannot pass 0 or less for a score.")
		self.score = value
		Runtime:dispatchEvent({target=self, name="ScoreModel_scoreChanged"})
	end

	function model:addToScore(value)
		assert(value ~= nil, "You must pass in a valid score value to add.")
		assert(value > 0, "You must pass in a value greater than 0.")
		self:setScore(self.score + value)
	end

	return model

end

return ScoreModel