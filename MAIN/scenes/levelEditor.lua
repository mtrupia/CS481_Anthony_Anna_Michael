---------------------------------------------------------------------------------
--
-- levelEditor.lua	: MAKE A LEVEL BBY
--
---------------------------------------------------------------------------------

local sceneName = ...
local composer = require( "composer" )
local scene = composer.newScene( sceneName )

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
local statusBar
local pauseButton
local placer
local editType
local editImg
local editFilter
local editPhysics
local editName
local key
local pos

function scene:create( event )
	sceneGroup = self.view
end

function scene:loadLevel()
	level = require('levels.3')
	
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
		placeItem(b.name, b.x, b.y)
	end
end

function scene:saveLevel() 
	package.loaded['levels.3'] = nil
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
			s = s .. '\t\t{name = \'' .. b.myName .. '\', x = ' .. math.floor(b.x) .. ', y = ' .. math.floor(b.y) .. '}'
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
	
    local path = system.pathForFile('levels/3.lua', system.ResourceDirectory)
    local file = io.open(path, 'w')
    
	if file then
        file:write(s)
        io.close(file)
    end
    
	print('level 3 saved')
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
        			composer.gotoScene( "scenes.settingsScene", { effect = "fade", time = 300 } )
        		end
        	end
        	pauseButton:addEventListener( "touch", pauseButton )
		end
    end 
end

function scene:hide( event )
    sceneGroup = self.view
    local phase = event.phase

    if event.phase == "will" then
		if pauseButton then
			pauseButton:removeEventListener("touch", pauseButton)
			pauseButton = nil
		end
		if Player then
			Runtime:removeEventListener("enterFrame", beginMovement)
			Runtime:removeEventListener("mouse", onMouseEvent)
			Runtime:removeEventListener("key", onKeyEvent)
			Player:destroy()
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
		if Enemies then
			Enemies:removeSelf()
			Enemies = nil
		end
		if Items then
			Items:removeSelf()
			Items = nil
		end
		if editType then
			editType:removeSelf()
			editType = nil
		end
		if placer then 
			placer:removeSelf()
			placer = nil
		end
    elseif phase == "did" then
	
    end 
end

function scene:destroy( event )
	sceneGroup = self.view
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
					newItem = ItemsLib.newItem(1, editName, event.x, event.y)
					Items:insert(newItem)
					newItem:spawn()
				end
			end
		end
	elseif event.isMiddleButtonDown then
		id = 0
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

function scene:initLevel( event )
	-- Create background
	bg = display.newImage(backGround)
	bg.rotation = 90
	sceneGroup:insert(bg)
	-- Player
	Player = PlayerLib.NewPlayer( {} )
	sceneGroup:insert(Player)
	Player:spawnPlayer()
	-- Enemy
	Enemies = display.newGroup()
	sceneGroup:insert(Enemies)
	-- Items
	Items = display.newGroup()
	sceneGroup:insert(Items)
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
	
	pauseButton = display.newImage(pauseImage)
	pauseButton.x = display.contentWidth+20
	pauseButton.y = 21
	pauseButton.alpha = 0.2
	sceneGroup:insert(pauseButton)
	-- bomb placer
	placer = display.newCircle( display.contentWidth - 40, display.contentHeight - 40, 20)
	sceneGroup:insert(placer)
	placer.img = display.newImage("images/Bomb.png", display.contentWidth - 40, display.contentHeight - 40)
	placer.img:scale(0.5,0.5)
	sceneGroup:insert(placer.img)
end

function createBomb(x, y)
	local bomb = ItemsLib.newItem(1,"bomb",x, y)
	Items:insert(bomb)
	bomb:spawn()
	
	function boom(item)
		print("boom")
		if(item) then
			for n = 0, Enemies.numChildren, 1 do
				if(Enemies[n] and item) then
					local dis = item:getDistance(Enemies[n], item)
					if(dis < 100) then
						Enemies[n]:damage(100)
						print("Hit Enemy: " .. n)
					end
				end
			end
			if(item:getDistance(Player,item) < 100) then
				print("Hit Player")
				statusBar:dHPB(Player)
				statusBar:dHPB(Player)
				statusBar:dHPB(Player)
			end
			item:destroy()
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