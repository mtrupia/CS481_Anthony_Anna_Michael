module (..., package.seeall)

-- Enemy
local enemyImage
local health
local enemyType

function NewEnemy( props )
	local enemy 	= display.newGroup()
	enemy.speed		= props.speed or 0.5
	enemy.x 		= props.x or 0
	enemy.y 		= props.y or 0
	enemyImage 		= props.img or "images/flower.png"
	enemyType 		= props.enemyType or "x"
	health 			= props.health or 10
	
	
	function enemy:spawn()
		enemyImg = display.newImage(enemyImage)
		enemy:insert(enemyImg)
		physics.addBody(enemy, {filter = enemyCollisionFilter})
	end
	
	function enemy:killEnemy()
		if (enemy[1]) then
			enemy[1]:removeSelf()
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
	
	--visibility???
	
	function enemy:move( player )
		if (enemy[1] and player) then
			hyp=math.sqrt((player.x-enemy.x)^2 + (player.y-enemy.y)^2)
			enemy.x=enemy.x + (player.x-enemy.x)/hyp
			enemy.y=enemy.y + (player.y-enemy.y)/hyp
		end
		
	end

	return enemy
end