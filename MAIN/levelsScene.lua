---------------------------------------------------------------------------------
--
-- levelsScene.lua	: Loads the levels of the game ( SO FAR ONLY 1 :( )
--
---------------------------------------------------------------------------------

local sceneName = ...
local composer = require( "composer" )
local scene = composer.newScene( sceneName )

---------------------------------------------------------------------------------

-- Consts
local pauseImg = "pauseIcon.png"
local screenW = display.contentWidth
local screenH = display.contentHeight
local halfW = screenW/2
local halfH = screenH/2
local borders = 40
-- Physics
local physics = require("physics")
physics.start()
physics.setGravity(0, 0)
local worldCollisionFilter = {categoryBits = 1, maskBits = 6}
-- classes
local PlayerLib = require("Player")
local StickLib = require("lib_analog_stick")
-- variables
local walls 
local Player
local Joystick
local levelID
local pauseButton

function scene:create( event )
	local sceneGroup = self.view
	-- Create background
	local bg = display.newImage("testBG.png")
	bg.rotation = 90
	sceneGroup:insert(bg)
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
		-- LevelID
		levelID = event.params.levelID
		-- Player
		Player = PlayerLib.NewPlayer(
			{
				x		= 50,
				y		= screenH-50,
				health 	= 100,
				mana	= 100,
				score	= 0,
				speed	= 3,
				bg		= bg
			}
		)
		sceneGroup:insert(Player)
		Player:spawnPlayer()
		-- Joystick
		Joystick = StickLib.NewStick(
			{
				x             = 10,
				y             = screenH-(52),
				thumbSize     = 20,
				borderSize    = 32, 
				snapBackSpeed = .2, 
				R             = 0,
				G             = 1,
				B             = 1
			} 
		)
		sceneGroup:insert(Joystick)
		Joystick.alpha = 0.2
		-- Create some collision
		walls = display.newGroup()
		for n = 1, levelID, 1 do
			local crate
			if n <= 5 then
				crate = display.newImage("crate.png", 50+75*(n-1), 100)
			else
				crate = display.newImage("crate.png", 50+75*(n-6), 200)
			end
			physics.addBody(crate, "static", { filter = worldCollisionFilter } )
			walls:insert(crate)
		end
		sceneGroup:insert(walls)
		
		pauseButton = display.newImage(pauseImg)
		pauseButton.x = display.contentWidth+20
		pauseButton.y = 21
		pauseButton.alpha = 0.2
		sceneGroup:insert(pauseButton)
	elseif phase == "did" then
		if Player and Joystick then
			function begin( event )
				Player:move(Joystick)
				
				--move world if outside border
				if Player.x < -8 then	-- moving left
					Player.x = -8
					
					for n = 1, walls.numChildren, 1 do
						walls[n].x = walls[n].x + Player.speed
					end
				end
				if Player.x > screenW+8 then	-- moving right
					Player.x = screenW+8
					
					for n = 1, walls.numChildren, 1 do
						walls[n].x = walls[n].x - Player.speed
					end
				end
				if Player.y < borders then	-- moving up
					Player.y = borders
					
					for n = 1, walls.numChildren, 1 do
						walls[n].y = walls[n].y + Player.speed
					end
				end
				if Player.y > screenH-borders then	-- moving down
					Player.y = screenH-borders
					
					for n = 1, walls.numChildren, 1 do
						walls[n].y = walls[n].y - Player.speed
					end
				end
			end
			Runtime:addEventListener("enterFrame", begin)
		end
		if pauseButton then
			function pauseButton:touch ( event )
        		local phase = event.phase
        		if "ended" == phase then
        			composer.showOverlay( "pauseScene", { isModal = true, effect = "fade", time = 300 } )
        		end
        	end
        	pauseButton:addEventListener( "touch", pauseButton )
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
		end
		if Player then
			Runtime:removeEventListener("enterFrame", begin)
			Player:destroy()
		end
		if Joystick then
			Joystick:delete()
		end
		if walls then
			walls:removeSelf()
			walls = nil
		end
    end 
end

function scene:destroy( event )
    local sceneGroup = self.view
end

function scene:leaveLvl()
	composer.gotoScene( "levelSelectionScene", { effect = "fade", time = 300 } )
end

function scene:restartLvl( id )
	composer.gotoScene( "levelsScene", { effect = "fade", time = 300, params = { levelID = levelID } } )
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene
