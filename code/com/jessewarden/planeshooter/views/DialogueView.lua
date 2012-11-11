require "com.jessewarden.planeshooter.core.constants"

require "org.robotlegs.globals"

DialogueView = {}

function DialogueView:new(right)

	local group = display.newGroup()
	group.name = globals.getID()
	group.classType = "DialogueView"
	group:setReferencePoint(display.TopLeftReferencePoint)

	-- 383, 118
	local img
	if right == nil or right == false then
		group.right = false
		img = display.newImage("gamegui_dialogue.png")
	else
		group.right = true
		img = display.newImage("gamegui_dialogue2.png")
	end
	img:setReferencePoint(display.TopLeftReferencePoint)
	group:insert(img)

	if DialogueView.lightSheet == nil then
		local lightSheet = sprite.newSpriteSheet("gamegui_dialogue_audio_level_sheet.png", 47, 7)
		local lightSet = sprite.newSpriteSet(lightSheet, 1, 12)
		sprite.add(lightSet, "lights", 1, 12, 500, 2)
		DialogueView.lightSheet = lightSheet
		DialogueView.lightSet = lightSet

		local staticSheet = sprite.newSpriteSheet("gamegui_dialogue_static_sheet.png", 72, 72)
		local staticSet = sprite.newSpriteSet(staticSheet, 1, 3)
		sprite.add(staticSet, "static", 1, 3, 600, 0)
		DialogueView.staticSheet = staticSheet
		DialogueView.staticSet = staticSet
	end

	local lightsAnime = sprite.newSprite(DialogueView.lightSet)
	lightsAnime:setReferencePoint(display.TopLeftReferencePoint)
	group:insert(lightsAnime)
	if group.right == false then
		lightsAnime.x = 16
		lightsAnime.y = 91
	else
		lightsAnime.x = 319
		lightsAnime.y = 91
	end

	local platform = system.getInfo("platformName")
	local text
	local fontSize = 11
	if platform == "Android" or platform == "iPhone OS" then
		text = native.newTextBox( 0, 0, 278, 68 )
		text.hasBackground = false
		text.isEditable = false
		text.align = "left"
	else
		text = display.newText("", 0, 0, 278, 68, native.systemFont, fontSize)
	end
	--text:setReferencePoint(display.TopLeftReferencePoint)
	text:setTextColor(255, 255, 255)
	text.size = fontSize
	text.font = native.newFont( native.systemFont, fontSize )
	group:insert(text)
	
	
	function group:setText(value)
		-- TODO: wipe this in (animate mask or whatever)
		text.text = value
		
		local platform = system.getInfo("platformName")
		if platform == "Android" or platform == "iPhone OS" then
			text.x = 100
			text.y = 16
		else
			if group.right == false then
				text.x = 100 + (text.width / 2)
			else
				text.x = 16 + (text.width / 2)
			end
			text.y = 16 + (text.height / 2)
		end
		
		--[[
		if group.rect ~= nil then
			group:remove(group.rect)
			group.rect = nil
		end
		
		local rect = display.newRect(0,0, text.width, text.height)
		group:insert(rect)
		rect:setReferencePoint(display.TopLeftReferencePoint)
		rect:setFillColor(0, 0, 0, 0) 
		rect:setStrokeColor(255, 0, 0)
		rect.strokeWidth = 2
		rect.x = text.xOrigin
		rect.y = text.yOrigin
		
		print("x: ", text.x, ", xRef: ", text.xReference, ", xOri: ", text.xOrigin)
		
		group.rect = rect
		]]--
	end

	function group:setCharacter(character, emotion)
		self.character = character
		if self.characterImage ~= nil then
			self:remove(self.characterImage)
			self.characterImage = nil
		end

		local img
		if character == constants.CHARACTER_JESTERXL then
			img = display.newImage("gamegui_head_shot_jesterxl_" .. emotion .. ".jpg")
		elseif character == constants.CHARACTER_BINDY then
			img = display.newImage("gamegui_head_shot_bindy_" .. emotion .. ".jpg")
		end

		if img ~= nil then
			img:setReferencePoint(display.TopLeftReferencePoint)
			self:insert(img)
			if group.right == false then
				img.x = 16
			else
				img.x = 298
			end
			img.y = 16
		end
		self.characterImage = img
	end
	
	function group:showLights()
		lightsAnime:prepare("lights")
		lightsAnime:play()
	end


	function group:destroy()
		img:removeSelf()
		lightsAnime:pause()
		lightsAnime:removeSelf()
		text.text = ""
		text:removeSelf()

		if self.characterImage ~= nil then
			self.characterImage:removeSelf()
			self.characterImage = nil
		end

		self:removeSelf()
	end

	
	return group

end

return DialogueView