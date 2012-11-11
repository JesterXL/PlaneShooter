FlightPathCheckpoint = {}

function FlightPathCheckpoint:new(reached)

	local flightPath = display.newGroup()

	function flightPath:setReached(reached)
		if(flightPath.img) then
			flightPath:remove(flightPath.img)
		end

		local img
		if(reached == false) then
			img = display.newImage("gamegui_flightpath_checkpoint.png")
		else
			img = display.newImage("gamegui_flightpath_checkpoint_reached.png")
		end
		img:setReferencePoint(display.TopLeftReferencePoint)
		flightPath.img = img
		flightPath:insert(img)
	end

	function flightPath:destroy()
		flightPath:remove(flightPath.img)
		flightPath:removeSelf()
	end
	
	flightPath:setReached(false)
	
	return flightPath

end

return FlightPathCheckpoint