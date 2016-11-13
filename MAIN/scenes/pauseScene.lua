---------------------------------------------------------------------------------
--
-- pauseScene.lua	: Pause menu of a level
--
---------------------------------------------------------------------------------

local sceneName = ...
local composer = require( "composer" )
local scene = composer.newScene( sceneName )

---------------------------------------------------------------------------------

local bgImg = "images/Key.png"
local titleImg = "images/gameTitle.png"

local pauseState = "continue"
local restartButton
local homeButton
local continueButton

function scene:create( event )
    local sceneGroup = self.view
	local bg = display.newImage(bgImg)
	bg.rotation = 90
	bg.alpha = 0.7
	local title = display.newImage(titleImg)
	title.x = display.contentWidth/2
	title.y = display.contentHeight/2 - 100
	sceneGroup:insert(bg)
	sceneGroup:insert(title)
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
        restartButton = display.newText("Restart", display.contentWidth/2, display.contentHeight/2, native.systemFont, 32)
		sceneGroup:insert(restartButton)
		homeButton = display.newText("Level Selection", display.contentWidth/2, display.contentHeight/2+50, native.systemFont, 32)
		sceneGroup:insert(homeButton)
		continueButton = display.newText("Continue", display.contentWidth/2, display.contentHeight/2+100, native.systemFont, 32)
		sceneGroup:insert(continueButton)
	elseif phase == "did" then
		if restartButton then
        	function restartButton:touch ( event )
        		local phase = event.phase
        		if "ended" == phase then
					--restart the lvl
					pauseState = "restart"
					composer.hideOverlay(true, "fade", 300)
        		end
        	end
        	restartButton:addEventListener( "touch", restartButton )
		end
		if homeButton then
        	function homeButton:touch ( event )
        		local phase = event.phase
        		if "ended" == phase then
					--go to level selection scene
					pauseState = "lvls"
					composer.hideOverlay(true, "fade", 300)
        		end
        	end
        	homeButton:addEventListener( "touch", homeButton )
		end
		if continueButton then
        	function continueButton:touch ( event )
        		local phase = event.phase
        		if "ended" == phase then
					-- go back to lvl
					pauseState = "continue"
					composer.hideOverlay(true, "fade", 300)
        		end
        	end
        	continueButton:addEventListener( "touch", continueButton )
		end
    end
end

function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase
	local parent = event.parent

    if event.phase == "will" then
		parent:unPause()
		if pauseState == "restart" then
			parent:restartLvl(parent.levelID)
		end
		if pauseState == "lvls" then
			parent:leaveLvl()
		end
    elseif phase == "did" then
		if restartButton then
			restartButton:removeEventListener( "touch", restartButton )
		end
		if homeButton then
			homeButton:removeEventListener( "touch", homeButton )
		end
		if continueButton then
			continueButton:removeEventListener( "touch", continueButton )
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
