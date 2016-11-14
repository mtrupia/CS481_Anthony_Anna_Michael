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
_G.worldCollisionFilter 		 = {	categoryBits = 1, maskBits = 30 }
_G.playerCollisionFilter 		 = { categoryBits = 2, maskBits = 57 }
_G.powerCollisionFilter 		 = { categoryBits = 4, maskBits = 41 }
_G.enemyCollisionFilter 		 = { categoryBits = 8, maskBits = 47 }
_G.enemyPowerCollisionFilter = { categoryBits = 16, maskBits = 3 }
_G.itemCollisionFilter			 = { categoryBits = 32, maskBits = 14 }
-- Classes
_G.StickLib 	 = require( "classes.Analog" )
_G.NpcLib		   = require( "classes.Character" )
_G.AbilityLib	 = require( "classes.Ability" )
_G.BarLib		   = require( "classes.Bar" )
_G.ItemsLib    = require("classes.Items")
-- phone taps
_G.tTarget = nil

-- load Welcome Screen
composer.gotoScene( "scenes.welcomeScene" )
