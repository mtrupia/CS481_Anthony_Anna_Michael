module (..., package.seeall)

local enemyCollisionFilter = { categoryBits = 3, maskBits = 1 }

enemyImage = "flower.png"

function NewEnemy( Props )
 
        local enemy = display.newGroup()

		enemy.x = Props.x
		enemy.y = Props.y
		enemy.enemyType = Props.enemyType
		enemy.health = Props.health
		enemy.speed=1
		function enemy:spawn()
			enemy.img = display.newImage(enemyImage)
			enemy:insert(enemy.img)
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
		end
		
		function enemy:attack()
			print("attack")
		end
		
		--visibility???
		
        function enemy:move( targetx, targety )
			
			hyp=math.sqrt((targetx-enemy.x)^2 + (targety-enemy.y)^2)
			enemy.x=enemy.x + (targetx-enemy.x)/hyp
			enemy.y=enemy.y + (targety-enemy.y)/hyp
			
		end

        return enemy
 
end