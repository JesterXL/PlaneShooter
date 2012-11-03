LevelModel = {}

function LevelModel:new()

	local model = {}
	model.classType = "LevelModel"
	model.level = nil
	model.oldEvents = nil
	model.totalMilliseconds = nil

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
		gameLoop:addLoop(self)
	end

	function model:stop()
		gameLoop:removeLoop(self)
	end

	function model:tick(milliseconds)
		self.totalMilliseconds = self.totalMilliseconds + millisecondsPassed
		local progress = self.totalMilliseconds / (self.level.totalTime * 1000)
		local level = self.level
		local events = level.events
		local seconds = self.milliseconds / 1000
		local oldEvents = self.oldEvents
		local totalMilliseconds = self.totalMilliseconds
		local i = 1
		while events[i] do
			local event = events[i]
			if event.when <= seconds then
				table.remove(events, i)
				table.insert(oldEvents, event)
				if event.pause == true then
					self:pause()
				end
				Runtime:dispatchEvent({name="LevelModel_eventReady", target=self, event=event})
			end
			i = i + 1
		end

		local index = #events
		if seconds >= level.totalTime and index == 0 then
			self:pause()
			Runtime:dispatchEvent({name="LevelModel_levelComplete", target=self})
			return true
		end
	end


	return model

end

return LevelModel