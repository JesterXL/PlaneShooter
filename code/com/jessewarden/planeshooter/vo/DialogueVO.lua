DialogueVO = {}

function DialogueVO:new()

	local vo = {}
	vo.characterName = nil -- charactertypes
	vo.emotion = nil -- emotiontypes
	vo.audioName = nil
	vo.audioFile = nil
	vo.message = nil



	return vo

end


return DialogueVO
