---------------------------------------------------------------------------------
--
-- main.lua	: Begin the application by showing the Welcome Screen
--
---------------------------------------------------------------------------------

-- init game mode :D
display.setStatusBar( display.HiddenStatusBar )
system.activate( "multitouch" )

-- require the composer library
local composer = require( "composer" )

-- globals (_G = global map)
_G.actualW 		= display.pixelHeight
_G.actualH		= display.pixelWidth
_G.actualHalfW 	= actualW/2
_G.actualHalfH 	= actualH/2
_G.screenW 		= display.contentWidth
_G.screenH 		= display.contentHeight
_G.halfW 		= screenW/2
_G.halfH 		= screenH/2
_G.borders = 140
-- Physics and filters
_G.physics = require("physics")
_G.worldCollisionFilter 		 = {	categoryBits = 1, maskBits = 30 }
_G.playerCollisionFilter 		 = { categoryBits = 2, maskBits = 57 }
--_G.playerCollisionFilter 		 = { categoryBits = 2, maskBits = 56 }
_G.powerCollisionFilter 		 = { categoryBits = 4, maskBits = 9 }
_G.enemyCollisionFilter 		 = { categoryBits = 8, maskBits = 47 }
_G.enemyPowerCollisionFilter = { categoryBits = 16, maskBits = 35 }
_G.itemCollisionFilter			 = { categoryBits = 32, maskBits = 30 }
_G.score  = {}
-- Classes
_G.StickLib 	 = require( "libs.Analog" )
-- phone taps
_G.tTarget = nil

-- read player save file
function _G.loadPlayer()
	local player = display.newGroup()
	-- Path for the file to read
	local path = system.pathForFile( "player.txt", system.DocumentsDirectory )

	-- Open the file handle
	local file, errorString = io.open( path, "r" )

	if not file then
		-- create player file
		file = nil
		createPlayer()
		loadPlayer()
		return
	else
		player.level 	= file:read("*n")
		player.health 	= file:read("*n")
		player.mana		= file:read("*n")
		player.levels	= {}
		for i = 1, 5, 1 do
			player.levels[i]= {score = file:read("*n"), items = file:read("*n")}
		end
		-- Close the file handle
		io.close( file )
	end

	file = nil
	return player
end
-- update player save file
function _G.updatePlayer(level, Player)
	local s = ""
	local p = loadPlayer()

	--save new player data
	if level+1 > p.level then
		s = s .. tostring(level+1) .. '\n'
	else
		s = s .. p.level .. '\n'
	end
	s = s .. Player.sprite.maxHealth .. "\n"
	s = s .. Player.sprite.maxMana .. "\n"
	if level == 1 then
		if Player.sprite.score > p.levels[1].score then
			s = s .. Player.sprite.score .. "\n"
		else
			s = s .. p.levels[1].score .. "\n"
		end
		if Player.sprite.maxHealth >= 150 then
			s = s .. "1\n"
		else
			s = s .. "0\n"
		end
	else
		s = s .. p.levels[1].score .. "\n" .. p.levels[1].items .. "\n"
	end
	if level == 2 then
		if Player.sprite.score > p.levels[2].score then
			s = s .. Player.sprite.score .. "\n"
		else
			s = s .. p.levels[2].score .. "\n"
		end
		if Player.sprite.maxMana >= 150 then
			s = s .. "1\n"
		else
			s = s .. "0\n"
		end
	else
		s = s .. p.levels[2].score .. "\n" .. p.levels[2].items .. "\n"
	end
	if level == 3 then
		if Player.sprite.score > p.levels[3].score then
			s = s .. Player.sprite.score .. "\n"
		else
			s = s .. p.levels[3].score .. "\n"
		end
		if Player.sprite.maxHealth == 200 then
			s = s .. "1\n"
		else
			s = s .. "0\n"
		end
	else
		s = s .. p.levels[3].score .. "\n" .. p.levels[3].items .. "\n"
	end
	if level == 4 then
		if Player.sprite.score > p.levels[4].score then
			s = s .. Player.sprite.score .. "\n"
		else
			s = s .. p.levels[4].score .. "\n"
		end
		if Player.sprite.maxMana == 200 then
			s = s .. "1\n"
		else
			s = s .. "0\n"
		end
	else
		s = s .. p.levels[4].score .. "\n" .. p.levels[4].items .. "\n"
	end
	if level == 5 then
		if Player.sprite.score > p.levels[5].score then
			s = s .. Player.sprite.score .. "\n0\n"
		else
			s = s .. p.levels[5].score .. "\n0\n"
		end
	else
		s = s .. p.levels[5].score .. "\n" .. p.levels[5].items .. "\n"
	end

	local path = system.pathForFile( "player.txt", system.DocumentsDirectory )

	local file, errorString = io.open( path, "w" )

	if not file then
		print( "File error: " .. errorString )
	else
		file:write( s )
		io.close( file )
	end

	file = nil
end
-- create starting player save file
function _G.createPlayer()
	-- Data (string) to write
	local saveData = "1\n100\n100\n0\n0\n0\n0\n0\n0\n0\n0\n0\n0"

	-- Path for the file to write
	local path = system.pathForFile( "player.txt", system.DocumentsDirectory )

	-- Open the file handle
	local file, errorString = io.open( path, "w" )

	if not file then
		-- Error occurred; output the cause
		print( "File error: " .. errorString )
	else
		-- Write data to file
		file:write( saveData )
		-- Close the file handle
		io.close( file )
	end

	file = nil
end

-- load Welcome Screen
composer.gotoScene( "scenes.welcomeScene" )
