StaticEndSound = {}

function StaticEndSound:new(channel)

	local sound = audio.loadSound("audio/radio/static_end.wav")

	function sound:play()
		audio.play(self, {channel=channel,
							onComplete=self})
	end

	function sound:onComplete(event)
		Runtime:dispatchEvent({name="StaticEndSound_onComplete", target=self})
	end

	return sound

end

return StaticEndSound