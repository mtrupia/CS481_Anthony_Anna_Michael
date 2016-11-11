module (..., package.seeall)

-- Player
local Power
local enemyPower
local HitSound = audio.loadSound("sounds/Hit.wav")
--Declare and set up Sprite Image Sheet and sequence data
playerOptions = {
	height = 64,
	width = 64,
	numFrames = 273,
	sheetContentWidth = 832,
	sheetContentHeight = 1344
}
mySheet = graphics.newImageSheet("images/playerSprite.png", playerOptions)
sequenceDataP = {
	{name = "forward", 				frames={105,106,107,108,109,110,111,112}, 		time = 500, loopCount = 1},
	{name = "right", 					frames={144,145,146,147,148,149,150,151,152}, time = 500, loopCount = 1},
	{name = "back", 					frames={131,132,133,134,135,136,137,138,139}, time = 500, loopCount = 1},
	{name = "left", 					frames={118,119,120,121,122,123,124,125,126}, time = 500, loopCount = 1},
	{name = "attackForward", 	frames={157,158,159,160,161,162,157}, 				time = 400, loopCount = 1},
	{name = "attackRight", 		frames={196,197,198,199,200,201,196}, 				time = 400, loopCount = 1},
	{name = "attackBack", 		frames={183,184,185,186,187,188,183}, 				time = 400, loopCount = 1},
	{name = "attackLeft", 		frames={170,171,172,173,174,175,170}, 				time = 400, loopCount = 1},
	{name = "death", 					frames={261,262,263,264,265,266}, 						time = 500, loopCount = 1}
}

-- Enemy Sprite
local sheetInfo = require("Sprites.Sprite")
local enemySheet = graphics.newImageSheet( "Sprites/Sprite.png", sheetInfo:getSheet() )
local sequenceDataE = {
	{
		name = "walk",
		sheet = enemySheet,
		start = sheetInfo:getFrameIndex("1"),
		count = 8,
		time  = 1000,
		loopCount = 0
	}
}

-- Variables passed when Player is created

function NewPlayer ( props )
	local player				= display.newGroup()
	player.speed				= props.speed or 3
	player.Image				= props.image or "flower.png"
	player.hp 					= props.hp or 100
	player.mana					= props.mana or 100
	player.score				= props.score or 0
	player.myName 			= props.name or "player"
	player.x						= props.x or halfW
	player.y						= props.y or halfH

	player.visible			= props.visible or false
	player.index				= props.index or 0
	--player.enemyType	= props.enemyType or "chaser"
	player.enemyType	= props.enemyType or "chaser"
	player.attackDamage	= props.attackDamage or 0
	player.dmgReady 		= props.dmgReady or true

	player.items				= props.items
	player.statusBar		= props.statusBar


	function player:spawnPlayer()
		player.dmgReady = false
		playerSprite = display.newSprite(mySheet, sequenceDataP)
		playerSprite:setSequence("forward")
		player:insert(playerSprite)
		physics.addBody(player, {filter = playerCollisionFilter})
		-- Power
		Power = PowerLib.NewPower( { player = player} )
		Power:begin()
	end

	function player:spawnEnemy()
		player.myName = "enemy" .. player.index
		if ( player.enemyType == "chaser" ) then
			player.speed				= 1.0
			player.attackDamage	= 10
			player.hp						= 50
		elseif ( player.enemyType == "ranger" ) then
			player.speed				= 0.5
			player.Image				= "images/flower.png"
			player.attackDamage	= 15
			player.hp						= 50
		elseif ( player.enemyType == "trapper" ) then
			player.speed				= 0.5
			player.Image				= "images/flower.png"
			player.attackDamage	= 5
			player.hp						= 50
		elseif ( player.enemyType == "tank" ) then
			player.speed				= 0.25
			player.Image				= "images/flower.png"
			player.attackDamage	= 5
			player.hp						= 75
		else
			player.speed				= 0.5
			player.Image				= "images/flower.png"
			--error here
		end
		
		enemyPower = PowerLib.NewPower( { player = player} )

		player.enemySprite	= display.newSprite(enemySheet, sequenceDataE)
		player.enemySprite:setSequence("walk")
		player.enemySprite:play()
		player:insert(player.enemySprite)

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
				audio.play(HitSound)
				event.object2:damage( 100 ) --figure out what to do here
				else
					audio.play(HitSound)
					event.object1:damage( 100 )
				end
				--print("Collision: Object 1 =", event.object1.myName, "Object 2 =", event.object2.myName)
			elseif ( o1n == player.myName or o2n == player.myName) and (o1n == "player" or o2n == "player") and (event.object1.dmgReady or event.object2.dmgReady) then
				if o1n == "player" then
					event.object1.statusBar:dHPB(event.object1)
					event.object2.dmgReady = false
					function allowDmg()
						event.object2.dmgReady = true
					end
					timer.performWithDelay(250, allowDmg, 1)
				else
					event.object2.statusBar:dHPB(event.object2)
					event.object1.dmgReady = false
					function allowDmg()
						event.object1.dmgReady = true
					end
					timer.performWithDelay(250, allowDmg, 1)
				end
			end
		end

		function player:visibility(p)
			ready = false

			x1 = player.x
			y1 = player.y

			x2 = p.x
			y2 = p.y

			if math.sqrt(math.pow((x2-x1),2)+math.pow((y2-y1),2)) < 400 then
				ready = true
			end

			if ready then
				player.visible = true
			elseif not (ready) then
				player.visible = false
			end
		end

		function player:enemyMove( p )
			player:visibility(p)
			if player.visible then
				hyp=math.sqrt((p.x-player.x)^2 + (p.y-player.y)^2)
				dist=200
				--enemyPower:enemyShoot(player, p)
				if(player.x > p.x ) then
					player.enemySprite.xScale = 1
					player.enemySprite:play()
				elseif (player.x < p.x) then
					player.enemySprite.xScale = -1
					player.enemySprite:play()
				end
				if ( player[1] and p and player.visible and player.enemyType == "chaser" ) then
					player.x=player.x + (p.x-player.x)/hyp
					player.y=player.y + (p.y-player.y)/hyp
				elseif ( player[1] and p and player.visible and player.enemyType == "ranger" ) then
					if (hyp>=dist) then
						--approach player
						player.x=player.x + (p.x-player.x)/hyp
						player.y=player.y + (p.y-player.y)/hyp
					else
						--move away from player
						player.x=player.x - (p.x-player.x)/hyp
						player.y=player.y - (p.y-player.y)/hyp
					end
				elseif ( player[1] and p and player.visible and player.enemyType == "trapper" ) then
					if (hyp>=dist) then  --approach player
						player.x=player.x + (p.x-player.x)/hyp
						player.y=player.y + (p.y-player.y)/hyp
					else
						--set trap

						--then move away
						player.x=player.x - (p.x-player.x)/hyp
						player.y=player.y - (p.y-player.y)/hyp
					end
				elseif ( player[1] and p and player.visible and player.enemyType == "tank" ) then
					player.x=player.x + (p.x-player.x)/hyp
					player.y=player.y + (p.y-player.y)/hyp
				end
			end
		end

		function player:move( joystick )
			if (player[1] and joystick) then
				joystick:move(player, self.speed, false)
				player.rotation = 0

				player.angle = joystick:getAngle()
				moving = joystick:getMoving()

				--Determine which animation to play based on the direction of the analog stick
				--
				if(player.angle <= 45 or player.angle > 315) then
					seq = "forward"
				elseif(player.angle <= 135 and player.angle > 45) then
					seq = "right"
				elseif(player.angle <= 225 and player.angle > 135) then
					seq = "back"
				elseif(player.angle <= 315 and player.angle > 225) then
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
