---------------------------------------------------------------------------------
--
-- welcomeScene.lua	: Beginning screen of the application - Sends user accordingly on their option
--
---------------------------------------------------------------------------------

local sceneName = ...
local composer = require( "composer" )
-- Load scene with same root filename as this file
local scene = composer.newScene( sceneName )

---------------------------------------------------------------------------------

local bgImg = "tealBG.png"
local titleImg = "gameTitle.png"

local levelSelectionButton
local settingsButton
local creditsButton
local exitButton

function scene:create( event )
    local sceneGroup = self.view

    -- Called when the scene's view does not exist
    -- 
    -- INSERT code here to initialize the scene
    -- e.g. add display objects to 'sceneGroup', add touch listeners, etc
	local bg = display.newImage(bgImg)
	bg.rotation = 90
	sceneGroup:insert(bg)
	local title = display.newImage(titleImg)
	title.x = display.contentWidth/2
	title.y = display.contentHeight/2 - 100
	sceneGroup:insert(title)
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
        -- Called when the scene is still off screen and is about to move on screen
		levelSelectionButton = display.newText("Level Selection", display.contentWidth/2, display.contentHeight/2, native.systemFont, 32)
		settingsButton = display.newText("Settings", levelSelectionButton.x, levelSelectionButton.y+40, native.systemFont, 32)
		creditsButton = display.newText("Credits", settingsButton.x, settingsButton.y+40, native.systemFont, 32)
		exitButton = display.newText("Exit", creditsButton.x, creditsButton.y+40, native.systemFont, 32)
		sceneGroup:insert(levelSelectionButton)
		sceneGroup:insert(settingsButton)
		sceneGroup:insert(creditsButton)
		sceneGroup:insert(exitButton)
	elseif phase == "did" then
        -- Called when the scene is now on screen
        -- 
        -- INSERT code here to make the scene come alive
        -- e.g. start timers, begin animation, play audio, etc
        if levelSelectionButton then
        	-- touch listener for the button
        	function levelSelectionButton:touch ( event )
        		local phase = event.phase
        		if "ended" == phase then
        			composer.gotoScene( "levelSelectionScene", { effect = "fade", time = 300 } )
        		end
        	end
        	-- add the touch event listener to the button
        	levelSelectionButton:addEventListener( "touch", levelSelectionButton )
        end
        if settingsButton then
        	function settingsButton:touch ( event )
        		local phase = event.phase
        		if "ended" == phase then
        			composer.gotoScene( "settingsScene", { effect = "fade", time = 300 } )
        		end
        	end
        	settingsButton:addEventListener( "touch", settingsButton )
        end
		if creditsButton then
        	function creditsButton:touch ( event )
        		local phase = event.phase
        		if "ended" == phase then
        			composer.gotoScene( "creditsScene", { effect = "fade", time = 300 } )
        		end
        	end
        	creditsButton:addEventListener( "touch", creditsButton )
        end
		if exitButton then
        	function exitButton:touch ( event )
        		local phase = event.phase
        		if "ended" == phase then
        			native.requestExit()
        		end
        	end
        	exitButton:addEventListener( "touch", exitButton )
        end
    end 
end

function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if event.phase == "will" then
        -- Called when the scene is on screen and is about to move off screen
        --
        -- INSERT code here to pause the scene
        -- e.g. stop timers, stop animation, unload sounds, etc.)
    elseif phase == "did" then
        -- Called when the scene is now off screen
		if levelSelectionButton then
			levelSelectionButton:removeEventListener( "touch", levelSelectionButton )
		end
		if settingsButton then
			settingsButton:removeEventListener( "touch", settingsButton )
		end
		if creditsButton then
			creditsButton:removeEventListener( "touch", creditsButton )
		end
		if exitButton then
			exitButton:removeEventListener( "touch", exitButton )
		end
    end 
end


function scene:destroy( event )
    local sceneGroup = self.view

    -- Called prior to the removal of scene's "view" (sceneGroup)
    -- 
    -- INSERT code here to cleanup the scene
    -- e.g. remove display objects, remove touch listeners, save state, etc
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene
