PlayerMovementController = {}

function PlayerMovementController:new(player)

	local controller = {}
	controller.player = player

	function controller:touch(event)
		if(event.phase == "began" or event.phase == "moved") then
			self.player:setDestination(event.x, event.y - 40)
			return true
		end
	end

	function controller:start()
		Runtime:addEventListener("touch", self)
	end

	function controller:stop()
		Runtime:removeEventListener("touch", self)
	end

	function controller:onRegister()
		-- TODO
	end

	function controller:onRemove()
		self:stop()
	end

	return controller

end

return PlayerMovementController