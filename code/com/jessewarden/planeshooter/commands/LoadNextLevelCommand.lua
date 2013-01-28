require "com.jessewarden.planeshooter.sounds.SoundManager"

LoadNextLevelCommand = {}

function LoadNextLevelCommand:new()

	local command = {}

	function command:execute(event, context)
		local progressModel = context:getModel("progressModel")
		local level
		if progressModel.currentLevel == nil then
			-- start the game
			print(">>> Loading level1.json")
			level = LoadLevelService:new("level1.json")
			-- [jwarden 1.27.2013] HACK/KLUDGE: CAN YOU SMELL WHAT THE DEADLINE IS COOKIN!?
			Runtime:dispatchEvent({name="onLevelChanged", target=self, level="level1.json"})
		elseif progressModel.currentLevel.fileName == "level1.json" then
			-- load level 2
			print(">>> Loading level2.json")
			level = LoadLevelService:new("level2.json")
			-- [jwarden 1.27.2013] HACK/KLUDGE: CAN YOU SMELL WHAT THE DEADLINE IS COOKIN!?
			Runtime:dispatchEvent({name="onLevelChanged", target=self, level="level2.json"})
		else
			print("done!")
			level = nil
		end
		assert(level ~= nil, "You cannot create a nil next level.")
		progressModel.currentLevel = level

		local levelModel = context:getModel("levelModel")
		levelModel:init(level)
		levelModel:start()
		SoundManager.inst:playMusic(level.musicFile)

		--levelModel:setLevelTime(50 * 1000)
	end

	return command

end

return LoadNextLevelCommand