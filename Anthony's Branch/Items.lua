module (..., package.seeall)
healthImage = "Health.png"
manaImage = "Mana.png"
keyImage = "Key.png"
doorImage = "Sonic.png"
scene = require "levelsScene"
local items = display.newGroup()
function newItems ( arg, x, y )
  if(arg == "hp") then
    items.hp = display.newImage( healthImage, x, y )
    items:insert(items.hp)
    physics.addBody( items.hp, "static" )
    items.hp.myName = "hp"
  end
  if(arg == "mana") then
    items.mana = display.newImage( manaImage, x, y )
    items:insert(items.mana)
    physics.addBody( items.mana, "static" )
    items.mana.myName = "mana"
  end
  -- key
  if (arg == "key") then
    items.key = display.newImage( keyImage, x, y )
    items:insert(items.key)
    physics.addBody( items.key, "static")
    items.key.myName = "key"
  end
  if (arg == "door") then
    items.door = display.newImage( doorImage, x, y )
    items:insert(items.door)
    physics.addBody( items.door, "static")
    items.door.myName = "door"
  end
  function items:destroy()
    display.remove(self)
    statusBar.key = nil
    self:removeSelf()
  end

  return items
end
