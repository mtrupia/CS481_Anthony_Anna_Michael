-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here
local screenW = display.contentWidth
local screenH = display.contentHeight
local StickLib = require("lib_analog_stick")
local physics = require("physics")
physics.start()
physics.setGravity(0,0)
-- local circle
local localGroup = display.newGroup()
local borders = display.newGroup()

 motionx = 0;
 motiony = 0;
 speed = 10;
local posX = display.contentWidth/2
local posY = display.contentHeight/2
MyStick = StickLib.NewStick( 
        {
        x             = 0,
        y             = display.contentHeight - 40,
        thumbSize     = 16,
        borderSize    = 32, 
        snapBackSpeed = .2, 
        R             = 0,
        G             = 40,
        B             = 40
        } )
        
local function main ( event )
        MyStick:move(circle, 3, false)
        end
 timer.performWithDelay(2000, function()
 --MyStick:delete()
 end, 1)
Runtime:addEventListener( "enterFrame", main )

local function onLocalPreCollision( self, event)
	print("YO YOU'RE ABOUT TO COLLIDE")
end
local bg = display.newImage("background.png")
bg.x = posX
bg.y = posY

circle = display.newCircle( posX, posY, 15)
wall = display.newImage(borders, "wall.PNG", 100, 100)
physics.addBody(circle, {density = 1.0, friction = 0.3, bounce = 0.3 } )
physics.addBody(wall, {density = 1.0, friction = 0.3, bounce = 0.3 } )
circle.preCollision = onLocalPreCollision
circle:addEventListener("preCollision")
localGroup:insert(bg)
localGroup:insert(circle)

