require "com.jessewarden.planeshooter.sounds.SoundManager"

BossBigPlaneDeath = {}

function BossBigPlaneDeath:new(startX, startY)

	if(BossBigPlaneDeath.bossSheet == nil) then
		local bossSheet = sprite.newSpriteSheet("bomber_explode.png", 135, 79)
		local bossSet = sprite.newSpriteSet(bossSheet, 1, 6)
		sprite.add(bossSet, "bossBigPlaneDeath", 1, 6, 3800, 1)
		BossBigPlaneDeath.bossSheet = bossSheet
		BossBigPlaneDeath.bossSet = bossSet
	end

	local boss = sprite.newSprite(BossBigPlaneDeath.bossSet)
	
	boss.classType = "BossBigPlaneDeath"
	
	function boss:init()
		self:addEventListener("sprite", self)
		self:prepare("bossBigPlaneDeath")
		self:play()
		self.x = startX
		self.y = startY
		SoundManager.inst:playBossBigPlaneDeathSound()
	end

	function boss:sprite(event)
		if event.phase == "end" then
			self:destroy()
		end
	end

	function boss:destroy()
		self:removeEventListener("sprite", self)
		self:removeSelf()
	end

	boss:init()

	return boss

end

return BossBigPlaneDeath