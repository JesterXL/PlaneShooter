require "com.jessewarden.planeshooter.views.FlightPathCheckpoint"

FlightPath = {}

function FlightPath:new()

	local group = display.newGroup()

	local img = display.newImage("gamegui_flightpath_text.png")
	img:setReferencePoint(display.TopLeftReferencePoint)
	group:insert(img)
	img.x = 54
	img.y = 0

	group.BAR_WIDTH = 175
	group.BAR_HEIGHT = 11
	local bar = movieclip.newAnim({
									"gamegui_flightpath_bar0001.png",
									"gamegui_flightpath_bar0002.png",
									"gamegui_flightpath_bar0003.png",
									"gamegui_flightpath_bar0004.png",
									"gamegui_flightpath_bar0005.png",
									"gamegui_flightpath_bar0006.png",
									"gamegui_flightpath_bar0007.png",
									"gamegui_flightpath_bar0008.png",
									"gamegui_flightpath_bar0009.png",
									"gamegui_flightpath_bar0011.png"
		  								})
	bar:setReferencePoint(display.TopLeftReferencePoint)
	group:insert(bar)
	bar.x = 0
	bar.y = 18
	
	local checkpointsGroup = display.newGroup()
	group:insert(checkpointsGroup)
	
	local plane = display.newImage("gamegui_flightpath_plane.png")
	plane:setReferencePoint(display.TopLeftReferencePoint)
	group:insert(plane)
	plane.x = 0
	plane.y = bar.y - (plane.height / 4)

	function group:drawCheckpoints(level)
		for i,v in ipairs(checkpointsGroup) do
			table.remove(checkpointsGroup, i)
		end
		checkpointsGroup.pointCache = nil
		
		local events = level["events"]
		local totalTime = level.totalTime
		checkpointsGroup.totalTime = totalTime
		checkpointsGroup.pointCache = {}
		local counter = 1
		for i=1,#events do
			local event = events[i]
			if event.classType == "movie" then
				local when = event.when
				local percentage = when / totalTime
				local pointX = self.BAR_WIDTH * percentage
				local checkPointImage = FlightPathCheckpoint:new(false)
				checkPointImage:setReferencePoint(display.TopLeftReferencePoint)
				checkpointsGroup:insert(checkPointImage)
				checkPointImage.x = pointX - (checkPointImage.width / 2)
				checkPointImage.y = bar.y - (checkPointImage.height / 2)
				
				checkpointsGroup.pointCache[counter] = event
				counter = counter + 1
			end
		end
		
		self:setProgress(1, 10)
	end

	-- NOTE: it's assumed you're passing in value=current time and total=totalTime
	function group:setProgress(value, total)
		local percentage = value / total
		--if percentage < 0 then percentage = 0 end
		--if percentage > 1 then percentage = 1 end
		local frame = percentage * 100
		frame = math.floor(frame / 10)
		--print("value: ", value, ", total: ", total, ", percentage: ", percentage, ", frame: ", frame)
		if frame <= 0 then frame = 1 end
		bar:stopAtFrame(frame)
		plane.x = (group.BAR_WIDTH * percentage) - (plane.width / 2)
		plane.y = bar.y - (plane.height / 4)
		
		if checkpointsGroup.pointCache == nil then return true end
		local i = 1
		local totalTime = checkpointsGroup.totalTime
		while checkpointsGroup.pointCache[i] do
			local event = checkpointsGroup.pointCache[i]
			if event.when >= value then
				local checkPointImage = checkpointsGroup[i]
				checkPointImage:setReached(true)
			end
			i = i + 1
		end
	end

	return group

end

return FlightPath