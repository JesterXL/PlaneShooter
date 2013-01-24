require "com.jessewarden.planeshooter.sprites.player.PlayerBulletSingle"
require "com.jessewarden.planeshooter.sprites.player.PlayerBulletDual"
require "com.jessewarden.planeshooter.sprites.player.PlayerBulletAngle"
require "com.jessewarden.planeshooter.sprites.player.PlayerRailGun"
require "com.jessewarden.planeshooter.sounds.SoundManager"


PlayerWeaponsController = {}

function PlayerWeaponsController:new(player)


	assert(player ~= nil, "Must pass in a player.")
	
	local regulator 			= {} -- Mount up!

	regulator.player 			= player

	regulator.classType 		= "PlayerWeaponsController"
	regulator.bullets 			= 0
	regulator.fireSpeed 		= 300
	regulator.lastFire 			= 0
	regulator.fireFunc 			= nil
	regulator.enabled 			= false
	regulator.powerLevel 		= 0

	function regulator:start()
		gameLoop:addLoop(self)
		Runtime:addEventListener("touch", self)
	end

	function regulator:stop()
		self.enabled = false
		gameLoop:removeLoop(self)
		Runtime:removeEventListener("touch", self)
	end

	function regulator:onRegister()
		-- TODO
	end

	function regulator:onRemove()
		self:stop()
	end

	function regulator:touch(event)
		--print("touch: ", event.phase)
		if event.phase == "began" or event.phase == "moved" then
			self.enabled = true
			--audio.play(planeShootSound, {channel=planeShootSoundChannel, loops=-1})
			SoundManager.inst:playPlayerShootSound()
			return true
		end

		if event.phase == "ended" or event.phase == "cancelled" then
			self.enabled = false
			--if planeShootSoundChannel ~= nil then
			--	audio.stop(planeShootSoundChannel)
			--end
			SoundManager.inst:stopPlayerShootSound()
			return true
		end
	end

	function regulator:tick(millisecondsPassed)
		if self.enabled == false then return true end
		if self.fireFunc == nil then return true end
		self.lastFire = self.lastFire + millisecondsPassed
		if(self.lastFire >= self.fireSpeed) then
			self.fireFunc(player.x, player.y)
			self.lastFire = 0
		end
		return true
	end

	function regulator:setPowerLevel(newPowerLevel)
		self.powerLevel = newPowerLevel
		if(newPowerLevel == 1) then
			regulator.fireFunc = createBullet1
		elseif(newPowerLevel == 2) then
			regulator.fireFunc = createBullet2
		elseif(newPowerLevel == 3) then
			regulator.fireFunc = createBullet3
		elseif(newPowerLevel == 4) then
			regulator.fireFunc = createRailGun
		end
		return true
	end

	function createBullet1(millisecondsPassed)
		local player = regulator.player
		local bullet = PlayerBulletSingle:new(player.x, player.y)
		mainGroup:insert(bullet)
	end

	function createBullet2()
		local player = regulator.player
		local bullet = PlayerBulletDual:new(player.x, player.y)
		mainGroup:insert(bullet)
	end

	function createBullet3()
		local player = regulator.player
		local bullet1 = PlayerBulletDual:new(player.x, player.y)
		mainGroup:insert(bullet1)

		local target = {x = player.x, y = player.y}
		target.x = target.x - 3
		target.y = target.y - 3

		local bullet2 = PlayerBulletAngle:new(player.x, player.y, target.x, target.y)

		target.x = player.x + 3
		local bullet3 = PlayerBulletAngle:new(player.x, player.y, target.x, target.y)
		mainGroup:insert(bullet2)
		mainGroup:insert(bullet3)
	end

	
	function createRailGun()
		if regulator.rail == nil then
			regulator.rail = PlayerRailGun:new(player.x, player.y)
			regulator.rail:addEventListener("animeFinished", function(e)regulator:onRailGunComplete(e)end)
			mainGroup:insert(regulator.rail)
		end
	end

	function regulator:onRailGunComplete(event)
		self.rail:removeEventListener("animeFinished", self)
		self.rail = nil
	end
	
	return regulator
end


return PlayerWeaponsController