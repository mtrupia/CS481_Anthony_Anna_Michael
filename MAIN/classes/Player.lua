module (..., package.seeall)

-- Player
local Power

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

function NewPlayer ( props )
	local player		= display.newGroup()
	player.speed		= props.speed or 3
	player.Image		= props.image or "flower.png"
	player.hp 			= props.hp or 100
	player.mana			= props.mana or 100
	player.score		= props.score or 0
	player.myName 		= props.name or "player"
	player.x			= props.x or halfW
	player.y			= props.y or halfH
	
	player.visible		= props.visible or false
	player.index		= props.index or 0
	player.enemyType	= props.enemyType or "chaser"
	player.attackDamage	= props.attackDamage or 0
	player.dmgReady 	= props.dmgReady or true
	

	function player:spawnPlayer()
		player.dmgReady = false
		playerSprite = display.newSprite(mySheet, sequenceData)
		playerSprite:setSequence("forward")
		player:insert(playerSprite)
		physics.addBody(player, {filter = playerCollisionFilter})
		-- Power
		Power = PowerLib.NewPower( { player = player } )
		Power:begin()
	end
	
	function player:spawnEnemy()
		player.myName = "enemy" .. player.index
		if ( player.enemyType == "chaser" ) then
			player.speed			= 1.0
			player.Image	= "images/flower.png"
			player.attackDamage	= 10
			player.hp			= 50
		elseif ( player.enemyType == "ranger" ) then
			player.speed			= 0.5
			player.Image	= "images/flower.png"
			player.attackDamage	= 15
			player.hp			= 50
		elseif ( player.enemyType == "trapper" ) then
			player.speed			= 0.5
			player.Image	= "images/flower.png"
			player.attackDamage	= 5
			player.hp			= 50
		elseif ( player.enemyType == "tank" ) then
			player.speed			= 0.25
			player.Image	= "images/flower.png"
			player.attackDamage	= 5
			player.hp			= 75
		else
			player.speed			= 0.5
			player.Image	= "images/flower.png"
			--error here
		end

		enemyImg = display.newImage(player.Image)
		player:insert(enemyImg)
		physics.addBody(player, {filter = enemyCollisionFilter})
		player.isFixedRotation = true
		Runtime:addEventListener("collision", onGlobalCollision)
	end

	function player:kill()
		if (player) then
			player:removeSelf()
		end
		
		if player.myName == "player" then
			Power:destroy()
		end
	end

	function player:destroy()
		Power:destroy()
		self:removeSelf()
	end
	
	function player:useSpecial()
		if ( player.enemyType == "chaser" ) then
			print("useSpecial chaser")
		elseif ( player.enemyType == "ranger" ) then
			print("useSpecial ranger")
		elseif ( player.enemyType == "trapper" ) then
			print("useSpecial trapper")
		elseif ( player.enemyType == "tank" ) then
			print("useSpecial tank")
		end
	end
	
	function player:attack( p )
		print("attack")
		p:damage( player.attackDamage )
	end

	function player:damage( amt )
		player.hp = player.hp - amt
		if player.hp <= 0 then
			player:kill()
		end
	end
	
	function onGlobalCollision ( event )
		local o1n = event.object1.myName
		local o2n = event.object2.myName
		
		
		if ( o1n == player.myName or o2n == player.myName) and (o1n == "power" or o2n == "power") then
			if o1n == "power" then
				event.object2:damage( 100 ) --figure out what to do here
			else
				event.object1:damage( 100 )
			end
			--print("Collision: Object 1 =", event.object1.myName, "Object 2 =", event.object2.myName)
		elseif ( o1n == player.myName or o2n == player.myName) and (o1n == "player" or o2n == "player") and (event.object1.dmgReady or event.object2.dmgReady) then 
			if o1n == "player" then
				event.object1.hp = event.object1.hp - 10
				statusBar:dHPB()
				event.object2.dmgReady = false
				function allowDmg()
					event.object2.dmgReady = true
				end
				timer.performWithDelay(250, allowDmg, 1)
			else
				event.object2.hp = event.object2.hp - 10
				statusBar:dHPB()
				event.object1.dmgReady = false
				function allowDmg()
					event.object1.dmgReady = true
				end
				timer.performWithDelay(250, allowDmg, 1)
			end
		end
	end
	
	function player:visibility()
		player.visible = true
	end
	
	function player:enemyMove( p )
		player:visibility()
		if ( player[1] and p and player.visible and player.enemyType == "chaser" ) then
			hyp=math.sqrt((p.x-player.x)^2 + (p.y-player.y)^2)
			player.x=player.x + (p.x-player.x)/hyp
			player.y=player.y + (p.y-player.y)/hyp
		elseif ( player[1] and p and player.visible and player.enemyType == "ranger" ) then
			print("move ranger")
		elseif ( player[1] and p and player.visible and player.enemyType == "trapper" ) then
			print("move trapper")
		elseif ( player[1] and p and player.visible and player.enemyType == "tank" ) then
			hyp=math.sqrt((p.x-player.x)^2 + (p.y-player.y)^2)
			player.x=player.x + (p.x-player.x)/hyp
			player.y=player.y + (p.y-player.y)/hyp
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

	return player
end
