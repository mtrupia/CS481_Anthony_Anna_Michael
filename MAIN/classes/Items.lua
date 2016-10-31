module (..., package.seeall)
-- Image Variables for Items
local healthImage = "images/Health.png"
local manaImage = "images/Mana.png"
local keyImage = "images/Key.png"
local doorImage = "images/Door.png"
local fdoorImage = "images/FinalDoor.png"
local bombImage = "images/Bomb.png"
-- Variable to store Items
local item

function newItem ( index, type, x, y )
  item = display.newGroup()
  item.x      = x or 0
  item.y      = y or 0
  item.type   = type
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
    elseif (item.type == "fdoor") then
      item.image = fdoorImage
    elseif (item.type == "bomb") then
      item.image = bombImage
    end
    item.img = display.newImage(item.image)
    if(item.type == "bomb") then
      item.img:scale(0.5,0.5)
    end
    item:insert(item.img)
    if(item.type == "bomb") then
      physics.addBody( item, "dynamic")
    else
      physics.addBody(item, "static")
    end
  end
  function item:destroy()
    self:removeSelf()
  end



  return item
end
