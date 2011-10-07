
MockOpenFeint = {}

function MockOpenFeint:new()
	local mock = display.newGroup()
	local globalStage = display.getCurrentStage()
	mock.stage = globalStage
	mock.width = 200
	mock.height = 40
	local rect = display.newRect(0, 0, 200, 54)
	rect:setReferencePoint(display.TopLeftReferencePoint)
	rect:setFillColor(255, 255, 255, 120)
	mock:insert(rect)
	rect.isVisible = false
	mock.background = rect
	mock.FONT_SIZE = 11
	mock.HANG_TIME = 3000
	
	local platform = system.getInfo("platformName")
	local text
	if platform == "Android" or platform == "iPhone OS" then
		text = native.newTextBox( 0, 0, 146, 54 )
		text.hasBackground = false
		text.isEditable = false
		text.align = "left"
	else
		text = display.newText("", 0, 0, native.systemFont, mock.FONT_SIZE)
	end
	text:setReferencePoint(display.TopLeftReferencePoint)
	text:setTextColor(255, 255, 255)
	text.size = mock.FONT_SIZE
	text.font = native.newFont( native.systemFont, mock.FONT_SIZE )
	mock:insert(text)
	text.isVisible = false
	mock.textField = text
	mock.platform = platform
	
	local imgGroup = display.newGroup()
	mock:insert(imgGroup)
	mock.imgHolder = imgGroup
	
	function mock:init(message)
		self.message = message
		self.timerID = timer.performWithDelay(1000, mock.onInit)
	end
	
	function mock.onInit()
		local self = mock
		timer.cancel(self.timerID)
		self.timerID = nil
		self:showInit()
	end
	
	function mock:showInit(newMessage)
		self.background.isVisible = true
		self.background.x = (self.stage.width / 2) - (self.background.width / 2)
		self.background.y = self.stage.height - self.background.height
		
		self.imgHolder.isVisible = false
		
		self.textField.isVisible = true
		
		local textMessage
		if newMessage ~= nil then
			textMessage = newMessage
		else
			textMessage = self.message
		end
		
		self.textField.text = textMessage
		if self.platform == "Android" or self.platform == "iPhone OS" then
			self.textField.x = self.background.x + 2
		else
			text.x = 100 + (text.width / 2)
			self.textField.x = self.background.x + 2 + (self.textField.width / 2)
		end
		
		self.textField.y = self.background.y + (self.textField.height / 2) + self.FONT_SIZE
		
		self.alpha = 0
		if self.tween ~= nil then
			transition.cancel(self.tween)
		end
		self.tween = transition.to(self, {time=500, alpha=1, onComplete=mock.onShowInitComplete})
	end
	
	function mock.onShowInitComplete(self)
		if self.tween ~= nil then
			transition.cancel(self.tween)
		end
		self.tween = transition.to(self, {time=300, alpha=0, delay=mock.HANG_TIME, onComplete=mock.onHideInitComplete})
	end
	
	function mock.onHideInitComplete(self)
		self.tween = nil
		self.background.isVisible = false
		self.textField.isVisible = false
	end
	
	function mock:showAchievement(img, text)
		self.background.isVisible = true
		self.background.x = (self.stage.width / 2) - (self.background.width / 2)
		self.background.y = self.stage.height - self.background.height
		
		self.imgHolder.isVisible = true
		self.imgHolder.x = self.background.x + 2
		self.imgHolder.y = self.background.y + 2
		if self.imgHolder.image ~= nil then
			self.imgHolder.image:removeSelf()
		end
		self.imgHolder.image = display.newImage(img)
		self.imgHolder.image:setReferencePoint(display.TopLeftReferencePoint)
		self.imgHolder:insert(self.imgHolder.image)
		
		
		self.textField.text = text
		self.textField.isVisible = true
		if self.platform == "Android" or self.platform == "iPhone OS" then
			self.textField.x = self.imgHolder.x + 2
		else
			self.textField.x = self.background.x + self.imgHolder.x + 2 + (self.textField.width / 2)
		end
		self.textField.y = self.background.y + (self.textField.height / 2) + self.FONT_SIZE
		
		self.alpha = 0
		if self.tween ~= nil then
			transition.cancel(self.tween)
		end
		self.tween = transition.to(self, {time=500, alpha=1, onComplete=mock.onShowAchievementComplete})
	end
	
	function mock.onShowAchievementComplete(self)
		if self.tween ~= nil then
			transition.cancel(self.tween)
		end
		self.tween = transition.to(self, {time=300, alpha=0, delay=mock.HANG_TIME, onComplete=mock.onHideAchievementComplete})
	end
	
	function mock.onHideAchievementComplete(self)
		self.tween = nil
		self.background.isVisible = false
		self.textField.isVisible = false
		self.imgHolder.isVisible = false
	end
	
	return mock
end

return MockOpenFeint