---------------------------------------------------------------------------------
--
-- creditsScene.lua	: Credits of the game...
--
---------------------------------------------------------------------------------

-- load credits scene
local sceneName = ...
local composer = require( "composer" )
local scene = composer.newScene( sceneName )

---------------------------------------------------------------------------------

-- images
local titleImg = "images/gameTitle.png"

-- private vars
local credits = "Anna Schmedding\n  Anthony Austin\n  Michael Trupia" 

-- buttons
local backButton

-- create credits scene
function scene:create( event )
    local sceneGroup = self.view
	
	-- create background and title image
	local bg = display.newRect(sceneGroup, 0, 0, actualW, actualH)
	bg:setFillColor( 0,0.5,0.5 )
	local title = display.newImage(sceneGroup, titleImg, halfW, halfH - 100)
	
	-- create credits text
	local creditsTxt = display.newText(sceneGroup, credits, halfW, halfH+50, native.systemFont, 32)
end

-- display credits scene, create buttons, add listeners
function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
        backButton = display.newText(sceneGroup, "Back", display.contentWidth-50, display.contentHeight/2+110, native.systemFont, 32)
	elseif phase == "did" then
		if backButton then
        	function backButton:touch ( event )
        		local phase = event.phase
        		if "ended" == phase then
        			composer.gotoScene( "scenes.welcomeScene" )
        		end
        	end
        	backButton:addEventListener( "touch", backButton )
		end
    end 
end

-- hide credits scene once user chooses button.  Clean up listeners and buttons
function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if event.phase == "will" then
		if backButton then
			backButton:removeEventListener( "touch", backButton )
			backButton:removeSelf()
			backButton = nil
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
