require "com.jessewarden.planeshooter.gamegui.controls.ProgressBar"
require "com.jessewarden.planeshooter.gamegui.screens.equipscreenclasses.EquipTile"
EquipScreen = {}

function EquipScreen:new()

	local screen = display.newGroup()
	screen.tileHeight = nil
	screen.tileRight  = nil
	screen.isFocus    = false

	screen.guns       = nil
	screen.cannons    = nil
	screen.rockets    = nil
	screen.bodies     = nil
	screen.engines    = nil

	screen.tileGroup 		= display.newGroup()
	screen:insert(screen.tileGroup)
	screen.inventoryGroup  = display.newGroup()
	screen:insert(screen.inventoryGroup)

	function screen:setCollection(current, collection)
		local target = current
		if target ~= nil then
			target:removeEventListener("onChange", self)
		end
		target = collection
		if collection ~= nil then
			collection:addEventListener("onChange", self)
		end
	end

	function screen:setGuns(collection)
		self:setCollection(self.guns, collection)
	end

	function screen:setCannons(collection)
		self:setCollection(self.cannons, collection)
	end

	function screen:setRockets(collection)
		self:setCollection(self.rockets, collection)
	end

	function screen:setBodies(collection)
		self:setCollection(self.bodies, collection)
	end

	function screen:setEngines(collection)
		self:setCollection(self.engines, collection)
	end

	function screen:Collection_change(event)
		local collection = event.target
		if collection == self.guns then
			self:redrawGuns()
		elseif collection == self.cannons then
			self:redrawCannons()
		elseif collection == self.rockets then
			self:redrawRockets()
		elseif collection == self.bodies then
			self:redrawBodies()
		elseif collection == self.engines then
			self:redrawEngines()
		end
	end

	function screen:redrawGuns()

		local group = self.inventoryGroup
		local len = group.numChildren
		while len > 0 do
			local object = group[len]
			if object.classType == "gun" then
				object:removeSelf()
			end
			len = len - 1
		end

		local allGuns = self.guns
		print("guns length: ", #allGuns)
		local i = 1
		local max = 4
		while i <= max do
			local gunVO = self.guns[i]
			print("gunVO: ", gunVO)
			if gunVO ~= nil then
				local temp = display.newImage("__temp.png")
				temp.classType = "gun"
				temp:setReferencePoint(display.TopLeftReferencePoint)
				self.inventoryGroup:insert(temp)
				local tile = self["gunTile_" .. i]
				temp.x = tile.x
				temp.y = tile.y
			end
			i = i + 1
		end
	end

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
		self:buildRow(startX, startY, "enginesTile")
		startY = startY + self.tileHeight + 4

		local titleBodies = display.newImage("equip_bodies.png")
		titleBodies:setReferencePoint(display.TopLeftReferencePoint)
		screen.titleBodies = titleBodies
		screen:insert(titleBodies)
		titleBodies.y = startY
		startY = startY + titleBodies.height + 4
		self:buildRow(startX, startY, "bodiesTile")
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
		

		temp:addEventListener("touch", temp)
		]]--

	end

	function screen:buildRow(startX, startY, namePrefix)
		local i = 1
		local tile
		while i < 5 do
			tile = screen:getTile()
			tile.x = startX
			tile.y = startY
			tile.name = namePrefix .. "_" .. i
			self[tile.name] = tile

			startX = startX + tile.width + 8
			i = i + 1
		end
		if self.tileRight == nil then self.tileRight = startX - 8 end
	end

	function screen:getTile(addTouchListener)
		if addTouchListener == nil then addTouchListener = true end
		local tile = EquipTile:new()
		if self.tileHeight == nil then self.tileHeight = tile.height end
		tile:setReferencePoint(display.TopLeftReferencePoint)
		self.tileGroup:insert(tile)
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