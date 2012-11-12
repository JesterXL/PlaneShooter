UserProgressVO = {}

function UserProgressVO:new()

	local vo = {}

	vo.levelFileName = nil
	vo.weaponsConfig = nil -- memento of PlayerModel
	vo.score = nil
	vo.timestamp = os.date()
	-- TODO
	--vo.achievements = nil

	return vo

end

return UserProgressVO