
print("PlayerModel")
PlayerModel = {}
PlayerModel.ID = globals:getID()
PlayerModel.instance = require("robotlegs_Actor").new()
PlayerModel.instance.hitPoints = 10
PlayerModel.instance.maxHitPoints = 10
PlayerModel.instance.score = 0

local inst = PlayerModel.instance

function inst:setHitPoints(value)
	print("PlayerModel::setHitPoints, value: ", value)
	value = math.max(value, 0)
	if value > PlayerModel.instance.maxHitPoints then value = PlayerModel.instance.maxHitPoints end
	self.hitPoints = value
	self:dispatch({target=self, name="hitPointsChanged"})
end

function inst:getHitpointsPercentage()
	return self.hitPoints / self.maxHitPoints
end

function inst:onBulletHit()
	self:setHitPoints(self.hitPoints - 1)
end

function inst:onMissileHit()
	self:setHitPoints(self.hitPoints - 2)
end

function inst:setScore(value)
	assert(value, "You must pass in a valid score value.")
	if value < 0 then value = 0 end
	PlayerModel.instance.score = value
	self:dispatch({target=self, name="scoreChanged"})
end

function inst:addToScore(value)
	--assert(value ~= nil, "You must pass in a valid score value to add.")
	if(value > 0) then
		inst:setScore(PlayerModel.instance.score + value)
	end
end

return PlayerModel