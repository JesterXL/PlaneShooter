
-- TODO: add this guy to game loop

ScrollingTerrain = {}

function ScrollingTerrain:new(image)
	
	local terrain = display.newGroup()
	
	local terrain1 = display.newImage(image, 0, 0, true)
	terrain1:setReferencePoint(display.TopLeftReferencePoint)
	terrain:insert(terrain1)
	local terrain2 = display.newImage(image, 0, 0, true)
	terrain2:setReferencePoint(display.TopLeftReferencePoint)
	terrain:insert(terrain2)
	terrain1.x = 0
	terrain1.y = 0
	terrain2.x = 0
	terrain2.y = terrain1.y + terrain1.height
	
	terrain.speed = 0.07
	terrain.onTerrain = terrain1
	terrain.offTerrain = terrain2
	terrain.targetY = terrain1.height
	terrain.playing = false

	function terrain:start()
		if self.playing == false then
			self.playing = true
			gameLoop:addLoop(self)
		end
	end

	function terrain:stop()
		if self.playing == true then
			self.playing = false
			gameLoop:removeLoop(self)
		end
	end
	
	function terrain:tick(millisecondsPassed)
		local deltaX = self.onTerrain.x
		local deltaY = self.onTerrain.y - self.targetY
		local dist = math.sqrt((deltaX * deltaX) + (deltaY * deltaY))

		local moveX = self.speed * (deltaX / dist)
		local moveY = self.speed * (deltaY / dist)

		if (self.speed >= dist) then
			self.onTerrain.y = self.offTerrain.y + self.offTerrain.height
			local oldOn = self.onTerrain
			self.onTerrain = self.offTerrain
			self.offTerrain = oldOn
		else
			self.onTerrain.x = self.onTerrain.x - moveX
			self.onTerrain.y = self.onTerrain.y - moveY
			self.offTerrain.x = self.onTerrain.x
			self.offTerrain.y = self.onTerrain.y - self.onTerrain.height
		end
	end

	return terrain
end

return ScrollingTerrain