---------------------------------------------------------------------------------
--
-- levelSelectionScene.lua	: Choose a level from the game (starts at lvl 1 if beginning)
--
---------------------------------------------------------------------------------

-- load selection scene
local sceneName = ...
local composer = require( "composer" )
local scene = composer.newScene( sceneName )
local scoreArray = {}
scoreArray[1] = {930, 1860, 2790}
scoreArray[2] = {1470, 2940, 4410}
scoreArray[3] = {3090, 6180, 9270}
scoreArray[4] = {2430, 4860, 7290}
scoreArray[5] = {3510, 7020, 10530}
---------------------------------------------------------------------------------

-- images
local titleImg = "images/gameTitle.png"
local emptyStar = "images/EmptyStar.png"
local fullStar = "images/FullStar.png"
-- buttons
local levelsButton
local backButton

-- create selection scene
function scene:create( event )
	local sceneGroup = self.view

	-- create background and title image
	local bg = display.newRect(sceneGroup, 0, 0, actualW, actualH)
	bg:setFillColor( 0,0,0 )
	local title = display.newImage(sceneGroup, titleImg, halfW, halfH - 100)
end

-- display selection scene, create buttons, add listeners
function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if phase == "will" then
		loadPlayer()
		--create buttons
		local levels = loadPlayer().level
		if levels > 5 then levels = 5 end

		levelsButton = display.newGroup()
		for n = 1, levels, 1 do
			local btn
			if n<=5 then
				local score = 0
				local p = loadPlayer()
				score = p.levels[n].score
				btn = display.newText(levelsButton, n, (n-1)*120, display.contentHeight/2, native.systemFont, 32)
				btn.id = n
				_G.score[n] = p.levels[n].score
				displayStars(n)
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
						composer.gotoScene( "scenes.levelsScene", { params = { levelID = level.id } } )
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

function displayStars(n)
	if (not(_G.score[n])) then
		btnscore = 	display.newImage(levelsButton, emptyStar, (n-1) * 120 - 22, display.contentHeight/3 + 20)
		btnscore2 = display.newImage(levelsButton, emptyStar, (n-1) * 120 + 3, display.contentHeight/3 + 10)
		btnscore3 = display.newImage(levelsButton, emptyStar, (n-1) * 120 + 28, display.contentHeight/3 + 20)
	else
		if(_G.score[n] >= scoreArray[n][1]) then
			btnscore = 	display.newImage(levelsButton, fullStar, (n-1) * 120 - 22, display.contentHeight/3 + 20)
		else
			btnscore = 	display.newImage(levelsButton, emptyStar, (n-1) * 120 - 22, display.contentHeight/3 + 20)
		end
		if(_G.score[n] >= scoreArray[n][2]) then
			btnscore2 = display.newImage(levelsButton, fullStar, (n-1) * 120 + 3, display.contentHeight/3 + 10)
		else
			btnscore2 = display.newImage(levelsButton, emptyStar, (n-1) * 120 + 3, display.contentHeight/3 + 10)
		end
		if(_G.score[n] >= scoreArray[n][3]) then
			btnscore3 = display.newImage(levelsButton, fullStar, (n-1) * 120 + 28, display.contentHeight/3 + 20)
		else
			btnscore3 = display.newImage(levelsButton, emptyStar, (n-1) * 120 + 28, display.contentHeight/3 + 20)
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
