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
    item.image  = item.findImage()
    item.img    = display.newImage(item.image)
    item:insert(item.img)
    if(item.type == "bomb") then
      item.img:scale(.5,.5)
      physics.addBody( item, "dynamic")
    elseif (item.type == "bombP") then

      item.img:scale(.3,.3)
      physics.addBody(item, "static")

    else
      physics.addBody(item, "static")
    end
  end
  function item:destroy()
	if item then
		self:removeSelf()
	end
  end
  function item:getDistance(objA, objB)
	if objA and objB then
		local xDist = objB.x - objA.x
		local yDist = objB.y - objA.y

		return math.sqrt( (xDist ^ 2) + (yDist ^ 2) )
	end
	return nil
  end

  function item:findImage()
    local image
    if( item.type == "hp") then
      image = healthImage
    elseif (item.type == "mana") then
      image = manaImage
    elseif (item.type == "key") then
      image = keyImage
    elseif (item.type == "door") then
      image = doorImage
    elseif (item.type == "fdoor") then
      image = fdoorImage
    elseif (item.type == "bomb" or item.type == "bombP") then
      image = bombImage
    end
    return image
  end
  return item
end
