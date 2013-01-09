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
		elseif progressModel.currentLevel.fileName == "level3.json" then
			-- load level 2
			print(">>> Loading level2.json")
			level = LoadLevelService:new("level1.json")
		end
		assert(level ~= nil, "You cannot create a nil next level.")
		progressModel.currentLevel = level

		local levelModel = context:getModel("levelModel")
		levelModel:init(level)
		levelModel:start()
	end

	return command

end

return LoadNextLevelCommand