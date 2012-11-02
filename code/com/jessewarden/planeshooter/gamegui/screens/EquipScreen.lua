require "com.jessewarden.planeshooter.gamegui.controls.ProgressBar"
require "com.jessewarden.planeshooter.gamegui.screens.equipscreenclasses.EquipTile"
require "com.jessewarden.planeshooter.gamegui.screens.equipscreenclasses.DraggableTile"
require "com.jessewarden.planeshooter.core.constants"
require "com.jessewarden.planeshooter.vo.weapons.WeaponVO"
EquipScreen = {}

function EquipScreen:new()

	local screen               = display.newGroup()
	screen.tileHeight          = nil
	screen.tileRight           = nil
	screen.isFocus             = false
	
	screen.guns                = nil
	screen.cannons             = nil
	screen.missiles            = nil
	screen.bodies              = nil
	screen.engines             = nil
	
	screen.equippedGun         = nil
	screen.equippedEngine      = nil
	screen.equippedBody        = nil
	screen.equippedCannon      = nil
	screen.equippedMissile     = nil
	
	screen.equippedGunView     = nil
	screen.equippedEngineView  = nil
	screen.equippedBodyView    = nil
	screen.equippedCannonView  = nil
	screen.equippedMissileView = nil
	
	screen.tileGroup           = display.newGroup()
	screen:insert(screen.tileGroup)
	screen.inventoryGroup      = display.newGroup()
	screen:insert(screen.inventoryGroup)

	function screen:setCollection(currentName, collection)
		local current = self[currentName]
		if current ~= nil then
			current:removeEventListener("onChange", self)
		end
		self[currentName] = collection
		if collection ~= nil then
			collection:addEventListener("onChange", self)
		end
	end

	function screen:setGuns(collection)
		self:setCollection("guns", collection)
		self:redrawGuns()
	end

	function screen:setBodies(collection)
		self:setCollection("bodies", collection)
		self:redrawBodies()
	end

	function screen:setEngines(collection)
		self:setCollection("engines", collection)
		self:redrawEngines()
	end

	function screen:setCannons(collection)
		self:setCollection("cannons", collection)
		self:redrawCannons()
	end

	function screen:setMissiles(collection)
		self:setCollection("missiles", collection)
		self:redrawMissiles()
	end

	function screen:onChange(event)
		local t = event.target
		if t == self.guns then
			self:redrawGuns()
		elseif t == self.engines then
			self:redrawEngines()
		elseif t == self.bodies then
			self:redrawBodies()
		elseif t == self.cannons then
			self:redrawCannons()
		elseif t == self.missiles then
			self:redrawMissiles()
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

	function screen:setEquippedBody(bodyVO)
		self.equippedBody = bodyVO
		self:redrawEquippedBody()
	end

	function screen:setEquippedCannon(cannonVO)
		self.equippedCannon = cannonVO
		self:redrawEquippedCannon()
	end

	function screen:setEquippedMissile(missileVO)
		self.equippedMissile = missileVO
		self:redrawEquippedMissile()
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

	function screen:redraw(targetName)
		self:removeInventoryItems(targetName)
		local targetCollection
		if targetName == "engine" then
			targetCollection = self.engines
		elseif targetName == "gun" then
			targetCollection = self.guns
		elseif targetName == "body" then
			targetCollection = self.bodies
		elseif targetName == "missile" then
			targetCollection = self.missiles
		elseif targetName == "cannon" then
			targetCollection = self.cannons
		else
			error("Unknown targetName: ", targetName)
		end

		local i = 1
		local max = 4
		while i <= max do
			local vo = targetCollection[i]
			if vo ~= nil then
				local temp = DraggableTile:new()
				temp.dragSource = targetName
				temp:setVO(vo)
				self.inventoryGroup:insert(temp)
				temp:addEventListener("onStartDragging", self)
				temp:addEventListener("onStopDragging", self)

				local tile = self[targetName .. "Tile_" .. i]
				temp.x = tile.x
				temp.y = tile.y
			end
			i = i + 1
		end
	end

	function screen:redrawEngines()
		self:redraw("engine")
	end

	function screen:redrawGuns()
		self:redraw("gun")
	end

	function screen:redrawBodies()
		self:redraw("body")
	end

	function screen:redrawCannons()
		self:redraw("cannon")
	end

	function screen:redrawMissiles()
		self:redraw("missile")
	end

	-- [jwarden 10.28.2012] TODO: change targetName to a constant,
	-- it's used in 'redraw' method as well.
	function screen:redrawEquipped(targetName)
		local viewMiddle = targetName:sub(1,1):upper() .. targetName:sub(2)
		local voName = "equipped" .. viewMiddle
		local targetVO = self[voName]
		local viewName = voName .. "View"
		local targetView = self[viewName]
		if targetView ~= nil then
			targetView:destroy()
			self[viewName] = nil
		end

		local stopDragHandlerName = "onStopDraggingEquipped" .. viewMiddle
		local stopDraggingHandler = function(e)
			self[stopDragHandlerName](self)
		end

		local targetTile = self["tile" .. viewMiddle]
		if targetVO ~= nil then
			local temp = DraggableTile:new()
			temp.dragSource = voName
			temp:setVO(targetVO)
			self.inventoryGroup:insert(temp)
			temp:addEventListener("onStartDragging", self)
			temp:addEventListener("onStopDragging", stopDraggingHandler)

			self[viewName] = temp
			temp.x = targetTile.x
			temp.y = targetTile.y
			temp:toFront()
		end
	end

	function screen:redrawEquippedBody()
		self:redrawEquipped("body")
	end

	function screen:redrawEquippedEngine()
		self:redrawEquipped("engine")
	end

	function screen:redrawEquippedGun()
		self:redrawEquipped("gun")
	end

	function screen:redrawEquippedCannon()
		self:redrawEquipped("cannon")
	end

	function screen:redrawEquippedMissile()
		self:redrawEquipped("missile")
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
		elseif dragSource == "equippedEngine" then
			self:drawTilesFlash("engineTile_", true)
		elseif dragSource == "body" then
			self.tileBody:drawFlash(true)
		elseif dragSource == "equippedBody" then
			self:drawTilesFlash("bodyTile_", true)
		elseif dragSource == "cannon" then
			self.tileCannon:drawFlash(true)
		elseif dragSource == "equippedCannon" then
			self:drawTilesFlash("cannonTile_", true)
		elseif dragSource == "missile" then
			self.tileMissile:drawFlash(true)
		elseif dragSource == "equippedMissile" then
			self:drawTilesFlash("missileTile_", true)
		else
			self.tileGun:drawFlash(false)
			self.tileEngine:drawFlash(false)
			self.tileBody:drawFlash(false)
			self.tileCannon:drawFlash(false)
			self.tileMissile:drawFlash(false)
			self:drawTilesFlash("gunTile_", false)
			self:drawTilesFlash("engineTile_", false)
			self:drawTilesFlash("bodyTile_", false)
			self:drawTilesFlash("cannonTile_", false)
			self:drawTilesFlash("missileTile_", false)
		end
	end

	function screen:onStopDragging(event)
		local hitGun = self.tileGun.showingBorder
		local hitEngine = self.tileEngine.showingBorder
		local hitBody = self.tileBody.showingBorder
		local hitMissile = self.tileMissile.showingBorder
		local hitCannon = self.tileCannon.showingBorder

		self.tileGun:drawFlash(false)
		self.tileEngine:drawFlash(false)
		self.tileBody:drawFlash(false)
		self.tileCannon:drawFlash(false)
		self.tileMissile:drawFlash(false)

		self:drawTilesFlash("gunTile_", false)
		self:drawTilesFlash("engineTile_", false)
		self:drawTilesFlash("bodyTile_", false)
		self:drawTilesFlash("missileTile_", false)
		self:drawTilesFlash("cannonTile_", false)

		print("hitMissile: ", hitMissile, ", type: ", event.target.vo.weaponType)
		
		local draggingVO = event.target.vo
		if hitGun == true and draggingVO.weaponType == WeaponVO.TYPE_GUN then
			print("wants to equip gun")
			self:dispatchEvent({name="onEquipGun", target=self, vo=draggingVO})
			return true
		elseif hitEngine == true and draggingVO.type == constants.ENGINE then
			print("wants to equip engine")
			self:dispatchEvent({name="onEquipEngine", target=self, vo=draggingVO})
			return true
		elseif hitBody == true and draggingVO.type == constants.BODY then
			print("wants to equip body")
			self:dispatchEvent({name="onEquipBody", target=self, vo=draggingVO})
			return true
		elseif hitCannon == true and draggingVO.weaponType == WeaponVO.TYPE_CANNON then
			print("wants to equip cannon")
			self:dispatchEvent({name="onEquipCannon", target=self, vo=draggingVO})
			return true
		elseif hitMissile == true and draggingVO.weaponType == WeaponVO.TYPE_MISSILE then
			print("wants to equip missile")
			self:dispatchEvent({name="onEquipMissile", target=self, vo=draggingVO})
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

	function screen:onStopDraggingEquippedBody(event)
		self:drawTilesFlash("bodyTile_", false)
		if self.tileBody.showingBorder == false then
			self:dispatchEvent({name="onRemoveBody", target=self, vo=self.equippedBody})
		end
	end

	function screen:onStopDraggingEquippedCannon(event)
		self:drawTilesFlash("cannonTile_", false)
		if self.tileCannon.showingBorder == false then
			self:dispatchEvent({name="onRemoveCannon", target=self, vo=self.equippedCannon})
		end
	end

	function screen:onStopDraggingEquippedMissile(event)
		self:drawTilesFlash("missileTile_", false)
		if self.tileMissile.showingBorder == false then
			self:dispatchEvent({name="onRemoveMissile", target=self, vo=self.equippedMissile})
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

		local tileMissile = self:getTile(false)
		self.tileMissile = tileMissile
		tileMissile.x = 400
		tileMissile.y = 770

		local tileEngine = self:getTile(false)
		self.tileEngine = tileEngine
		tileEngine.x = 235
		tileEngine.y = 700

		local tileBody = self:getTile(false)
		self.tileBody = tileBody
		tileBody.x = 235
		tileBody.y = 800

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