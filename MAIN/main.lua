-- Setup
display.setStatusBar(display.HiddenStatusBar)
system.activate( "multitouch" )

-- Load Classes --
-- Physics
local physics		= require("physics")
physics.start()
physics.setGravity(0, 0)
physics.setDrawMode( "hybrid" )
-- Screen
local ScreenClass	= require("Screen")
Screen = ScreenClass.NewScreen()
Screen:welcomeScreen()

-- Run Program
local function main (event)
	
end
Runtime:addEventListener("enterFrame", main) 