module (..., package.seeall)

local playerCollisionFilter = { categoryBits = 2, maskBits = 1 }

local PowerClass = require("Power")
playerImage = "flower.png"

function NewPlayer ( props )
	local player	= display.newGroup()
	player.x		= props.x
	player.y		= props.y
	player.health 	= props.health
	player.mana		= props.mana
	player.score	= props.score
	player.speed	= props.speed
	player.bg		= props.bg
	
	function player:spawnPlayer()
		player.person = display.newImage(playerImage)
		player:insert(player.person)
		physics.addBody(player, {filter = playerCollisionFilter})
		-- Power
		Power = PowerClass.NewPower( player )
		Power:begin(player.bg)
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
	
	function player:move( joystick )
		if (player[1] and joystick) then
			joystick:move(player, player.speed, false)
			player.rotation = 0
		end
	end
	
	return player
end