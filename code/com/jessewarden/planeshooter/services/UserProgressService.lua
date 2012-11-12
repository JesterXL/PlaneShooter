
UserProgressService = {}
UserProgressService.fileName = "plane_shooter_progress_"
UserProgressService.directory = system.DocumentsDirectory

function UserProgressService:new()

	local service = {}

	function service:getFilePath()
		-- TODO: verify this works on devices. It shows / in the paths on Desktop.
		-- ex: plane_shooter_progress_Sun Nov 11 19/07/44 2012.json
		
		return UserProgressService.fileName .. os.date() .. ".json"
	end

	function service:delete()
		local path = system.pathForFile(self:getFilePath(), UserProgressService.directory)
		return os.remove(path)
	end

	function service:save(userProgressVO)
		-- create a file path for corona i/o
		local path = system.pathForFile(self:getFilePath(), UserProgressService.directory)
		assert(path ~= nil, "path is nil")
		local json = require "json"
		-- will hold contents of file
		local contents = json.encode(userProgressVO)

		-- io.open opens a file at path. returns nil if no file found
		local file = io.open( path, "w" )
		--print("base: ", base, ", path: ", path, ", file: ", file)
		if file then
			file:write(contents)
		   io.close( file )	-- close the file after using it
		end
		return true
	end

	function service:read()
		-- create a file path for corona i/o
		local path = system.pathForFile(self:getFilePath(), UserProgressService.directory)
		assert(path ~= nil, "path is nil")
		-- will hold contents of file
		local contents

		-- io.open opens a file at path. returns nil if no file found
		local file = io.open( path, "r" )
		if file then
			contents = file:read( "*a" )
			io.close( file )	-- close the file after using it
		end
		if contents == nil then return nil end
		local json = require "json"
		local vo = json.decode(contents)
		return vo
	end


	return service
end

return UserProgressService