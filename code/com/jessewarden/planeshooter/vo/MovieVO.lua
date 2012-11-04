MovieVO = {}

function MovieVO:new()

	local vo = {}

	vo.when = 0
	vo.pause = false
	vo.name = "Default Movie"
	vo.dialogues = {} -- DialogueVO
	vo.autoPlay = false


	return vo

end

return MovieVO
