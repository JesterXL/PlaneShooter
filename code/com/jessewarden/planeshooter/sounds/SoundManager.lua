require "com.jessewarden.planeshooter.sounds.StaticStartSound"
require "com.jessewarden.planeshooter.sounds.StaticEndSound"

SoundManager = {}
SoundManager.inst = nil

function SoundManager:new()

	local manager = {}
	manager.musicVolume = 0.6
	manager.dialogueVolume = 1
	manager.effectsVolume = 0.8
	manager.masterVolume = 1

	manager.CHANNEL_MUSIC = 1
	manager.CHANNEL_DIALOGUE = 2
	manager.CHANNEL_EFFECTS = 3
	manager.CHANNEL_STATIC_START = 4
	manager.CHANNEL_STATIC_END = 5

	manager.staticStartSound = nil
	manager.staticEndSound = nil
	manager.dialogueStream = nil
	manager.musicStream = nil

	manager.staticStartSoundCompleteCallback = nil
	manager.staticEndSoundCompleteCallback = nil

	function manager:init()
		self:reserveChannels()
		--self:adjustVolume()
		self:loadStaticSounds()
	end

	function manager:reserveChannels()
		local result, err = audio.reserveChannels(5)
		assert(result == 5, "SoundManager::reserve Channels, failed to reserve all 5 channels.", err)
	end

	function manager:adjustVolume()
		-- TODO: handle device max/min value

		audio.setVolume(self.masterVolume)
		audio.setVolume(self.musicVolume, {channel=self.CHANNEL_MUSIC})
		audio.setVolume(self.dialogueVolume, {channel=self.CHANNEL_DIALOGUE})
		audio.setVolume(self.effectsVolume, {channel=self.CHANNEL_EFFECTS})

		audio.setVolume(self.dialogueVolume, {channel=self.CHANNEL_STATIC_START})
		audio.setVolume(self.dialogueVolume, {channel=self.CHANNEL_STATIC_END})
	end

	function manager:loadStaticSounds()
		self.staticStartSound = StaticStartSound:new(self.CHANNEL_DIALOGUE)
		self.staticEndSound = StaticEndSound:new(self.CHANNEL_DIALOGUE)

		Runtime:addEventListener("StaticStartSound_onComplete", self)
		Runtime:addEventListener("StaticEndSound_onComplete", self)
	end

	function manager:playStaticStartSound(callback)
		print("SoundManager::playStaticStartSound")
		self.staticStartSoundCompleteCallback = callback
		self.staticStartSound:play()
	end

	function manager:StaticStartSound_onComplete(event)
		local callback = self.staticStartSoundCompleteCallback
		self.staticStartSoundCompleteCallback = nil
		callback()
	end

	function manager:playStaticEndSound(callback)
		self.staticEndSoundCompleteCallback = callback
		self.staticEndSound:play()
	end

	function manager:StaticEndSound_onComplete(event)
		local callback = self.staticEndSoundCompleteCallback
		self.staticEndSoundCompleteCallback = nil
		callback()
	end

	function manager:stopAllStaticSounds()
		if audio.isChannelActive(self.CHANNEL_STATIC_START) then
			audio.stop(self.staticStartSound)
		end
		if audio.isChannelActive(self.CHANNEL_STATIC_END) then
			audio.stop(self.staticEndSound)
		end
	end

	function manager:playDialogue(dialogueFile, callback)
		if dialogueFile == nil then return false end

		local localCallback = function(e)
			if e.completed == true then
				callback()
			end
		end
		self.dialogueStream = audio.loadStream(dialogueFile)
		audio.play(self.dialogueStream, {channel=self.CHANNEL_DIALOGUE,
											onComplete=callback})
	end

	function manager:destroyDialogue()
		if self.dialogueStream then
			audio.stop(self.CHANNEL_DIALOGUE)
			audio.dispose(self.dialogueStream)
			self.dialogueStream = nil
		end
	end

	function manager:playMusic(musicFile)
		if musicFile == nil then
			error("musicFile is required")
		end

		self.musicStream = audio.loadStream(musicFile)
		audio.play(self.musicStream, {channel=self.CHANNEL_MUSIC})
		audio.setVolume(self.musicVolume, {channel=self.CHANNEL_MUSIC})
	end

	return manager

end

if SoundManager.inst == nil then
	SoundManager.inst = SoundManager:new()
	SoundManager.inst:init()
end

return SoundManager