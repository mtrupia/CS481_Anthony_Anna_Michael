---------------------------------------------------------------------------------
--
-- levelsScene.lua	: Loads the levels of the game ( SO FAR ONLY 1 :( )
--
---------------------------------------------------------------------------------

local sceneName = ...
local composer = require( "composer" )
local scene = composer.newScene( sceneName )

---------------------------------------------------------------------------------

-- start phyics up
physics.start()
physics.setGravity(0, 0)
--physics.setDrawMode( "hybrid" )
-- Vars
local pauseImg
local backGround
local walls
local Player
local Items = {}
local itemCount = 0
local Enemies = {}
local statusBar
local enemyCount = 0
local Joystick
local levelID
local pauseButton

local text

function scene:create( event )
	local sceneGroup = self.view

	backGround			= "images/testBG.png"
	pauseImg				= "images/pauseIcon.png"

	-- Create background
	bg 							= display.newImage(backGround)
	bg.rotation 		= 90
	sceneGroup:insert(bg)
end

function scene:loadLevel()
	level = require('levels.1')

	Player.x = level.player[1].x
	Player.y = level.player[1].y

	for i = 1, #level.enemies do
		local b = level.enemies[i]
		enemy = EnemyLib.NewEnemy( {x = b.x, y = b.y} )
		enemy:spawn()
		Enemies:insert(enemy)
	end

	for i = 1, #level.walls do
		local b = level.walls[i]
		crate = display.newImage("images/crate.png", b.x, b.y)
		physics.addBody(crate, "static", { filter = editFilter } )
		walls:insert(crate)
	end

	for i = 1, #level.items do
		local b = level.items[i]
		Items:newItem(b.name, b.x, b.y)
	end
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if phase == "will" then
		text= display.newText("YOU WIN", halfW, halfH, native.systemFont, 80)
		text.isVisible = false
		sceneGroup:insert(text)

		-- BG may change
		bg 			= "images/testBG.png"
		-- LevelID
		levelID = 1
		-- Player
		Player = PlayerLib.NewPlayer( {} )
		Items = {}
		Items[itemCount] = ItemsLib.newItem(itemCount,"hp",100,100)
		sceneGroup:insert(Items[itemCount])
		Items[itemCount]:spawn()
		sceneGroup:insert(Player)
		Player:spawnPlayer()
		-- Enemy
		Enemies = display.newGroup()
		sceneGroup:insert(Enemies)
		-- StatusBar
		statusBar = iniStatusBar(Player)
		sceneGroup:insert(statusBar)

		statusBar:iHPB()

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
	--for n = 1, levelID, 1 do
	--	local crate
	--	if n <= 5 then
	--		crate = display.newImage("images/crate.png", 50+75*(n-1), 100)
	--	else
	--		crate = display.newImage("images/crate.png", 50+75*(n-6), 300)
	--	end
	--	physics.addBody(crate, "static", { filter = worldCollisionFilter } )
	--	walls:insert(crate)
	--end
	sceneGroup:insert(walls)
	-- Pause Button Initialization
	pauseButton 			= display.newImage(pauseImg)
	pauseButton.x 		= display.contentWidth+20
	pauseButton.y 		= 21
	pauseButton.alpha = 0.5
	sceneGroup:insert(pauseButton)
elseif phase == "did" then
	if levelID == 2 then
		self.loadLevel()
	end

	if Player and Joystick then
		function begin( event )
			statusBar:toFront()
			Joystick:toFront()
			pauseButton:toFront()
			Player:move(Joystick)
			--for n=1, Enemies.numChildren, 1 do
			--	Enemies[n]:move(Player)
			--end

			--move world if outside border
			if Player.x < -8 then	-- moving left
				Player.x = -8

				for n = 1, walls.numChildren, 1 do
					walls[n].x = walls[n].x + Player.speed
				end
				for n = 1, Enemies.numChildren, 1 do
					Enemies[n].x = Enemies[n].x + Player.speed
				end
				for n = 0, itemCount, 1 do
					if(Items[n]) then
						Items[n].x = Items[n].x + Player.speed
					end
				end
			end
			if Player.x > screenW+8 then	-- moving right
				Player.x = screenW+8

				for n = 1, walls.numChildren, 1 do
					walls[n].x = walls[n].x - Player.speed
				end
				for n = 1, Enemies.numChildren, 1 do
					Enemies[n].x = Enemies[n].x - Player.speed
				end
				for n = 0, itemCount, 1 do
					if(Items[n]) then
						Items[n].x = Items[n].x - Player.speed
					end
				end
			end
			if Player.y < borders then	-- moving up
				Player.y = borders

				for n = 1, walls.numChildren, 1 do
					walls[n].y = walls[n].y + Player.speed
				end
				for n = 1, Enemies.numChildren, 1 do
					Enemies[n].y = Enemies[n].y + Player.speed
				end
				for n = 0, itemCount, 1 do
					if(Items[n]) then
						Items[n].y = Items[n].y + Player.speed
					end
				end
			end
			if Player.y > screenH-borders then	-- moving down
				Player.y = screenH-borders

				for n = 1, walls.numChildren, 1 do
					walls[n].y = walls[n].y - Player.speed
				end
				for n = 1, Enemies.numChildren, 1 do
					Enemies[n].y = Enemies[n].y - Player.speed
				end
				for n = 0, itemCount, 1 do
					if(Items[n]) then
						Items[n].y = Items[n].y - Player.speed
					end
				end
			end
		end
		Runtime:addEventListener("enterFrame", begin)
	end
	if pauseButton then
		function pauseButton:touch ( event )
			local phase = event.phase
			if "ended" == phase then
				physics.pause()
				Runtime:removeEventListener("enterFrame", begin)
				composer.showOverlay( "scenes.pauseScene", { isModal = true, effect = "fade", time = 300 } )
			end
		end
		pauseButton:addEventListener( "touch", pauseButton )
	end
end
end

function scene:hide( event )
	local sceneGroup 	= self.view
	local phase 			= event.phase

	if event.phase == "will" then
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
			Items = nil
		end
		if statusBar then
			statusBar:destroy()
			statusBar:removeSelf()
		end
		if Enemies then
			Enemies:removeSelf()
			Enemies = nil
		end
	elseif phase == "did" then

	end
end

function scene:unPause()
	physics.start()
	Runtime:addEventListener("enterFrame", begin)
end

function scene:destroy( event )
	local sceneGroup = self.view
end

function scene:leaveLvl()
	composer.gotoScene( "scenes.welcomeScene", { effect = "fade", time = 300 } )
end

function scene:restartLvl( id )
	composer.gotoScene( "scenes.levelsScene", { effect = "fade", time = 300, params = { levelID = levelID } } )
end

function onGlobalCollision ( event )
	local o1
	local o2
	if(event.object1.type) then
		o1 = event.object1
		o2 = event.object2
	else
		o1 = event.object2
		o2 = event.object1
	end
	local index
	local pname 	= "player"
	local health 	= "hp"
	local mana 		= "mana"
	local key 		= "key"
	local door		= "door"
	local fdoor 	= "fdoor"
	if(o1.type == health and o2.myName == pname) then
		display.remove( o1 )
		Items[o1.index] = nil
		Player.hp = Player.hp + 10
		statusBar:iHPB()
	elseif(o1.type == mana and o2.myName == pname) then
		display.remove( o1 )
		Items[o1.index] = nil
		Player.mana = Player.mana + 10
		statusBar:iMPB()
	elseif(o1.type == key and o2.myName == pname) then
		display.remove( o1 )
		Items[o1.index] = nil
		statusBar.key.isVisible = true
	elseif(o1.type == door and o2.myName == pname) then
		if(statusBar.key.isVisible) then
			statusBar.key.isVisible = false
			display.remove( o1 )
			Items[o1.index] = nil
		end
	elseif(o1.type == fdoor and o2.myName == pname) then
		text.isVisible = true
		function endLevel()
			composer.gotoScene( "scenes.levelSelectionScene", { effect = "fade", time = 300 } )
		end
		timer.performWithDelay(3000, endLevel, 1)
	end
end
---------------------------------------------------------------------------------

-- Listener setup
Runtime:addEventListener("collision", onGlobalCollision)
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene
