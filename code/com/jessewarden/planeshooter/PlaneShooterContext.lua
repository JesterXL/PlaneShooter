PlaneShooterContext = {}

function PlaneShooterContext:new()

	local context = {}
	context.controllerMap = {}
	context.controllerInstances = {}
	context.models = {}
	context.commandMap = {}

	function context:mapSingletonModel(name, modelClass)
		assert(name ~= nil, "name must not be nil")
		assert(modelClass ~= nil, "modelClass must not be nil")
		self.models[name] = {class = modelClass, instance = nil}
	end

	function context:getModel(modelName)
		assert(modelName ~= nil, "modelName cannot be nil.")
		local object = self.models[modelName]
		if object.instance == nil then
			local classObject = require(object.class)
			local instance = classObject:new()
			object.instance = instance
		end
		return object.instance
	end

	function context:mapController(viewClass, controllerClass)
		assert(viewClass ~= nil, "viewClass cannot be nil.")
		assert(controllerClass ~= nil, "controllerClass cannot be nil.")
		assert(require(viewClass), "Could not find viewClass")
		assert(require(controllerClass), "Could not find controllerClass")
		--print("Context::mapMediator, viewClass: ", viewClass, ", mediatorClass: ", mediatorClass)
		-- NOTE: we're storing the actual class name, and discarding the package. This can lead to bugs,
		-- but until we have an easier way to get package information, we have zero clue what Lua/Corona
		-- does with our classes.
		local className = self:getClassNameFromPackage(viewClass)
		Runtime:addEventListener(className .. "_init", function(e)
			print("sup init")
			self:onViewInit(e)
		end)
		Runtime:addEventListener(className .. "_destroy", function(e)
			print("sup destroy")
			self:onViewDestroy(e)
		end)
		self.controllerMap[className] = controllerClass
		return true
	end

	function context:onViewInit(event)
		--print("PlaneShooterContext::onViewInit")
		-- do we have a registered controller?
		local view = event.target
		local hasCreatedController = self:hasCreatedController(view)
		--print("\thasCreatedController: ", hasCreatedController, ", classType: ", view.classType)
		if hasCreatedController == false then
			self:createController(view)
		end
	end

	function context:onViewDestroy(event)
		-- do we have a registered controller?
		local view = event.target
		if self:hasCreatedController(view) == false then
			self:destroyController(view)
		end
	end

	-- private --
	function context:createController(viewInstance)
		--print("PlaneShooterContext::createController, viewInstance: ", viewInstance)
		assert(viewInstance.classType ~= nil, "viewInstance does not have a classType parameter.")
		assert(self:hasCreatedController(viewInstance) == false, "viewInstance already has an instantiated Controller.")
		local controllerClassName = self.controllerMap[viewInstance.classType]
		assert(controllerClassName, "There is no Controller class registered for this View class.")
		assert(require(controllerClassName), "No controllerClassName exists: " .. controllerClassName)
		local requireResponse = require(controllerClassName)
		local controllerClass
		if type(requireResponse) == "table" then
			controllerClass = requireResponse:new()
		else
			local className = self:getClassNameFromPackage(controllerClassName)
			controllerClass = _G[className]:new()
		end
		table.insert(self.controllerInstances, controllerClass)
		controllerClass.context = self
		controllerClass.view = viewInstance
		controllerClass:onRegister()
		return true
	end

	-- private --
	function context:getClassNameFromPackage(classPackage)
		local firstIndex, lastIndex, searching
		searching = true
		firstIndex = 0
		lastIndex = 0
		while searching do
			local newFirst, newSecond
			newFirst, newSecond = string.find(classPackage, ".", firstIndex + 1, true)
			if newFirst == nil then
				searching = false
				break
			else
				firstIndex = newFirst
				lastIndex = newSecond
			end
		end
		local className = classPackage:sub(lastIndex + 1, #classPackage)
		return className
	end

	function context:destroyController(viewInstance)
		local controllerInstances = self.controllerInstances
		local len = #controllerInstances
		local i = 1
		while controllerInstances[i] do
			local instance = controllerInstances[i]
			if instance.view == viewInstance then
				instance:onRemove()
				table.remove(controllerInstances, i)
				return true
			end
			i = i + 1
		end
		return false
	end

	-- private --
	function context:hasCreatedController(viewInstance)
		local i, controllerMapInstance
		local controllerMap = self.controllerMap
		for i, controllerInstance in ipairs(self.controllerInstances) do
			if controllerInstance ~= nil then
				if controllerInstance.view == viewInstance then
					return true, i
				end
			end
		end
		return false
	end

	-- private --
	function context:mapCommand(eventName, commandClass)
		assert(eventName ~= nil, "eventName required.")
		assert(commandClass ~= nil, "commandClass required.")
		assert(require(commandClass), "Could not find commandClass")
		self.commandMap[eventName] = commandClass
		Runtime:addEventListener(eventName, function(e)
			self:onCommandEvent(e)
		end)
	end

	function context:onCommandEvent(event)
		local commandClassName = context.commandMap[event.name]
		if commandClassName ~= nil then
			local commandRequire = require(commandClassName)
			local command
			if type(commandRequire) == "table" then
				command = commandRequire:new()
			else
				local className = self:getClassNameFromPackage(commandClassName)
				command = _G[className]:new()
			end
			assert(command ~= nil, "Failed to create command class.")
			command:execute(event, context)
		end
	end

	return context

end

return PlaneShooterContext