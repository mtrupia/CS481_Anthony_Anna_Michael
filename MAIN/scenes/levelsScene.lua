---------------------------------------------------------------------------------
--
-- levelsScene.lua	: Loads the levels of the game ( SO FAR ONLY 1 :( )
--
---------------------------------------------------------------------------------

local sceneName = ...
local composer = require( "composer" )
local scene = composer.newScene( sceneName )
local BoomSound = audio.loadSound( "sounds/Boom.wav" )
local DoorOpenSound = audio.loadSound( "sounds/DoorOpen.wav" )
local OpenPlayed = false
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
local Items
local Enemies
local statusBar
local placer

local sceneGroup

function scene:create( event )
	sceneGroup = self.view
end

function scene:loadLevel()
	if (levelID > 3) then
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

	for i = 1, #level.walls do
		local b = level.walls[i]
		crate = display.newImage("images/crate.png", b.x, b.y)
		physics.addBody(crate, "static", { filter = editFilter } )
		walls:insert(crate)
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
		if placer then
			placer:addEventListener("touch", placeBomb )
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
			pauseButton = nil;
		end
		if placer then
			placer:removeEventListener("touch", placeBomb )
			placer:removeSelf()
			placer = nil
		end
		if Player then
			Runtime:removeEventListener("enterFrame", beginMovement)
			Runtime:removeEventListener("collision",  onGlobalCollision)
			Player:destroy()
			Player = nil;
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
			statusBar = nil
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
	Items = display.newGroup()
	Player = PlayerLib.NewPlayer( {} )
	sceneGroup:insert(Items)
	sceneGroup:insert(Player)
	Player:spawnPlayer()
	-- Enemy
	Enemies = display.newGroup()
	sceneGroup:insert(Enemies)
	-- StatusBar
	statusBar = SBLib.iniStatusBar(Player)
	sceneGroup:insert(statusBar)
	Player.statusBar = statusBar
	statusBar:iHPB(Player)
	statusBar:iMPB(Player)
	-- Joystick
	Joystick = StickLib.NewStick(
	{
		x             = 10,
		y             = screenH-(52),
		thumbSize     = 40,
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
-- bomb placer
placer = display.newCircle( display.contentWidth - 40, display.contentHeight - 40, 20)
sceneGroup:insert(placer)
placer.img = display.newImage("images/Bomb.png", display.contentWidth - 40, display.contentHeight - 40)
placer.img:scale(0.5,0.5)
sceneGroup:insert(placer.img)
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

function placeBomb( event )
	if "ended" == event.phase then
		if(Player.angle and statusBar.count > 0) then
			if(Player.angle <= 45 or Player.angle > 315) then
				createBomb(Player.x, Player.y - 60)
			elseif(Player.angle <= 135 and Player.angle > 45) then
				createBomb(Player.x + 60, Player.y)
			elseif(Player.angle <= 225 and Player.angle > 135) then
				createBomb(Player.x, Player.y + 60)
			elseif(Player.angle <= 315 and Player.angle > 225) then
				createBomb(Player.x - 60, Player.y)
			end

			statusBar.count = statusBar.count - 1
			statusBar.bomb.count.text = "x" .. statusBar.count
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
	local bombP   = "bombP"
	if(o1.type == health and o2.myName == pname) then
		display.remove( o1 )
		Items[o1.index] = nil
		for n = 1, 5, 1 do
			statusBar:iHPB(Player)
		end
	elseif(o1.type == mana and o2.myName == pname) then
		display.remove( o1 )
		Items[o1.index] = nil
		for n = 1, 5, 1 do
			statusBar:iMPB(Player)
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
	elseif(o1.type == bombP and o2.myName == pname) then
		statusBar.count = statusBar.count + 1
		statusBar.bomb.count.text = "x".. statusBar.count
		display.remove( o1 )
	end
end

function createBomb(x, y)
	local bomb = ItemsLib.newItem(1,"bomb",x, y)
	Items:insert(bomb)
	bomb:spawn()

	function boom(item)
		audio.play(BoomSound)
		print("boom")
		if(item) then
			if Enemies then
				for n = 0, Enemies.numChildren, 1 do
					if(Enemies[n] and item) then
						local dis = item:getDistance(Enemies[n], item)
						if(dis < 100) then
							Enemies[n]:damage(100)
							print("Hit Enemy: " .. n)
						end
					end
				end
			end
			if Player and item then
				if(item:getDistance(Player,item) < 100) then
					print("Hit Player")
					statusBar:dHPB(Player)
					statusBar:dHPB(Player)
					statusBar:dHPB(Player)
				end
			end
			if item then
				item:destroy()
			end
		end
	end

	timer.performWithDelay( 3000,
	function()
		boom(bomb)
	end,
	1)
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
