---------------------------------------------------------------------------------
--
-- main.lua	: Begin the application by showing the Welcome Screen
--
---------------------------------------------------------------------------------

-- hide the status bar
display.setStatusBar( display.HiddenStatusBar )
system.activate( "multitouch" )

-- require the composer library
local composer = require "composer"

-- objects that should appear on all scenes below (e.g. tab bar, hud, etc)

-- system wide event handlers, location, key events, system resume/suspend, memory, etc.

-- load Welcome Screen
composer.gotoScene( "welcomeScene" )
