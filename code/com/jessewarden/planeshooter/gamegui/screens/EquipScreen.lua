require "com.jessewarden.planeshooter.gamegui.controls.ProgressBar"
require "com.jessewarden.planeshooter.gamegui.screens.equipscreenclasses.EquipTile"
require "com.jessewarden.planeshooter.gamegui.screens.equipscreenclasses.DraggableTile"
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

	screen.equippedGun = nil
	screen.equippedEngine = nil

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
		if self.guns ~= nil then self.guns:removeEventListener("onChange", self) end
		self.guns = collection
		if self.guns ~= nil then self.guns:addEventListener("onChange", self) end
		self:redrawGuns()
	end

	function screen:onChange(event)
		local t = event.target
		if t == self.guns then
			self:redrawGuns()
		elseif t == self.engines then
			self:redrawEngines()
		end
	end

	function screen:setEquippedGun(gunVO)
		self.equippedGun = gunVO
		self:redrawEquippedGun()
	end

	function screen:setEquippedEngine(engineVO)
		self.equippedEngine = engineVO
		self:redrawEquippedEngine()
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
		if self.engines ~= nil then self.engines:removeEventListener("onChange", self) end
		self.engines = collection
		if self.engines ~= nil then self.engines:addEventListener("onChange", self) end
		self:redrawEngines()
	end

	function screen:removeInventoryItems(dragSourceType)
		local group = self.inventoryGroup
		local len = group.numChildren
		while len > 0 do
			local object = group[len]
			if object and object.dragSource == dragSourceType then
				object:destroy()
			end
			len = len - 1
		end
	end

	function screen:redrawEngines()
		self:removeInventoryItems("engine")

		local i = 1
		local max = 4
		while i <= max do
			local engineVO = self.engines[i]
			if engineVO ~= nil then
				local temp = DraggableTile:new()
				temp.dragSource = "engine"
				temp.vo = engineVO
				self.inventoryGroup:insert(temp)
				temp:addEventListener("onStartDragging", self)
				temp:addEventListener("onStopDragging", self)

				local tile = self["engineTile_" .. i]
				temp.x = tile.x
				temp.y = tile.y
			end
			i = i + 1
		end
	end

	function screen:redrawGuns()
		self:removeInventoryItems("gun")

		local i = 1
		local max = 4
		while i <= max do
			local gunVO = self.guns[i]
			if gunVO ~= nil then
				local temp = DraggableTile:new()
				temp.dragSource = "gun"
				temp.vo = gunVO
				self.inventoryGroup:insert(temp)
				temp:addEventListener("onStartDragging", self)
				temp:addEventListener("onStopDragging", self)

				local tile = self["gunTile_" .. i]
				temp.x = tile.x
				temp.y = tile.y
			end
			i = i + 1
		end
	end

	function screen:redrawEquippedEngine()
		if self.equippedEngineView ~= nil then
			self.equippedEngineView:destroy()
			self.equippedEngineView = nil
		end

		if self.equippedEngine ~= nil then
			local temp = DraggableTile:new()
			temp.dragSource = "equippedEngine"
			temp.vo = self.equippedEngine
			self.inventoryGroup:insert(temp)
			temp:addEventListener("onStartDragging", self)
			temp:addEventListener("onStopDragging", function(e)self:onStopDraggingEquippedEngine(e)end)

			self.equippedEngineView = temp
			temp.x = self.tileEngine.x
			temp.y = self.tileEngine.y
			temp:toFront()
		end 
	end

	function screen:redrawEquippedGun()
		if self.equippedGunView ~= nil then
			self.equippedGunView:destroy()
			self.equippedGunView = nil
		end

		if self.equippedGun ~= nil then
			local temp = DraggableTile:new()
			temp.dragSource = "equippedGun"
			temp.vo = self.equippedGun
			self.inventoryGroup:insert(temp)
			temp:addEventListener("onStartDragging", self)
			temp:addEventListener("onStopDragging", function(e)self:onStopDraggingEquippedGun(e)end)

			self.equippedGunView = temp
			temp.x = self.tileGun.x
			temp.y = self.tileGun.y
			temp:toFront()
		end
	end

	function screen:onStartDragging(event)
		local classType = event.target.classType
		local dragSource = event.target.dragSource
		if dragSource == "gun" then
			self.tileGun:drawFlash(true)
		elseif dragSource == "equippedGun" then
			self:drawTilesFlash("gunTile_", true)
		elseif dragSource == "engine" then
			self.tileEngine:drawFlash(true)
		else
			self.tileGun:drawFlash(false)
			self.tileEngine:drawFlash(false)
			self:drawTilesFlash("gunTile_", false)
		end
	end

	function screen:onStopDragging(event)
		local hitGun = self.tileGun.showingBorder
		local hitEngine = self.tileEngine.showingBorder

		self.tileGun:drawFlash(false)
		self.tileEngine:drawFlash(false)
		self:drawTilesFlash("gunTile_", false)
		
		local draggingVO = event.target.vo
		if hitGun == true then
			print("wants to equip gun")
			self:dispatchEvent({name="onEquipGun", target=self, vo=draggingVO})
			return true
		elseif hitEngine == true then
			print("wants to equip engine")
			self:dispatchEvent({name="onEquipEngine", target=self, vo=draggingVO})
			return true
		end
	end

	function screen:onStopDraggingEquippedGun(event)
		self:drawTilesFlash("gunTile_", false)
		if self.tileGun.showingBorder == false then
			self:dispatchEvent({name="onRemoveGun", target=self, vo=self.equippedGun})
		end
	end

	function screen:onStopDraggingEquippedEngine(event)
		self:drawTilesFlash("engineTile_", false)
		if self.tileGun.showingBorder == false then
			self:dispatchEvent({name="onRemoveEngine", target=self, vo=self.equippedEngine})
		end
	end

	function screen:drawTilesFlash(tilePrefix, show)
		local i = 1
		while i <= 4 do
			local gunTile = self[tilePrefix .. i]
			gunTile:drawFlash(show)
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
		self:buildRow(startX, startY, "engineTile")
		startY = startY + self.tileHeight + 4

		local titleBodies = display.newImage("equip_bodies.png")
		titleBodies:setReferencePoint(display.TopLeftReferencePoint)
		screen.titleBodies = titleBodies
		screen:insert(titleBodies)
		titleBodies.y = startY
		startY = startY + titleBodies.height + 4
		self:buildRow(startX, startY, "bodyTile")
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
	
		self.inventoryGroup:toFront()
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

		local titleWeight = self:getTitle("Weight", startX, startY)
		self.titleWeight = titleWeight
		startY = startY + titleWeight.height + 4

		local progressWeight = self:getProgress(startX, startY)
		self.progressWeight = progressWeight
		startY = startY + progressWeight.height + 4

		local titlePower = self:getTitle("Power", startX, startY)
		self.titlePower = titlePower
		startY = startY + titlePower.height + 4

		local progressPower = self:getProgress(startX, startY)
		self.progressPower = progressPower
		startY = startY + progressPower.height + 4

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