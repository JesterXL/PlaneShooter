require "constants"

function new(x, y)
	local img = display.newImage("icon_power_up.png")
	img.x = x
	img.y = y
	img.lifetime = constants.POWER_UP_LIFETIME -- milliseconds
	

	
	physics.addBody( img, { density = 1.0, friction = 0.3, bounce = 0.2, 
								bodyType = "kinematic", 
								isBullet = false, isSensor = true, isFixedRotation = true,
								filter = { categoryBits = 16, maskBits = 1 }
							} )
	
	-- TODO: add to game loop			
	--addLoop(img)
			
	function onHit(self, event)
		if(event.other.name == "Player") then
			-- TODO: fixme, add an event
			--addPowerUp()
			-- TODO: remove from game loop
			-- removeLoop(img)
			img:removeSelf()
			img = nil
			return true
		end
	end
	
	function img:tick(millisecondsPassed)
		-- TODO/FIXME/BUG: this is weird; it's a non-nil reference, but it's just a table
		if(img.removeSelf ~= nil) then
			img.lifetime = img.lifetime - millisecondsPassed
			if(img.lifetime <= 0) then
				img:removeSelf()
			end
		end
	end
	
	img.collision = onHit
	img:addEventListener("collision", img)
	
	return img
end