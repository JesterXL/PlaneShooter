
Text = {}

function Text:new(left, top, width, height)
	
	local text
	local platform = system.getInfo("platformName")
	if platform == "Android" or platform == "iPhone OS" then
		text = native.newTextBox( left, top, width, height)
		text.hasBackground = false
		text.isEditable = false
		text.align = "left"
		text.font = native.newFont( native.systemFont, 16 )
	else
		text = display.newText("", 0, 0, native.systemFont, 16)
	end
	text:setReferencePoint(display.TopLeftReferencePoint)
	text:setTextColor(255, 255, 255)
	text.size = 16
	return text
end

return Text

