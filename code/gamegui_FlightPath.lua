require "gamegui_FlightPathCheckpoint"
FlightPath = {}

function FlightPath:new()

	local group = display.newGroup()
	local checkpointsGroup = display.newGroup()
	group:insert(checkpointsGroup)

	local img = display.newImage("gamegui_flightpath_text.png")
	group:insert(img)
	img.x = 54

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
									"gamegui_flightpath_bar0010.png",
									"gamegui_flightpath_bar0011.png"
		  								})
	group:insert(bar)
	bar.y = 11


	function group:drawCheckpoints(checkpoints)
	    -- TODO: Object pool these
		for i,v in ipairs(checkpointsGroup) do
			table.remove(checkpointsGroup, i)
		end

		for i=1,#checkpoints do
			local checkPointTable = checkpoints[i]
			local checkPointImage = FlightPathCheckpoint:new(checkPointTable.reached)
			checkpointsGroup:insert(checkPointImage)
			checkPointImage.x = math.floor(checkPointTable.progress * group.BAR_WIDTH)
		end
	end

	function group:setProgress(value, total)
		local frame = (value / total) * 100
		frame = math.floor(frame / 10)
		frame = 11 - frame
		bar:stopAtFrame(frame)
	end


end

return FlightPath