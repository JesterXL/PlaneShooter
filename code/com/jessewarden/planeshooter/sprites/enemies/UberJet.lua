UberJet = {}

function UberJet:new()

	local jet = display.newGroup()
	jet.classType = "UberJet"

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

		-- TODO: figure out his flight pattern
		gameLoop:addLoop(self)

		self:addEventListener("collision", self)
		physics.addBody( self, { density = 3.0, friction = 0.3, bounce = 0.2, 
								bodyType = "kinematic", 
								isBullet = true, isSensor = true, 
								isFixedRotation = false,
								shape=bossShape,
								filter = { categoryBits = 4, maskBits = 3 }
							} )
	end

	function jet:destroy()
		gameLoop:removeLoop(self)
		self:removeEventListener("collision", self)
		self:removeSelf()
	end

	function jet:collision(event)
		if(event.other.name == "Bullet") then
			event.other:destroy()
		elseif(event.other.name == "Player") then
			event.other:onBulletHit()
		end
		Runtime:dispatchEvent({name="onShowFloatingText", 
								x=self.x, y=self.y, target=self, amount=100})
		self:destroy()
	end
	
	


	function jet:tick(milliseconds)

	end

	jet:init()

	return jet

end

return UberJet