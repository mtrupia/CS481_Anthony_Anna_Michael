---------------------------------------------------------------------------------
--
-- levelsScene.lua	: Loads the levels of the game ( SO FAR ONLY 1 :( )
--
---------------------------------------------------------------------------------

local sceneName = ...
local composer = require( "composer" )
local scene = composer.newScene( sceneName )

---------------------------------------------------------------------------------

local LevelClass = require("Level")
local pauseImg = "pause.png"
local Level
local pauseButton

function scene:create( event )
	local sceneGroup = self.view
	Level = LevelClass.NewLevel()
	sceneGroup:insert(Level)
	pauseButton = display.newImage(pauseImg)
	pauseButton.x = display.contentWidth+20
	pauseButton.y = 21
	pauseButton.alpha = 0.2
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
	elseif phase == "did" then
		if pauseButton then
			function pauseButton:touch ( event )
        		local phase = event.phase
        		if "ended" == phase then
					-- WORK ON PAUSE SHIT...
        			composer.gotoScene( "welcomeScene", { effect = "fade", time = 0, params = {  } } )
        		end
        	end
        	pauseButton:addEventListener( "touch", pauseButton )
		end
		if Level then
			function begin (event)
				Level:begin()
			end
			Runtime:addEventListener("enterFrame", begin)
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
			pauseButton:removeSelf()
			pauseButton = nil
		end
		if Level then
			Runtime:removeEventListener("enterFrame", begin)
			Level:destroy()
			Level = nil
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
