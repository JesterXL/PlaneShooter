module (..., package.seeall)

local function new(hitPoints, maxHitPoints)
	local model = require("Actor").new()
	model.hitPoints = hitPoints
	model.maxHitPoints = maxHitPoints
	
	function model:setHitPoints(value)
		self.hitPoints = value
		self:dispatch({target=self, name="hitPointsChanged"})
	end
	
	return model
end