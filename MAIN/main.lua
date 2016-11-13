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
_G.borders = 140			-- TODO: move this!

-- Physics and filters
_G.physics = require("physics")
_G.worldCollisionFilter 	= {categoryBits = 1, maskBits = 30}
_G.playerCollisionFilter 	= { categoryBits = 2, maskBits = 26 }
_G.powerCollisionFilter 	= { categoryBits = 4, maskBits = 29 }
_G.enemyCollisionFilter 	= { categoryBits = 8, maskBits = 15 }
_G.enemyPowerCollisionFilter 	= { categoryBits = 16, maskBits = 7 }
-- Classes 
_G.StickLib 	= require("classes.lib_analog_stick")
_G.PlayerLib	= require("classes.Player")
_G.ItemsLib    	= require("classes.Items")
_G.PowerLib 	= require("classes.Power")
_G.SBLib       	= require("classes.StatusBar")
-- phone taps
_G.tTarget = nil

-- load Welcome Screen
composer.gotoScene( "scenes.welcomeScene" )
