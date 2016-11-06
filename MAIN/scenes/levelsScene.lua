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
local Joystick
local levelID
local pauseButton

local sceneGroup

function scene:create( event )
	sceneGroup = self.view
end

function scene:loadLevel()
	if (levelID > 2) then
		level = require('levels.1')
	else
		level = require('levels.' .. levelID)
	end

	Player.x = level.player[1].x
	Player.y = level.player[1].y

	for i = 1, #level.enemies do
		local b = level.enemies[i]
		placeEnemy(b.x, b.y)
	end

	minX=0
	minY=0
	maxX=0
	maxY=0
	
	for i = 1, #level.walls do
		local b = level.walls[i]
		crate = display.newImage("images/crate.png", b.x, b.y)
		physics.addBody(crate, "static", { filter = editFilter } )
		walls:insert(crate)
		if b.x<minX then
			minX=b.x
		end
		if b.x>maxX then
			maxX=b.x
		end
		if b.y<minY then
			minY=b.y
		end
		if b.y>maxY then
			maxY=b.y
		end
	end
	
	minX=minX-30
	maxX=maxX+30
	minY=minY-30
	maxY=maxY+30
	
	wallArr = {}
	for i=0, maxX-minX do
		wallArr[i]={}
		for j=0, maxY-minY do
			wallArr[i][j] = false
		end
	end
	for i=1, #level.walls do
		local b=level.walls[i]
		
		for j=b.x-minX-30, b.x-minX+30 do
			for k=b.y-minY-30, b.y-minY+30 do
				wallArr[j][k]=true
			end
		end
	end
	
	for i = 1, #level.items do
		local b = level.items[i]
		placeItem(b.name, b.x, b.y)
	end
end

function scene:show( event )
	sceneGroup = self.view
	local phase = event.phase

	if phase == "will" then
		-- BG may change
		backGround		= event.params.bg or "images/testBG.png"
		pauseImg		= event.params.pauseImg or "images/pauseIcon.png"

		self:initLevel(event)

		self.loadLevel()
	elseif phase == "did" then
		if Player and Joystick then
			Runtime:addEventListener("collision", onGlobalCollision)
			Runtime:addEventListener("enterFrame", beginMovement)
		end
		if pauseButton then
			function pauseButton:touch ( event )
				local phase = event.phase
				if "ended" == phase then
					physics.pause()
					Runtime:removeEventListener("enterFrame", beginMovement)
					composer.showOverlay( "scenes.pauseScene", { isModal = true, effect = "fade", time = 300 } )
				end
			end
			pauseButton:addEventListener( "touch", pauseButton )
		end
	end
end

function scene:hide( event )
	sceneGroup 		= self.view
	local phase 	= event.phase

	if event.phase == "will" then
		if pauseButton then
			pauseButton:removeEventListener("touch", pauseButton)
		end
		if Player then
			Runtime:removeEventListener("enterFrame", beginMovement)
			Runtime:removeEventListener("collision",  onGlobalCollision)
			Player:destroy()
		end
		if Joystick then
			Joystick:delete()
			Joystick = nil
		end
		if walls then
			walls:removeSelf()
			walls = nil
		end
		if Items then
			Items:removeSelf()
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

function scene:destroy( event )
	local sceneGroup = self.view
end

function scene:initLevel( event )
	-- Create background
	bg = display.newImage(backGround)
	bg.rotation 		= 90
	sceneGroup:insert(bg)
	-- LevelID
	levelID = event.params.levelID
	-- Player
	Player = PlayerLib.NewPlayer( {} )
	Items = display.newGroup()
	sceneGroup:insert(Items)
	sceneGroup:insert(Player)
	Player:spawnPlayer()
	-- Enemy
	Enemies = display.newGroup()
	sceneGroup:insert(Enemies)
	-- StatusBar
	statusBar = iniStatusBar(Player)
	sceneGroup:insert(statusBar)
	statusBar:iHPB()
	statusBar:iMPB()
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
	sceneGroup:insert(walls)
	-- Pause Button Initialization
	pauseButton 		= display.newImage(pauseImg)
	pauseButton.x 		= display.contentWidth+20
	pauseButton.y 		= 21
	pauseButton.alpha = 0.5
	sceneGroup:insert(pauseButton)
end

function scene:unPause()
	physics.start()
	Runtime:addEventListener("enterFrame", beginMovement)
end

function scene:leaveLvl()
	composer.gotoScene( "scenes.levelSelectionScene", { effect = "fade", time = 300 } )
end

function scene:restartLvl( id )
	composer.gotoScene( "scenes.levelsScene", { effect = "fade", time = 300, params = { levelID = levelID } } )
end

function beginMovement( event )
	if (Player.hp <= 0) then
		scene:leaveLvl()
		return
	end

	statusBar:toFront()
	Joystick:toFront()
	pauseButton:toFront()
	Player:move(Joystick)
	for n=1, Enemies.numChildren, 1 do
		Enemies[n]:enemyMove(Player)
	end

	--move world if outside border
	if Player.x < borders-80 then	-- moving left
		Player.x = borders-80
		for n = 1, walls.numChildren, 1 do
			walls[n].x = walls[n].x + Player.speed
		end
		for n = 1, Enemies.numChildren, 1 do
			Enemies[n].x = Enemies[n].x + Player.speed
		end
		for n = 0, Items.numChildren, 1 do
			if(Items[n]) then
				Items[n].x = Items[n].x + Player.speed
			end
		end
	end
	if Player.x > screenW-borders then	-- moving right
		Player.x = screenW-borders

		for n = 1, walls.numChildren, 1 do
			walls[n].x = walls[n].x - Player.speed
		end
		for n = 1, Enemies.numChildren, 1 do
			Enemies[n].x = Enemies[n].x - Player.speed
		end
		for n = 0, Items.numChildren, 1 do
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
		for n = 0, Items.numChildren, 1 do
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
		for n = 0, Items.numChildren, 1 do
			if(Items[n]) then
				Items[n].y = Items[n].y - Player.speed
			end
		end
	end
end

function onGlobalCollision ( event )
	--if event.object1.myName and event.object2.myName then
	--	print(event.object1.myName .. ":" .. event.object2.myName)
	--end

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
		for n = 1, 5, 1 do
			Player.hp = Player.hp + 10
			statusBar:iHPB()
		end
	elseif(o1.type == mana and o2.myName == pname) then
		display.remove( o1 )
		Items[o1.index] = nil
		for n = 1, 5, 1 do
			Player.mana = Player.mana + 10
			statusBar:iMPB()
		end
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
		composer.gotoScene( "scenes.levelSelectionScene", { effect = "fade", time = 300 } )
	end
end

function placeItem(type, x, y)
	newItem = ItemsLib.newItem(1, type,x,y)
	Items:insert(newItem)
	newItem:spawn()
end

function placeEnemy(t,z)
	enemy = PlayerLib.NewPlayer( {x = t, y = z} )
	enemy:spawnEnemy()
	Enemies:insert(enemy)
end
---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene
