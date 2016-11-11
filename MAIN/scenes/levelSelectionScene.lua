---------------------------------------------------------------------------------
--
-- levelSelectionScene.lua	: Choose a level from the game (starts at lvl 1 if beginning)
--
---------------------------------------------------------------------------------

local sceneName = ...
local composer = require( "composer" )
local scene = composer.newScene( sceneName )

---------------------------------------------------------------------------------

local bgImg = "images/tealBG.png"
local titleImg = "images/gameTitle.png"

local levelsButton = {}
local levels = 0
local backButton

function scene:create( event )
  local sceneGroup = self.view

  local bg = display.newImage(bgImg)
  bg.rotation = 90
  sceneGroup:insert(bg)
  local title = display.newImage(titleImg)
  title.x = display.contentWidth/2
  title.y = display.contentHeight/2 - 100
  sceneGroup:insert(title)
  local titleTxt = display.newText("Levels", 30, 32, native.systemFont, 32)
  sceneGroup:insert(titleTxt)
end

function scene:show( event )
  local sceneGroup = self.view
  local phase = event.phase
  if phase == "will" then
	playerlevel = require('levels.player')
	levels = playerlevel.levels
	
    for n = 1, levels, 1 do
      if n<=5 then
        levelsButton[n] = display.newText(n, (n-1)*120, display.contentHeight/2, native.systemFont, 32)
      else
        levelsButton[n] = display.newText(n, 120*(n-6), display.contentHeight/2+64, native.systemFont, 32)
      end
      sceneGroup:insert(levelsButton[n])
    end
    backButton = display.newText("Back", display.contentWidth/2, display.contentHeight/2+110, native.systemFont, 32)
    sceneGroup:insert(backButton)
  elseif phase == "did" then
    for n = 1, levels, 1 do
      if levelsButton[n] then
        level = levelsButton[n]
        function level:touch ( event )
          local phase = event.phase
          if "ended" == phase then
            composer.gotoScene( "scenes.levelsScene", { effect = "fade", time = 300, params = { levelID = n } } )
          end
        end
        level:addEventListener( "touch", level )
      end
    end
    if backButton then
      function backButton:touch ( event )
        local phase = event.phase
        if "ended" == phase then
          composer.gotoScene( "scenes.welcomeScene", { effect = "fade", time = 300 } )
        end
      end
      backButton:addEventListener( "touch", backButton )
    end
  end 
end

function scene:hide( event )
  local sceneGroup = self.view
  local phase = event.phase

  if event.phase == "will" then
  elseif phase == "did" then
    for n = 1, levels, 1 do
      if levelsButton[n] then
        levelsButton[n]:removeEventListener( "touch", levelsButton[n] )
      end
    end
    if backButton then
      backButton:removeEventListener( "touch", backButton )
    end
  end
end


function scene:destroy( event )
  local sceneGroup = self.view
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene
