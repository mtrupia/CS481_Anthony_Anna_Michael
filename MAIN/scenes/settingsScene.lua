---------------------------------------------------------------------------------
--
-- settingsScene.lua	: Settings of the game...  Maybe make harder??? (DIFFICULTY SCENE???)
--
---------------------------------------------------------------------------------

local sceneName = ...
local composer = require( "composer" )
local scene = composer.newScene( sceneName )

---------------------------------------------------------------------------------

local bgImg = "images/tealBG.png"
local titleImg = "images/gameTitle.png"

local backButton

function scene:create( event )
    local sceneGroup = self.view
	local bg = display.newImage(bgImg)
	bg.rotation = 90
	local title = display.newImage(titleImg)
	title.x = display.contentWidth/2
	title.y = display.contentHeight/2 - 100
	local titleTxt = display.newText("Settings", 30, 32, native.systemFont, 32)
	
	sceneGroup:insert(bg)
	sceneGroup:insert(title)
	sceneGroup:insert(titleTxt)
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
        backButton = display.newText("Back", display.contentWidth/2, display.contentHeight/2+110, native.systemFont, 32)
		sceneGroup:insert(backButton)
		stuffers = display.newText("Create a Level", display.contentWidth/2, display.contentHeight/2, native.systemFont, 32)
		sceneGroup:insert(stuffers)
	elseif phase == "did" then
		if backButton then
        	function backButton:touch ( event )
        		local phase = event.phase
        		if "ended" == phase then
        			composer.gotoScene( "scenes.welcomeScene", { effect = "fade", time = 300 } )
        		end
        	end
        	backButton:addEventListener( "touch", backButton )
		end
		if stuffers then
			function stuffers:touch ( event )
				local phase = event.phase
				if "ended" == phase then
					composer.gotoScene( "scenes.levelEditor", { effect = "fade", time = 300, params = { } } )
				end
			end
			stuffers:addEventListener( "touch", stuffers)
		end
    end 
end

function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if event.phase == "will" then
    elseif phase == "did" then
		if backButton then
			backButton:removeEventListener( "touch", backButton )
		end
		if stuffers then
			stuffers:removeEventListener( "touch", stuffers)
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
