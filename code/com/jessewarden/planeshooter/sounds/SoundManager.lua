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

	manager.playerShootSingleSound = nil
	manager.playerShootDualSound = nil
	manager.playerHit1Sound = nil
	manager.playerHit2Sound = nil
	manager.playerDeath1Sound = nil
	manager.playerDeath2Sound = nil

	manager.bomberLoopSound = nil
	manager.bomberLoopSoundChannel = nil
	manager.bomberShootSound = nil
	manager.bomberDeathSound = nil

	manager.smallPlaneShootSound = nil
	manager.smallPlaneDeathSound = nil

	manager.staticStartSoundCompleteCallback = nil
	manager.staticEndSoundCompleteCallback = nil
	manager.dialogueCallback = nil

	manager.tankManAnnouncementSound = nil
	manager.tankManArmsMove1Sound = nil
	manager.tankManArmsMove2Sound = nil
	manager.tankManEngineNormalSound = nil
	manager.tankManEngineDamagedSound = nil
	manager.tankManFlakSound = nil
	manager.tankManHitSound = nil
	manager.tankManEngineSoundChannel = nil

	manager.missileSound = nil
	manager.jetFlyBySound = nil

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
		self.playerShootSingleSound = audio.loadSound("audio/player/player_shoot_single.wav")
		self.playerShootDualSound = audio.loadSound("audio/player/player_shoot_dual.wav")
		self.playerHit1Sound = audio.loadSound("audio/player/player_hit_sound1.mp3")
		self.playerHit2Sound = audio.loadSound("audio/player/player_hit_sound2.wav")
		self.playerDeath1Sound = audio.loadSound("audio/player/player_death_sound1.mp3")
		self.playerDeath2Sound = audio.loadSound("audio/player/player_death_sound2.wav")

		self.bomberLoopSound = audio.loadSound("audio/bomber/bomber_loop.wav")
		self.bomberShootSound = audio.loadSound("audio/bomber/bomber_fire.wav")
		self.bomberDeathSound = audio.loadSound("audio/bomber/bomber_explode.wav")

		self.smallPlaneShootSound = audio.loadSound("audio/small_plane/small_plane_shoot.wav")
		self.smallPlaneDeathSound = audio.loadSound("audio/small_plane/small_plane_death.mp3")

		self.missileSound = audio.loadSound("audio/jet/enemy_missle_jet_missle.mp3")
		self.jetFlyBySound = audio.loadSound("audio/jet/enemy_missle_jet.mp3")

		self.tankManAnnouncementSound = audio.loadSound("audio/tank_man/tank_man_announcement.wav")
		self.tankManArmsMove1Sound = audio.loadSound("audio/tank_man/tank_man_arms_move1.wav")
		self.tankManArmsMove2Sound = audio.loadSound("audio/tank_man/tank_man_arms_move2.wav")
		self.tankManEngineNormalSound = audio.loadSound("audio/tank_man/tank_man_engine_normal.wav")
		self.tankManEngineDamagedSound = audio.loadSound("audio/tank_man/tank_man_engine_damaged.wav")
		self.tankManFlakSound = audio.loadSound("audio/tank_man/tank_man_flak.wav")
		self.tankManHitSound = audio.loadSound("audio/tank_man/tank_man_hit.wav")


	end

	function manager:getOneOrTwo()
		local num = math.floor(math.random() * 2) + 1
		return num
	end

	function manager:playEffectSound(soundFile)
		local channel = audio.play(soundFile)
		audio.setVolume(self.effectsVolume, {channel=channel})
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

	function manager:playPlayerShootSingleSound()
		if audio.isChannelActive(self.CHANNEL_PLAYER) == false then
			audio.play(self.playerShootSingleSound, {channel=self.CHANNEL_PLAYER, loops=-1})
			audio.setVolume(self.effectsVolume, {channel=self.CHANNEL_PLAYER})
		end
	end

	function manager:stopPlayerShootSound()
		audio.stop(self.CHANNEL_PLAYER)
	end

	function manager:playPlayerShootDualSound()
		if audio.isChannelActive(self.CHANNEL_PLAYER) == false then
			audio.play(self.playerShootDualSound, {channel=self.CHANNEL_PLAYER, loops=-1})
			audio.setVolume(self.effectsVolume, {channel=self.CHANNEL_PLAYER})
		end
	end

	function manager:stopPlayerShootDualSound()
		audio.stop(self.CHANNEL_PLAYER)
	end

	function manager:playPlayerRandomHitSound()
		local num = self:getOneOrTwo()
		if num == 1 then
			self:playPlayerHit1Sound()
		else
			self:playPlayerHit2Sound()
		end
	end

	function manager:playPlayerHit1Sound()
		audio.play(self.playerHit1Sound, {channel=self.CHANNEL_PLAYER})
		audio.setVolume(self.effectsVolume, {channel=self.CHANNEL_PLAYER})
	end

	function manager:stopPlayerHit1Sound()
		audio.stop(self.CHANNEL_PLAYER)
	end

	function manager:playPlayerHit2Sound()
		audio.play(self.playerHit2Sound, {channel=self.CHANNEL_PLAYER})
		audio.setVolume(self.effectsVolume, {channel=self.CHANNEL_PLAYER})
	end

	function manager:stopPlayerHit2Sound()
		audio.stop(self.CHANNEL_PLAYER)
	end

	function manager:playPlayerRandomDeathSound()
		local num = self:getOneOrTwo()
		if num == 1 then
			self:playPlayerDeath1Sound()
		else
			self:playPlayerDeath2Sound()
		end
	end

	function manager:playPlayerDeath1Sound()
		audio.play(self.playerDeath1Sound, {channel=self.CHANNEL_PLAYER})
		audio.setVolume(self.effectsVolume, {channel=self.CHANNEL_PLAYER})
	end

	function manager:stopPlayerDeath1Sound()
		audio.stop(self.CHANNEL_PLAYER)
	end

	function manager:playPlayerDeath2Sound()
		audio.play(self.playerDeath2Sound, {channel=self.CHANNEL_PLAYER})
		audio.setVolume(self.effectsVolume, {channel=self.CHANNEL_PLAYER})
	end

	function manager:stopPlayerDeath2Sound()
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
		self:playEffectSound(self.bomberDeathSound)
	end

	function manager:playBossBigPlaneHitSound()
		self:playEffectSound(self.bomberHitSound)
	end

	function manager:playBossBigPlaneShootSound()
		self:playEffectSound(self.bomberShootSound)
	end

	function manager:playSmallPlaneShootSound()
		self:playEffectSound(self.smallPlaneShootSound)
	end

	function manager:playSmallPlaneDeathSound()
		self:playEffectSound(self.smallPlaneDeathSound)
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

	function manager:playJetFlyBySound()
		self:playEffectSound(self.jetFlyBySound)
	end
	
	function manager:playMissileSound()
		self:playEffectSound(self.missileSound)
	end

	function manager:playTankManAnnouncement()
		self:playEffectSound(self.tankManAnnouncementSound)
	end

	function manager:playTankManArmsMove1Sound()
		self:playEffectSound(self.tankManArmsMove1Sound)
	end

	function manager:playTankManArmsMove2Sound()
		self:playEffectSound(self.tankManArmsMove2Sound)
	end

	function manager:playTankManEngineNormalSound(params)
		self.tankManEngineSoundChannel = audio.play(self.tankManEngineNormalSound, {loops=-1})
		if params.fadeIn == true then
			audio.setVolume(0, {channel=self.tankManEngineSoundChannel})
			audio.fade({channel = self.tankManEngineSoundChannel, time=10000, volume=self.effectsVolume})
		else
			audio.setVolume(self.effectsVolume, {channel=self.tankManEngineSoundChannel})
		end
	end

	function manager:stopTankManEngineNormalSound()
		if self.tankManEngineSoundChannel then
			audio.stop(self.tankManEngineSoundChannel)
			self.tankManEngineSoundChannel = nil
		end
	end

	function manager:playTankManEngineDamagedSound()
		self.tankManEngineSoundChannel = audio.play(self.tankManEngineDamagedSound, {loops=-1})
		audio.setVolume(self.effectsVolume, {channel=self.tankManEngineSoundChannel})
	end

	function manager:stopTankManEngineDamagedSound()
		if self.tankManEngineSoundChannel then
			audio.stop(self.tankManEngineSoundChannel)
			self.tankManEngineSoundChannel = nil
		end
	end

	function manager:playTankManFlakSound()
		self:playEffectSound(self.tankManFlakSound)
	end

	function manager:playTankManHitSound()
		self:playEffectSound(self.tankManHitSound)
	end


	return manager

end

if SoundManager.inst == nil then
	SoundManager.inst = SoundManager:new()
	SoundManager.inst:init()
end

return SoundManager