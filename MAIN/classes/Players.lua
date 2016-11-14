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
---------------------------------------------------------------------------------
-- Class: Player
-- Functions: initialize, spawn, useShielf, kill, destroy,
--            attack, damage, collision, visibility, move
---------------------------------------------------------------------------------
Player = class('Player')
function Player:initialize(props)
  self.x          = props.x or halfW
  self.y          = props.y or halfH
  self.angle      = props.angle or 0
  self.health     = props.health or 100
  self.mana       = props.mana or 100
  self.score      = props.score or 0
  self.name       = props.name or "player"
  self.hasShield  = props.hasShield or false
  self.dmgReady   = props.dmgReady or false
  self.speed      = props.speed or 3
  self.power      = props.power
  self.items      = props.items
  self.statusBar  = props.statusBar
  self.sprite     = props.sprite
end

function Player:spawn()
  if self.sprite then
    player.image = display.newSprite(self.sprite, playerSpriteSheet, playerSpriteData)
    player.image:setSequence("forward")
    physics.addBody(player.image, {filter = playerCollisionFilter})
    self.power = PowerLib.NewPower({player = self})
    self.power:begin()
  end
end

function Player:useAbility(type)
  if type == "shield" then
    self.power:Shield()
  end
end

function Player:kill()
  if self.power then
    self.power:destroy()
    self.power = nil
  end
  if self.sprite[1] then
    self.sprite:removeSelf()
    self.sprite = nil
  end
end
--Don't need this function
function Player:destroy()
  self:kill()
end

function Player:move( obj )
  if self.sprite and obj then
    obj:move(self.sprite,self.speed,false)
    self.sprite.rotation = 0

    self.sprite.angle = obj:getAngle()
    local angle = self.sprite.angle
    local moving = obj:getMoving()

    if angle <= 45 or angle > 315 then
      seq = "forward"
    elseif angle <= 135 and angle > 45 then
      seq = "right"
    elseif angle <= 225 and angle > 135 then
      seq = "back"
    elseif angle <= 315 and angle > 225 then
      seq = "left"
    end

    if (not(seq == self.sprite[1].sequence) and moving) then
      self.sprite[1]:setSequence(seq)
    end

    if moving then
      self.sprite[1]:play()
    end
  end
end
