DebugViewController = {}

function DebugViewController:new()

	local controller = {}
	controller.classType = "DebugViewController"
	controller.view = nil

	function controller:onRegister()
		self.view.levelModel = self.context:getModel("levelModel")
	end

	function controller:onRemove()
		self.view.levelModel = nil
	end

	return controller
end

return DebugViewController