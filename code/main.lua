local physics = require "physics"
physics.start()
physics.setDrawMode( "hybrid" )
physics.setGravity( 0, 0 )

local function createImageComponent(filename)
	local img = display.newImage(filename,0,0)
	
	img.speed = 6 -- pixels per second
	
	function img:move(x, y)
		self.x = x
		self.y = y
	end
	
	function img:tick(millisecondsPassed)
		if(self.x == planeXTarget) then
			return
		else
			local deltaX = self.x - planeXTarget
			local deltaY = self.y - planeYTarget
			local dist = math.sqrt((deltaX * deltaX) + (deltaY * deltaY))

			local moveX = self.speed * (deltaX / dist)
			local moveY = self.speed * (deltaY / dist)

			if (self.speed >= dist) then
				self.x = planeXTarget
				self.y = planeYTarget
			else
				self.x = self.x - moveX
				self.y = self.y - moveY
			end
		end
			
	end
	
	return img
end

local function createBullet(filename)
	
end

local function onHit(event)
	print("onHit: ", event)
end


plane = createImageComponent("plane.png")
physics.addBody( plane, { density = 1.0, friction = 0.3, bounce = 0.2, 
							bodyType = "kinematic", isBullet = true, isSensor = true, isFixedRotation = true} )
crate = display.newImage("crate.png")
physics.addBody( crate, { density = 1.0, friction = 0.3, bounce = 0.2, 
							bodyType = "kinematic", isBullet = true, isSensor = true, isFixedRotation = true} )
crate:addEventListener("collision", onHit)
crate.x = 300
crate.y = 200
local lastTick = system.getTimer()
tickers = {}
table.insert(tickers, plane)
stage = display.getCurrentStage()
planeXTarget = stage.width / 2
planeYTarget = stage.height / 2


function animate(event)
	local now = system.getTimer()
	local difference = now - lastTick
	lastTick = now
	
	for i,v in ipairs(tickers) do
		v:tick(difference)
	end
end

function onTouch(event)
	if(event.phase == "began" or event.phase == "moved") then
		planeXTarget = event.x
		planeYTarget = event.y
	end
end




Runtime:addEventListener("enterFrame", animate )
Runtime:addEventListener("touch", onTouch)