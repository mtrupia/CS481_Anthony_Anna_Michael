module (..., package.seeall)

local screenW = display.contentWidth
local screenH = display.contentHeight
local halfW = screenW/2
local halfH = screenH/2
local borders = 40
-- Physics
local physics		= require("physics")
physics.start()
physics.setGravity(0, 0)

local worldCollisionFilter = {categoryBits = 1, maskBits = 6}
local PlayerClass	= require("Player")
local StickLib		= require("lib_analog_stick")
local mainGroup = display.newGroup()
local wallsGroup = display.newGroup()

function NewLevel()
	local level = display.newGroup()
	if not mainGroup then
		print("hey")
	end
	
	-- Create background
	local bg = display.newImage("bg.png")
	bg.rotation = 90
	mainGroup:insert(bg)
	
	-- Player
	Player = PlayerClass.NewPlayer(
		{
			x		= 50,
			y		= screenH-50,
			health 	= 100,
			mana	= 100,
			score	= 0,
			speed	= 3,
			bg		= bg
		}
	)
	Player:spawnPlayer()
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
	Joystick.alpha = 0.2
	
	function level:destroy()
		Player:destroy()
		Joystick:delete()
		mainGroup:removeSelf()
		wallsGroup:removeSelf()
		self:removeSelf()
	end
	
	function level:begin()
		Player:move(Joystick)
		
		-- move world if outside border
		if Player.x < -8 then	-- moving left
			Player.x = -8
			
			for n = 1, wallsGroup.numChildren, 1 do
				wallsGroup[n].x = wallsGroup[n].x + Player.speed
			end
		end
		if Player.x > screenW+8 then	-- moving right
			Player.x = screenW+8
			
			for n = 1, wallsGroup.numChildren, 1 do
				wallsGroup[n].x = wallsGroup[n].x - Player.speed
			end
		end
		if Player.y < borders then	-- moving up
			Player.y = borders
			
			for n = 1, wallsGroup.numChildren, 1 do
				wallsGroup[n].y = wallsGroup[n].y + Player.speed
			end
		end
		if Player.y > screenH-borders then	-- moving down
			Player.y = screenH-borders
			
			for n = 1, wallsGroup.numChildren, 1 do
				wallsGroup[n].y = wallsGroup[n].y - Player.speed
			end
		end
	end




	-- Create some collision
	crate1 = display.newImage("crate.png", 50, 50)
	wallsGroup:insert(crate1)
	crate2 = display.newImage("crate.png", 300, 50)
	wallsGroup:insert(crate2)
	physics.addBody(crate1, "static", {filter=worldCollisionFilter})
	physics.addBody(crate2, "static", {filter=worldCollisionFilter})
	
	return level
end