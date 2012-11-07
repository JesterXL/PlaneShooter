DialogueVO = {}

function DialogueVO:new()

	local vo = {}
	vo.characterName = nil -- charactertypes
	vo.emotion = nil -- emotiontypes
	vo.audioName = nil
	vo.audioFile = nil
	vo.message = nil
	vo.advanceOnAudioEnd = false
	vo.dialogueTime = nil
	vo.autoPlay = false
	return vo

end


return DialogueVO
