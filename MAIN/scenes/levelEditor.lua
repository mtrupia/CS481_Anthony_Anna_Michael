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
local pauseButton
local editType
local editImg
local editFilter
local editPhysics
local editName
local key
local pos

function scene:create( event )
	local sceneGroup = self.view
	
	backGround	= event.params.bg or "images/testBG.png"
	pauseImage	= event.params.pauseImg or "images/pauseIcon.png"
	
	-- Create background
	bg = display.newImage(backGround)
	bg.rotation = 90
	sceneGroup:insert(bg)
end

function scene:loadLevel()
	level = require('levels.2')
	
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
		physics.addBody(crate, "static", { filter = worldCollisionFilter } )
		walls:insert(crate)
	end
	
	for i = 1, #level.items do
		local b = level.items[i]
		newItem = ItemsLib.newItem(1, b.name, b.x, b.y)
		Items:insert(newItem)
		newItem:spawn()
	end
end

function scene:saveLevel() 
	package.loaded['levels.2'] = nil
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
	
    local path = system.pathForFile('levels/2.lua', system.ResourceDirectory)
    local file = io.open(path, 'w')
    
	if file then
        file:write(s)
        io.close(file)
    end
    
	print('level 2 saved')
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
		-- BG may change
		bg = event.params.bg or "images/testBG.png"
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
		
		-- StatusBar
		statusBar = iniStatusBar(Player)
		sceneGroup:insert(statusBar)

		statusBar:iHPB()
		statusBar:iMPB()
		
		pauseButton = display.newImage(pauseImage)
		pauseButton.x = display.contentWidth+20
		pauseButton.y = 21
		pauseButton.alpha = 0.2
		sceneGroup:insert(pauseButton)
	elseif phase == "did" then
		if Player and Joystick then
			Runtime:addEventListener("collision", onGlobalCollision)
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
								enemy = EnemyLib.NewEnemy( {x = event.x, y = event.y} )
								enemy:spawn()
								editType:insert(enemy)
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
			Runtime:addEventListener("mouse", onMouseEvent)
			-- 1 = walls,	2 = enemies,	3 = health,		4 = mana,	5 = key,	6 = door,	7 = fdoor
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
					elseif key == "deleteBack" then
						self.loadLevel()
					elseif key == "insert" then
						self.saveLevel()
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
			Runtime:addEventListener("key", onKeyEvent)
		
			function begin( event )
				if (Player.hp <= 0) then
					composer.gotoScene( "scenes.levelSelectionScene", { effect = "fade", time = 300 } )
					return
				end
			
				Joystick:toFront()
				Player:move(Joystick)
				
				--move world if outside border
				if Player.x < borders-80 then	-- moving left
					Player.x = borders-80
					
					for n = 1, walls.numChildren, 1 do
						walls[n].x = walls[n].x + Player.speed
					end
					
					for n=1, Enemies.numChildren, 1 do
						Enemies[n].x = Enemies[n].x + Player.speed
					end
					
					for n=1, Items.numChildren, 1 do
						Items[n].x = Items[n].x + Player.speed
					end
				end
				if Player.x > screenW-borders then	-- moving right
					Player.x = screenW-borders
					
					for n = 1, walls.numChildren, 1 do
						walls[n].x = walls[n].x - Player.speed
					end
					
					for n=1, Enemies.numChildren, 1 do
						Enemies[n].x = Enemies[n].x - Player.speed
					end
					
					for n=1, Items.numChildren, 1 do
						Items[n].x = Items[n].x - Player.speed
					end
				end
				if Player.y < borders then	-- moving up
					Player.y = borders
					
					for n = 1, walls.numChildren, 1 do
						walls[n].y = walls[n].y + Player.speed
					end
					
					for n=1, Enemies.numChildren, 1 do
						Enemies[n].y = Enemies[n].y + Player.speed
					end
					
					for n=1, Items.numChildren, 1 do
						Items[n].y = Items[n].y + Player.speed
					end
				end
				if Player.y > screenH-borders then	-- moving down
					Player.y = screenH-borders
					
					for n = 1, walls.numChildren, 1 do
						walls[n].y = walls[n].y - Player.speed
					end
					
					for n=1, Enemies.numChildren, 1 do
						Enemies[n].y = Enemies[n].y - Player.speed
					end
					
					for n=1, Items.numChildren, 1 do
						Items[n].y = Items[n].y - Player.speed
					end
				end
			end
			Runtime:addEventListener("enterFrame", begin)
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
    local sceneGroup = self.view
    local phase = event.phase

    if event.phase == "will" then
		if pauseButton then
			pauseButton:removeEventListener("touch", pauseButton)
		end
		if Player then
			Runtime:removeEventListener("enterFrame", begin)
			Runtime:removeEventListener("collision", onGlobalCollision)
			Runtime:removeEventListener("mouse", onMouseEvent)
			Runtime:removeEventListener("key", onKeyEvent)
			Player:destroy()
		end
		if Joystick then
			Joystick:delete()
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
    elseif phase == "did" then
	
    end 
end

function scene:destroy( event )
    local sceneGroup = self.view
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

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene