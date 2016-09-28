display.setStatusBar(display.HiddenStatusBar)
system.activate( "multitouch" )
local StickLib = require("lib_analog_stick")
local physics = require ("physics")

physics.start()
physics.setGravity(0, 0)
physics.setDrawMode( "hybrid" )

local screenW = display.contentWidth
local screenH = display.contentHeight
local posX = display.contentWidth/2
local posY = display.contentHeight/2
local speed = 3
local bulletSpeed = 250
local worldBorder = 20
local mainGroup = display.newGroup()
--Object controller
local objects = { }
local objN = 2
--filter controllers
local worldCollisionFilter = {categoryBits = 1, maskBits = 6}
local playerCollisionFilter = { categoryBits = 2, maskBits = 1 }
local powerCollisionFilter = { categoryBits = 4, maskBits = 5 }

--Joystick
Joystick = StickLib.NewStick(
	{
		x             = 10,
		y             = screenH-(52),
		thumbSize     = 16,
		borderSize    = 32, 
		snapBackSpeed = .2, 
		R             = 0,
		G             = 1,
		B             = 1
	} 
)
Joystick.alpha = 0.2

local function main (event)
	Joystick.y = display.contentHeight-(52)
	player.rotation = 0
	
	--move player with joystick
	Joystick:move(player, speed, false)

	--move world if outside border
	if player.x < -20 then	-- moving left
		player.x = -20
		
		for count = 1, objN, 1 do
			objects[count].x = objects[count].x + speed
		end
	elseif player.x > display.contentWidth-worldBorder then	-- moving right
		player.x = display.contentWidth-worldBorder
		
		for count = 1, objN, 1 do
			objects[count].x = objects[count].x - speed
		end
	elseif player.y < worldBorder then	-- moving up
		player.y = worldBorder
		
		for count = 1, objN, 1 do
			objects[count].y = objects[count].y + speed
		end
	elseif player.y > display.contentHeight-worldBorder then	-- moving down
		player.y = display.contentHeight-worldBorder
		
		for count = 1, objN, 1 do
			objects[count].y = objects[count].y - speed
		end
	end
end
Runtime:addEventListener("enterFrame", main) 

-- Bullets
bullets = {}
n = 0

local function shoot (event)
	if "began" == event.phase then
		n = n + 1
		bullets[n] = display.newImage("brick.png", player.x, player.y)
		physics.addBody( bullets[n], { density=3.0, friction=0.5, bounce=0.05, filter=powerCollisionFilter } )
		deltaX = event.x - player.x
		deltaY = event.y - player.y
		normDeltaX = deltaX / math.sqrt(math.pow(deltaX,2) + math.pow(deltaY,2))
		normDeltaY = deltaY / math.sqrt(math.pow(deltaX,2) + math.pow(deltaY,2))
		bullets[n]:setLinearVelocity( normDeltaX * bulletSpeed, normDeltaY * bulletSpeed )
	end
end

-- Create background
local bg = display.newImage("bg.png")
bg.rotation = 90
bg:addEventListener("touch", shoot)

-- Create player
player = display.newImage("flower.png")
player.x = 50
player.y = display.contentHeight-50
physics.addBody(player, {filter = playerCollisionFilter})

-- Create some collision
crate1 = display.newImage("crate.png", 50, 50)
crate2 = display.newImage("crate.png", 300, 50)
physics.addBody(crate1, "static", {filter=worldCollisionFilter})
physics.addBody(crate2, "static", {filter=worldCollisionFilter})
objects[1] = crate1
objects[2] = crate2

mainGroup:insert(bg)