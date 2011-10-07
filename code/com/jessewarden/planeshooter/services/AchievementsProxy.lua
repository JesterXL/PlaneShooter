require "gameNetwork"
require "com.jessewarden.planeshooter.core.constants"
require "com.jessewarden.mock.openfeint.MockOpenFeint"

AchievementsProxy = {}
AchievementsProxy.mode = "openfeint"
AchievementsProxy.achievements = nil
AchievementsProxy.kills = 0
local platform = system.getInfo("platformName")
if platform == "Android" or platform == "iPhone OS" then
	AchievementsProxy.useMock = false
else
	AchievementsProxy.useMock = true
	-- TODO: make a Papaya one
	AchievementsProxy.mock = MockOpenFeint:new()
	local stage = display.getCurrentStage()
	stage:insert(AchievementsProxy.mock)
end

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
	if self.useMock == false then
		gameNetwork.init("papaya", "asdf")
	else
		self.mock:showInit("Welcome Back Player 2938JKHS8")
	end
end

function AchievementsProxy:initOpenFeint()
	if self.useMock == false then
		gameNetwork.init("openfeint", 
							"asdf", 
							"asdf", 
							"JesterXL: Invaded Skies", 
							"111111")
	else
		self.mock:showInit("Welcome Back Player 2938JKHS8")
	end
end

function AchievementsProxy:unlock(achievementVO)
	print("AchievementsProxy::unlock, achievementVO: ", achievementVO, ", self.mode: ", self.mode)
	if achievementVO.done == true then
		return true
	end
	
	achievementVO.done = true
	
	if self.useMock == true then
		self.mock:showAchievement(achievementVO.image, achievementVO.name)
		return true
	end
	
	local idFieldName
	if self.mode == "openfeint" then
		idFieldName = "oid"
	elseif self.mode == "papayamobile" then
		idFieldName = "pid"
	end
	
	print("\tidFieldName: ", idFieldName, ", achievementVO[idFieldName]: ", achievementVO[idFieldName])
	gameNetwork.request("unlockAchievement", achievementVO[idFieldName])
end

function AchievementsProxy:onKill()
	self.kills = self.kills + 1
	if self.kills == 1 then
		self:unlock(constants.achievements.firstBlood)
	elseif self.kills == 10 then
		self:unlock(constants.achievements.dogFighter)
	end
end


return AchievementsProxy