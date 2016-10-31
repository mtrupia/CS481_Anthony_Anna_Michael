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
screenW = display.contentWidth
screenH = display.contentHeight
halfW 	= screenW/2
halfH 	= screenH/2
borders = 40
-- Physics
physics = require("physics")
worldCollisionFilter 	= {categoryBits = 1, maskBits = 14}
playerCollisionFilter 	= { categoryBits = 2, maskBits = 9 }
powerCollisionFilter 	= { categoryBits = 4, maskBits = 13 }
enemyCollisionFilter 	= { categoryBits = 8, maskBits = 15 }
-- Classes   ('require('classes.cannon').newCannon') <--- change to
StickLib 	  = require("libs.lib_analog_stick")
PlayerLib 	= require("classes.Player")
ItemsLib    = require("classes.Items")
PowerLib 	  = require("classes.Power")
EnemyLib 	  = require("classes.Enemy")
SBLib       = require("classes.StatusBar")
AStarLib    = require("libs.a-star")

-- load Welcome Screen
composer.gotoScene( "scenes.welcomeScene" )
