local class = require 'libs.middleclass'
local healthSpriteOptions = {
  width = 60,
  height = 20,
  numFrames = 11
}
local healthSpriteSheet = graphics.newImageSheet( "images/healthBar.png", healthSpriteOptions )
local healthSpriteData = {
  { name = "0", start=1, count=1, time=0,   loopCount=1 },
  { name = "1", start=2, count=1, time=0, loopCount=1 },
  { name = "2", start=3, count=1, time=0, loopCount=1 },
  { name = "3", start=4, count=1, time=0, loopCount=1 },
  { name = "4", start=5, count=1, time=0, loopCount=1 },
  { name = "5", start=6, count=1, time=0,   loopCount=1 },
  { name = "6", start=7, count=1, time=0, loopCount=1 },
  { name = "7", start=8, count=1, time=0, loopCount=1 },
  { name = "8", start=9, count=1, time=0, loopCount=1 },
  { name = "9", start=10, count=1, time=0, loopCount=1 },
  { name = "10", start=11, count=1, time=0, loopCount=1 }
}
local manaSpriteOptions = {
  width = 60,
  height = 20,
  numFrames = 11
}
local manaSpriteSheet = graphics.newImageSheet( "images/manaBar.png", manaSpriteOptions)
local manaSpriteData = {
  { name = "0",  start=1, count=1,  time=0,   loopCount=1 },
  { name = "1", start=2, count=1, time=0,   loopCount=1 },
  { name = "2", start=3, count=1, time=0,   loopCount=1 },
  { name = "3", start=4, count=1, time=0,   loopCount=1 },
  { name = "4", start=5, count=1, time=0,   loopCount=1 },
  { name = "5", start=6, count=1, time=0,   loopCount=1 },
  { name = "6", start=7, count=1, time=0,   loopCount=1 },
  { name = "7", start=8, count=1, time=0,   loopCount=1 },
  { name = "8", start=9, count=1, time=0,   loopCount=1 },
  { name = "9", start=10, count=1, time=0,  loopCount=1 },
  { name = "10", start=11, count=1, time=0, loopCount=1 }
}
Bar = class ('Bar')
function Bar:initialize(props)
  self.target = props.target
  self.sprite = props.sprite
end

function Bar:show()
  self.sprite = display.newGroup()
  local sprite = self.sprite
  
  -- Health Bar
  sprite.healthBar = display.newSprite(sprite, healthSpriteSheet, healthSpriteData)
  sprite.healthBar.x = screenW - 460
  sprite.healthBar.y = screenH - 300
  sprite.healthBar:scale(2,1)
  sprite.healthBar:setSequence("10")
  sprite.healthBar:play()
  -- Mana Bar
  sprite.manaBar = display.newSprite(sprite, manaSpriteSheet, manaSpriteData)
  sprite.manaBar.x = screenW - 335
  sprite.manaBar.y = screenH - 300
  sprite.manaBar:scale(2,1)
  sprite.manaBar:setSequence("10")
  sprite.manaBar:play()
  
  -- Score
  sprite.score = display.newText(self.target.score, screenW - 100, screenH - 305)
  sprite.score:setFillColor( 1, 0, 0.5 )
  -- Key
  sprite.key = display.newImage(sprite, "images/Key.png", 230, 15)
  sprite.key:scale(0.5,0.5)
  sprite.key.isVisible = false
  -- Bombs
  sprite.count = 0
  sprite.bomb = display.newImage(sprite, "images/Bomb.png", 420, 15)
  sprite.bomb:scale(0.5,0.5)
  sprite.bomb.count = display.newText(sprite, "x" .. sprite.count, 420, 15)
end

function Bar:setHealth(amt)
	local player = self.target
	local sprite = self.sprite
	-- Update Health
	player.health = player.health + amt
	-- Upper and Lower Bounds for Player Health
	if player.health < 0 then player.health = 0
	elseif player.health >= player.maxHealth then player.health = player.maxHealth end
	
	if sprite then
		sprite.healthBar:setSequence(player.health / (player.maxHealth/10))
		sprite.healthBar:play()
	end
end

function Bar:setMana(amt)
  local player = self.target
  local sprite = self.sprite
  -- Update mana
  player.mana = player.mana + amt
  -- Upper and Lower Bounds for Player mana
  if player.mana < 0 then player.mana = 0
  elseif player.mana >= player.maxMana then player.mana = player.maxMana end

  if sprite then
    sprite.manaBar:setSequence(player.mana / (player.maxMana/10))
	sprite.manaBar:play()
  end
end

function Bar:destroy()
  if self.sprite then
    self.sprite:removeSelf()
    self.sprite = nil
  end
end

-- Enemy Health Bars Subclass
eBar = class('eBar', Bar)
function eBar:initialize(props)
  self.target = props.target
  self.scaleX = 0.5
  self.scaleY = 0.5
end

function eBar:show()
  self.sprite = display.newGroup()
  local sprite = self.sprite
  local target = self.target
  sprite.healthBar = display.newSprite(sprite, healthSpriteSheet, healthSpriteData)
  sprite.healthBar.x = target.x
  sprite.healthBar.y = target.y - 20
  sprite.healthBar:scale(self.scaleX, self.scaleY)
  sprite.healthBar:setSequence("10")
  sprite.healthBar:play()
  sprite.fire = display.newImage(sprite, "images/Fire.png", target.x-25, target.y - 20)
  sprite.fire:scale(0.25,0.25)
  sprite.fire.isVisible = false
  sprite.ice = display.newImage(sprite, "images/Ice.png", target.x-25, target.y - 20)
  sprite.ice:scale(0.4,0.4)
  sprite.ice.isVisible = false
end

function eBar:move()
	if self.sprite then
	  if self.sprite.x and self.target.x then
		self.sprite.healthBar.x = self.target.x
		self.sprite.healthBar.y = self.target.y - 20
		self.sprite.fire.x = self.target.x-25
		self.sprite.fire.y = self.target.y-20
		self.sprite.ice.x = self.target.x-25
		self.sprite.ice.y = self.target.y-20
		
		if self.target.onFire then
			self.sprite.fire.isVisible = true
		else
			self.sprite.fire.isVisible = false
		end
		
		if self.target.onIce then
			self.sprite.ice.isVisible = true
		else
			self.sprite.ice.isVisible = false
		end
	  end
	 end
end
