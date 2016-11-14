---------------------------------------------------------------------------------
--
-- levelEditor.lua	: MAKE A LEVEL BBY
--
---------------------------------------------------------------------------------

local sceneName = ...
local composer = require( "composer" )
local scene = composer.newScene( sceneName )
local BoomSound = audio.loadSound( "sounds/Boom.wav" )

---------------------------------------------------------------------------------

-- start phyics up
physics.start()
physics.setGravity(0, 0)
-- Vars
local pauseImage
local backGround

local walls 
local Player
local Enemies
local Items
local Joystick

local pauseButton

local editType
local editImg
local editFilter
local editPhysics
local editName
local key
local pos

local e = {}
local en = 1

function scene:create( event )
	sceneGroup = self.view
end

function scene:loadLevel()
	level = require('levels.edit')
	
	Player.x = level.player[1].x
	Player.y = level.player[1].y
	
	for i = 1, #level.enemies do
		local b = level.enemies[i]
		placeEnemy(b.x, b.y)
	end
	
	for i = 1, #level.walls do
		local b = level.walls[i]
		crate = display.newImage("images/crate.png", b.x, b.y)
		physics.addBody(crate, "static", { filter = worldCollisionFilter } )
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
		placeItem(b.name, b.x, b.y)
	end
end

function scene:saveLevel() 
	package.loaded['levels.edit'] = nil
	local s = 'return {\n'

	s = s .. '\tplayer = {\n'
	local b = Player
	if b.x then
		s = s .. '\t\t{x = ' .. math.floor(b.x) .. ', y = ' .. math.floor(b.y) .. '}'
		s = s .. '\n'
	end
    s = s .. '\t},\n'
	
    s = s .. '\tenemies = {\n'
    for i = 1, Enemies.numChildren do
        local b = Enemies[i]
        if b.x then
            s = s .. '\t\t{x = ' .. math.floor(b.x) .. ', y = ' .. math.floor(b.y) .. '}'
            if i < Enemies.numChildren then
                s = s .. ',\n'
            else
                s = s .. '\n'
            end
        end
    end
    s = s .. '\t},\n'
	
	--items
	s = s .. '\titems = {\n'
    for i = 1, Items.numChildren do
        local b = Items[i]
		if b.x then
			s = s .. '\t\t{name = \'' .. b.name .. '\', x = ' .. math.floor(b.x) .. ', y = ' .. math.floor(b.y) .. '}'
			if i < Items.numChildren then
				s = s .. ',\n'
			else
				s = s .. '\n'
			end
		end
    end
    s = s .. '\t},\n'

    s = s .. '\twalls = {\n'
    for i = 1, walls.numChildren do
        local b = walls[i]
		if b.x then
			s = s .. '\t\t{x = ' .. math.floor(b.x) .. ', y = ' .. math.floor(b.y) .. '}'
			if i < walls.numChildren then
				s = s .. ',\n'
			else
				s = s .. '\n'
			end
		end
    end
    s = s .. '\t},\n'
	
    s = s .. '}\n'
	
    local path = system.pathForFile('levels/edit.lua', system.ResourceDirectory)
    local file = io.open(path, 'w')
    
	if file then
        file:write(s)
        io.close(file)
    end
    
	print('edit lvl saved')
end

function scene:show( event )
    sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
		-- BG may change
		backGround	= event.params.bg or "images/testBG.png"
		pauseImage	= event.params.pauseImg or "images/pauseIcon.png"
		
		self:initLevel(event)
	elseif phase == "did" then
		if Player and Joystick then
			Runtime:addEventListener("mouse", onMouseEvent)
			Runtime:addEventListener("key", onKeyEvent)
			Runtime:addEventListener("enterFrame", beginMovement)
		end
		if pauseButton then
			function pauseButton:touch ( event )
        		local phase = event.phase
        		if "ended" == phase then
        			composer.gotoScene( "scenes.settingsScene")
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
		if Player then
			Runtime:removeEventListener("enterFrame", beginMovement)
			Runtime:removeEventListener("collision",  onGlobalCollision)
			Runtime:removeEventListener("mouse", onMouseEvent)
			Runtime:removeEventListener("key", onKeyEvent)
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

function beginMovement( event )
	if (Player.sprite.health <= 0) then
		scene:leaveLvl()
		return
	end
	Player.sprite.statusBar.sprite:toFront()
	Joystick:toFront()
	pauseButton:toFront()
	Player:move(Joystick)

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
-- 1 = walls,	2 = enemies,	3 = health,		4 = mana,	5 = key,	6 = door,	7 = fdoor, 8 = bombs
function onKeyEvent( event )
	local phase = event.phase
	
	if phase == "down" then
		key = event.keyName
		if key == "1" then
			print("walls")
			editType = walls
			editImg = "images/crate.png"
			editFilter = worldCollisionFilter
			editPhysics = "static"
		elseif key == "2" then
			print("enemies")
			editType = Enemies
			editFilter = enemyCollisionFilter
			editPhysics = "dynamic"
		elseif key == "3" then
			print("health")
			editType = Items
			editName = "hp"
		elseif key == "4" then
			print("mana")
			editType = Items
			editName = "mana"
		elseif key == "5" then
			print("key")
			editType = Items
			editName = "key"
		elseif key == "6" then
			print("door")
			editType = Items
			editName = "door"
		elseif key == "7" then
			print("fdoor")
			editType = Items
			editName = "fdoor"
		elseif key == "8" then
			print("bombs")
			editType = Items
			editName = "bombP"
		elseif key == "deleteBack" then
			scene.loadLevel()
		elseif key == "insert" then
			scene.saveLevel()
		elseif key == "w" then
			print("wall building mode")
		elseif pos then
			local makeBlock = true
			for n = 1, walls.numChildren, 1 do
				if pos.x == walls[n].x and pos.y == walls[n].y then
					makeBlock = false
				end
			end
			
			if makeBlock then
				print("making crate")
				crate = display.newImage("images/crate.png", pos.x, pos.y)
				physics.addBody(crate, "static", { filter = worldCollisionFilter } )
				walls:insert(crate)
			end
			
			if key == "right" then
				pos.x = pos.x + walls[1].width
			elseif key == "left" then
				pos.x = pos.x - walls[1].width
			elseif key == "up" then
				pos.y = pos.y - walls[1].height
			elseif key == "down" then
				pos.y = pos.y + walls[1].height
			end
		end
	end

end

function onMouseEvent( event )
	if not editType then
		editType = walls
		editImg = "images/crate.png"
		editFilter = worldCollisionFilter
		editPhysics = "static"
		editName = "hp"
	end
	if event.isSecondaryButtonDown then
		if key == "w" then
			x1 = event.x
			y1 = event.y
		
			for n = 1, walls.numChildren, 1 do
				x2 = walls[n].x
				y2 = walls[n].y
				
				if math.sqrt(math.pow((x2-x1),2)+math.pow((y2-y1),2)) < 60 then
					x1 = walls[n].x
					y1 = walls[n].y
				end
			end
		
			pos = { x = x1, y = y1}
		else
			ready = 1
			for n = 1, editType.numChildren, 1 do
				x1 = editType[n].x
				x2 = event.x
				y1 = editType[n].y
				y2 = event.y
				
				if math.sqrt(math.pow((x2-x1),2)+math.pow((y2-y1),2)) < 60 then
					ready = 0
				end
			end
			if (ready == 1) then
				if editType == walls then
					crate = display.newImage(editImg, event.x, event.y)
					physics.addBody(crate, editPhysics, { filter = editFilter } )
					editType:insert(crate)
				elseif editType == Enemies then
					placeEnemy(event.x, event.y)
				elseif editType == Items then
					if(editName == "hp") then editName = HP end
					if(editName == "mana") then editName = Mana end
					if(editName == "key") then editName = Key end
					if(editName == "door") then editName = Door end
					if(editName == "fdoor") then editName = FDoor end
					if(editName == "bombP") then editName = BombP end
					placeItem(editName, event.x, event.y)
				end
			end
		end
	elseif event.isMiddleButtonDown then
		id = 0
		if editType.numChildren > 0 then
			for n = 1, editType.numChildren, 1 do
				x1 = editType[n].x
				x2 = event.x
				y1 = editType[n].y
				y2 = event.y
				
				if math.sqrt(math.pow((x2-x1),2)+math.pow((y2-y1),2)) < 30 then
					id = n
				end
			end
			editType:remove(id)
		end
	end
end

function scene:initLevel( event )
	-- Create background
	bg = display.newImage(backGround)
	bg.rotation = 90
	sceneGroup:insert(bg)
	-- Items
	Items = display.newGroup()
	sceneGroup:insert(Items)
	--Player
	Player = NpcLib.new("player", {})
	Player:spawn()
	sceneGroup:insert(Player.sprite)
	--Enemies
	Enemies = display.newGroup()
	sceneGroup:insert(Enemies)
	
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
	
	pauseButton = display.newImage(pauseImage)
	pauseButton.x = display.contentWidth+20
	pauseButton.y = 21
	pauseButton.alpha = 0.2
	sceneGroup:insert(pauseButton)
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
	local item = type:new(x, y, Player.sprite.statusBar)
	Items:insert(item.image)
end

function placeEnemy(t,z)
	e[en] = NpcLib.new( "enemy", {x = t, y = z} )
	e[en]:spawn()
	Enemies:insert(e[en].sprite)
	en = en + 1
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )

---------------------------------------------------------------------------------

return scene