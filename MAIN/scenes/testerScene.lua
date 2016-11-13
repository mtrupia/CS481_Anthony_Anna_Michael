---------------------------------------------------------------------------------
--
-- levelsScene.lua	: Loads the levels of the game
--
---------------------------------------------------------------------------------
local sceneName = ...
local composer = require( "composer" )
local scene = composer.newScene( sceneName )
local BoomSound = audio.loadSound("sounds/Boom.wav")

local powerImage = "images/brick.png"
local powers = {}
local n = 0
local alivePowers = {}
local x = 0
local powerLife = 1000
local powerSpeed = 250
local density		 = 3
local friction = 0.500
local bounce = 1
---------------------------------------------------------------------------------

-- start phyics up
physics.start()
physics.setGravity(0, 0)
physics.setDrawMode( "hybrid" )
-- Vars
local pauseImg
local backGround
local walls
local statusBar
local Joystick = {}
local pauseButton
local sceneGroup
local placer
local Items

local ItemList = {}

function scene:create( event )
	sceneGroup = self.view
end

function scene:loadLevel()
	level = require('levels.1')

	Player.x = level.player[1].x
	Player.y = level.player[1].y

	for i = 1, #level.enemies do
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

		backGround			= "images/testBG.png"
		pauseImg				= "images/pauseIcon.png"

		self:initLevel(event)
	elseif phase == "did" then
		if Player and Joystick then
			Runtime:addEventListener("enterFrame", beginMovement)
			--Runtime:addEventListener("collision", onGlobalCollision)
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
		if placer then
			placer:addEventListener("touch", placeBomb )
		end
	end
end

function scene:hide( event )
	local sceneGroup 	= self.view
	local phase 			= event.phase

	if event.phase == "will" then
		if pauseButton then
			pauseButton:removeEventListener("touch", pauseButton)
			pauseButton = nil
		end
		if Player then
			Runtime:removeEventListener("enterFrame", beginMovement)
			Runtime:removeEventListener("collision",  onGlobalCollision)
			Player:destroy()
			Player = nil
		end
		if placer then
			placer:removeEventListener("touch", placeBomb )
			placer:removeSelf()
			placer = nil
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

function beginMovement( event )
	if (Player.hp <= 0) then
		scene:leaveLvl()
		return
	end

	statusBar:toFront()
	--Joystick:toFront()
	pauseButton:toFront()
	Player:move(Joystick)
	for n=1, Enemies.numChildren, 1 do
		Enemies[n]:enemyMove(Player)
	end

	--move world if outside border
	-- if Player.x < borders-80 then	-- moving left
	-- 	Player.x = borders-80
	-- 	for n = 1, walls.numChildren, 1 do
	-- 		walls[n].x = walls[n].x + Player.speed
	-- 	end
	-- 	for n = 1, Enemies.numChildren, 1 do
	-- 		Enemies[n].x = Enemies[n].x + Player.speed
	-- 	end
	-- 	for n = 0, Items.numChildren, 1 do
	-- 		if(Items[n]) then
	-- 			Items[n].x = Items[n].x + Player.speed
	-- 		end
	-- 	end
	-- end
	-- if Player.x > screenW-borders then	-- moving right
	-- 	Player.x = screenW-borders
	--
	-- 	for n = 1, walls.numChildren, 1 do
	-- 		walls[n].x = walls[n].x - Player.speed
	-- 	end
	-- 	for n = 1, Enemies.numChildren, 1 do
	-- 		Enemies[n].x = Enemies[n].x - Player.speed
	-- 	end
	-- 	for n = 0, Items.numChildren, 1 do
	-- 		if(Items[n]) then
	-- 			Items[n].x = Items[n].x - Player.speed
	-- 		end
	-- 	end
	-- end
	-- if Player.y < borders then	-- moving up
	-- 	Player.y = borders
	--
	-- 	for n = 1, walls.numChildren, 1 do
	-- 		walls[n].y = walls[n].y + Player.speed
	-- 	end
	-- 	for n = 1, Enemies.numChildren, 1 do
	-- 		Enemies[n].y = Enemies[n].y + Player.speed
	-- 	end
	-- 	for n = 0, Items.numChildren, 1 do
	-- 		if(Items[n]) then
	-- 			Items[n].y = Items[n].y + Player.speed
	-- 		end
	-- 	end
	-- end
	-- if Player.y > screenH-borders then	-- moving down
	-- 	Player.y = screenH-borders
	--
	-- 	for n = 1, walls.numChildren, 1 do
	-- 		walls[n].y = walls[n].y - Player.speed
	-- 	end
	-- 	for n = 1, Enemies.numChildren, 1 do
	-- 		Enemies[n].y = Enemies[n].y - Player.speed
	-- 	end
	-- 	for n = 0, Items.numChildren, 1 do
	-- 		if(Items[n]) then
	-- 			Items[n].y = Items[n].y - Player.speed
	-- 		end
	-- 	end
	-- end
end

function scene:initLevel(event)
	-- Create background
	bg 							= display.newImage(backGround)
	bg.rotation 		= 90
	sceneGroup:insert(bg)
	-- Player
	Player = PlayerLib.NewPlayer( {} )
	Items = display.newGroup()
	sceneGroup:insert(Items)
	sceneGroup:insert(Player)
	Player:spawnPlayer()

	-- Enemy
	Enemies = display.newGroup()
	sceneGroup:insert(Enemies)
	-- Status Bar
	statusBar = SBLib.newStatusBar(Player)
	sceneGroup:insert(statusBar)
	Player.statusBar = statusBar
	-- UNIT TEST INITIALIZATION
	placeItem(HP,120,140)
	placeItem(Mana,220,100)
	placeItem(Key,320,100)
	placeItem(Door,470,100)
	placeItem(FDoor,570,100)
	ItemList[1]:test()
	--placeEnemy(100, 150)
	function Joystick:move()
		if (Player.x > 61) then
			Player.x = Player.x - 1
			Player.x = math.floor(Player.x + 0.5)
		elseif (Player.x == 61 and Player.y > 140) then
			Player.y = Player.y - 1
			Player.y = math.floor(Player.y + 0.5)
		elseif (Player.x < 70) then
			Player.x = Player.x + 1
		end
	end
	function Joystick:delete()
		print("delete")
	end
	function Joystick:getAngle()
		if(Player.x > 60 and Player.y == 160) then
			return 310
		end
		if (Player.x == 60) then
			return 44
		end
		return 310
	end
	function Joystick:getMoving()
		return true
	end

	local function Shoot()
		local event = {}
		event.x = Player.x - 10
		event.y = Player.y
		audio.play( ShootSound )
		n = n + 1
		powers[n] = display.newImage(powerImage, Player.x, Player.y)
		physics.addBody( powers[n], { density=density, friction=friction, bounce=bounce, filter=powerCollisionFilter } )
		powers[n].myName = "power"
		deltaX = event.x - Player.x
		deltaY = event.y - Player.y
		normDeltaX = deltaX / math.sqrt(math.pow(deltaX,2) + math.pow(deltaY,2))
		normDeltaY = deltaY / math.sqrt(math.pow(deltaX,2) + math.pow(deltaY,2))
		powers[n]:setLinearVelocity( normDeltaX * powerSpeed, normDeltaY * powerSpeed )
		alivePowers[n] = n
		Player.statusBar:setMana(Player, -10)

		if Player.hasShield and Player.mana <= 0 then
			Player.hasShield = false
			Player:remove(Player.Shield)
		end

		function delete()
			x = x + 1
			if (powers[alivePowers[x]]) then
				powers[alivePowers[x]]:removeSelf()
			end
		end
		timer.performWithDelay(powerLife, delete)
		tTarget = nil
	end
	--Shoot()
	-- Create some collision
	walls = display.newGroup()
	sceneGroup:insert(walls)
	-- Pause Button Initialization
	pauseButton 			= display.newImage(pauseImg)
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
	Runtime:addEventListener("enterFrame", begin)
end

function scene:destroy( event )
	local sceneGroup = self.view
end

function scene:leaveLvl()
	composer.gotoScene( "scenes.levelSelectionScene", { effect = "fade", time = 300 } )
end

function scene:restartLvl( id )
	composer.gotoScene( "scenes.testerScene", { effect = "fade", time = 300, params = { levelID = levelID } } )
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

-- function createBomb(x, y)
-- 	local bomb = ItemsLib.newItem(1,"bomb",x, y)
-- 	Items:insert(bomb)
-- 	bomb:spawn()
--
-- 	function boom(item)
-- 		print("boom")
-- 		audio.play( BoomSound )
-- 		if(item) then
-- 			if Enemies then
-- 				for n = 0, Enemies.numChildren, 1 do
-- 					if(Enemies[n] and item) then
-- 						local dis = item:getDistance(Enemies[n], item)
-- 						if(dis < 100) then
-- 							Enemies[n]:damage(100)
-- 							print("Hit Enemy: " .. n)
-- 						end
-- 					end
-- 				end
-- 			end
-- 			if Player and item then
-- 				if(item:getDistance(Player,item) < 100) then
-- 					print("Hit Player")
-- 					statusBar:dHPB(Player)
-- 					statusBar:dHPB(Player)
-- 					statusBar:dHPB(Player)
-- 				end
-- 			end
-- 			if item then
-- 				item:destroy()
-- 			end
-- 		end
-- 	end
--
-- 	timer.performWithDelay( 3000,
-- 	function()
-- 		boom(bomb)
-- 	end,
-- 	1)
-- end


function placeEnemy(t,z)
	enemy = PlayerLib.NewPlayer( {x = t, y = z} )
	enemy:spawnEnemy()
	Enemies:insert(enemy)
end

function placeItem(type, x, y)
	local item = type:new(x,y,statusBar)
	table.insert(ItemList, item)
	Items:insert(item.image)
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------
return scene
