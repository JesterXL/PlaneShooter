DamageHUD = {}

function DamageHUD:new()
	local hud = display.newGroup()
	hud.classType = "gamegui_DamageHUD"

	local title = display.newImage("gamegui_damage_text.png")
	hud:insert(title)
	title.x = 3

	local planeAnimation = movieclip.newAnim({ "gamegui_damage0001.png",
												"gamegui_damage0002.png",
												"gamegui_damage0003.png",
												"gamegui_damage0004.png",
												"gamegui_damage0005.png",
												"gamegui_damage0006.png",
												"gamegui_damage0007.png",
												"gamegui_damage0008.png",
												"gamegui_damage0009.png",
												"gamegui_damage0010.png",
												"gamegui_damage0011.png"
											})
	hud:insert(planeAnimation)
	planeAnimation.y = 40

	function hud:setHitpoints(current, max)
		local frame = (current / max) * 100
		--print("-----frame: ", frame)
		frame = math.floor(frame / 10)
		--print("frame: ", frame)
		frame = 11 - frame
		--print("frame: ", frame)
		--print("current: ", current, ", max: ", max, ", frame: ", frame)
		planeAnimation:stopAtFrame(frame)
	end

	function hud:destroy()
		title:removeSelf()
		planeAnimation:stop()
		planeAnimation:removeSelf()
		self:removeSelf()
	end

	return hud
end

return DamageHUD