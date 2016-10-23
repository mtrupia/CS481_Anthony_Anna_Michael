module (..., package.seeall)
-- Image Variables for Items
local healthImage = "images/Health.png"
local manaImage = "images/Mana.png"
local keyImage = "images/Key.png"
local doorImage = "images/Door.png"
local fdoorImage = "images/FinalDoor.png"

-- Variable to store Items
local item

function newItem ( props )
  item = display.newGroup()
  item.x      = props.x or 0
  item.y      = props.y or 0
  item.type   = props.type or "key"
  item.index  = props.index or 0
  item.myName = props.type

  function item:spawn()
    if( item.type == "hp") then
      item.image = healthImage
    elseif (item.type == "mana") then
      item.image = manaImage
    elseif (item.type == "key") then
      item.image = keyImage
    elseif (item.type == "door") then
      item.image = doorImage
      item.circle = display.newCircle(item.x, item.y - 20, 8)
      item.circle:setFillColor(1,0,0)
      item:insert(item.circle)
    elseif (item.type == "fdoor") then
      item.image = fdoorImage
    end

    itemImg = display.newImage(item.image)
    item:insert(itemImg)
    physics.addBody(item, "static")
  end
  function item:destroy()
    self:removeSelf()
  end

  return item
end
