
-- TODO: add this guy to game loop

ScrollingTerrain = {}

function ScrollingTerrain:new()
	
	local terrain = display.newGroup()
	
	terrain1 = display.newImage("debug_terrain.png", 0, 0)
	terrain:insert(terrain1)
	terrain2 = display.newImage("debug_terrain.png", 0, 0)
	terrain:insert(terrain2)
	terrain1.x = 0
	terrain1.y = 0
	
	local terrainScroller = {}
	terrain.terrainScroller = terrainScroller
	terrainScroller.speed = TERRAIN_SCROLL_SPEED
	terrainScroller.onTerrain = terrain1
	terrainScroller.offTerrain = terrain2
	terrainScroller.targetY = -terrain1.height
	
	function terrainScroller:tick(millisecondsPassed)
		local deltaX = self.onTerrain.x
		local deltaY = self.onTerrain.y - self.targetY
		local dist = math.sqrt((deltaX * deltaX) + (deltaY * deltaY))

		local moveX = self.speed * (deltaX / dist)
		local moveY = self.speed * (deltaY / dist)

		if (self.speed >= dist) then
			self.y = self.targetY
			self.onTerrain.y = self.offTerrain.y + self.offTerrain.height
			local oldOn = self.onTerrain
			self.onTerrain = self.offTerrain
			self.offTerrain = oldOn
		else
			self.onTerrain.x = self.onTerrain.x - moveX
			self.onTerrain.y = self.onTerrain.y - moveY
			self.offTerrain.x = self.onTerrain.x
			self.offTerrain.y = self.onTerrain.y + self.onTerrain.height + 2
		end
	end
end

return ScrollingTerrain