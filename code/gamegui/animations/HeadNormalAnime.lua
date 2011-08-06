local movieclip = require("movieclip")

HeadNormalAnime = {}

function HeadNormalAnime:new(x, y)
	
	if(HeadNormalAnime.frames == nil) then
		HeadNormalAnime.frames = {}
		-- head_normal_00000.jpg
		for i=1,51 do
			local digit = i - 1
			if(digit < 10) then
				digit = "0" .. digit
			end
		
			table.insert(HeadNormalAnime.frames, "gamegui/animations/head_normal/head_normal_000" .. digit .. ".jpg")
		end
	end
	local anime = movieclip.newAnim(HeadNormalAnime.frames)
	anime:setReferencePoint(display.TopLeftReferencePoint)
	anime.x = x
	anime.y = y
	anime:play()
	return anime
end

return HeadNormalAnime