Collection = {}

function Collection:new()

	local collection = display.newGroup()
	collection.items = collection

	function collection:addItem(item)
		table.insert(self.items, item)
		self:dispatchEvent({name="onChange", target=self, kind="add"})
	end

	function collection:removeItem(item)
		local index = table.indexOf(self, item)
		if index ~= nil then
			table.remove(self.items, index)
			self:dispatchEvent({name="onChange", target=self, kind="remove"})
			return true
		else
			return false
		end
	end

	function collection:set(items)
		if items == nil then
			self.items = {}
			self:dispatchEvent({name="onChange", target=self, kind="set"})
			return true
		end

		local i = 1
		while items[i] do
			table.insert(self.items, items[i])
			i = i + 1
		end
		self:dispatchEvent({name="onChange", target=self, kind="set"})
	end

	function collection:sort(sortFunction)
		if sortFunction ~= nil then
			table.sort(self, sortFunction)
		else
			table.sort(self)
		end
		self:dispatchEvent({name="onChange", target=self, kind="sort"})
	end

	return collection
end

return Collection