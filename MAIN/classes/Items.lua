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
    item:insert(item.img)
    if(item.type == "bomb") then
      item.img:scale(.5,.5)
      physics.addBody( item, "dynamic")
      timer.performWithDelay( 3000, function()
        item:boom(item)
      end, 1)
    else
      physics.addBody(item, "static")
    end
  end
  function item:destroy()
    self:removeSelf()
  end
  function item:getDistance(objA, objB)
    -- Get the length for each of the components x and y
    -- if(objA.myName) then
    --   print(objA.myName)
    -- elseif(objA.type) then
    --   print(objA.type)
    -- end
      local xDist = objB.x - objA.x
      local yDist = objB.y - objA.y

    return math.sqrt( (xDist ^ 2) + (yDist ^ 2) )
  end
  function item:boom(item)
    print("boom")
    if(item) then
      for n = 0, Enemies.numChildren, 1 do
        if(Enemies[n] and item) then
          local dis = item:getDistance(Enemies[n], item)
          if(dis < 100) then
            Enemies[n]:damageEnemy(30)
            print("Hit Enemy: " .. n)
          end
        end
      end
      if(item:getDistance(Player,item) < 100) then
        print("Hit Player")
        Player:damage(30)
        statusBar:dHPB()
        statusBar:dHPB()
        statusBar:dHPB()
      end
      item:destroy()
    end
  end

  return item
end
