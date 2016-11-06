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
--Initialize Item
-- Index [NEEDS TO BE REMOVED]
-- Type: HP, MANA, KEY, DOOR, FDOOR, Bomb
-- Coordinates: X, Y
function newItem ( index, type, x, y )
  item = display.newGroup()
  item.x      = x or 0
  item.y      = y or 0
  item.type   = type or "key"
  item.index  = index or 0
  item.myName = type

  -- Spawn the item
  -- Special Case for Bomb: Just scale the iamge down and call the Boom function to make it go Boom. Bomb is dynamic
  -- All other items are static



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

    if(item.type == "bomb") then
      item.img:scale(.5,.5)
      physics.addBody( item, "dynamic",{density = 3.0})
      timer.performWithDelay( 3000, function()
        item:boom(item)
      end, 1)
    else
      physics.addBody(item, "static")
    end

    physics.addBody(item, "static")

  end
  function item:destroy()
    self:removeSelf()
  end
  -- Calculates Distance between to objects as long as they have an X & Y
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
  -- Make the bomb go boom.
  -- Bomb detonates after 3 Seconds.
  -- Radius: 100
  --
  function item:boom(item)
    print("boom")
    if(item) then
      for n = 1, Enemies.numChildren, 1 do
        if(Enemies[n]) then
          local dis = item:getDistance(Enemies[n], item)
          if(dis < 100) then
            Enemies[n]:damageEnemy(30)
            print("Hit Enemy: " .. n)
          end
        end
      end
      if(item:getDistance(Player,item) < 100) then
        print("Hit Player")
        Player:damagePlayer(30)
        statusBar:dHPB()
        statusBar:dHPB()
        statusBar:dHPB()
      end
      item:destroy()
    end
  end

  return item
end
