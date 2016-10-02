module (..., package.seeall)

powerImage = "brick.png"

--Bullets
local powerCollisionFilter = { categoryBits = 4, maskBits = 5 }
bullets = {}
n = 0
aliveBullets = {}
x = 0

function NewPower( player )
	local power = display.newGroup()
	
	function power:begin( bg )
		bg:addEventListener("touch", Shoot) 
	end
	
	function power:stop( bg )
		bg:removeEventListener("touch", Shoot) 
	end
	
	function Shoot (event)
		if "began" == event.phase then
			n = n + 1
			bullets[n] = display.newImage("brick.png", player.x, player.y)
			physics.addBody( bullets[n], { density=3.0, friction=0.5, bounce=0.5, filter=powerCollisionFilter } )
			deltaX = event.x - player.x
			deltaY = event.y - player.y
			normDeltaX = deltaX / math.sqrt(math.pow(deltaX,2) + math.pow(deltaY,2))
			normDeltaY = deltaY / math.sqrt(math.pow(deltaX,2) + math.pow(deltaY,2))
			bullets[n]:setLinearVelocity( normDeltaX * 250, normDeltaY * 250 )
			aliveBullets[n] = n
			
			function delete()
				x = x + 1
				if (bullets[aliveBullets[x]]) then
					bullets[aliveBullets[x]]:removeSelf()
				end
			end
		
			timer.performWithDelay(2500, delete)
		end
	end
	
	return power
end