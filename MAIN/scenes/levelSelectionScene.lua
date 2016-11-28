---------------------------------------------------------------------------------
--
-- levelSelectionScene.lua	: Choose a level from the game (starts at lvl 1 if beginning)
--
---------------------------------------------------------------------------------

-- load selection scene
local sceneName = ...
local composer = require( "composer" )
local scene = composer.newScene( sceneName )

---------------------------------------------------------------------------------

-- images
local titleImg = "images/gameTitle.png"

-- buttons
local levelsButton
local backButton

-- create selection scene
function scene:create( event )
	local sceneGroup = self.view

	-- create background and title image
	local bg = display.newRect(sceneGroup, 0, 0, actualW, actualH)
	bg:setFillColor( 0,0.5,0.5 )
	local title = display.newImage(sceneGroup, titleImg, halfW, halfH - 100)
end

-- display selection scene, create buttons, add listeners
function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if phase == "will" then
		-- create buttons
		local levels = require('levels.player').levels

		levelsButton = display.newGroup()
		for n = 1, levels, 1 do
			local btn
			if n<=5 then
				btn = display.newText(levelsButton, n, (n-1)*120, display.contentHeight/2, native.systemFont, 32)
				if (not(_G.score[n])) then
					btnscore = display.newText(levelsButton,0, (n-1) * 120, display.contentHeight/3 + 10, native.systemFont, 10)
				else
					btnscore = display.newText(levelsButton, _G.score[n], (n-1) * 120, display.contentHeight/3 + 10, native.systemFont, 10)
				end
			else
				btn = display.newText(levelsButton, n, 120*(n-6), display.contentHeight/2+64, native.systemFont, 32)
			end
		end
		sceneGroup:insert(levelsButton)
		backButton = display.newText(sceneGroup, "Back", display.contentWidth/2, display.contentHeight/2+110, native.systemFont, 32)
	elseif phase == "did" then
		-- create listeners
		if levelsButton then
			for i = 1, levelsButton.numChildren, 1 do
				local level = levelsButton[i]
				function level:touch ( event )
					local phase = event.phase
					if "ended" == phase then
						composer.gotoScene( "scenes.levelsScene", { params = { levelID = i } } )
					end
				end
				level:addEventListener( "touch", level )
			end
		end
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

-- hide selection scene once user chooses button.  Clean up listeners and buttons
function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase

	if event.phase == "will" then
		if levelsButton then
			for i = 1, levelsButton.numChildren, 1 do
				local level = levelsButton[i]
				level:removeEventListener( "touch", level )
			end
			levelsButton:removeSelf()
			levelsButton = nil
		end
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
