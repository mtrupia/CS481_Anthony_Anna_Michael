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
function Ability:initialize(target, mana, damage, name)
  self.life     = 500    -- how long the power shall stay alive
  self.speed    = 300    -- how fast will this power move
  self.density  = 0.0000001    -- density of this power
  self.friction = 0.00000001 -- friction of this power
  self.bounce   = 0.00000001     -- bounce of this power
  self.target   = target          -- target of the power
  self.name		= name or 'reg'
  self.damage 	= damage or -30
  self.mana		= mana or 0
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
  if event.phase == "began" and event.target == tTarget and target.mana >= (self.mana*-1) then
    audio.play( ShootSound )
    n = n + 1
    powers[n] = display.newImage(image, target.x, target.y)
    physics.addBody( powers[n], {density = self.density, friction = self.friction, bounce = self.bounce, filter = powerCollisionFilter})
    powers[n].name = "power"
    powers[n].spell = self.name
	powers[n].damage = self.damage
    local deltaX = event.x - target.x
    local deltaY = event.y - target.y
    local normDeltaX = deltaX / math.sqrt(math.pow(deltaX,2) + math.pow(deltaY,2))
    local normDeltaY = deltaY / math.sqrt(math.pow(deltaX,2) + math.pow(deltaY,2))
    powers[n]:setLinearVelocity( normDeltaX * self.speed, normDeltaY * self.speed )
    alivePowers[n] = n
	target.statusBar:setMana(self.mana)
    function delete()
      x = x + 1
      if powers[alivePowers[x]] then
        powers[alivePowers[x]]:removeSelf()
      end
    end
    timer.performWithDelay(self.life,delete)

	if target.hasShield then
		if target.mana <= 0 then
			target.hasShield = false
			target:remove(target.Shield)
		end
	end

	if target.mana < self.mana*-1 then
		Ability.initialize(self, self.target)
	end
	
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

  self.target = props.target

  self:use()
end

function Shield:use()
  local target = self.target
  if target.mana > 0 and not target.hasShield then
    target.hasShield = true
    target.Shield = display.newCircle(target, 0, 0, 40)
    target.Shield:setFillColor( 1, 1, 0)
    target.Shield.alpha = 0.2
  end
end

-- Fireball Subclass
Fireball = class('Fireball', Ability)
function Fireball:initialize(target)
  self.name = "fireball"
  self.target = target
  self.mana = -10
  self.damage = -40
  Ability.initialize(self, self.target, self.mana, self.damage, self.name)
end

-- Iceball Subclass
Iceball = class('Iceball', Ability)
function Iceball:initialize(target)
  self.name = "iceball"
  self.target = target
  self.mana = -10
  self.damage = -40
  Ability.initialize(self, self.target, self.mana, self.damage, self.name)
end
