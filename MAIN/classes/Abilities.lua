local class = require 'libs.middleclass'
local image = "images/brick.png"

-- sounds
local ShootSound = audio.loadSound( "sounds/Shoot.wav" )
local PoofSound = audio.loadSound( "sounds/Poof.wav" )
-- controls creation and deletion of powers
local powers = {}
local n = 0
local alivePowers = {}
local x = 0

Ability = class('Ability')
function Ability:initialize(props)
  self.life     = props.life or 1000    -- how long the power shall stay alive
  self.speed    = props.speed or 250    -- how fast will this power move
  self.density  = props.density or 3    -- density of this power
  self.friction = props.friction or 0.5 -- friction of this power
  self.bounce   = props.bounce or 1     -- bounce of this power
  self.target   = props.target          -- target of the power
end

function Ability:Shoot(event)
  local target = self.target
  if event.phase == "began" and target.mana <= 0 and event.target == tTarget then
    audio.play( PoofSound )
  end
  if event.phase == "began" and target.mana > 0 and event.target == tTarget then
    audio.play( ShootSound )
    n = n + 1
    powers[n] = display.newImage(image, target.sprite.x, target.sprite.y)
    physics.addBody( powers[n], {density = self.density, friction = self.friction, bounce = self.bounce, filter = powerCollisionFilter})
    powers[n].name = "power"
    local deltaX = event.x - target.sprite.x
    local deltaY = event.y - target.sprite.y
    local normDeltaX = deltaX / math.sqrt(math.pow(deltaX,2) + math.pow(deltaY,2))
    local normDeltaY = deltaY / math.sqrt(math.pow(deltaX,2) + math.pow(deltaY,2))
    powers[n]:setLinearVelocity( normDeltaX * self.speed, normDeltaY * self.speed )
    alivePowers[n] = n
    target.statusBar:setMana(-10)
    function delete()
      x = x + 1
      if powers[alivePowers[x]] then
        powers[alivePowers[x]]:removeSelf()
      end
    end
    timer.performWithDelay(self.life,delete)
    tTarget = nil
  end
end
-- Shield Subclass
Shield = class('Shield', Ability)
function Shield:initialize(props)
  print(props.target.name)
  self.target = props.target
end

function Shield:use()
  local target = self.target
  if target.mana > 0 and not target.hasShield then
    target.hasShield = true
    target.Shield = display.newCircle (target, 0, 5, 40)
    target.Shield:setFillColor( 1, 1, 0)
    target.Shield.alpha = 0.2
  end
end

-- Fireball Subclass
Fireball = class('Fireball', Ability)
function Fireball:initialize(props)
  -- TODO: Initialize Fireball power
end

function Fireball:use()
  -- TODO: I don't know if we'll need this function if it's just going to use the Shoot function
  -- Option for this class: Have this function be called on Enemies to handle the Damage over Time
end

-- Iceball Subclass
Iceball = class('Iceball', Ability)
function Iceball:initialize(props)
  -- TODO: Initialize Iceball power
end

function Iceball:use()

end
