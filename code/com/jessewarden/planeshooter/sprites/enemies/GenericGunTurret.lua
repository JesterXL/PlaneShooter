GenericGunTurret = {}

function GenericGunTurret:new(player)

	local turret = display.newGroup()
	local image = display.newImage("boss_big_plane_turret.png")
	turret.image = image
	turret:insert(image)
	turret.player = player
	turret.targetRotation = 0
	turret.speed = 1
	

	function turret:getRotation(target)
		local targetX, targetY = target:localToContent(target.x, target.y)
		local rot = math.atan2(turret.player.y - targetY, turret.player.x - targetX) / math.pi * 180 - 90
		return rot
	end

	function turret:tick(millisecondsPassed)
		self.image.rotation = self:getRotation(self.image)
		--[[
		local image = self.image
		self.targetRotation = self:getRotation(image)
		if image.rotation ~= self.targetRotation then
			if image.rotation + self.speed > self.targetRotation then
				image.rotation = self.targetRotation
			else
				image.rotation = image.rotation + self.speed
				print("r: ", image.rotation, ", target: ", self.targetRotation)
			end
		end
		]]--

		--[[
		local deltaY = image.rotation + self.targetRotation
		local dist = math.sqrt((deltaX * deltaX) + (deltaY * deltaY))
		local moveX = self.speed * (deltaX / dist) * millisecondsPassed
		local moveY = self.speed * (deltaY / dist) * millisecondsPassed
			
			print("moveX: " .. moveX .. ", moveY: " .. moveY)
		if (math.abs(moveX) > dist or math.abs(moveY) > dist) then
			image.rotation = self.targetRotation
		else
			image.rotation = self.rotation + moveX
		end
		]]--
	end


	-- gunPoint1Img.rotation = boss:getRotation(gunPoint1Img )
	return turret

end

return GenericGunTurret
