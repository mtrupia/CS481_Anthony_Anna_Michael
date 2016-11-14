-------------------------------------------------
--
-- Bar.lua
--
-- Controls health and mana bar placements
--
-------------------------------------------------

local bar = {}
local bar_mt = { __index = bar }

-------------------------------------------------
-- PRIVATE FUNCTIONS
-------------------------------------------------

--sprites
local healthSpriteOptions = {
	width = 60,
	height = 20,
	numFrames = 11
}
local healthSpriteSheet = graphics.newImageSheet( "images/healthBar.png", healthSpriteOptions )
local healthSpriteData = {
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
local manaSpriteOptions = {
	width = 60,
	height = 20,
	numFrames = 11
}
local manaSpriteSheet = graphics.newImageSheet( "images/manaBar.png", manaSpriteOptions)
local manaSpriteData = {
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

-------------------------------------------------
-- PUBLIC FUNCTIONS
-------------------------------------------------
-- create new bar/bars
function bar.new ( props )
	local newBar
	
	newBar = {
		healthPos = {
			x 		= props.healthX or screenW - 460,
			y 		= props.healthY or screenH - 300,
			scaleX 	= props.healthScaleX or 2,
			scaleY 	= props.healthScaleY or 1
		},
		manaPos = {
			x 		= props.manaX or screenW - 335,
			y 		= props.manaY or screenH - 300,
			scaleX  = props.manaScaleX or 2,
			scaleY  = props.manaScaleY or 1
		},
		target 		= props.target,
		sprite		= props.sprite
	}
	
	return setmetatable( newBar, bar_mt )
end

-------------------------------------------------
-- show the bars
function bar:show()
	if self.sprite then
		if self.target.name == "player" then
			-- health bar
			self.sprite.healthBar = display.newSprite( self.sprite, healthSpriteSheet, healthSpriteData )
			self.sprite.healthBar.x = self.healthPos.x
			self.sprite.healthBar.y = self.healthPos.y
			self.sprite.healthBar:scale(self.healthPos.scaleX, self.healthPos.scaleY)
			self.sprite.healthBar:setSequence( "100" )
			self.sprite.healthBar:play()
			-- mana bar
			self.sprite.manaBar = display.newSprite( self.sprite, manaSpriteSheet, manaSpriteData )
			self.sprite.manaBar.x = self.manaPos.x
			self.sprite.manaBar.y = self.manaPos.y
			self.sprite.manaBar:scale(self.manaPos.scaleX, self.manaPos.scaleY)
			self.sprite.manaBar:setSequence( "100" )
			self.sprite.manaBar:play()
			-- key
			self.sprite.key = display.newImage(self.sprite, "images/Key.png", 230, 15)
			self.sprite.key:scale(0.5, 0.5)
			self.sprite.key.isVisible = false
			-- bombs
			self.sprite.count = 0
			self.sprite.bomb = display.newImage(self.sprite, "images/Bomb.png", 420, 15)
			self.sprite.bomb:scale(0.5, 0.5)
			self.sprite.bomb.count = display.newText(self.sprite, "x".. self.sprite.count, 420, 15)
		else
			self.sprite.healthBar = display.newSprite( self.sprite, healthSpriteSheet, healthSpriteData )
			self.sprite.healthBar.x = self.target.x
			self.sprite.healthBar.y = self.target.y - 10
			self.sprite.healthBar:scale(0.5, 0.5)
			self.sprite.healthBar:setSequence( "100" )
			self.sprite.healthBar:play()
		end
	else
		self.sprite = display.newGroup()
		
		self:show()
	end
end

-------------------------------------------------
-- set health bar sprite
function bar:setHealth( amt )
	local player = self.target
	player.health = player.health + amt
	
	if player.health < 0 then player.health = 0
	elseif player.health > 100 then player.health = 100 end

	if self.sprite then
		self.sprite.healthBar:setSequence( ""..player.health )
		self.sprite.healthBar:play()
	end
end

-------------------------------------------------
-- set mana bar sprite
function bar:setMana( amt )
	local player = self.target
	player.mana = player.mana + amt
	
	if player.mana < 0 then player.mana = 0
	elseif player.mana > 100 then player.mana = 100 end

	self.sprite.manaBar:setSequence( ""..player.mana )
	self.sprite.manaBar:play()
end

-------------------------------------------------
-- destroy the sprites
function bar:destroy()
	if self.sprite then
		if self.sprite[1] then
			self.sprite:removeSelf()
			self.sprite = nil
		end
	end
end

-------------------------------------------------
-- move the sprites()
function bar:move()
	if self.sprite and self.target then
		self.sprite.healthBar.x = self.target.x
		self.sprite.healthBar.y = self.target.y - 10
	end
end

-------------------------------------------------

return bar