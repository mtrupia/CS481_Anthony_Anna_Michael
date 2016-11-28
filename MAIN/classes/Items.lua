local class = require 'libs.middleclass'
-- Image Variables for Items
local healthImage = "images/Health.png"
local manaImage = "images/Mana.png"
local keyImage = "images/Key.png"
local doorImage = "images/Door.png"
local fdoorImage = "images/FinalDoor.png"
local bombImage = "images/Bomb.png"
local composer = require("composer")

local BombPSound = audio.loadSound("sounds/BombP.wav")
local DoorSound = audio.loadSound("sounds/Door.wav")
local FDoorSound = audio.loadSound("sounds/FDoor.wav")
local HealthSound = audio.loadSound("sounds/Health.wav")
---------------------------------------------------------------------------------
-- Class: Item
-- Functions: initialize, test, getDistance
---------------------------------------------------------------------------------
local Item = class('Item')
local sb
local player
function Item:initialize( x, y, name )
  self.x = x
  self.y = y
  self.name = name
  self.score = 100
  return self
end

function Item:test()
  print("Name  = " .. self.name)
  print("X     = " .. self.x)
  print("Y     = " .. self.y)
  --Loop that prints members of the object
  for key,value in pairs(self) do
    print("found member " .. key);
  end
end

function Item:getDistance(a)
  if self and a then
    local xDist = a.x - self.x
    local yDist = a.y - self.y
    return math.sqrt( (xDist ^ 2) + (yDist^2) )
  end
  return nil
end

function Item:destroy()
  if self then
    display.remove( self.image )
  end
end
---------------------------------------------------------------------------------
-- End of Class: Item
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
-- Subclass: HP
-- Functions: initialize, spawn, collision
---------------------------------------------------------------------------------
HP = class('HP', Item)
function HP:initialize(x,y, statusBar)
  self.exists = true
  sb = statusBar
  Item.initialize(self, x, y, "HP")
  return HP.spawn(self)
end

function HP.spawn(self)
  local pot = self
  pot.image = display.newImage(healthImage, pot.x, pot.y)
  pot.image.name = pot.name
  physics.addBody(pot.image, "static", { filter = itemCollisionFilter} )
  pot.image.collision = function(self,event)
    HP.collision(pot,event)
  end
  self.image:addEventListener("collision")
  return pot.image
end

function HP.collision(self, event)
  if(event.other.name == "player") then
    display.remove(self.image)
    audio.play(HealthSound)
    self.exists = false
    sb:setHealth(100)
    event.other.score = event.other.score + self.score
  end
end
---------------------------------------------------------------------------------
-- End of SubClass: HP
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
-- Subclass: Mana
-- Functions: initialize, spawn, collision
---------------------------------------------------------------------------------
Mana = class('Mana', Item)
function Mana:initialize(x,y, statusBar)
  self.exists = true
  sb = statusBar
  Item.initialize(self, x, y, "Mana")
  return Mana.spawn(self)
end

function Mana.spawn(self)
  local pot = self
  pot.image = display.newImage(manaImage, pot.x, pot.y)
  pot.image.name = pot.name
  physics.addBody(pot.image, "static", { filter = itemCollisionFilter} )
  pot.image.collision = function(self,event)
    Mana.collision(pot,event)
  end
  self.image:addEventListener("collision")
  return pot.image
end

function Mana.collision(self, event)
  if(event.other.name == "player") then
    display.remove(self.image)
    self.exists = false
    sb:setMana(100)
    event.other.score = event.other.score + self.score
  end
end
---------------------------------------------------------------------------------
-- End of SubClass: Mana
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
-- Subclass: Key
-- Functions: initialize, spawn, collision
---------------------------------------------------------------------------------

Key = class('Key', Item)
function Key:initialize(x,y, statusBar)
  self.exists = true
  sb = statusBar
  Item.initialize(self, x, y, "Key")
  return Key.spawn(self)
end

function Key.spawn(self)
  local pot = self
  pot.image = display.newImage(keyImage, pot.x, pot.y)
  pot.image.name = pot.name
  physics.addBody(pot.image, "static", { filter = itemCollisionFilter} )
  pot.image.collision = function(self,event)
    Key.collision(pot,event)
  end
  self.image:addEventListener("collision")
  return pot.image
end

function Key.collision(self, event)
  if(event.other.name == "player") then
    display.remove(self.image)
    self.exists = false
    sb.sprite.key.isVisible = true
    event.other.score = event.other.score + self.score
  end
end
---------------------------------------------------------------------------------
-- End of SubClass: Key
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
-- Subclass: Door
-- Functions: initialize, spawn, collision
---------------------------------------------------------------------------------
Door = class('Door', Item)
function Door:initialize(x,y, statusBar)
  self.exists = true
  sb = statusBar
  Item.initialize(self, x, y, "Door")
  return Door.spawn(self)
end

function Door.spawn(self)
  local pot = self
  pot.image = display.newImage(doorImage, pot.x, pot.y)
  pot.image.name = pot.name
  physics.addBody(pot.image, "static", { filter = itemCollisionFilter} )
  pot.image.collision = function(self,event)
    Door.collision(pot,event)
  end
  self.image:addEventListener("collision")
  return pot.image
end

function Door.collision(self, event)
  if(event.other.name == "player" and sb.sprite.key.isVisible) then
    sb.sprite.key.isVisible = false
    display.remove(self.image)
    audio.play(DoorSound)
    self.exists = false
    event.other.score = event.other.score + self.score
  end
end
---------------------------------------------------------------------------------
-- End of SubClass:  Door
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
-- Subclass: FDoor
-- Functions: initialize, spawn, collision
---------------------------------------------------------------------------------
FDoor = class('FDoor', Item)
function FDoor:initialize(x,y, statusBar)
  self.exists = true
  sb = statusBar
  Item.initialize(self, x, y, "FDoor")
  self.score = 1000
  return FDoor.spawn(self)
end

function FDoor.spawn(self)
  local pot = self
  pot.image = display.newImage(fdoorImage, pot.x, pot.y)
  pot.image.name = pot.name
  physics.addBody(pot.image, "static", { filter = itemCollisionFilter} )
  pot.image.collision = function(self,event)
    FDoor.collision(pot,event)
  end
  self.image:addEventListener("collision")
  return pot.image
end

function FDoor.collision(self, event)
  if(event.other.name == "player") then
    event.other.score = event.other.score + self.score
    display.remove(self.image)
    audio.play(FDoorSound)
    self.exists = false
    updatePlayerLevel()
    ItemsList = nil
    composer.gotoScene( "scenes.levelSelectionScene", { effect = "fade", time = 300 } )

  end
end
---------------------------------------------------------------------------------
-- End of SubClass:  FDoor
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
-- Subclass: Bomb
-- Functions: initialize, spawn
---------------------------------------------------------------------------------
Bomb = class('Bomb', Item)
function Bomb:initialize(x,y, statusBar)
  self.exists = true
  sb = statusBar
  Item.initialize(self, x, y, "Bomb")
  return Bomb.spawn(self)
end

function Bomb.spawn(self)
  local pot = self
  pot.image = display.newImage(bombImage, pot.x, pot.y)
  pot.image.name = pot.name
  pot.image:scale(.5,.5)
  physics.addBody(pot.image, "dynamic")
  return pot.image
end
---------------------------------------------------------------------------------
-- End of SubClass:  Bomb
---------------------------------------------------------------------------------

Spikes = class('Spikes', Item)
function Spikes:initialize(x, y, player)
	self.exists = true
	p = player
	Item.initialize(self, x, y, "Spikes")
	return Spikes.spawn(self)
end

function Spikes.spawn(self)
	self.image = display.newImage("images/spikes.PNG", self.x, self.y)
	self.image.name = self.name

	local function spike( event )
		self:active(p)
	end

	Runtime:addEventListener("enterFrame", spike)

	return self.image
end

function Spikes:active(p)
	local ready = false
	local x1 = p.x
	local y1 = p.y
	local x2 = self.image.x
	local y2 = self.image.y

	if x2 and y2 and x1 and y1 then
		if math.sqrt(math.pow((x2-x1),2)+math.pow((y2-y1),2)) < 40 then
			ready = true
		end

		if ready then
			if not p.hasShield then
				p.statusBar:setHealth(-100)
			end
		end
	end
end

HealthUpgrade = class('HealthUpgrade', Item)
function HealthUpgrade:initialize(x,y, player)
  self.exists = true
  self.score = 100
  p = player
  Item.initialize(self, x, y, "HealthUpgrade")
  return HealthUpgrade.spawn(self)
end

function HealthUpgrade.spawn(self)
  local pot = self
  pot.image = display.newImage("images/HealthUpgrade.png", pot.x, pot.y)
  pot.image.name = pot.name
  physics.addBody(pot.image, "static", { filter = itemCollisionFilter} )
  pot.image.collision = function(self,event)
    HealthUpgrade.collision(pot,event)
  end
  self.image:addEventListener("collision")
  return pot.image
end

function HealthUpgrade.collision(self, event)
  if(event.other.name == "player") then
    display.remove(self.image)
    self.exists = false
	p.maxHealth = p.maxHealth + 50
    p.statusBar:setHealth(p.maxHealth)
    event.other.score = event.other.score + self.score
  end
end

ManaUpgrade = class('ManaUpgrade', Item)
function ManaUpgrade:initialize(x,y, player)
  self.exists = true
  self.score = 100
  p = player
  Item.initialize(self, x, y, "ManaUpgrade")
  return ManaUpgrade.spawn(self)
end

function ManaUpgrade.spawn(self)
  local pot = self
  pot.image = display.newImage("images/ManaUpgrade.png", pot.x, pot.y)
  pot.image.name = pot.name
  physics.addBody(pot.image, "static", { filter = itemCollisionFilter} )
  pot.image.collision = function(self,event)
    ManaUpgrade.collision(pot,event)
  end
  self.image:addEventListener("collision")
  return pot.image
end

function ManaUpgrade.collision(self, event)
  if(event.other.name == "player") then
    display.remove(self.image)
    self.exists = false
	p.maxMana = p.maxMana + 50
	p.statusBar:setMana(p.maxMana)
    event.other.score = event.other.score + self.score
  end
end

---------------------------------------------------------------------------------
-- Subclass: BombP
-- Functions: initialize, spawn
---------------------------------------------------------------------------------
BombP = class('BombP', Item)
function BombP:initialize(x,y, statusBar)
  self.exists = true
  sb = statusBar
  Item.initialize(self, x, y, "BombP")
  return BombP.spawn(self)
end

function BombP.spawn(self)
  local pot = self
  pot.image = display.newImage(bombImage, pot.x, pot.y)
  pot.image.name = pot.name
  pot.image:scale(.3,.3)
  physics.addBody(pot.image, "static", { filter = itemCollisionFilter} )
  pot.image.collision = function(self,event)
    BombP.collision(pot,event)
  end
  self.image:addEventListener("collision")
  return pot.image
end

function BombP.collision(self, event)
  if(event.other.name == "player") then
    sb.sprite.count = sb.sprite.count + 1
    sb.sprite.bomb.count.text = "x" .. sb.sprite.count
    display.remove(self.image)
    audio.play(BombPSound)
    self.exists = false
    event.other.score = event.other.score + self.score
  end
end
