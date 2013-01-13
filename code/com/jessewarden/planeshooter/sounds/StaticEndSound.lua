StaticEndSound = {}

function StaticEndSound:new(channel)

	local sound = {}
	sound.file = nil

	function sound:init()
		self.file = audio.loadSound("audio/radio/static_end.wav")
	end

	function sound:play()
		audio.play(self.file, {channel=channel,
							onComplete=function(e)
										sound:onComplete(e)
									   end})
	end

	function sound:onComplete(event)
		if event.completed == true then
			Runtime:dispatchEvent({name="StaticEndSound_onComplete", target=self})
		end
	end

	sound:init()

	return sound

end

return StaticEndSound