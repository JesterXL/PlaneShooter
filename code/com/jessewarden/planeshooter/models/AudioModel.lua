require "com.jessewarden.planeshooter.sounds.StaticStartSound"
require "com.jessewarden.planeshooter.sounds.StaticStartEnd"

AudioModel = {}

function AudioModel:new()

	local model = {}
	model.musicVolume = 0.7
	model.dialogueVolume = 1
	model.effectsVolume = 0.8
	model.masterVolume = 1

	model.CHANNEL_MUSIC = 1
	model.CHANNEL_DIALOGUE = 2
	model.CHANNEL_EFFECTS = 3

	model.staticStartSound = nil
	model.staticEndSound = nil

	function model:init()
		self:reserveChannels()
		--self:adjustVolume()
		self:loadStaticSounds()
	end

	function model:reserveChannels()
		local result, err = audio.reserveChannels(3)
		assert(result == 3, "AudioModel::reserve Channels, failed to reserve all 3 channels.", err)
	end

	function model:adjustVolume()
		-- TODO: handle device max/min value

		audio.setVolume(self.masterVolume)
		audio.setVolume(self.musicVolume, {channel=self.CHANNEL_MUSIC})
		audio.setVolume(self.dialogueVolume, {channel=self.CHANNEL_DIALOGUE})
		audio.setVolume(self.effectsVolume, {channel=self.CHANNEL_EFFECTS})
	end

	function model:loadStaticSounds()
		self.staticStartSound = StaticStartSound:new(self.CHANNEL_DIALOGUE)
		self.staticEndSound = StaticEndSound:new(self.CHANNEL_DIALOGUE)
	end

	function model:playMusic(file)
		return audio.loadStream(file)

	return model

end

return AudioModel