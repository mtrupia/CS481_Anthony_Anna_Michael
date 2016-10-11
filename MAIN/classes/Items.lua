module (..., package.seeall)
-- Image Variables for Items
local healthImage = "images/Health.png"
local manaImage = "images/Mana.png"
local keyImage = "images/Key.png"
local doorImage = "images/Door.png"
local fdoorImage = "images/FinalDoor.png"

-- Variable to store Items
local items = display.newGroup()

function newItems ( arg, x, y )
  -- Health
  -- Restores Health
  if(arg == "hp") then
    items.hp = display.newImage( healthImage, x, y )
    items:insert(items.hp)
    physics.addBody( items.hp, "static" )
    items.hp.myName = "hp"
  end
  -- Mana
  -- Replenishes Mana
  if(arg == "mana") then
    items.mana = display.newImage( manaImage, x, y )
    items:insert(items.mana)
    physics.addBody( items.mana, "static" )
    items.mana.myName = "mana"
  end

  -- Key
  -- Unlocks Doors
  if (arg == "key") then
    items.key = display.newImage( keyImage, x, y )
    items:insert(items.key)
    physics.addBody( items.key, "static")
    items.key.myName = "key"
  end

  -- Final Door
  -- Ends Level
  if (arg == "fdoor") then
    items.fdoor = display.newImage( fdoorImage, x, y )
    items:insert(items.fdoor)
    physics.addBody( items.fdoor, "static")
    items.fdoor.myName = "fdoor"
  end

  -- Door
  -- Locked, unlocked by using a key
  if (arg == "door") then
    items.door = display.newImage( doorImage, x, y )
    items:insert(items.door)
    items.door.circle = display.newCircle( x, y - 20, 8)
    items.door.circle:setFillColor(1,0,0)
    items:insert(items.door.circle)
    physics.addBody( items.door, "static")
    items.door.myName = "door"
  end

  function items:destroy()
    display.remove(self)
    self:removeSelf()
  end

  return items
end
