require "json"

LoadLevelService = {}
LoadLevelService.loader = nil

function LoadLevelService:new(jsonFileName)

	local loader

	if LoadLevelService.loader == nil then
		LoadLevelService.loader = {}

		loader = LoadLevelService.loader

		-- jsonFile() loads json file & returns contents as a string
		function loader:jsonFile( filename, base )
			-- set default base dir if none specified
			if not base then base = system.ResourceDirectory; end

			-- create a file path for corona i/o
			local path = system.pathForFile( filename, base )

			-- will hold contents of file
			local contents

			-- io.open opens a file at path. returns nil if no file found
			local file = io.open( path, "r" )
			if file then
			   -- read all contents of file into a string
			   contents = file:read( "*a" )
			   io.close( file )	-- close the file after using it
			end

			return contents
		end
	else
		loader = LoadLevelService.loader
	end

	local jsonString = loader:jsonFile(jsonFileName)
	local level = json.decode(jsonString)

	return level
end

return LoadLevelService