module (..., package.seeall)

-- Enemy
local enemyImage
local health
local enemyType
local enemyImg

function NewEnemy( props )
	local enemy 	= display.newGroup()
	enemy.speed		= props.speed or 0.5
	enemy.x 		= props.x or 0
	enemy.y 		= props.y or 0
	enemyImage 		= props.img or "images/flower.png"
	enemyType 		= props.enemyType or "x"
	health 			= props.health or 10
	enemy.myName = "enemy"
	
	function enemy:spawn()
		enemyImg = display.newImage(enemyImage)
		enemy:insert(enemyImg)
		physics.addBody(enemy, {filter = enemyCollisionFilter})
	end
	
	function enemy:killEnemy()
		if (enemy[1]) then
			enemy[1]:removeSelf()
			display.remove(enemy.enemyImg)
		end
	end
	
	function enemy:useSpecial()
		print("useSpecial")
	end
	
	function enemy:damageEnemy( amt )
		enemy.health = enemy.health - amt
		if enemy.health <= 0 then
			enemy:killEnemy()
		end
	end
	
	function enemy:attack()
		print("attack")
	end
	
	function enemy:destroy()
		self:removeSelf()
	end
	
	function onGlobalCollision ( event )
	
    local o1n = event.object1.myName
    local o2n = event.object2.myName


    if ( o1n == "enemy" or o2n == "enemy") and (o1n == "player" or o2n == "player") then
		enemy:killEnemy()
		print("Collision: Object 1 =", event.object1.myName, "Object 2 =", event.object2.myName)
		
    end
	end
	--visibility???
	
	function enemy:move( player )
		if (enemy[1] and player) then
			hyp=math.sqrt((player.x-enemy.x)^2 + (player.y-enemy.y)^2)
			enemy.x=enemy.x + (player.x-enemy.x)/hyp
			enemy.y=enemy.y + (player.y-enemy.y)/hyp
		end
		
	end
	
	Runtime:addEventListener("collision", onGlobalCollision)
	
	return enemy
end