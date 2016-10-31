module (..., package.seeall)

-- Player
local Power
local angle
--Declare and set up Sprite Image Sheet and sequence data
spriteOptions = {
	height = 64,
	width = 64,
	numFrames = 273,
	sheetContentWidth = 832,
	sheetContentHeight = 1344
}
mySheet = graphics.newImageSheet("images/playerSprite.png", spriteOptions)
sequenceData = {
	{name = "forward", frames={105,106,107,108,109,110,111,112}, time = 500, loopCount = 1},
	{name = "right", frames={144,145,146,147,148,149,150,151,152}, time = 500, loopCount = 1},
	{name = "back", frames= {131,132,133,134,135,136,137,138,139}, time = 500, loopCount = 1},
	{name = "left", frames={118,119,120,121,122,123,124,125,126}, time = 500, loopCount = 1},
	{name = "attackForward", frames={157,158,159,160,161,162,157}, time = 400, loopCount = 1},
	{name = "attackRight", frames={196,197,198,199,200,201,196}, time = 400, loopCount = 1},
	{name = "attackBack", frames={183,184,185,186,187,188,183}, time = 400, loopCount = 1},
	{name = "attackLeft", frames={170,171,172,173,174,175,170}, time = 400, loopCount = 1},
	{name = "death", frames={261,262,263,264,265,266}, time = 500, loopCount = 1}
}
-- Variables passed when Player is created
local playerImage

function NewPlayer ( props )
	local player		= display.newGroup()
	player.speed		= props.speed or 3
	player.x			= props.x or halfW
	player.y			= props.y or halfH
	playerImage			= props.image or "flower.png"
	player.myName 		= "player"
	player.hp 			= props.hp or 100
	player.mana			= props.mana or 100
	player.score		= props.score or 0


	function player:spawnPlayer()
		playerSprite = display.newSprite(mySheet, sequenceData)
		playerSprite:setSequence("forward")
		player:insert(playerSprite)
		physics.addBody(player, {filter = playerCollisionFilter})
		-- Power
		Power = PowerLib.NewPower( { player = player } )
		Power:begin()
	end

	function player:killPlayer()
		if (player[1]) then
			player[1]:removeSelf()
		end

		Power:destroy()
	end

	function player:destroy()
		Power:destroy()
		self:removeSelf()
	end

	function player:damagePlayer( amt )
		player.hp = player.hp - amt
		if player.hp <= 0 then
			player:killPlayer()
		end
	end

	function player:move( joystick )
		if (player[1] and joystick) then
			joystick:move(player, self.speed, false)
			player.rotation = 0

			angle = joystick:getAngle()
			moving = joystick:getMoving()

			--Determine which animation to play based on the direction of the analog stick
			--
			if(angle <= 45 or angle > 315) then
				seq = "forward"
			elseif(angle <= 135 and angle > 45) then
				seq = "right"
			elseif(angle <= 225 and angle > 135) then
				seq = "back"
			elseif(angle <= 315 and angle > 225) then
				seq = "left"
			end

			--Change the sequence only if another sequence isn't still playing
			if(not (seq == player[1].sequence) and moving) then -- and not attacking
				player[1]:setSequence(seq)
			end

			--If the analog stick is moving, animate the sprite
			if(moving) then
				player[1]:play()
			end
		end
	end
	local placeBomb = function( event )
		if(angle and statusBar.bomb.isVisible) then
			if(angle <= 45 or angle > 315) then
				local bomb = ItemsLib.newItem(1,"bomb",player.x, player.y - 60)
				Items:insert(bomb)
				bomb:spawn()
			elseif(angle <= 135 and angle > 45) then
				local bomb = ItemsLib.newItem(1,"bomb",player.x + 60, player.y)
				Items:insert(bomb)
				bomb:spawn()
			elseif(angle <= 225 and angle > 135) then
				local bomb = ItemsLib.newItem(1,"bomb",player.x, player.y + 60)
				Items:insert(bomb)
				bomb:spawn()
			elseif(angle <= 315 and angle > 225) then
				local bomb = ItemsLib.newItem(1,"bomb",player.x - 60, player.y)
				Items:insert(bomb)
				bomb:spawn()
			end
			statusBar.bomb.isVisible = false
		end
	end

	local placer = display.newCircle( display.contentWidth - 40, display.contentHeight - 40, 20)

	placer:addEventListener("touch", placeBomb )

	return player
end
