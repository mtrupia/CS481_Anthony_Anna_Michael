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

-- start phyics up
physics.start()
physics.setGravity(0, 0)
physics.setDrawMode( "normal" )

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
local bombPlacer
local shieldPlacer

local sceneGroup

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

	for i = 1, #level.walls do
		local b = level.walls[i]
		crate = display.newImage("images/crate.png", b.x, b.y)
		crate.name = "wall"
		physics.addBody(crate, "static", { filter = editFilter } )
		walls:insert(crate)
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
		if(b.name == "healthupgrade" or b.name == "HealthUpgrade") then b.name = HealthUpgrade end
		if(b.name == "manahupgrade" or b.name == "ManaUpgrade") then b.name = ManaUpgrade end
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
			_G.score[levelID] = Player.sprite.score
			display.remove(Player.sprite.statusBar.sprite.score )
			Player:kill()
			Player = nil

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
	Player = Mollie:new({speed = 5, health = require('levels.player').health, mana = require('levels.player').mana})
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
		Player.sprite.score = 0
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
	Player.sprite.statusBar.sprite.score.text = Player.sprite.score
end
function updatePlayerLevel()
	local p = require('levels.player')
	
	package.loaded['levels.player'] = nil
		
	local s = 'return {\n'
	if ((p.levels < levelID + 1) and not (levelID + 1 == 6)) then
		s = s .. '\tlevels = ' .. tostring(levelID + 1) .. ',\n'
	else
		s = s .. '\tlevels = ' .. p.levels .. ',\n'
	end
	s = s .. '\thealth = ' .. Player.sprite.maxHealth .. ',\n'
	s = s .. '\tmana = ' .. Player.sprite.maxMana .. ',\n'
	if levelID == 1 then
		if Player.sprite.maxHealth == 150 then
			s = s .. '\tlevel1 = {score = ' .. Player.sprite.score .. ', items = ' .. 1 .. '},\n'
		else
			s = s .. '\tlevel1 = {score = ' .. Player.sprite.score .. ', items = ' .. 0 .. '},\n'
		end
	else
		s = s .. '\tlevel1 = {score = ' .. p.level1.score .. ', items = ' .. p.level1.items .. '},\n'
	end
	print(levelID)
	if levelID == 2 then
		if Player.sprite.maxMana == 150 then
			s = s .. '\tlevel2 = {score = ' .. Player.sprite.score .. ', items = ' .. 1 .. '},\n'
		else
			s = s .. '\tlevel2 = {score = ' .. Player.sprite.score .. ', items = ' .. 0 .. '},\n'
		end
	else
		s = s .. '\tlevel2 = {score = ' .. p.level2.score .. ', items = ' .. p.level2.items .. '},\n'
	end
	if levelID == 3 then
		if Player.sprite.maxHealth == 200 then
			s = s .. '\tlevel3 = {score = ' .. Player.sprite.score .. ', items = ' .. 1 .. '},\n'
		else
			s = s .. '\tlevel3 = {score = ' .. Player.sprite.score .. ', items = ' .. 0 .. '},\n'
		end
	else
		s = s .. '\tlevel3 = {score = ' .. p.level3.score .. ', items = ' .. p.level3.items .. '},\n'
	end
	if levelID == 4 then
		if Player.sprite.maxMana == 200 then
			s = s .. '\tlevel4 = {score = ' .. Player.sprite.score .. ', items = ' .. 1 .. '},\n'
		else
			s = s .. '\tlevel4 = {score = ' .. Player.sprite.score .. ', items = ' .. 0 .. '},\n'
		end
	else
		s = s .. '\tlevel4 = {score = ' .. p.level4.score .. ', items = ' .. p.level4.items .. '},\n'
	end
	if levelID == 5 then
		s = s .. '\tlevel5 = {score = ' .. Player.sprite.score .. ', items = ' .. 0 .. '}\n'
	else
		s = s .. '\tlevel5 = {score = ' .. p.level5.score .. ', items = ' .. p.level5.items .. '}\n'
	end
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
							local dis = item:getDistance(e[n].sprite)
							if(dis < 100) then
								e[n]:Damage(-100)
								print("Hit Enemy: " .. n)
							end
						end
					end
				end
			end
			if Player and item then
				if(item:getDistance(Player.sprite) < 100) then
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
	local item

	if type == Spikes then
		item = type:new(x, y, Player.sprite)
	elseif type == HealthUpgrade and levelID == 1 then
		local p = require('levels.player')
		if p.level1.items == 0 then
			item = type:new(x, y, Player.sprite)
		end
	elseif type == ManaUpgrade and levelID == 2 then
		local p = require('levels.player')
		if p.level2.items == 0 then
			item = type:new(x, y, Player.sprite)
		end
	elseif type == HealthUpgrade and levelID == 3 then
		local p = require('levels.player')
		if p.level3.items == 0 then
			item = type:new(x, y, Player.sprite)
		end
	elseif type == ManaUpgrade and levelID == 4 then
		local p = require('levels.player')
		if p.level4.items == 0 then
			item = type:new(x, y, Player.sprite)
		end
	else 
		item = type:new(x, y, Player.sprite.statusBar)
	end
	
	if item then
		Items:insert(item.image)
	end
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
