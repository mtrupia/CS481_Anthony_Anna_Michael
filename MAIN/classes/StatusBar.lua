module (..., package.seeall)
-- HEALTH BAR LOCATION
local HPBx =  display.contentWidth  - 460
local HPBy =  display.contentHeight - 300
-- MANA BAR LOCATION
local MPBx =  display.contentWidth  - 335
local MPBy =  display.contentHeight - 300

-- Health Bar Sprite
local HealthOptions = {
	width = 60,
	height = 20,
	numFrames = 11
}
local HealthSheet = graphics.newImageSheet( "images/healthBar.png", HealthOptions)
local HealthsequenceData = {
	{ name = "0", start=1, count=1, time=0,   loopCount=1 },
	{ name = "10", start=2, count=1, time=0, loopCount=1 },
	{ name = "20", start=3, count=1, time=0, loopCount=1 },
	{ name = "30", start=4, count=1, time=0, loopCount=1 },
	{ name = "40", start=5, count=1, time=0, loopCount=1 },
	{ name = "50", start=6, count=1, time=0,   loopCount=1 },
	{ name = "60", start=7, count=1, time=0, loopCount=1 },
	{ name = "70", start=8, count=1, time=0, loopCount=1 },
	{ name = "80", start=9, count=1, time=0, loopCount=1 },
	{ name = "90", start=10, count=1, time=0, loopCount=1 },
	{ name = "100", start=11, count=1, time=0, loopCount=1 }
}

-- Mana Bar Sprite
local ManaOptions = {
	width = 60,
	height = 20,
	numFrames = 11
}
local ManaSheet = graphics.newImageSheet( "images/manaBar.png", ManaOptions)
local ManasequenceData = {
	{ name = "0", start=1, count=1, time=0,   loopCount=1 },
	{ name = "10", start=2, count=1, time=0, loopCount=1 },
	{ name = "20", start=3, count=1, time=0, loopCount=1 },
	{ name = "30", start=4, count=1, time=0, loopCount=1 },
	{ name = "40", start=5, count=1, time=0, loopCount=1 },
	{ name = "50", start=6, count=1, time=0,   loopCount=1 },
	{ name = "60", start=7, count=1, time=0, loopCount=1 },
	{ name = "70", start=8, count=1, time=0, loopCount=1 },
	{ name = "80", start=9, count=1, time=0, loopCount=1 },
	{ name = "90", start=10, count=1, time=0, loopCount=1 },
	{ name = "100", start=11, count=1, time=0, loopCount=1 }
}

function newStatusBar (player)
	statusBar = display.newGroup()
	statusBar.count = 1
	-- HP BAR
	if player.myName == "player" then
		-- Make Health Bar Sprite
		statusBar.HealthBar = display.newSprite( HealthSheet, HealthsequenceData)
		statusBar.HealthBar.x = HPBx
		statusBar.HealthBar.y = HPBy
		statusBar.HealthBar:scale(2, 1)
		statusBar:insert(statusBar.HealthBar)
		statusBar.HealthBar:setSequence( "100" )
		statusBar.HealthBar:play()
		-- Make Mana Bar Sprite
		statusBar.ManaBar = display.newSprite( ManaSheet, ManasequenceData)
		statusBar.ManaBar.x = MPBx + 10
		statusBar.ManaBar.y = MPBy
		statusBar.ManaBar:scale(2, 1)
		statusBar:insert(statusBar.ManaBar)
		statusBar.ManaBar:setSequence( "100" )
		statusBar.ManaBar:play()

		-- KEY
		statusBar.key = display.newImage("images/Key.png", 230, 15)
		statusBar:insert(statusBar.key)
		statusBar.key:scale(0.5,0.5)
		statusBar.key.isVisible = false

		-- BOMB
		statusBar.bomb = display.newImage("images/Bomb.png", 420, 15)
		statusBar:insert(statusBar.bomb)
		statusBar.bomb:scale(0.5,0.5)
		statusBar.bomb.count = display.newText("x" .. statusBar.count, 420,15)
		statusBar:insert(statusBar.bomb.count)
	end

	--Configure Health Bar
	function statusBar:setHP (player, amt)
		player.hp = player.hp + amt

		if player.hp < 0 then player.hp = 0
		elseif player.hp > 100 then player.hp = 100 end

		statusBar.HealthBar:setSequence( ""..player.hp )
		statusBar.HealthBar:play()
	end
	
	--Configure Mana Bar
	function statusBar:setMana(player, amt)
		player.mana = player.mana + amt
		
		if player.mana < 0 then player.mana = 0
		elseif player.mana > 100 then player.mana = 10 end
		
		if player.myName == "player" then
			statusBar.ManaBar:setSequence( ""..player.mana )
			statusBar.ManaBar:play()
		end
	end
  
  function statusBar:destroy()
	self:removeSelf()
  end
  
  return statusBar
end
