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

-- create settings scene
function scene:create( event )
	local sceneGroup = self.view

	-- create background and title image
	local bg = display.newRect(sceneGroup, 0, 0, actualW, actualH)
	bg:setFillColor( 0,0.5,0.5 )
	local title = display.newImage(sceneGroup, titleImg, halfW, halfH - 100)
end

-- display settings scene, create buttons, add listeners
function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
		-- create buttons
        backButton = display.newText(sceneGroup, "Back", display.contentWidth/2, display.contentHeight/2+110, native.systemFont, 32)
		createLevelButton = display.newText(sceneGroup, "Create a Level", display.contentWidth/2, display.contentHeight/2, native.systemFont, 32)
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
    end 
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )

---------------------------------------------------------------------------------

return scene
