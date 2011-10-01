
Timer = {}

function Timer:new()
	local ticker = {}
	ticker.lastTick = system.getTimer()
	ticker.paused = true
	ticker.totalTime = 0
	
	function ticker:enterFrame(event)
		local lastTick = self.lastTick
		local now = system.getTimer()
		local difference = now - lastTick
		self.lastTick = now
		self.totalTime = self.totalTime + difference
	end

	function ticker:pause()
		self.paused = true
		Runtime:removeEventListener("enterFrame", self)
	end

	function ticker:reset()
		self.lastTick = system.getTimer()
	end
	
	function ticker:unpause()
		if self.paused == true then
			self.paused = false
			Runtime:removeEventListener("enterFrame", self)
			self.lastTick = system.getTimer()
		end
	end
	
	function ticker:start()
		Runtime:removeEventListener("enterFrame", self)
		self.paused = false
		Runtime:addEventListener("enterFrame", self)
	end

	return ticker
end

return Timer