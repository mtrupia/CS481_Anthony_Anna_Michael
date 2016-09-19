display.setStatusBar( display.HiddenStatusBar )  

    -- Set the background color to white  
    local background = display.newRect( 0, 0, 1280, 720 )  
    background:setFillColor( 255, 255, 255 )  
	x = 0
    -- Add a score label  
    -- local score = 0  
    -- local scoreLabel = display.newText( score, 0, 0, native.systemFontBold, 120 )  
    -- scoreLabel.x = display.viewableContentWidth / 2  
    -- scoreLabel.y = display.viewableContentHeight / 2  
    -- scoreLabel:setTextColor( 0, 0, 0, 10 )
	
	 -- Creates and returns a new player.
    local function createPlayer( x, y, width, height, rotation )
        --  Player is a black square.
        local p = display.newRect( x, y, width, height )
        p:setFillColor( 0, 0, 0 )
        p.rotation = rotation

        return p
    end

    local player = createPlayer( display.viewableContentWidth / 2, display.viewableContentHeight / 2, 20, 20, 0 )
	 background.alpha = 0.5
	 player:setFillColor ( 0, 0, 0 )
	 
     local playerRotation = function()
        player.rotation = player.rotation + 1
     end

    Runtime:addEventListener( "enterFrame", playerRotation )
	
	 local function onTouch( event )
        if "began" == event.phase then
            player.isFocus = true
			x = x + 10
			player:setFillColor(0,x,0)
            player.x0 = event.x - player.x
            player.y0 = event.y - player.y
        elseif player.isFocus then
            if "moved" == event.phase then
                player.x = event.x - player.x0
                player.y = event.y - player.y0
            elseif "ended" == phase or "cancelled" == phase then
                player.isFocus = false
            end
        end

        -- Return true if the touch event has been handled.
        return true
    end

    -- Only the background receives touches.
	background:addEventListener( "touch", onTouch)
	
	local function myTapListener( event )

    -- Code executed when the button is tapped
    print( "Object tapped: " .. tostring(event.target) )  -- "event.target" is the tapped object
    return true
end

local myButton = display.newRect( 100, 100, 50, 50 )
myButton:addEventListener( "tap", myTapListener )  -- Add a "tap" listener to the object