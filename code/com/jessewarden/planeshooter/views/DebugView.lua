DebugView = {}

function DebugView:new()

	local view = display.newGroup()
	view.classType = "DebugView"

	function view:init()
		local textField = display.newText("0", 0, 0, native.systemFont, 14)
		--textField:setReferencePoint(display.TopLeftReferencePoint)
		textField:setTextColor(255, 255, 0)
		self:insert(textField)
		self.textField = textField
		textField.y = 20

		Runtime:addEventListener("enterFrame", self)
		Runtime:dispatchEvent({name="DebugView_init", target=self})
	end

	function view:enterFrame()
		if self.levelModel ~= nil then
			self.textField.text = "level time: " .. tostring(self.levelModel.totalMilliseconds)
		else
			self.textField.text = "..."
		end
	end

	view:init()

	return view
end

return DebugView