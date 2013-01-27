

Flak = {}

function Flak:new()

	if(Flak.spriteSheet == nil) then
		local spriteSheet = sprite.newSpriteSheet("flak_sheet.png", 100, 90)
		local spriteSet = sprite.newSpriteSet(spriteSheet, 1, 2)
		sprite.add(spriteSet, "flak", 1, 2, 500, 1)
		Flak.spriteSheet = spriteSheet
		Flak.spriteSet = spriteSet
	end
	
	local flak = sprite.newSprite(Flak.spriteSet)

	function flak:init()
		flak:addEventListener("sprite", flak)
		flak:prepare("flak")
		flak:play()
	end

	function flak:destroy()
		self.isVisible = false
		self:removeSelf()
	end

	function flak:sprite(event)
		if event.phase == "end" then
			self:destroy()
		end
	end

	flak:init()

	return flak

end

return Flak