
print("PlayerModel")
PlayerModel = {}
PlayerModel.ID = globals:getID()
PlayerModel.instance = require("Actor").new()
PlayerModel.instance.hitPoints = 3
PlayerModel.instance.maxHitPoints = 3

local inst = PlayerModel.instance

function inst:setHitPoints(value)
	print("PlayerModel::setHitPoints, value: ", value)
	self.hitPoints = value
	self:dispatch({target=self, name="hitPointsChanged"})
end

function inst:onBulletHit()
	print("PlayerModel::onBulletHit")
	self:setHitPoints(self.hitPoints - 1)
end

return PlayerModel