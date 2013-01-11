UberJet = {}

function UberJet:new()

	local jet = display.newGroup()

	function jet:init()
		if UberJet.spriteSheet == nil then
			local jetSpriteSheet = sprite.newSpriteSheet("uber_jet_sheet.png", 248, 232)
			local jetSpriteSet = sprite.newSpriteSet(jetSpriteSheet, 1, 3)
			sprite.add(jetSpriteSet, "uberjet", 1, 3, 500, 0)
			UberJet.jetSpriteSheet = jetSpriteSheet
			UberJet.jetSpriteSet = jetSpriteSet
		end

		local jetSprite = sprite.newSprite(UberJet.jetSpriteSet)
		self.jetSprite = jetSprite
		jetSprite:setReferencePoint(display.TopLeftReferencePoint)
		self:insert(jetSprite)
		jetSprite.x = 0
		jetSprite.y = 0
		jetSprite:prepare("uberjet")
		jetSprite:play()
	end

	jet:init()

	return jet

end

return UberJet