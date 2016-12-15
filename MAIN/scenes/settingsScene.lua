---------------------------------------------------------------------------------
--
-- settingsScene.lua	: Settings of the game...  Maybe make harder??? (DIFFICULTY SCENE???)
--
---------------------------------------------------------------------------------

-- load settings scene
local sceneName = ...
local composer = require( "composer" )
local scene = composer.newScene( sceneName )

---------------------------------------------------------------------------------

-- images
local titleImg = "images/gameTitle.png"

-- buttons
local createLevelButton
local backButton
local hardmodeButton
local restartButton

-- create settings scene
function scene:create( event )
	local sceneGroup = self.view

	-- create background and title image
	local bg = display.newRect(sceneGroup, 0, 0, actualW, actualH)
	bg:setFillColor( 0,0,0 )
	local title = display.newImage(sceneGroup, titleImg, halfW, halfH - 100)
end

-- display settings scene, create buttons, add listeners
function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
		-- create buttons
        backButton = display.newText(sceneGroup, "Back", display.contentWidth/2, display.contentHeight/2+110, native.systemFont, 32)
		createLevelButton = display.newText(sceneGroup, "Create a Level", display.contentWidth/2, display.contentHeight/2+75, native.systemFont, 32)
		hardmodeButton = display.newText(sceneGroup, "Enable Hard Mode", display.contentWidth/2, display.contentHeight/2, native.systemFont, 32)
		if HARDMODE == 1 then
			hardmodeButton.text = "Disable Hard Mode"
			hardmodeButton:setFillColor( 1, 0 ,0 )
		end
		restartButton = display.newText(sceneGroup, "Reset Save Data", display.contentWidth/2, display.contentHeight/2+40, native.systemFont, 32)
		restartButton.id = 0
	elseif phase == "did" then
		-- create listeners
		if backButton then
        	function backButton:touch ( event )
        		local phase = event.phase
        		if "ended" == phase then
        			composer.gotoScene( "scenes.welcomeScene" )
        		end
        	end
        	backButton:addEventListener( "touch", backButton )
		end
		if createLevelButton then
			function createLevelButton:touch ( event )
				local phase = event.phase
				if "ended" == phase then
					composer.gotoScene( "scenes.levelEditor" , { params = { } } )
				end
			end
			createLevelButton:addEventListener( "touch", createLevelButton)
		end
		if hardmodeButton then
			function hardmodeButton:touch ( event )
				local phase = event.phase
				if "ended" == phase then
					if HARDMODE == 1 then
						HARDMODE = 0
					else
						HARDMODE = 1
					end
					updatePlayer(0, nil)
					composer.gotoScene( "scenes.welcomeScene" , { params = { } } )
				end
			end
			hardmodeButton:addEventListener( "touch", hardmodeButton)
		end
		if restartButton then
			function restartButton:touch ( event )
				local phase = event.phase
				if "ended" == phase then
					if restartButton.id == 0 then
						restartButton.id = 1
						restartButton.text = "Are You Sure!?"
						restartButton:setFillColor( 1, 1, 0 )
					else
						restartButton.id = 0
						createPlayer()
						HARDMODE = 0
						composer.gotoScene( "scenes.welcomeScene" , { params = { } } )
					end
				end
			end
			restartButton:addEventListener( "touch", restartButton)
		end
    end 
end

-- hide settings scene once user chooses button.  Clean up listeners and buttons
function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if event.phase == "will" then
		if backButton then
			backButton:removeEventListener( "touch", backButton )
			backButton:removeSelf()
			backButton = nil
		end
		if createLevelButton then
			createLevelButton:removeEventListener( "touch", createLevelButton)
			createLevelButton:removeSelf()
			createLevelButton = nil
		end
		if hardmodeButton then
			hardmodeButton:removeEventListener( "touch", hardmodeButton)
			hardmodeButton:removeSelf()
			hardmodeButton = nil
		end
		if restartButton then
			restartButton:removeEventListener( "touch", restartButton)
			restartButton:removeSelf()
			restartButton = nil
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
