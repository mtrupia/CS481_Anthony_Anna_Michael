module (..., package.seeall)
healthImage = "Health.png"
manaImage = "Mana.png"
keyImage = "Key.png"
local statusBar
local options = {
  width = 60,
  height = 20,
  numFrames = 6
}
function newItems ()
  local items = display.newGroup()
  -- FROM HEALTH BAR TUTORIAL
  statusBar = display.newGroup()
  statusBar.name = "statusBar"
  items:insert(statusBar)
  healthSheet = graphics.newImageSheet( "img-omni-2.png", options)
  sequenceData = {
     { name = "health0", start=1, count=1, time=0,   loopCount=1 },
     { name = "health1", start=1, count=2, time=100, loopCount=1 },
     { name = "health2", start=1, count=3, time=200, loopCount=1 },
     { name = "health3", start=1, count=4, time=300, loopCount=1 },
     { name = "health4", start=1, count=5, time=400, loopCount=1 },
     { name = "health5", start=1, count=6, time=500, loopCount=1 }
  }
  healthSprite = display.newSprite( healthSheet, sequenceData )

  healthSprite.x = 75
  healthSprite.y = 15
  statusBar:insert( healthSprite )  -- "statusBar" is a display group
  healthSprite:setSequence( "health" .. 1 )
  healthSprite:play()
  -- END OF CODE FROM HEALTH BAR TUTORIAL

  -- Heart
  items.hp = display.newImage(healthImage, 100, 100)
  items:insert(items.hp)
  physics.addBody( items.hp, "static" )
  items.hp.myName = "hp"

  -- Mana
  items.mana = display.newImage(manaImage, display.contentWidth / 2 + 60, display.contentHeight / 2)
  items:insert(items.mana)
  physics.addBody( items.mana, "static" )
  items.mana.myName = "mana"

  -- key
  items.key = display.newImage(keyImage, display.contentWidth / 2 + 100, display.contentHeight / 2)
  items:insert(items.key)
  physics.addBody( items.key, "static")
  items.key.myName = "key"

  function onGlobalCollision ( event )
    print("Collision: Object 1 =", event.object1.myName, "Object 2 =", event.object2.myName)
    local o1n = event.object1.myName
    local o2n = event.object2.myName
    local health = items.hp.myName
    local mana = items.mana.myName
    local key = items.key.myName

    if ( o1n == health or o2n == health) and (o1n == "player" or o2n == "player") then
      display.remove( items.hp )
      healthSprite:setSequence("health5")
      healthSprite:setFrame( 3 )
      --healthSprite:play()
    elseif (o1n == mana or o2n == mana) and (o1n == "player" or o2n == "player") then
      display.remove( items.mana )
    elseif (o1n == key or o2n == key) and (o1n == "player" or o2n == "player") then
      display.remove( items.key )
      statusBar.key = display.newImage(keyImage, 470, 20)
      statusBar:insert(statusBar.key)
      statusBar.key:scale(0.5,0.5)
    end
  end
  function items:destroy()
    items.remove(self)
    display.remove(self)
    self:removeSelf()
  end
  Runtime:addEventListener("collision", onGlobalCollision)
  return items
end
