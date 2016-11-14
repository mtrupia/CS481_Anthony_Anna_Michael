---------------------------------------------------------------------------------
--
-- levelsScene.lua	: Loads the levels of the game ( SO FAR ONLY 1 :( )
--
---------------------------------------------------------------------------------

local sceneName = ...
local composer = require( "composer" )
local scene = composer.newScene( sceneName )
local BoomSound = audio.loadSound("sounds/Boom.wav")
local bun
local bunS
local bunD
local bunO
--require("classes.Items")
---------------------------------------------------------------------------------

-- start phyics up
physics.start()
physics.setGravity(0, 0)
physics.setDrawMode( "hybrid" )
-- Vars
local pauseImg
local backGround
local walls
local Player
local Joystick
local levelID
local pauseButton
local Items
local ItemsList = {}
local Enemies
local bombPlacer
local shieldPlacer

local e = {}
local en = 1

local sceneGroup

function scene:create( event )
	sceneGroup = self.view
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
		end
		if pauseButton then
			function pauseButton:touch( event )
				local phase = event.phase
				if phase == "began" then
					tTarget = pauseButton
				elseif phase == "ended" and event.target == tTarget then
					physics.pause()
					Runtime.removeEventListener("enterFrame", beginMovement)
					composer.showOverlay( "scenes.pauseScene", {isModal = true, effect = "fade", time = 300} )
					tTarget = nil
				end
				pauseButton:addEventListener( "touch", pauseButton)
			end
		end
	end
end
function scene:hide( event )
	sceneGroup = self.view
	local phase = event.phase

	if phase == "will" then
		if pauseButton then
			pauseButton:removeEventListener("touch", pauseButton)
			pauseButton = nil;
		end
		if Player then
			Runtime:removeEventListener("enterFrame", beginMovement)
			Runtime:removeEventListener("collision",  onGlobalCollision)
			Player:destroy()
			Player = nil;
		end
		if Joystick then
			--Joystick:delete()
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
		if ItemsList then
			for n = 1, #ItemsList, 1 do
				if ItemsList[1] then
					ItemsList[1]:destroy()
					ItemsList[1] = nil
				end
			end
		end
		if Enemies then
			for n = 1, en, 1 do
				if e[n] then
					e[n]:destroy()
					e[n] = nil
				end
			end
			Enemies:removeSelf()
			Enemies = nil
			e = {}
			en = 1
		end
	elseif phase == "did" then
	end
end

function scene:initLevel(event)
	-- Create backGround
	bg = display.newImage(backGround)
	bg.rotation = 90
	sceneGroup:insert(bg)
	--LevelID
	-- Items
	Items = display.newGroup()
	-- Player
	Player = NpcLib.new("player", {})
	sceneGroup:insert(Items)
	-- Enemy
	Enemies = display.newGroup()
	sceneGroup:insert(Enemies)
	Player:spawn()
	sceneGroup:insert(Player.sprite)
	-- Joystick
	Joystick = {}
	ItemsList = {}
	bun = system.getTimer()
	bunS = bun
	bunD = bun + 10000
	bunO = true
	walls = display.newGroup()
	sceneGroup:insert(walls)
	crate = display.newImage(walls,"images/crate.png", 100, 100)
	-------------------------------
	-- Unit Testing Begins
	-------------------------------
	placeItem(Door,176,70)
	placeEnemy(50,100)
	-- Checks Initialization of Player and Items
	assert(walls[1].x == 100, "Error: Wall X is Incorrect")
	assert(walls[1].y == 100, "Error: Wall Y is Incorrect")
	assert(e[1].sprite.x == 50, "Error: Enemy X is Incorrect")
	assert(e[1].sprite.y == 100, "Error: Enemy Y is Incorrect")
	assert(e[1].sprite.health == 100, "Error: Enemy health is Incorrect")
	assert(e[1].sprite.name == "enemy", "Error: Enemy name is Incorrect")
	assert(e[1].sprite.hasShield == false, "Error: Enemy hasShield is Incorrect")
	assert(e[1].sprite.dmgReady == true, "Error: Enemy dmgReady is Incorrect")
	assert(e[1].sprite.attReady == true, "Error: Enemy attReady is Incorrect")
	-- These 3 Variables aren't passed to the sprite
	assert(e[1].visible == false, "Error: Enemy visible is Incorrect")
	assert(e[1].index == 0, "Error: Enemy index is Incorrect")
	assert(e[1].enemyType == "chaser", "Error: Enemy enemyType is Incorrect")
	-----------------------------------------------
	assert(e[1].sprite.damage == 10, "Error: Enemy damage is Incorrect")
	assert(e[1].sprite.speed == 1, "Error: Enemy speed is Incorrect")
	assert(e[1].sprite.shootReady == true, "Error: Enemy shootReady is Incorrect")
	assert(ItemsList[1].x == 176, "Error: Door X is Incorrect")
	assert(ItemsList[1].y == 70, "Error: Door X is Incorrect")
	assert(ItemsList[1].name == "Door", "Error: Door has wrong name")
	assert(Player.sprite.x == 240, "Error: Player X is Incorrect")
	assert(Player.sprite.y == 160, "Error: Player Y is Incorrect")
	assert(Player.sprite.angle == 0, "Error: Player angle is Incorrect")
	assert(Player.sprite.health == 100, "Error: Player health is Incorrect")
	assert(Player.sprite.mana == 100, "Error: Player mana is Incorrect")
	assert(Player.sprite.score == 0, "Error: Player score is Incorrect")
	assert(Player.sprite.name == "player", "Error: Player name is Incorrect")
	assert(Player.sprite.hasShield == false, "Error: Player hasShield is Incorrect")
	assert(Player.sprite.dmgReady == false, "Error: Player dmgReady is Incorrect")
	assert(Player.sprite.speed == 3, "Error: Player speed is Incorrect")
	assert(Player.sprite.attReady == true, "Error: Player attReady is Incorrect")

	function Joystick:move()
		--Left
		if(Player.sprite.x > 224 and Player.sprite.y == 160 and bunO) then
			Player.sprite.x = Player.sprite.x - 1
			Player.sprite.x = math.floor(Player.sprite.x+0.5)
			--print("1Player.x = " .. Player.sprite.x .. " Player.y = " .. Player.sprite.y)
			-- Up
		elseif(Player.sprite.x <= 225 and Player.sprite.y >= 141) then
			Player.sprite.y = Player.sprite.y - 1
			Player.sprite.y = math.floor(Player.sprite.y+0.5)
			--print("2Player.y = " .. Player.sprite.y .. " Player.x = " .. Player.sprite.x)
			bunO = false
			-- Right
		elseif(Player.sprite.y <= 141 and Player.sprite.x < 340) then
			Player.sprite.x = Player.sprite.x + 1
			Player.sprite.x = math.floor(Player.sprite.x+0.5)
			--print("3Player.x = " .. Player.sprite.x .. " Player.y = " .. Player.sprite.y)
			-- Down
		elseif(Player.sprite.x <= 343 and Player.sprite.y < 160 and bunO == false) then
			Player.sprite.y = Player.sprite.y + 1
			Player.sprite.y = math.floor(Player.sprite.y+0.5)
			--print("4Player.y = " .. Player.sprite.y .. " Player.x = " .. Player.sprite.x)
			--Left
		elseif(Player.sprite.x >  225 and Player.sprite.y == 160) then
			Player.sprite.x = Player.sprite.x - 1
			Player.sprite.x = math.floor(Player.sprite.x+0.5)
			bunO = true
		end
	end

	function Joystick:getAngle()
		--Left
		if(Player.sprite.x > 224 and Player.sprite.y == 160 and bunO) then
			return 313
			--Back
		elseif(Player.sprite.x <= 225 and Player.sprite.y >= 141) then
			return 316
			-- Right
		elseif(Player.sprite.y <= 141 and Player.sprite.x < 340) then
			return 134
			--Forward
		elseif(Player.sprite.x <= 343 and Player.sprite.y < 160 and bunO == false) then
			return 220
			--Left
		elseif(Player.sprite.x >  225 and Player.sprite.y == 160) then
			return 313
		end
		return 1
	end

	function Joystick:getMoving()
		return true
	end
	walls = display.newGroup()
	sceneGroup:insert(walls)
	-- Pause Button Initialization
	pauseButton 			= display.newImage(pauseImg)
	pauseButton.x 		= display.contentWidth+20
	pauseButton.y			= 21
	pauseButton.alpha = 0.5
	sceneGroup:insert(pauseButton)
end

function scene:unPause()
	physics.start()
	Runtime:addEventListener("enterFrame", begin)
end

function scene:leaveLvl()
	composer.gotoScene( "scenes.levelSelectionScene", { effect = "fade", time = 300 } )
end

function scene:restartLvl( id )
	composer.gotoScene( "scenes.testerScene", { effect = "fade", time = 300, params = { levelID = levelID } } )
end

function beginMovement( event )
	if (Player.sprite.health <= 0) then
		scene:leaveLvl()
		return
	end
	--Joystick:toFront()
	pauseButton:toFront()
	if(bun <= bunD) then
		if(bun >= bunD - 5000) then
			assert(ItemsList[1].exists == false, "Error: Door still Exists!")
			assert(ItemsList[2].exists == false, "Error: Health still Exists!")
			assert(ItemsList[3].exists == false, "Error: Mana still Exists!")
			assert(ItemsList[4].exists == false, "Error: Key still Exists!")
			assert(ItemsList[5].exists == true, "Error: Final Door doesn't Exists!")
		end
		bun = system.getTimer()
		if (bun > bunS + 600 and bun < bunS + 620) then
			if(#ItemsList == 1) then
				placeItem(HP,176,159)
				assert(ItemsList[2].x == 176, "Error: Health X is Incorrect")
				assert(ItemsList[2].y == 159, "Error: Health Y is Incorrect")
				assert(ItemsList[2].name == "HP", "Error: Health Pot has wrong name")
			end

		elseif (bun > bunS + 700 and bun < bunS + 720) then
			if(#ItemsList == 2) then
				placeItem(Mana,300,141)
				assert(ItemsList[3].x == 300, "Error: Mana X is Incorrect")
				assert(ItemsList[3].y == 141, "Error: Mana Y is Incorrect")
				assert(ItemsList[3].name == "Mana", "Error: Mana Pot has wrong name")
			end
		elseif (bun > bunS + 800 and bun < bunS + 820) then
			if(#ItemsList == 3) then
				placeItem(Key, 350, 141)
				assert(ItemsList[4].x == 350, "Error: Key X is Incorrect")
				assert(ItemsList[4].y == 141, "Error: Key Y is Incorrect")
				assert(ItemsList[4].name == "Key", "Error: Key has wrong name")
			end
		elseif(bun > bunS + 4000 and bun < bunS + 4020) then
			if(#ItemsList == 4) then
				placeItem(FDoor, 350,141)
				assert(ItemsList[5].x == 350, "Error: Final Door X is Incorrect")
				assert(ItemsList[5].y == 141, "Error: Final Door Y is Incorrect")
				assert(ItemsList[5].name == "FDoor", "Error: FDoor has wrong name")

			end
		end
		Player:move(Joystick)
	end
	for n=1, en, 1 do
		if e[n] then
			if e[n].sprite then
				--e[n].sprite.statusBar:move()
				--e[n]:move(Player)
			end
		end
	end

	--move world if outside border
	if Player.sprite.x < borders-80 then	-- moving left
		Player.sprite.x = borders-80
		for n = 1, walls.numChildren, 1 do
			walls[n].x = walls[n].x + Player.sprite.speed
		end
		for n = 1, Enemies.numChildren, 1 do
			Enemies[n].x = Enemies[n].x + Player.sprite.speed
		end
		for n = 0, Items.numChildren, 1 do
			if(Items[n]) then
				Items[n].x = Items[n].x + Player.sprite.speed
			end
		end
	end
	if Player.sprite.x > screenW-borders then	-- moving right
		Player.sprite.x = screenW-borders

		for n = 1, walls.numChildren, 1 do
			walls[n].x = walls[n].x - Player.sprite.speed
		end
		for n = 1, Enemies.numChildren, 1 do
			Enemies[n].x = Enemies[n].x - Player.sprite.speed
		end
		for n = 0, Items.numChildren, 1 do
			if(Items[n]) then
				Items[n].x = Items[n].x - Player.sprite.speed
			end
		end
	end
	if Player.sprite.y < borders then	-- moving up
		Player.sprite.y = borders

		for n = 1, walls.numChildren, 1 do
			walls[n].y = walls[n].y + Player.sprite.speed
		end
		for n = 1, Enemies.numChildren, 1 do
			Enemies[n].y = Enemies[n].y + Player.sprite.speed
		end
		for n = 0, Items.numChildren, 1 do
			if(Items[n]) then
				Items[n].y = Items[n].y + Player.sprite.speed
			end
		end
	end
	if Player.sprite.y > screenH-borders then	-- moving down
		Player.sprite.y = screenH-borders

		for n = 1, walls.numChildren, 1 do
			walls[n].y = walls[n].y - Player.sprite.speed
		end
		for n = 1, Enemies.numChildren, 1 do
			Enemies[n].y = Enemies[n].y - Player.sprite.speed
		end
		for n = 0, Items.numChildren, 1 do
			if(Items[n]) then
				Items[n].y = Items[n].y - Player.sprite.speed
			end
		end
	end
end


function createBomb(x, y)
	print("hi")
	local bomb = Bomb:new(x, y, Player.sprite.statusBar)
	Items:insert(bomb.image)

	function boom(item)
		audio.play(BoomSound)
		print("boom")
		if(item) then
			if Enemies then
				for n = 1, en, 1 do
					if(e[n] and item) then
						if e[n].sprite then
							if e[n].sprite[1] then
								local dis = item:getDistance(e[n].sprite, item)
								if(dis < 100) then
									e[n]:attack(100)
									print("Hit Enemy: " .. n)
								end
							end
						end
					end
				end
			end
			if Player and item then
				if(item:getDistance(Player.sprite,item) < 100) then
					print("Hit Player")
					if Player.sprite.hasShield then
						Player.sprite.statusBar:setMana(-30)

						if Player.sprite.mana <= 0 then
							Player.sprite.hasShield = false
							Player.sprite:remove(Player.sprite.Shield)
						end
					else
						Player.sprite.statusBar:setHealth(-30)
					end
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
	local item = type:new(x,y,Player.sprite.statusBar)
	Items:insert(item.image)
	table.insert(ItemsList, item)
end
function placeEnemy(t,z)
	e[en] = NpcLib.new("enemy", {x = t, y = z, enemyType = "chaser"} )
	e[en]:spawn()
	Enemies:insert(e[en].sprite)
	en = en + 1
end



---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene
