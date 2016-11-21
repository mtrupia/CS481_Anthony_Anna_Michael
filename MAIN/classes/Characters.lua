-- Variables
local HitSound = audio.loadSound("sounds/Hit.wav")
local class = require 'libs.middleclass'
require 'classes.Bars'
require 'classes.Abilities'

-- Player Sprite
local playerSpriteOptions = {
  height = 64,
  width = 64,
  numFrames = 273
}
local playerSpriteSheet = graphics.newImageSheet("images/playerSprite.png", playerSpriteOptions)
local playerSpriteData = {
  {name = "forward", 			frames={105,106,107,108,109,110,111,112}, 		time = 500, loopCount = 1},
  {name = "right", 			frames={144,145,146,147,148,149,150,151,152}, 	time = 500, loopCount = 1},
  {name = "back", 			frames={131,132,133,134,135,136,137,138,139}, 	time = 500, loopCount = 1},
  {name = "left", 			frames={118,119,120,121,122,123,124,125,126}, 	time = 500, loopCount = 1},
  {name = "attackForward", 	frames={157,158,159,160,161,162,157}, 			time = 400, loopCount = 1},
  {name = "attackRight", 		frames={196,197,198,199,200,201,196}, 			time = 400, loopCount = 1},
  {name = "attackBack", 		frames={183,184,185,186,187,188,183}, 			time = 400, loopCount = 1},
  {name = "attackLeft", 		frames={170,171,172,173,174,175,170}, 			time = 400, loopCount = 1},
  {name = "death", 			frames={261,262,263,264,265,266}, 				time = 500, loopCount = 1}
}
------------------------------------------------

local function damagePlayer(p, e)
	if p.hasShield then
		p.statusBar:setMana(-e.damage)
		if p.mana <= 0 then
			p.hasShield = false
			p:remove(p.Shield)
		end
	else
		p.statusBar:setHealth(-e.damage)
	end

	e.dmgReady = false
	function allowDmg()
		e.dmgReady = true
	end
	timer.performWithDelay(250, allowDmg, 1)
end

Mollie = class('Mollie')
function Mollie:initialize(props)
  self.x = props.x or halfW
  self.y = props.y or halfH
  self.name = props.name or "player"
  self.angle = props.angle or 0
  self.health = props.health or 100
  self.mana = props.mana or 100
  self.score = props.score or 0
  self.hasShield = props.hasShield or false
  self.speed = props.speed or 3
  self:spawn()
  return self
end

function Mollie:spawn()
  self.sprite = display.newGroup()
  playerSprite = display.newSprite(self.sprite, playerSpriteSheet, playerSpriteData)
  self.sprite.x = self.x
  self.sprite.y = self.y
  self.sprite.name = self.name
  self.sprite.health = self.health
  self.sprite.mana = self.mana
  self.sprite.score = self.score
  self.sprite.speed = self.speed
  self.sprite.hasShield = self.hasShield
  playerSprite:setSequence("forward")
  physics.addBody(self.sprite, {filter = playerCollisionFilter})
  -- Initialize Player's StatusBar
  self.sprite.statusBar = Bar:new({target = self.sprite})
  self.sprite.statusBar:show()
  -- Initialize Player Power
  self.power = Ability:new(self.sprite)
  local function Shoot(event)
    if self.power then
      self.power:Shoot(event)
    end
  end
  Runtime:addEventListener("touch", Shoot)
  
  self.sprite.collision = function (self, event) 
	Mollie.collision(self, event)
  end
  
  self.sprite:addEventListener("collision")
end

function Mollie.collision(self, event)
	if event then
		if(event.other.name == "Enemy") then
			if event.other.dmgReady then
				damagePlayer(self, event.other)
			end
		end
	end
end

function Mollie:useAbility( type )
  if self.name == "player" then
    s = type:new({target = self.sprite })
  end
end

function Mollie:kill()
  if self.name == "player" then
    if self.power then
      --Runtime.removeEventListener("touch", Shoot)
      self.power = nil
    end
  end
  if self.sprite then
    if self.sprite.statusBar then
      self.sprite.statusBar:destroy()
      self.sprite.statusBar = nil
    end
    display.remove(self.sprite)
  end
end

function Mollie:move( obj )
  if self and obj then
    obj:move(self.sprite, self.speed, false)
    self.sprite.rotation = 0

    self.angle = obj:getAngle()
    angle = self.angle
    moving = obj:getMoving()

    if angle <= 45 or angle > 315 then
      seq = "forward"
    elseif angle <= 135 and angle > 45 then
      seq = "right"
    elseif angle <= 225 and angle > 135 then
      seq = "back"
    elseif angle <= 315 and angle > 225 then
      seq = "left"
    end

    if (not (seq == self.sprite[1].sequence) and moving) then
      self.sprite[1]:setSequence(seq)
    end

    if moving then
      self.sprite[1]:play()
    end
  end
end