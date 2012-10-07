require "com.jessewarden.planeshooter.gamegui.controls.ProgressBar"
EquipScreen = {}

function EquipScreen:new()

	local screen = display.newGroup()
	screen.tileHeight = nil
	screen.tileRight = nil
	screen.isFocus = false

	function screen:init()
		local startX = 0
		local startY = 0

		local titleGuns = display.newImage("equip_guns.png")
		titleGuns:setReferencePoint(display.TopLeftReferencePoint)
		screen.titleGuns = titleGuns
		screen:insert(titleGuns)
		startY = startY + titleGuns.height + 4
		self:buildRow(startX, startY, "gunTile")
		startY = startY + self.tileHeight + 4

		local titleCanons = display.newImage("equip_cannons.png")
		titleCanons:setReferencePoint(display.TopLeftReferencePoint)
		screen.titleCanons = titleCanons
		screen:insert(titleCanons)
		titleCanons.y = startY
		startY = startY + titleCanons.height + 4
		self:buildRow(startX, startY, "cannonTile")
		startY = startY + self.tileHeight + 4

		local titleMissiles = display.newImage("equip_missiles.png")
		titleMissiles:setReferencePoint(display.TopLeftReferencePoint)
		screen.titleMissiles = titleMissiles
		screen:insert(titleMissiles)
		titleMissiles.y = startY
		startY = startY + titleMissiles.height + 4
		self:buildRow(startX, startY, "missileTile")
		startY = startY + self.tileHeight + 4

		local titleEngines = display.newImage("equip_engines.png")
		titleEngines:setReferencePoint(display.TopLeftReferencePoint)
		screen.titleEngines = titleEngines
		screen:insert(titleEngines)
		titleEngines.y = startY
		startY = startY + titleEngines.height + 4
		self:buildRow(startX, startY)
		startY = startY + self.tileHeight + 4

		local titleBodies = display.newImage("equip_bodies.png")
		titleBodies:setReferencePoint(display.TopLeftReferencePoint)
		screen.titleBodies = titleBodies
		screen:insert(titleBodies)
		titleBodies.y = startY
		startY = startY + titleBodies.height + 4
		self:buildRow(startX, startY)
		startY = startY + self.tileHeight + 4

		local titleInformation = display.newImage("equip_information.png")
		titleInformation:setReferencePoint(display.TopLeftReferencePoint)
		self:insert(titleInformation)
		self.titleInformation = titleInformation
		titleInformation.x = self.tileRight + 8

		local infoTextBox = display.newText("---", 0, 0, 276, 264, native.systemFont, 21)
		infoTextBox:setReferencePoint(display.TopLeftReferencePoint)
		infoTextBox:setTextColor(0, 0, 0)
		self:insert(infoTextBox)
		self.infoTextBox = infoTextBox
		infoTextBox.x = titleInformation.x + 8
		infoTextBox.y = titleInformation.y + titleInformation.height

		self:buildStats(infoTextBox.x, infoTextBox.y + infoTextBox.height + 8)
	end

	function screen:getTitle(text, x, y)
		local title = display.newText(text, 0, 0, 120, 28, native.systemFont, 21)
		title:setReferencePoint(display.TopLeftReferencePoint)
		title:setTextColor(0, 0, 0)
		self:insert(title)
		title.x = x
		title.y = y
		return title
	end

	function screen:getProgress(startX, startY)
		local progress = ProgressBar:new(0, 0, 0, 255, 242, 0, 200, 16)
		self:insert(progress)
		progress.x = startX
		progress.y = startY
		progress:setProgress(100, 100)
		return progress
	end

	function screen:buildStats(textX, textBottom)
		local startX = textX
		local startY = textBottom

		local titleFireSpeed = self:getTitle("Fire Speed", startX, startY)
		self.titleFireSpeed = titleFireSpeed
		startY = startY + titleFireSpeed.height + 4

		local progressFireSpeed = self:getProgress(startX, startY)
		self.progressFireSpeed = progressFireSpeed
		startY = startY + progressFireSpeed.height + 4

		local titleFirepower = self:getTitle("Firepower", startX, startY)
		self.titleFirepower = titleFirepower
		startY = startY + titleFirepower.height + 4

		local progressFirepower = self:getProgress(startX, startY)
		self.progressFirepower = progressFirepower
		startY = startY + progressFirepower.height + 4

		local titleSpeed = self:getTitle("Speed", startX, startY)
		self.titleSpeed = titleSpeed
		startY = startY + titleSpeed.height + 4

		local progressSpeed = self:getProgress(startX, startY)
		self.progressSpeed = progressSpeed
		startY = startY + progressSpeed.height + 4

		local titleDefense = self:getTitle("Defense", startX, startY)
		self.titleDefense = titleDefense
		startY = startY + titleDefense.height + 4

		local progressDefense = self:getProgress(startX, startY)
		self.progressDefense = progressDefense
		startY = startY + progressDefense.height + 4

		local equipPlane = display.newImage("equip_plane.png")
		equipPlane:setReferencePoint(display.TopLeftReferencePoint)
		equipPlane.y = 660
		self.equipPlane = equipPlane
		self:insert(equipPlane)

		local tileGun = self:getTile(false)
		self.tileGun = tileGun
		tileGun.x = 150
		tileGun.y = 600

		local tileCannon = self:getTile(false)
		self.tileCannon = tileCannon
		tileCannon.x = 235
		tileCannon.y = 550

		local tileRocket = self:getTile(false)
		self.tileRocket = tileRocket
		tileRocket.x = 400
		tileRocket.y = 770

		local tileEngine = self:getTile(false)
		self.tileEngine = tileEngine
		tileEngine.x = 235
		tileEngine.y = 700

		local tileBody = self:getTile(false)
		self.tileBody = tileBody
		tileBody.x = 235
		tileBody.y = 800

		-- Example drag and drop; works great
		--[[
		local temp = display.newImage("__temp.png")
		temp:setReferencePoint(display.TopLeftReferencePoint)
		temp.x = 2
		temp.y = 42

		function temp:touch(event)
			local phase = event.phase
			if phase == "began" then
				display.getCurrentStage():setFocus(self)
				self:toFront()
				screen.isFocus = true
				screen.x0 = event.x - self.x
				screen.y0 = event.y - self.y
			elseif screen.isFocus == true then
				if phase == "moved" then
					self.x = event.x - screen.x0
					self.y = event.y - screen.y0
				elseif phase == "ended" or phase == "cancelled" then
					display.getCurrentStage():setFocus(nil)
					screen.isFocus = false
				end
			end
			return true
		end
		]]--

		temp:addEventListener("touch", temp)

	end

	function screen:buildRow(startX, startY)
		local i = 1
		local tile
		while i < 5 do
			tile = screen:getTile()
			tile.x = startX
			tile.y = startY

			startX = startX + tile.width + 8
			i = i + 1
		end
		if self.tileRight == nil then self.tileRight = startX - 8 end
	end

	function screen:getTile(addTouchListener)
		if addTouchListener == nil then addTouchListener = true end
		local tile = display.newImage("equip_tile.png")
		if self.tileHeight == nil then self.tileHeight = tile.height end
		tile:setReferencePoint(display.TopLeftReferencePoint)
		self:insert(tile)
		if addTouchListener == true then
			tile:addEventListener("touch", function(e)self:onTileTouched(e)end)
		end
		return tile
	end

	function screen:onTileTouched(event)

	end


	return screen

end

return EquipScreen