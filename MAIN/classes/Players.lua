module (..., package.seeall)
local class = require 'classes.middleclass'
-- Player
local Power
local HitSound = audio.loadSound("sounds/Hit.wav")
-- Player Sprite
local playerOptions = {
  height = 64,
	width = 64,
	numFrames = 273,
}
local mySheet = graphics.newImageSheet("images/playerSprite.png", playerOptions)
local sequenceDataP = {
	{name = "forward", 				frames={105,106,107,108,109,110,111,112}, 		time = 500, loopCount = 1},
	{name = "right", 					frames={144,145,146,147,148,149,150,151,152}, time = 500, loopCount = 1},
	{name = "back", 					frames={131,132,133,134,135,136,137,138,139}, time = 500, loopCount = 1},
	{name = "left", 					frames={118,119,120,121,122,123,124,125,126}, time = 500, loopCount = 1},
	{name = "attackForward", 	frames={157,158,159,160,161,162,157}, 				time = 400, loopCount = 1},
	{name = "attackRight", 		frames={196,197,198,199,200,201,196}, 				time = 400, loopCount = 1},
	{name = "attackBack", 		frames={183,184,185,186,187,188,183}, 				time = 400, loopCount = 1},
	{name = "attackLeft", 		frames={170,171,172,173,174,175,170}, 				time = 400, loopCount = 1},
	{name = "death", 					frames={261,262,263,264,265,266}, 						time = 500, loopCount = 1}
}
-- Enemy Sprite
local enemyOptions = {
	width = 29,
	height = 36,
	numFrames = 8
}
local enemySheet = graphics.newImageSheet("images/enemySprite.png", enemyOptions)
enemyData = {
	{ name = "walk", start = 1, count = 8, time = 1000, loopCount = 1 }
}
---------------------------------------------------------------------------------
-- Class: Player
-- Functions:
---------------------------------------------------------------------------------
local Player = class('Player')
function Player:initialize( props )
  self.speed      = props.speed or 3
  self.image      = props.image or "flower.png"
  self.hp         = props.hp or 100
  self.mana       = props.mana or 100
  self.myName     = props.name or "player"
  self.x          = props.x or halfW
  self.y          = props.y or halfH
  self.hasShield  = props.hasShield or false
  self.visible    = props.visible or false
  self.index			= props.index or 0
  self.items      = props.items
  self.statusBar  = props.statusBar
end

function Player:spawn()
  playerSprite = display.newSprite(mySheet, sequenceDataP)
  playerSprite:setSequence("forward")
  player:insert(playerSprite)
  physics.addBody(playerSprite, {filter = playerCollisionFilter})
  -- Power
  Power = PowerLib.NewPower( { player = self} )
  Power:begin()
end

function Player:useShield()
  Power:Shield()
end

function Player:kill()
  if (self) then
    self:removeSelf()
  end
  Power:destroy()
end

function player:destroy()
  Power:destroy()
  self:removeSelf()
end

function player:attack( p )
  print("attack")
  p:damage( player.attackDamage)
end

function player:damage( amt )
  self.hp = self.hp - amt
  if self.hp <= 0 then
    self:kill()
  end
end

function player:collision ( event )
  if event.other.myName == "chaser" and event.other.dmgReady then
    if self.hasShield then
      self.statusBar:setMana(self, -10)
      if self.mana <= 0 then
        self.hasShield = false
        self:remove(self.Shield)
      end
    else
      self.statusBar:setHP(self, -10)
    end
    event.other.dmgReady = false
    function allowDmg()
      event.other.dmgReady = true
    end
    timer.performWithDelay(250, allowDmg, 1)
  end
end

function player:visibility(p)
  local ready = false
  local x1 = self.x
  local y1 = self.y
  local x2 = p.x
  local y2 = p.y

  if math.sqrt(math.pow((x2-x1),2)+math.pow((y2-y1),2)) < 400 then
    ready = true
  end

  if ready then
    self.visible = true
  elseif not (ready) then
    self.visible = false
  end
end

function player:move ( joystick )
  local seq
  if (self[1] and joystick) then
    joystick:move(self,self.speed,false)
    self.rotation = 0

    self.angle = joystick:getAngle()
    local moving = joystick:getMoving()

    -- Determine which animation to play based on the direction of the analog stick
    if(self.angle <= 45 or self.angle > 315) then
      seq = "forward"
    elseif(self.angle <= 135 and self.angle > 45) then
      seq = "right"
    elseif(self.angle <= 225 and self.angle > 135) then
      seq = "back"
    elseif(self.angle <= 315 and self.angle > 225) then
      seq = "left"
    end
    -- Change the sequence only if another sequence isn't still playing
    if(not (seq == self[1].sequence) and moving) then -- and not attacking
      self[1]:setSequence(seq)
    end

    -- If analog stick is moving, animate the sprite
    if(moving) then
      player[1]:play()
    end
  end
end
