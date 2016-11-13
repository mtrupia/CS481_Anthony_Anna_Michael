module (..., package.seeall)

-- Powers
local powerImage
local powers = {}
local n = 0
local alivePowers = {}
local x = 0
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
	powerLife 		= props.life or 1000
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
	
	function power:Shield()
		if player.mana > 20 and not player.hasShield then
			player.statusBar:setMana(player, -20)
			player.hasShield = true
			player.Shield = display.newCircle( 0, 5, 40)
			player.Shield:setFillColor(1, 1, 0)
			player.Shield.alpha = 0.2
			player:insert(player.Shield)
		end
	end

	function Shoot (event)
		if "began" == event.phase and player.mana > 0 and event.target == tTarget then
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
			player.statusBar:setMana(player, -10)
			
			if player.hasShield and player.mana <= 0 then
				player.hasShield = false
				player:remove(player.Shield)
			end
			
			function delete()
				x = x + 1
				if (powers[alivePowers[x]]) then
					powers[alivePowers[x]]:removeSelf()
				end
			end
			timer.performWithDelay(powerLife, delete)
			tTarget = nil
		end
	end

	return power
end
