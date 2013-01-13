StaticStartSound = {}

function StaticStartSound:new(channel)

	local sound = {}
	sound.file = nil

	function sound:init()
		self.file = audio.loadSound("audio/radio/static_start.wav")
	end

	function sound:play()
		local result, err = audio.play(self.file, {channel=channel,
							onComplete=function(e)
										sound:onComplete(e)
									   end})
	end

	function sound:onComplete(event)
		if event.completed == true then
			Runtime:dispatchEvent({name="StaticStartSound_onComplete", target=self})
		end
	end

	sound:init()

	return sound

end

return StaticStartSound