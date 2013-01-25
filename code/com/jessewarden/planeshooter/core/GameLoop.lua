
GameLoop = {}

function GameLoop:new()

	local gameLoop = {}

	gameLoop.classType = "GameLoop"
	gameLoop.tickers = {}
	gameLoop.lastTick = system.getTimer()
	gameLoop.paused = true
	gameLoop.stage = display.getCurrentStage()

	function gameLoop:addLoop(o)
		--print("GameLoop::addLoop", o)
		assert(o ~= nil, "You cannot pass nil values to the game loop")
		local tickers = self.tickers
		local index = table.indexOf(tickers, o)
		if(index == nil) then
			return table.insert(tickers, o)
		else
			print(o, " already added to the game loop.", " name: ", o.name)
			error(o.classType .. " Already added to the game loop.")
			return false
		end
	end

	function gameLoop:removeLoop(o)
		local tickers = self.tickers
		for i,v in ipairs(tickers) do
			if(v == o) then
				table.remove(tickers, i)
				return true
			end
		end
		self:pause()
		error("!! item not found !!")
		return false
	end

	function gameLoop:onRemoveFromGameLoop(event)
		event.target:removeEventListener("removeFromGameLoop", onRemoveFromGameLoop)
		return gameLoop:removeLoop(event.target)
	end

	function gameLoop:enterFrame(event)
		local lastTick = self.lastTick
		local now = system.getTimer()
		local difference = now - lastTick
		self.lastTick = now

		local i = 1
		local tickers = self.tickers
		while tickers[i] do
			tickers[i]:tick(difference)
			i = i + 1
		end
	end

	function gameLoop:pause()
		--print("GameLoop::pause")
		self.paused = true
		Runtime:removeEventListener("enterFrame", self)
		Runtime:dispatchEvent({name="GameLoop_onPauseChanged", target=self})
	end

	function gameLoop:reset()
		self.lastTick = system.getTimer()
	end

	function gameLoop:start()
		--print("GameLoop::start")
		Runtime:removeEventListener("enterFrame", self)
		self.paused = false
		Runtime:addEventListener("enterFrame", self)
		Runtime:dispatchEvent({name="GameLoop_onPauseChanged", target=self})
	end

	return gameLoop

end

return GameLoop