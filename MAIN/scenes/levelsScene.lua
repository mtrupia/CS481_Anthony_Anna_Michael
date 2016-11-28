---------------------------------------------------------------------------------
--
-- levelsScene.lua	: Loads the levels of the game
--
---------------------------------------------------------------------------------

local sceneName = ...
local composer = require( "composer" )
require( "classes.Characters")
require( "classes.Enemies")
require( "classes.Items")
require( "classes.Abilities")
local scene = composer.newScene( sceneName )
local BoomSound = audio.loadSound( "sounds/Boom.wav" )
local GameOverSound = audio.loadSound( "sounds/GameOver.wav")
---------------------------------------------------------------------------------

-- start physics up
physics.start()
physics.setGravity(0, 0)
physics.setDrawMode( "normal" )

-- Variables
local pauseImg
local backGround
local walls
local Player
local Joystick
local levelID
local pauseButton
local Items
local Enemies
local bombPlacer
local shieldPlacer

local sceneGroup
levelArr = {} --global

local e = {}
local en = 1

function scene:create( event )
	sceneGroup = self.view
end

function scene:loadLevel()
	if (levelID > 5) then
		level = require('levels.1')
	else
		level = require('levels.' .. levelID)
	end

	Player.sprite.x = level.player[1].x
	Player.sprite.y = level.player[1].y

	for i = 1, #level.enemies do
		local b = level.enemies[i]
		placeEnemy(b.x, b.y)
	end
	
	-- Determine sizes
	minX=0 --global
	local maxX=0
	minY=0 --global
	local maxY=0
	for i = 1, #level.walls do
		if level.walls[i].x < minX then minX=level.walls[i].x end
		if level.walls[i].x > maxX then maxX=level.walls[i].x end
		if level.walls[i].y < minY then minY=level.walls[i].y end
		if level.walls[i].y > maxY then maxY=level.walls[i].y end
	end
	--expand
	minX=minX-30
	maxX=maxX+30
	minY=minY-30
	maxY=maxY+30
	--initialize levelArr
	for i=0, maxX-minX do
		levelArr[i]={}
		for j=0, maxY-minY do
			levelArr[i][j]=0
		end
	end
	
	for i = 1, #level.walls do
		local b = level.walls[i]
		crate = display.newImage("images/crate.png", b.x, b.y)
		crate.name = "wall"
		physics.addBody(crate, "static", { filter = editFilter } )
		walls:insert(crate)
		--insert into levelArr
		for j=b.x-30-minX, b.x+30-minX do
			for k=b.y-30-minY, b.y+30-minY do
				levelArr[j][k]=1
			end
		end
	end
	for i=0, maxX-minX do
		for j=0, maxY-minY do
			io.write(levelArr[i][j] .. " ")
		end
		io.write("\n")
	end
	for i = 1, #level.items do
		local b = level.items[i]
		if(b.name == "hp" or b.name == "HP") then b.name = HP end
		if(b.name == "mana" or b.name == "Mana") then b.name = Mana end
		if(b.name == "key" or b.name == "Key") then b.name = Key end
		if(b.name == "door" or b.name == "Door") then b.name = Door end
		if(b.name == "fdoor" or b.name == "FDoor") then b.name = FDoor end
		if(b.name == "bombP" or b.name == "BombP") then b.name = BombP end
		if(b.name == "spikes" or b.name == "Spikes") then b.name = Spikes end
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
			--Runtime:addEventListener("collision", onGlobalCollision)
			Runtime:addEventListener("enterFrame", beginMovement)
		end
		if bombPlacer then
			function bombPlacer:touch ( event )
				if "began" == event.phase then
					tTarget = bombPlacer
				elseif "ended" == event.phase and event.target == tTarget then
					if(Player.angle and Player.sprite.statusBar.sprite.count > 0) then
						if(Player.angle <= 45 or Player.angle > 315) then
							createBomb(Player.sprite.x, Player.sprite.y - 60)
						elseif(Player.angle <= 135 and Player.angle > 45) then
							createBomb(Player.sprite.x + 60, Player.sprite.y)
						elseif(Player.angle <= 225 and Player.angle > 135) then
							createBomb(Player.sprite.x, Player.sprite.y + 60)
						elseif(Player.angle <= 315 and Player.angle > 225) then
							createBomb(Player.sprite.x - 60, Player.sprite.y)
						end

						Player.sprite.statusBar.sprite.count = Player.sprite.statusBar.sprite.count - 1
						Player.sprite.statusBar.sprite.bomb.count.text = "x" .. Player.sprite.statusBar.sprite.count
					end
					tTarget = nil
				end
			end
			bombPlacer:addEventListener("touch", bombPlacer )
		end
		if shieldPlacer then
			function shieldPlacer:touch ( event )
				if event.phase == "began" then
					tTarget = shieldPlacer
				elseif event.phase == "ended" and event.target == tTarget then
					Player:useAbility( Shield )
					tTarget = nil
				end
			end
			shieldPlacer:addEventListener( "touch", shieldPlacer )
		end
		if pauseButton then
			function pauseButton:touch ( event )
				local phase = event.phase
				if "began" == phase then
					tTarget = pauseButton
				elseif "ended" == phase and event.target == tTarget then
					physics.pause()
					Runtime:removeEventListener("enterFrame", beginMovement)
					composer.showOverlay( "scenes.pauseScene", { isModal = true, effect = "fade", time = 300 } )
					tTarget = nil
				end
			end
			pauseButton:addEventListener( "touch", pauseButton )
		end
	end
end

function scene:hide( event )
	sceneGroup 		= self.view
	local phase 	= event.phase

	if phase == "will" then
		if pauseButton then
			pauseButton:removeEventListener("touch", pauseButton)
			pauseButton = nil;
		end
		if bombPlacer then
			bombPlacer:removeEventListener("touch", bombPlacer )
			bombPlacer:removeSelf()
			bombPlacer = nil
		end
		if shieldPlacer then
			shieldPlacer:removeEventListener( "touch", shieldPlacer )
			shieldPlacer:removeSelf()
			shieldPlacer = nil
		end
		if Player then
			Runtime:removeEventListener("enterFrame", beginMovement)
			Runtime:removeEventListener("collision",  onGlobalCollision)
			Runtime:removeEventListener("enterFrame",  spike)
			Player:kill()
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
		if Enemies then
			for n = 1, en, 1 do
				if e[n] then
					e[n]:kill()
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
function scene:initLevel( event )
	-- Create background
	bg = display.newImage(backGround)
	bg.rotation 		= 90
	sceneGroup:insert(bg)
	-- LevelID
	levelID = event.params.levelID
	-- Player
	Items = display.newGroup()
	Player = Mollie:new("player", {})
	sceneGroup:insert(Items)
	-- Enemy
	Enemies = display.newGroup()
	sceneGroup:insert(Enemies)
	sceneGroup:insert(Player.sprite)

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
-- bomb bombPlacer
playerLevel = require('levels.player').levels

if playerLevel >= 2 then
	shieldPlacer = display.newCircle( display.contentWidth - 50, display.contentHeight - 40, 20)
	sceneGroup:insert(shieldPlacer)
	shieldPlacer.img = display.newImage("images/shield.png", display.contentWidth - 50, display.contentHeight - 40)
	shieldPlacer.img:scale(0.5,0.5)
	sceneGroup:insert(shieldPlacer.img)
end
if playerLevel >= 3 then
	bombPlacer = display.newCircle( display.contentWidth, display.contentHeight - 40, 20)
	sceneGroup:insert(bombPlacer)
	bombPlacer.img = display.newImage("images/Bomb.png", display.contentWidth, display.contentHeight - 40)
	bombPlacer.img:scale(0.5,0.5)
	sceneGroup:insert(bombPlacer.img)
end
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
	if (Player.sprite.health <= 0) then
		audio.play(GameOverSound)
		scene:leaveLvl()
		return
	end
	Player.sprite.statusBar.sprite:toFront()
	Joystick:toFront()
	pauseButton:toFront()
	Player:move(Joystick)
	for n=1, en, 1 do
		if e[n] then
			if e[n].sprite.statusBar then
				e[n].sprite.statusBar:move()
				e[n]:move(Player)
			end
		end
	end

	--move world if outside border
	if Player.sprite.x < borders-80 then	-- moving left
		Player.sprite.x = borders-80
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
	if Player.sprite.x > screenW-borders then	-- moving right
		Player.sprite.x = screenW-borders

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
	if Player.sprite.y < borders then	-- moving up
		Player.sprite.y = borders

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
	if Player.sprite.y > screenH-borders then	-- moving down
		Player.sprite.y = screenH-borders

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
function updatePlayerLevel()
	package.loaded['levels.player'] = nil

	local s = 'return {\n'
	s = s .. '\tlevels = ' .. tostring(levelID + 1) .. '\n'
	s = s .. '}'

	local path = system.pathForFile('levels/player.lua', system.ResourceDirectory)
	local file = io.open(path, 'w')


	if file then
		file:write(s)
		io.close(file)
	end
end

function createBomb(x, y)
	local bomb = Bomb:new(x, y, Player.sprite.statusBar)
	Items:insert(bomb.image)

	function boom(item)
		audio.play(BoomSound)
		if(item) then
			if Enemies then
				for n = 1, en, 1 do
					if(e[n] and item) then
						if e[n].sprite then
							local dis = item:getDistance(e[n].sprite, item)
							if(dis < 100) then
								e[n]:Damage(-50)
								print("Hit Enemy: " .. n)
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
						Player.statusBar:setHealth(-30)
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
	local item

	if type == Spikes then
		item = type:new(x, y, Player.sprite)
	else
		item = type:new(x, y, Player.sprite.statusBar)
	end
	Items:insert(item.image)
end

function placeEnemy(x,y)
	etype_number = math.random(1, 10)

	if etype_number <=2 then
		etype= Ranger
	elseif etype_number >=3 and etype_number<=6 then
		etype= Chaser
	elseif etype_number >=7 and etype_number <= 8 then
		etype= Tank
	else
		etype= Trapper
	end
	e[en] = etype:new(x,y, Player)
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
