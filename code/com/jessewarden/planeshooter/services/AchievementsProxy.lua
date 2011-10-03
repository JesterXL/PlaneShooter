require "gameNetwork"
require "com.jessewarden.planeshooter.core.constants"

AchievementsProxy = {}
AchievementsProxy.mode = "openfeint"
AchievementsProxy.achievements = nil

function AchievementsProxy:init(desiredMode, defaultAchievements)
	assert(desiredMode ~= nil, "desiredMode cannot be nil")
	assert(defaultAchievements ~= nil, "defaultAchievements cannot be nil")
	print("AchievementsProxy::init, self.mode is: ", self.mode)
	self.mode = desiredMode
	if self.mode == "papaya" then
		self:initPapaya()
	elseif self.mode == "openfeint" then
		self:initOpenFeint()
	else
		print("Unknown desiredMode")
	end
	
	self.achievements = defaultAchievements
end

function AchievementsProxy:initPapaya()
	gameNetwork.init("papaya", "asdf")
end

function AchievementsProxy:initOpenFeint()
	gameNetwork.init("openfeint", 
						"asdf", 
						"asdf", 
						"JesterXL: Invaded Skies", 
						"111111")
end

function AchievementsProxy:unlock(achievementVO)
	print("AchievementsProxy::unlock, achievementVO: ", achievementVO, ", self.mode: ", self.mode)
	local idFieldName
	if self.mode == "openfeint" then
		idFieldName = "oid"
	elseif self.mode == "papayamobile" then
		idFieldName = "pid"
	end
	
	print("\tidFieldName: ", idFieldName, ", achievementVO[idFieldName]: ", achievementVO[idFieldName])
	gameNetwork.request("unlockAchievement", achievementVO[idFieldName])
end


return AchievementsProxy