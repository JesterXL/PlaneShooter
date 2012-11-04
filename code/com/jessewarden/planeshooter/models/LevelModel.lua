LevelModel = {}

function LevelModel:new()

	local model = {}
	model.classType = "LevelModel"
	model.level = nil
	model.oldEvents = nil
	model.totalMilliseconds = nil
	model.paused = true

	function model:init(level)
		self.level = level

		local oldEvents = self.oldEvents
		local events = self.level.events
		if oldEvents ~= nil then
			local i = #oldEvents
			while oldEvents[i] do
				local event = oldEvents[i]
				table.remove(oldEvents, i)
				table.insert(events, event)
				i = i - 1
			end
		end

		self.oldEvents = {}
		self.totalMilliseconds = 0
	end

	function model:start()
		if self.paused == true then
			self.paused = false
			gameLoop:addLoop(self)
		end
	end

	function model:stop()
		if self.paused == false then
			self.paused = true
			gameLoop:removeLoop(self)
		end
	end

	function model:tick(milliseconds)
		self.totalMilliseconds = self.totalMilliseconds + milliseconds
		local progress = self.totalMilliseconds / (self.level.totalTime * 1000)
		local level = self.level
		local events = level.events
		local totalMilliseconds = self.totalMilliseconds
		local seconds = totalMilliseconds / 1000
		local oldEvents = self.oldEvents
		
		local i = 1
		while events[i] do
			local event = events[i]
			if event.when <= seconds then
				table.remove(events, i)
				table.insert(oldEvents, event)
				if event.pause == true then
					self:stop()
				end
				
				if event.classType == "enemy" then
					--print("LevelModel_onEnemyEvent")
					Runtime:dispatchEvent({name="LevelModel_onEnemyEvent", target=self, event=event})
				elseif event.classType == "movie" then
					--print("LevelModel_onMovieEvent")
					Runtime:dispatchEvent({name="LevelModel_onMovieEvent", target=self, event=event})
					return true
				end
			end
			i = i + 1
		end

		local index = #events
		if seconds >= level.totalTime and index == 0 then
			--print("LevelModel_levelComplete")
			self:stop()
			Runtime:dispatchEvent({name="LevelModel_levelComplete", target=self})
			return true
		end
	end


	return model

end

return LevelModel