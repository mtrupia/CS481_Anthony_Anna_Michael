---------------------------------------------------------------------------------
--
-- levelsScene.lua	: Loads the levels of the game ( SO FAR ONLY 10 :( )
--
---------------------------------------------------------------------------------

local sceneName = ...
local composer = require( "composer" )
local scene = composer.newScene( sceneName )

---------------------------------------------------------------------------------

-- start phyics up
physics.start()
physics.setGravity(0, 0)
--physics.setDrawMode( "hybrid" )
-- Vars
local pauseImg
local bg
local walls
local Items
local Player
local Joystick
local levelID
local pauseButton
statusBar = display.newGroup()
local options = {
  width = 60,
  height = 20,
  numFrames = 6
}


function scene:create( event )
  local sceneGroup = self.view

  bg			= event.params.bg or "testBG.png"
  pauseImg	= event.params.pauseImg or "pauseIcon.png"

  -- Create background
  bg = display.newImage("testBG.png")
  bg.rotation = 90
  sceneGroup:insert(bg)
end

function scene:show( event )
  local sceneGroup = self.view
  local phase = event.phase

  if phase == "will" then
    -- BG may change
    bg = event.params.bg or "testBG.png"
    -- LevelID
    levelID = event.params.levelID
    -- Player
    Player = PlayerLib.NewPlayer( {} )
    items = ItemsLib.newItems()
    ItemsLib.newItems("hp", 100, 100)
    ItemsLib.newItems("mana", 200, 100)
    ItemsLib.newItems("key", 300, 100)
    ItemsLib.newItems("door", 400, 100)
    sceneGroup:insert(Player)
    sceneGroup:insert(items)
    sceneGroup:insert(statusBar)
    Player:spawnPlayer()

    -- Joystick
    Joystick = StickLib.NewStick(
    {
      x             = 10,
      y             = screenH-(52),
      thumbSize     = 20,
      borderSize    = 32,
      snapBackSpeed = .2,
      R             = 0,
      G             = 1,
      B             = 1
    }
  )
  sceneGroup:insert(Joystick)
  Joystick.alpha = 0.2
  -- Create some collision
  walls = display.newGroup()
  for n = 1, levelID, 1 do
    local crate
    if n <= 5 then
      crate = display.newImage("crate.png", 50+75*(n-1), 100)
    else
      crate = display.newImage("crate.png", 50+75*(n-6), 300)
    end
    physics.addBody(crate, "static", { filter = worldCollisionFilter } )
    walls:insert(crate)
  end
  sceneGroup:insert(walls)

  pauseButton = display.newImage(pauseImg)
  pauseButton.x = display.contentWidth+20
  pauseButton.y = 21
  pauseButton.alpha = 0.2
  sceneGroup:insert(pauseButton)
  sceneGroup:insert(statusBar)
  -- STATUS BAR

  statusBar.EmptymanaSprite = display.newImage("EmptyBar.png", 111, 20)
  statusBar.EmptymanaSprite:scale(.5,1)
  statusBar:insert(statusBar.EmptymanaSprite)


  statusBar.EmptyHealthSprite = display.newImage("EmptyBar.png", 10, 20)
  statusBar.EmptyHealthSprite:scale(.5,1)
  statusBar:insert(statusBar.EmptyHealthSprite)
  healthIncrease()
elseif phase == "did" then
  if Player and Joystick then
    function begin( event )
      Player:move(Joystick)

      --move world if outside border
      if Player.x < -8 then	-- moving left
        Player.x = -8

        for n = 1, walls.numChildren, 1 do
          walls[n].x = walls[n].x + Player.speed
        end
        for n = 1, items.numChildren, 1 do
          items[n].x = items[n].x + Player.speed
        end
      end
      if Player.x > screenW+8 then	-- moving right
        Player.x = screenW+8

        for n = 1, walls.numChildren, 1 do
          walls[n].x = walls[n].x - Player.speed
        end
        for n = 1, items.numChildren, 1 do
          items[n].x = items[n].x - Player.speed
        end
      end
      if Player.y < borders then	-- moving up
        Player.y = borders

        for n = 1, walls.numChildren, 1 do
          walls[n].y = walls[n].y + Player.speed
        end
        for n = 1, items.numChildren, 1 do
          items[n].y = items[n].y + Player.speed
        end
      end
      if Player.y > screenH-borders then	-- moving down
        Player.y = screenH-borders

        for n = 1, walls.numChildren, 1 do
          walls[n].y = walls[n].y - Player.speed
        end
        for n = 1, items.numChildren, 1 do
          items[n].y = items[n].y - Player.speed
        end
      end
    end
    Runtime:addEventListener("enterFrame", begin)
  end
  if pauseButton then
    function pauseButton:touch ( event )
      local phase = event.phase
      if "ended" == phase then
        composer.showOverlay( "pauseScene", { isModal = true, effect = "fade", time = 300 } )
      end
    end
    pauseButton:addEventListener( "touch", pauseButton )
  end
end
end

function scene:hide( event )
  local sceneGroup = self.view
  local phase = event.phase

  if event.phase == "will" then
  elseif phase == "did" then
    if pauseButton then
      pauseButton:removeEventListener("touch", pauseButton)
    end
    if Player then
      Runtime:removeEventListener("enterFrame", begin)
      Player:destroy()
    end
    if Joystick then
      Joystick:delete()
    end
    if walls then
      walls:removeSelf()
      walls = nil
    end
    if items then
      items:destroy()
      items:removeSelf()
    end
  end
end

function scene:destroy( event )
  local sceneGroup = self.view
end

function scene:leaveLvl()
  composer.gotoScene( "levelSelectionScene", { effect = "fade", time = 300 } )
end

function scene:restartLvl( id )
  composer.gotoScene( "levelsScene", { effect = "fade", time = 300, params = { levelID = levelID } } )
end

function manaIncrease()
  Player.mana = Player.mana + 10
  for count = 30, 90, 10 do
    if (Player.mana == 10) then
      statusBar.circle = display.newCircle(68,15,6)
      statusBar:insert(statusBar.circle)
      statusBar.circle:setFillColor(0,0,255)
    end
    if (Player.mana == 20) then
      statusBar.rectangle = display.newRect(72,15,8,11)
      statusBar:insert(statusBar.rectangle)
      statusBar.rectangle.anchorX = 0
      statusBar.rectangle.anchorY = 0.5
      statusBar.rectangle:setFillColor(0,0,255)
    end
    if (Player.mana == 100) then
      statusBar.circle2 = display.newCircle(155,16,6)
      statusBar:insert(statusBar.circle2)
      statusBar.circle2:setFillColor(0,0,255)
    end
    if(Player.mana == count) then
      statusBar.rectangle.width = statusBar.rectangle.width + 10
    end
  end
end

function healthIncrease()
  Player.health = Player.health + 10
  for count = 30, 90, 10 do
    if (Player.health == 10) then
      statusBar.circleHP = display.newCircle(-32, 15, 6)
      statusBar.circleHP:setFillColor(1,0,0)
      statusBar:insert(statusBar.circleHP)

    end
    if (Player.health == 20) then
      statusBar.rectangleHP = display.newRect(-31,15,8,12)
      statusBar.rectangleHP:setFillColor(255,0,0)
      statusBar:insert(statusBar.rectangleHP)
      statusBar.rectangleHP.anchorX = 0
      statusBar.rectangleHP.anchorY = 0.5

    end
    if (Player.health == 100) then
      statusBar.circle2HP = display.newCircle(54,15,6)
      statusBar:insert(statusBar.circle2HP)
      statusBar.circle2HP:setFillColor(255,0,0)
    end
    if(Player.health == count) then
      statusBar.rectangleHP.width = statusBar.rectangle.width + 7
    end
  end
end

function onGlobalCollision ( event )
  print("Collision: Object 1 =", event.object1.myName, "Object 2 =", event.object2.myName)
  local o1n = event.object1.myName
  local o2n = event.object2.myName
  local health = "hp"
  local Mana = "mana"
  local key = "key"
  local door = "door"
  if ( o1n == health or o2n == health) and (o1n == "player" or o2n == "player") then
    display.remove( items.hp )
    healthIncrease()
  elseif (o1n == Mana or o2n == Mana) and (o1n == "player" or o2n == "player") then
    display.remove( items.mana )
    manaIncrease()
  elseif (o1n == key or o2n == key) and (o1n == "player" or o2n == "player") then
    items.key = display.remove( items.key )
    statusBar.key = display.newImage("Key.png", 400, 10)
    statusBar.key:scale(0.5,0.5)
  elseif (o1n == door or o2n == door) and (o1n == "player" or o2n == "player") then
    if(statusBar.key) then
      statusBar.key = display.remove(statusBar.key)
      timer.performWithDelay(200, removeP)
    end
  end
end

function removeP()
  Player:toFront()
  physics.removeBody( items.door )
end
---------------------------------------------------------------------------------

-- Listener setup
Runtime:addEventListener("collision", onGlobalCollision)
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene
