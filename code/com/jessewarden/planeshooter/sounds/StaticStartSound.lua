StaticStartSound = {}

function StaticStartSound:new(channel)

	local sound = audio.loadSound("audio/radio/static_start.wav")

	function sound:play()
		audio.play(self, {channel=channel,
							onComplete=self})
	end

	function sound:onComplete(event)
		Runtime:dispatchEvent({name="StaticStartSound_onComplete", target=self})
	end

	return sound

end

return StaticStartSound