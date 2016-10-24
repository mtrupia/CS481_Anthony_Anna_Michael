module (..., package.seeall)

-- Enemy Class
local dmgReady = true

function NewEnemy( props )
	local enemy			= display.newGroup()
	enemy.x				= props.x or 0
	enemy.y				= props.y or 0
	enemy.enemyType		= props.enemyType or "chaser"
	enemy.index			= props.index or 0

	enemy.myName		= "enemy" .. enemy.index
	enemy.visible		= false

	function enemy:spawn()
		if ( enemy.enemyType == "chaser" ) then
			enemy.speed			= 1.0
			enemy.enemyImage	= "images/flower.png"
			enemy.attackDamage	= 10
			enemy.hp			= 50
		elseif ( enemy.enemyType == "ranger" ) then
			enemy.speed			= 0.5
			enemy.enemyImage	= "images/flower.png"
			enemy.attackDamage	= 15
			enemy.hp			= 50
		elseif ( enemy.enemyType == "trapper" ) then
			enemy.speed			= 0.5
			enemy.enemyImage	= "images/flower.png"
			enemy.attackDamage	= 5
			enemy.hp			= 50
		elseif ( enemy.enemyType == "tank" ) then
			enemy.speed			= 0.25
			enemy.enemyImage	= "images/flower.png"
			enemy.attackDamage	= 5
			enemy.hp			= 75
		else
			enemy.speed			= 0.5
			enemy.enemyImage	= "images/flower.png"
			--error here
		end

		enemyImg = display.newImage(enemy.enemyImage)
		enemy:insert(enemyImg)
		physics.addBody(enemy, {filter = enemyCollisionFilter})
		enemy.isFixedRotation = true
	end

	function enemy:killEnemy()
		if (enemy) then
			self:removeSelf()
		end
	end

	function enemy:useSpecial()
		if ( enemy.enemyType == "chaser" ) then
			print("useSpecial chaser")
		elseif ( enemy.enemyType == "ranger" ) then
			print("useSpecial ranger")
		elseif ( enemy.enemyType == "trapper" ) then
			print("useSpecial trapper")
		elseif ( enemy.enemyType == "tank" ) then
			print("useSpecial tank")
		end
	end

	function enemy:damageEnemy( amt )
		enemy.hp = enemy.hp - amt
		if enemy.hp <= 0 then
			enemy:killEnemy()
		end
	end

	function enemy:attack( player )
		print("attack")
		player:damagePlayer( enemy.attackDamage )
	end

	function enemy:destroy()
		display.remove(enemy.enemyImg)
		self:removeSelf()
	end

	function onGlobalCollision ( event )
		local o1n = event.object1.myName
		local o2n = event.object2.myName
		
		
		if ( o1n == enemy.myName or o2n == enemy.myName) and (o1n == "power" or o2n == "power") then
			if o1n == "power" then
				event.object2:damageEnemy( 100 ) --figure out what to do here
			else
				event.object1:damageEnemy( 100 )
			end
			--print("Collision: Object 1 =", event.object1.myName, "Object 2 =", event.object2.myName)
		elseif ( o1n == enemy.myName or o2n == enemy.myName) and (o1n == "player" or o2n == "player") and dmgReady then 
			if o1n == "player" then
				event.object1.hp = event.object1.hp - 10
				statusBar:dHPB()
				dmgReady = false
				function allowDmg()
					dmgReady = true
				end
				timer.performWithDelay(250, allowDmg, 1)
			else
				event.object2.hp = event.object2.hp - 10
				statusBar:dHPB()
				dmgReady = false
				function allowDmg()
					dmgReady = true
				end
				timer.performWithDelay(250, allowDmg, 1)
			end
		end
	end

	function enemy:visibility()
		enemy.visible = true
	end

	function enemy:move( player )
		enemy:visibility()
		if ( enemy[1] and player and enemy.visible and enemy.enemyType == "chaser" ) then
			hyp=math.sqrt((player.x-enemy.x)^2 + (player.y-enemy.y)^2)
			enemy.x=enemy.x + (player.x-enemy.x)/hyp
			enemy.y=enemy.y + (player.y-enemy.y)/hyp
		elseif ( enemy[1] and player and enemy.visible and enemy.enemyType == "ranger" ) then
			print("move ranger")
		elseif ( enemy[1] and player and enemy.visible and enemy.enemyType == "trapper" ) then
			print("move trapper")
		elseif ( enemy[1] and player and enemy.visible and enemy.enemyType == "tank" ) then
			hyp=math.sqrt((player.x-enemy.x)^2 + (player.y-enemy.y)^2)
			enemy.x=enemy.x + (player.x-enemy.x)/hyp
			enemy.y=enemy.y + (player.y-enemy.y)/hyp
		end

	end

	Runtime:addEventListener("collision", onGlobalCollision)

	return enemy
end
