local class = require 'libs.middleclass'
local image = "images/brick.png"
require 'classes.Enemies'
-- sounds
local ShootSound = audio.loadSound( "sounds/Shoot.wav" )
local PoofSound = audio.loadSound( "sounds/Poof.wav" )
local HitSound = audio.loadSound("sounds/Hit.wav")
-- controls creation and deletion of powers
local powers = {}
local n = 0
local alivePowers = {}
local x = 0

Ability = class('Ability')
function Ability:initialize(target)
  self.life     = 1000    -- how long the power shall stay alive
  self.speed    = 250    -- how fast will this power move
  self.density  = 3    -- density of this power
  self.friction = 0.5 -- friction of this power
  self.bounce   = 1     -- bounce of this power
  self.target   = target          -- target of the power

end

function Ability:Shoot(event)
  local target = self.target
  if event.phase == "began" then
    if target.mana <= 0 then
      if event.target == tTarget then
        audio.play( PoofSound )
      end
    end
  end
  if event.phase == "began" and event.target == tTarget then
    audio.play( ShootSound )
    n = n + 1
    powers[n] = display.newImage(image, target.sprite.x, target.sprite.y)
    physics.addBody( powers[n], {density = self.density, friction = self.friction, bounce = self.bounce, filter = powerCollisionFilter})
    powers[n].name = "power"
    powers[n].spell = self.name
    local deltaX = event.x - target.sprite.x
    local deltaY = event.y - target.sprite.y
    local normDeltaX = deltaX / math.sqrt(math.pow(deltaX,2) + math.pow(deltaY,2))
    local normDeltaY = deltaY / math.sqrt(math.pow(deltaX,2) + math.pow(deltaY,2))
    powers[n]:setLinearVelocity( normDeltaX * self.speed, normDeltaY * self.speed )
    alivePowers[n] = n
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

function Ability:use(enemy)
  print("Use Basic Ability")
  print(enemy.name)
  audio.play(HitSound)
  -- if enemy.attReady then
  --   enemy.attReady = false
  --   enemy:damage(-20)
  -- end
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
  self.name = "Fireball"
  self.target = props.target
  Ability.initialize(self, self.target)
end

function Fireball:use(enemy)
  -- for key,value in pairs(enemy) do
  --   print("found member " .. key);
  -- end
  audio.play(HitSound)
  if enemy.attReady then
    enemy.attReady = false
  end
  --Initial Damage for connecting Fireball
  enemy:Damage(-20)
  function DOT()
    --print("DOT")
    --enemy:Damage(-10)
    --print("Enemy HP = " .. enemy.sprite.health)
  end
  -- Damage Over Time ticks 4 times, for 30 damage
  timer.performWithDelay(1000, DOT, 3)
end

-- Iceball Subclass
Iceball = class('Iceball', Ability)
function Iceball:initialize(props)
  self.target = props.target
end

function Iceball:use()
  print("Use Iceball Ability")
  audio.play(HitSound)
  if enemy.attReady then
    enemy.attReady = false
  end
  -- Initial Damage for connecting Iceball
  enemy:damage(-10)
  local regularSpeed = enemy.speed
  enemy.speed = enemy.speed * .6
  function removeSlow()
    enemy.speed = regularSpeed
  end
  timer.performWithDelay(3000, function()
    removeSlow()
  end,
  1)
end
