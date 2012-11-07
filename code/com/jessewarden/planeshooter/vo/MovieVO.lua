MovieVO = {}

function MovieVO:new()

	local vo = {}

	vo.classType = "MovieVO"
	vo.when = 0
	vo.pause = false
	vo.name = "Default Movie"
	vo.dialogues = {} -- DialogueVO


	return vo

end

return MovieVO
