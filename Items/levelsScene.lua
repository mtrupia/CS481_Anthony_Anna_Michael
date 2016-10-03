---------------------------------------------------------------------------------
--
-- levelsScene.lua	: Loads the levels of the game ( SO FAR ONLY 10 :( )
--
---------------------------------------------------------------------------------

local sceneName = ...
local composer = require( "composer" )
local scene = composer.newScene( sceneName )

---------------------------------------------------------------------------------

-- start phyics up
physics.start()
physics.setGravity(0, 0)
physics.setDrawMode( "hybrid" )
-- Vars
local pauseImg
local bg
local walls
local Items
local Player
local Joystick
local levelID
local pauseButton

function scene:create( event )
	local sceneGroup = self.view

	bg			= event.params.bg or "testBG.png"
	pauseImg	= event.params.pauseImg or "pauseIcon.png"

	-- Create background
	bg = display.newImage("testBG.png")
	bg.rotation = 90
	sceneGroup:insert(bg)
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if phase == "will" then
		-- BG may change
		bg = event.params.bg or "testBG.png"
		-- LevelID
		levelID = event.params.levelID
		-- Player
		Player = PlayerLib.NewPlayer( {} )
		items = ItemsLib.newItems()
		print("init")
		sceneGroup:insert(Player)
		sceneGroup:insert(items)
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
			crate = display.newImage("crate.png", 50+75*(n-6), 300)
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
				for n = 2, items.numChildren, 1 do
					items[n].x = items[n].x + Player.speed
				end
			end
			if Player.x > screenW+8 then	-- moving right
				Player.x = screenW+8

				for n = 1, walls.numChildren, 1 do
					walls[n].x = walls[n].x - Player.speed
				end
				for n = 2, items.numChildren, 1 do
					items[n].x = items[n].x - Player.speed
				end
			end
			if Player.y < borders then	-- moving up
				Player.y = borders

				for n = 1, walls.numChildren, 1 do
					walls[n].y = walls[n].y + Player.speed
				end
				for n = 2, items.numChildren, 1 do
					items[n].y = items[n].y + Player.speed
				end
			end
			if Player.y > screenH-borders then	-- moving down
				Player.y = screenH-borders

				for n = 1, walls.numChildren, 1 do
					walls[n].y = walls[n].y - Player.speed
				end
				for n = 2, items.numChildren, 1 do
					items[n].y = items[n].y - Player.speed
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
		if Items then
			Items:destroy()
			Items:removeSelf()
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
