


require "constants"
require "physics"
require "Player"

function startGame()
	
	physics.start()
	physics.setDrawMode( "hybrid" )
	physics.setGravity( 0, 0 )
	
	context = require("MainContext").new()
	context:init()
	player = Player.new()
	assert(context:createMediator(player), "Couldn't create player mediator.")
	
	print("player.onBulletHit: ", player.onBulletHit)
	player:onBulletHit()
	
end




startGame()





