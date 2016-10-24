module (..., package.seeall)
-- Image Variables for Items
local healthImage = "images/Health.png"
local manaImage = "images/Mana.png"
local keyImage = "images/Key.png"
local doorImage = "images/Door.png"
local fdoorImage = "images/FinalDoor.png"

-- Variable to store Items
local item

function newItem ( index, type, x, y )
  item = display.newGroup()
  item.x      = x or 0
  item.y      = y or 0
  item.type   = type or "key"
  item.index  = index or 0
  item.myName = type

  function item:spawn()
    if( item.type == "hp") then
      item.image = healthImage
    elseif (item.type == "mana") then
      item.image = manaImage
    elseif (item.type == "key") then
      item.image = keyImage
    elseif (item.type == "door") then
      item.image = doorImage
      --item.circle = display.newCircle(item.x, item.y - 20, 8)
      --item.circle:setFillColor(1,0,0)
    elseif (item.type == "fdoor") then
      item.image = fdoorImage
    end

    item.img = display.newImage(item.image)
    item:insert(item.img)
    physics.addBody(item, "static")
  end
  function item:destroy()
    self:removeSelf()
  end

  return item
end
