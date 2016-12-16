---------------------------------------------------------------------------------
--
-- welcomeScene.lua	: Beginning screen of the application - Sends user accordingly on their choice
--
---------------------------------------------------------------------------------

-- Load welcome scene
local sceneName = ...
local composer = require( "composer" )
local scene = composer.newScene( sceneName )

---------------------------------------------------------------------------------

-- images
local titleImg = "images/gameTitle.png"

-- buttons
local levelSelectionButton
local settingsButton
local creditsButton
local exitButton
local testerButton

-- create welcome scene (LOADED ONCE!)
function scene:create( event )
	local sceneGroup = self.view

	-- create background and title image
	local bg = display.newRect(sceneGroup, 0, 0, actualW, actualH)
	bg:setFillColor( 0,0.0,0.0 )
	local title = display.newImage(sceneGroup, titleImg, halfW, halfH - 100)
end

-- display welcome scene, create buttons, add listeners
function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if phase == "will" then
		-- create buttons
		levelSelectionButton = display.newText(sceneGroup, "Level Selection", halfW, halfH, native.systemFont, 32)
		settingsButton = display.newText(sceneGroup, "Settings", levelSelectionButton.x, levelSelectionButton.y+40, native.systemFont, 32)
		creditsButton = display.newText(sceneGroup, "Credits", settingsButton.x, settingsButton.y+40, native.systemFont, 32)
		exitButton = display.newText(sceneGroup, "Exit", creditsButton.x, creditsButton.y+40, native.systemFont, 32)
		--testerButton = display.newText(sceneGroup, "Unit Tests", 460, 10, native.systemFont, 20)
	elseif phase == "did" then
		-- create listeners
		if levelSelectionButton then
			function levelSelectionButton:touch ( event )
				local phase = event.phase
				if "ended" == phase then
					composer.gotoScene( "scenes.levelSelectionScene" )
				end
			end
			levelSelectionButton:addEventListener( "touch", levelSelectionButton )
		end
		if settingsButton then
			function settingsButton:touch ( event )
				local phase = event.phase
				if "ended" == phase then
					composer.gotoScene( "scenes.settingsScene" )
				end
			end
			settingsButton:addEventListener( "touch", settingsButton )
		end
		if creditsButton then
			function creditsButton:touch ( event )
				local phase = event.phase
				if "ended" == phase then
					composer.gotoScene( "scenes.creditsScene" )
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
		if testerButton then
			function testerButton:touch ( event )
				local phase = event.phase
				if "ended" == phase then
					composer.gotoScene( "scenes.testerScene" )
				end
			end
			testerButton:addEventListener( "touch" , testerButton )
		end
	end
end

-- hide welcome scene once user chooses button.  Clean up listeners and buttons
function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase

	if event.phase == "will" then
		if levelSelectionButton then
			levelSelectionButton:removeEventListener( "touch", levelSelectionButton )
			levelSelectionButton:removeSelf()
			levelSelectionButton = nil
		end
		if settingsButton then
			settingsButton:removeEventListener( "touch", settingsButton )
			settingsButton:removeSelf()
			settingsButton = nil
		end
		if creditsButton then
			creditsButton:removeEventListener( "touch", creditsButton )
			creditsButton:removeSelf()
			creditsButton = nil
		end
		if exitButton then
			exitButton:removeEventListener( "touch", exitButton )
			exitButton:removeSelf()
			exitButton = nil
		end
		if testerButton then
			testerButton:removeEventListener( "touch", testerButton )
			testerButton:removeSelf()
			testerButton = nil
		end
	end
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )

---------------------------------------------------------------------------------

return scene
