module (..., package.seeall)

-- Powers
local powerImage
local powers = {}
local n = 0
local alivePowers = {}
local x = 0
local enemyShootCount = 0
local enemyShootMax = 0

-- Variables passed when Power is created
local powerLife			-- in ms
local player			-- where shall the power come from
local powerSpeed		-- speed of Power
local density			-- density of the Power
local friction			-- friction of the Power
local bounce			-- bounce of the Power (fun)
local ShootSound = audio.loadSound( "sounds/Shoot.wav")

function NewPower( props )
	local power 	= display.newGroup()
	powerImage 		= props.image or "images/brick.png"
	powerLife 		= props.life or 500
	player			= props.player
	powerSpeed		= props.speed or 250
	density			= props.density or 3
	friction		= props.friction or 0.500
	bounce			= props.bounce or 1

	function power:begin()
		Runtime:addEventListener("touch", Shoot)
	end

	function power:destroy()
		Runtime:removeEventListener("touch", Shoot)
		if(power) then
			self:removeSelf()
		end
	end

	function Shoot (event)
	if player.myName == "player" then
		if "ended" == event.phase and player.mana > 0 then
			audio.play( ShootSound )
			n = n + 1
			powers[n] = display.newImage(powerImage, player.x, player.y)
			physics.addBody( powers[n], { density=density, friction=friction, bounce=bounce, filter=powerCollisionFilter } )
			powers[n].myName = "power"
			deltaX = event.x - player.x
			deltaY = event.y - player.y
			normDeltaX = deltaX / math.sqrt(math.pow(deltaX,2) + math.pow(deltaY,2))
			normDeltaY = deltaY / math.sqrt(math.pow(deltaX,2) + math.pow(deltaY,2))
			powers[n]:setLinearVelocity( normDeltaX * powerSpeed, normDeltaY * powerSpeed )
			alivePowers[n] = n
			player.statusBar:dMPB(player)
			function delete()
				x = x + 1
				if (powers[alivePowers[x]] and powers[alivePowers[x]].myName == "power") then
					powers[alivePowers[x]]:removeSelf()
				end
			end
			timer.performWithDelay(powerLife, delete)
		end
	end
	end

	function power:enemyShoot (enemy, target)
		if enemyShootCount < enemyShootMax then
		enemyShootCount=enemyShootCount + 1
		
		audio.play( ShootSound )
		n = n + 1
		powers[n] = display.newImage(powerImage, enemy.x, enemy.y)
		physics.addBody( powers[n], { density=density, friction=friction, bounce=bounce, filter=powerCollisionFilter } )		
		powers[n].myName = "enemyPower"
		
		deltaX=enemy.x - target.x
		deltaY=enemy.y - target.y
		normDeltaX = deltaX / math.sqrt(math.pow(deltaX,2) + math.pow(deltaY,2))
		normDeltaY = deltaY / math.sqrt(math.pow(deltaX,2) + math.pow(deltaY,2))
		
		powers[n]:setLinearVelocity( normDeltaX * powerSpeed, normDeltaY * powerSpeed )
		alivePowers[n] = n

		function delete()
			x = x + 1
			if (powers[alivePowers[x]] and powers[alivePowers[x]].myName == "enemyPower") then
				powers[alivePowers[x]]:removeSelf()
				enemyShootCount=enemyShootCount-1
			end
		end
		timer.performWithDelay(powerLife, delete)
		end
	end
	return power
end
