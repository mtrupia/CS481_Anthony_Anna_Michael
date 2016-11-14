local class = require 'classes.middleclass'
-- Image Variables for Items
local healthImage = "images/Health.png"
local manaImage = "images/Mana.png"
local keyImage = "images/Key.png"
local doorImage = "images/Door.png"
local fdoorImage = "images/FinalDoor.png"
local bombImage = "images/Bomb.png"
local composer = require("composer")
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

    self.exists = false
    sb:setHealth(50)
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
    sb:setMana(50)
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
    self.exists = false
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
  return FDoor.spawn(self)
end

function FDoor.spawn(self)
  local pot = self
  pot.image = display.newImage(fdoorImage, pot.x, pot.y)
  physics.addBody(pot.image, "static", { filter = itemCollisionFilter} )
  pot.image.collision = function(self,event)
    FDoor.collision(pot,event)
  end
  self.image:addEventListener("collision")
  return pot.image
end

function FDoor.collision(self, event)
  if(event.other.name == "player") then
    display.remove(self.image)
    self.exists = false
    --updatePlayerLevel()
    --CHANGE THIS BACK TO levelSelectionScene before Demo!!!!!!
    composer.gotoScene( "scenes.welcomeScene", { effect = "fade", time = 300 } )
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
  pot.image:scale(.5,.5)
  physics.addBody(pot.image, "dynamic")
  return pot.image
end
---------------------------------------------------------------------------------
-- End of SubClass:  Bomb
---------------------------------------------------------------------------------
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
    self.exists = false
  end
end
