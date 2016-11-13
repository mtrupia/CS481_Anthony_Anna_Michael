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
-- Functions: initialize, test
---------------------------------------------------------------------------------
local Item = class('Item')
local sb
function Item:initialize( x, y, name )
  self.x = x
  self.y = y
  self.myName = name
  return self
end

function Item:test()
  print("Name  = " .. self.myName)
  print("X     = " .. self.x)
  print("Y     = " .. self.y)
  --Loop that prints members of the object
  for key,value in pairs(self) do
    print("found member " .. key);
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
  sb = statusBar
  Item.initialize(self, x, y, "HP")
  return HP.spawn(self)
end

function HP.spawn(self)
  local pot = self
  pot.image = display.newImage(healthImage, pot.x, pot.y)
  physics.addBody(pot.image, "static")
  pot.image.collision = function(self,event)
    HP.collision(self,event)
  end
  self.image:addEventListener("collision")
  return pot.image
end

function HP.collision(self, event)
  if(event.other.myName == "player") then
    display.remove(self)
    sb:setHP(Player,50)
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
  sb = statusBar
  Item.initialize(self, x, y, "Mana")
  return Mana.spawn(self)
end

function Mana.spawn(self)
  local pot = self
  pot.image = display.newImage(manaImage, pot.x, pot.y)
  physics.addBody(pot.image, "static")
  pot.image.collision = function(self,event)
    Mana.collision(self,event)
  end
  self.image:addEventListener("collision")
  return pot.image
end

function Mana.collision(self, event)
  if(event.other.myName == "player") then
    display.remove(self)
    sb:setMana(Player,50)
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
  sb = statusBar
  Item.initialize(self, x, y, "Key")
  return Key.spawn(self)
end

function Key.spawn(self)
  local pot = self
  pot.image = display.newImage(keyImage, pot.x, pot.y)
  physics.addBody(pot.image, "static")
  pot.image.collision = function(self,event)
    Key.collision(self,event)
  end
  self.image:addEventListener("collision")
  return pot.image
end

function Key.collision(self, event)
  if(event.other.myName == "player") then
    display.remove(self)
    sb.key.isVisible = true
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
  sb = statusBar
  Item.initialize(self, x, y, "Door")
  return Door.spawn(self)
end

function Door.spawn(self)
  local pot = self
  pot.image = display.newImage(doorImage, pot.x, pot.y)
  physics.addBody(pot.image, "static")
  pot.image.collision = function(self,event)
    Door.collision(self,event)
  end
  self.image:addEventListener("collision")
  return pot.image
end

function Door.collision(self, event)
  if(event.other.myName == "player" and sb.key.isVisible) then
    sb.key.isVisible = false
    display.remove(self)
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
  sb = statusBar
  Item.initialize(self, x, y, "FDoor")
  return FDoor.spawn(self)
end

function FDoor.spawn(self)
  local pot = self
  pot.image = display.newImage(fdoorImage, pot.x, pot.y)
  physics.addBody(pot.image, "static")
  pot.image.collision = function(self,event)
    FDoor.collision(self,event)
  end
  self.image:addEventListener("collision")
  return pot.image
end

function FDoor.collision(self, event)
  if(event.other.myName == "player") then
    sb.key.isVisible = false
    display.remove(self)
    --updatePlayerLevel()
    composer.gotoScene( "scenes.levelSelectionScene", { effect = "fade", time = 300 } )
  end
end
