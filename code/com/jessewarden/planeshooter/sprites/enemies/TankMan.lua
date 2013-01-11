TankMan = {}

function TankMan:new()

	local tank = display.newGroup()
	tank.classType = "TankMan"

	function tank:init()
		if TankMan.spriteSheet == nil then
			local spriteSheet = sprite.newSpriteSheet("tank_man_sheet.png", 248, 163)
			local spriteSet = sprite.newSpriteSet(spriteSheet, 1, 1)
			sprite.add(spriteSet, "tankman", 1, 1, 500, 0)
			TankMan.spriteSheet = spriteSheet
			TankMan.spriteSet = spriteSet
		end

		local tankSprite = sprite.newSprite(TankMan.spriteSet)
		self.tankSprite = tankSprite
		tankSprite:setReferencePoint(display.TopLeftReferencePoint)
		self:insert(tankSprite)
		tankSprite.x = 0
		tankSprite.y = 0
		tankSprite:prepare("tankman")
		tankSprite:play()

		-- TODO: figure out his movement pattern + attach arms and flak guns
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

	function tank:destroy()
		gameLoop:removeLoop(self)
		self:removeEventListener("collision", self)
		self:removeSelf()
	end

	function tank:collision(event)
		if(event.other.name == "Bullet") then
			event.other:destroy()
		elseif(event.other.name == "Player") then
			event.other:onBulletHit()
		end
		Runtime:dispatchEvent({name="onShowFloatingText", 
								x=self.x, y=self.y, target=self, amount=100})
		self:destroy()
	end
	
	


	function tank:tick(milliseconds)

	end

	tank:init()

	return tank

end

return TankMan