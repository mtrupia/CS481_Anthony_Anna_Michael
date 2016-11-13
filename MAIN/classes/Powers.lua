module (..., package.seeall)
local class = require 'classes.middleclass'
-- Powers
local powerImage
local powers = {}
local n = 0
local alivePowers = {}
local x = 0

local ShootSound = audio.loadSound( "sounds/Shoot.wav")

Power = class('Power')
function Power:initialize(props)
  self.image    = props.image or "images/brick.png"
  self.life     = props.life or 1000 --what is this variable for?
  self.player   = props.player
  self.speed    = props.speed or 250
  self.density  = props.density or 3
  self.friction = props.friction or 0.500
  self.bounce   = props.bounce or 1
end
--Create EventListener
function Power:begin()
  Runtime:addEventListener("touch", Shoot)
end
-- Remove EventListener and remove the power
function Power:destroy()
  Runtime:removeEventListener("touch", Shoot)
  if self then
    self:removeSelf()
  end
end

function Power:Shield()
  local player = self.player
  if player.mana > 20 and not player.hasShield then
    player.statusBar:setMana(player, -20)
    player.hasShield = true
    player.Shield = display.newCircle (0, 5, 40)
    player.Shield:setFillColor(1,1,0)
    player.Shield.alpha = 0.2
    --player:insert(player.Shield)
    --Must add this into sceneGroup in levelScene
  end
end

function Shoot (event)
  if event.phase == "began" and self.player.mana > 0 and event.target == tTarget then --What is tTarget
    audio.play( ShootSound )
    n = n + 1
    powers[n] = display.newImage(powerImage, self.player.x, self.player.y)
    physics.addBody( powers[n], {
      density = self.density,
      friction = self.friction,
      bounce = self.bounce,
      filter = powerCollisionFilter
    })
    powers[n].myName = "power"
    local deltaX = event.x - self.player.x
    local deltaY = event.y - self.player.y
    local normDeltaX = deltaX / math.sqrt(math.pow(deltaX,2) + math.pow(deltaY,2))
    local normDeltaY = deltaY / math.sqrt(math.pow(deltaX,2) + math.pow(deltaY,2))
    powers[n]:setLinearVelocity( normDeltaX * powerSpeed, normDeltaY * powerSpeed )
    alivePowers[n] = n
    player.statusBar:setMana(player, -10)
    if player.hasShield and player.mana <= 0 then
      player.hasShield = false
      player:remove(player.Shield)
    end

    function delete()
      x = x + 1
      if (powers[alivePowers[x]]) then
        powers[alivePowers[x]]:removeSelf()
      end
    end
    timer.performWithDelay( powerLife, delete )
    tTarget = nil
  end
end
