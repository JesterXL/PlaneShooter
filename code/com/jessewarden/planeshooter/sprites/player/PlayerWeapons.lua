require "com.jessewarden.planeshooter.sprites.player.PlayerBulletSingle"
require "com.jessewarden.planeshooter.sprites.player.PlayerBulletDual"

PlayerWeapons = {}

function PlayerWeapons:new(player, mainGroup, gameLoop)

	assert(player ~= nil, "Must pass in a player.")
	assert(mainGroup ~= nil, "Must pass in a mainGroup")
	assert(gameLoop ~= nil, "Must pass in a gameLoop")
	
	local regulator 			= {} -- Mount up!

	regulator.player 			= player
	regulator.mainGroup			= mainGroup
	regulator.gameLoop			= gameLoop

	regulator.classType 		= "PlayerWeapons"
	regulator.bullets 			= 0
	regulator.fireSpeed 		= 300
	regulator.lastFire 			= 0
	regulator.fireFunc 			= nil
	regulator.enabled			= false
	
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

	function regulator:setPowerLevel(powerLevel)
		if(powerLevel == 1) then
			regulator.fireFunc = createBullet1
		elseif(powerLevel == 2) then
			regulator.fireFunc = createBullet2
		elseif(powerLevel == 3) then
			regulator.fireFunc = createBullet3
		end
		--regulator.fireFunc = createRailGun
		return true
	end

	function onRemoveFromGameLoop(event)
		--print("PlayerWeapons::removeFromGameLoop, name: ", event.target.name)
		regulator.gameLoop:removeLoop(event.target)
		return true
	end

	function createBullet1(millisecondsPassed)
		local player = regulator.player
		local bullet = PlayerBulletSingle:new(player.x, player.y)
		regulator.mainGroup:insert(bullet)
		bullet:addEventListener("removeFromGameLoop", onRemoveFromGameLoop)
		regulator.gameLoop:addLoop(bullet)
	end

	function createBullet2()
		local player = regulator.player
		local bullet = PlayerBulletDual:new(player.x, player.y)
		regulator.mainGroup:insert(bullet)
		bullet:addEventListener("removeFromGameLoop", regulator)
		regulator.gameLoop:addLoop(bullet)
	end

	function createBullet3()
		local player = regulator.player
		local bullet1, bullet2, bullet3 = PlayerBulletDual:new(player.x, player.y)
		regulator.mainGroup:insert(bullet1)
		regulator.mainGroup:insert(bullet2)
		regulator.mainGroup:insert(bullet3)
		bullet1:addEventListener("removeFromGameLoop", regulator)
		bullet2:addEventListener("removeFromGameLoop", regulator)
		bullet3:addEventListener("removeFromGameLoop", regulator)
		regulator.gameLoop:addLoop(bullet1)
		regulator.gameLoop:addLoop(bullet2)
		regulator.gameLoop:addLoop(bullet3)

	end

	--[[
	function createRailGun()
		if(rail == nil) then
			rail = PlayerRailGun:new(player.x, player.y)
			rail:addEventListener("animeFinished", onRailGunComplete)
			mainGroup:insert(rail)
		end
	end

	function onRailGunComplete(event)
	rail:removeEventListener("animeFinished", onRailGunComplete)
	rail = nil
end
	]]--

	regulator.gameLoop:addLoop(regulator)
	
	return regulator
end


return PlayerWeapons