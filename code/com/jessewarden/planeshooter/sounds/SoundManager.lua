require "com.jessewarden.planeshooter.sounds.StaticStartSound"
require "com.jessewarden.planeshooter.sounds.StaticEndSound"

SoundManager = {}
SoundManager.inst = nil

function SoundManager:new()

	local manager = {}
	manager.musicVolume = 0.6
	manager.dialogueVolume = 1
	manager.effectsVolume = 0.3
	manager.masterVolume = 1

	manager.CHANNEL_MUSIC = 1
	manager.CHANNEL_DIALOGUE = 2
	manager.CHANNEL_EFFECTS = 3
	manager.CHANNEL_STATIC_START = 4
	manager.CHANNEL_STATIC_END = 5
	manager.CHANNEL_PLAYER = 6

	manager.staticStartSound = nil
	manager.staticEndSound = nil
	manager.dialogueStream = nil
	manager.musicStream = nil

	manager.playerShootSound = nil
	manager.playerHitSound = nil
	manager.playerDeathSound = nil

	manager.bomberLoopSound = nil
	manager.bomberLoopSoundChannel = nil
	manager.bomberShootSound = nil
	manager.bomberDeathSound = nil

	manager.smallPlaneDeathSound = nil

	manager.staticStartSoundCompleteCallback = nil
	manager.staticEndSoundCompleteCallback = nil
	manager.dialogueCallback = nil

	manager.missileSound = nil

	function manager:init()
		self:reserveChannels()
		--self:adjustVolume()
		self:loadStaticSounds()
		-- [jwarden 1.23.2013] TODO: add per level vs. all at once
		self:loadSoundEffects()
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

	function manager:loadSoundEffects()
		self.playerShootSound = audio.loadSound("audio/player/player_shoot.mp3")
		self.playerHitSound = audio.loadSound("audio/player/player_hit_sound.mp3")
		self.playerDeathSound = audio.loadSound("audio/player/player_death_sound.mp3")

		self.bomberLoopSound = audio.loadSound("audio/bomber/bomber_loop.wav")
		self.bomberShootSound = audio.loadSound("audio/bomber/bomber_fire.wav")
		self.bomberDeathSound = audio.loadSound("audio/bomber/bomber_explode.wav")

		self.smallPlaneDeathSound = audio.loadSound("audio/small_plane/small_plane_death.mp3")

		self.missileSound = audio.loadSound("audio/jet/enemy_missle_jet_missle.mp3")
	end

	function manager:playStaticStartSound(callback)
		self.staticStartSoundCompleteCallback = callback
		self.staticStartSound:play()
	end

	function manager:StaticStartSound_onComplete(event)
		--print("SoundManager::StaticStartSound_onComplete")
		local callback = self.staticStartSoundCompleteCallback
		self.staticStartSoundCompleteCallback = nil
		callback()
	end

	function manager:playStaticEndSound(callback)
		self.staticEndSoundCompleteCallback = callback
		self.staticEndSound:play()
	end

	function manager:StaticEndSound_onComplete(event)
		--print("SoundManager::StaticEndSound_onComplete")
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
				--print("SoundManager::playDialogue callback executing", system.getTimer())
				callback()
			end
		end
		self.dialogueCallback = localCallback
		self.dialogueStream = audio.loadStream(dialogueFile)
		audio.play(self.dialogueStream, {channel=self.CHANNEL_DIALOGUE,
											onComplete=self.dialogueCallback})
		audio.setVolume(self.dialogueVolume, {channel=self.CHANNEL_DIALOGUE})
	end

	function manager:destroyDialogue()
		if self.dialogueStream then
			audio.stop(self.CHANNEL_DIALOGUE)
			audio.dispose(self.dialogueStream)
			self.dialogueStream = nil
			self.staticStartSoundCompleteCallback = nil
			self.staticEndSoundCompleteCallback = nil
			self.dialogueCallback = nil
		end
	end

	function manager:playMusic(musicFile)
		if musicFile == nil then
			error("musicFile is required")
		end

		self:stopMusic()

		self.musicStream = audio.loadStream(musicFile)
		audio.play(self.musicStream, {channel=self.CHANNEL_MUSIC})
		audio.setVolume(self.musicVolume, {channel=self.CHANNEL_MUSIC})
	end

	function manager:stopMusic()
		if self.musicStream then
			audio.stop(self.CHANNEL_MUSIC)
			audio.dispose(self.musicStream)
			self.musicStream = nil
		end
	end

	function manager:playPlayerShootSound()
		if audio.isChannelActive(self.CHANNEL_PLAYER) == false then
			audio.play(self.playerShootSound, {channel=self.CHANNEL_PLAYER, loops=-1})
			audio.setVolume(self.effectsVolume, {channel=self.CHANNEL_PLAYER})
		end
	end

	function manager:stopPlayerShootSound()
		audio.stop(self.CHANNEL_PLAYER)
	end

	function manager:playPlayerHitSound()
		audio.play(self.playerHitSound, {channel=self.CHANNEL_PLAYER})
		audio.setVolume(self.effectsVolume, {channel=self.CHANNEL_PLAYER})
	end

	function manager:stopPlayerHitSound()
		audio.stop(self.CHANNEL_PLAYER)
	end

	function manager:playPlayerDeathSound()
		audio.play(self.playerDeathSound, {channel=self.CHANNEL_PLAYER})
		audio.setVolume(self.effectsVolume, {channel=self.CHANNEL_PLAYER})
	end

	function manager:stopPlayerDeathSound()
		audio.stop(self.CHANNEL_PLAYER)
	end

	function manager:playLevelEndSound()
		audio.play(self.playerDeathSound, {channel=self.CHANNEL_PLAYER})
		audio.setVolume(self.effectsVolume, {channel=self.CHANNEL_PLAYER})
	end

	function manager:playLevelEndSound()
		self:playMusic("audio/level_end.wav")
	end

	function manager:playBossBigPlaneDeathSound()
		local channel = audio.play(self.bomberDeathSound)
		audio.setVolume(self.effectsVolume, {channel=channel})
	end

	function manager:playBossBigPlaneHitSound()
		local channel = audio.play(self.bomberHitSound)
		audio.setVolume(self.effectsVolume, {channel=channel})
	end

	function manager:playBossBigPlaneShootSound()
		local channel = audio.play(self.bomberShootSound)
		audio.setVolume(self.effectsVolume, {channel=channel})
	end

	function manager:playSmallPlaneDeathSound()
		local channel = audio.play(self.smallPlaneDeathSound)
		audio.setVolume(self.effectsVolume, {channel=channel})
	end

	function manager:playBossBigPlaneEngineSound()
		self.bomberLoopSoundChannel = audio.play(self.bomberLoopSound, {loops=-1})
		audio.setVolume(self.effectsVolume, {channel=self.bomberLoopSoundChannel})
	end

	function manager:stopBossBigPlaneEngineSound()
		if self.bomberLoopSoundChannel then
			audio.stop(self.bomberLoopSoundChannel)
			self.bomberLoopSoundChannel = nil
		end
	end

	function manager:playMissileSound()
		local channel = audio.play(self.missileSound)
		audio.setVolume(self.effectsVolume, {channel=channel})
	end

	return manager

end

if SoundManager.inst == nil then
	SoundManager.inst = SoundManager:new()
	SoundManager.inst:init()
end

return SoundManager