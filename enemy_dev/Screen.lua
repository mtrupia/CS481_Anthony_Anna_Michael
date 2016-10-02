module (..., package.seeall)

local welcomeImage = "blank.png"
local titleImage = "title.png"
--	Level
local LevelClass	= require("Level")
local widget = require "widget"

function NewScreen()
	local screen = display.newGroup()
	
	function screen:welcomeScreen()
		screen.screen = display.newImage(welcomeImage)
		screen.screen.rotation = 90
		screen:insert(screen.screen)
		screen.title = display.newImage(titleImage)
		screen.title.x = display.contentWidth/2
		screen.title.y = display.contentHeight/2-100
		screen:insert(screen.title)
		
		function onPlayBtnRelease()
			createLevel()
			Runtime:removeEventListener("enterFrame", main)
			Runtime:addEventListener("enterFrame", beginLevel)
			
			if (screen) then
				screen:removeSelf()
			end
			if (playBtn) then
				playBtn:removeSelf()
			end
			
			return true
		end
		
		playBtn = widget.newButton{
			label="Play Now",
			labelColor = { default={255}, over={128} },
			width=154, height=40,
			onRelease = onPlayBtnRelease	-- event listener function
		}
		playBtn.x = display.contentWidth/2
		playBtn.y = display.contentHeight/2
		screen:insert(playBtn)
	end
	
	function createLevel()
		Level = LevelClass.NewLevel()
	end
	
	function beginLevel( event )
		-- Begin a level
		Level:begin()
	end
	
	return screen
end