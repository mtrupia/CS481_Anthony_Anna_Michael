-------------------------------------------------
--
-- ability.lua
--
-- Controls all abilities of the play (NOT SPECIAL ITEMS EX: BOMBS)
--
-------------------------------------------------

local ability = {}
local ability_mt = { __index = ability }
-------------------------------------------------
-- PRIVATE FUNCTIONS
-------------------------------------------------
-- images
local image = "images/brick.png"

-- sounds
local ShootSound = audio.loadSound( "sounds/Shoot.wav" )
local PoofSound = audio.loadSound( "sounds/Poof.wav" )
-- controls creation and deletion of powers
local powers = {}
local n = 0
local alivePowers = {}
local x = 0

-------------------------------------------------
-- PUBLIC FUNCTIONS
-------------------------------------------------
--create new ability
function ability.new( props )
	local newAbility

	newAbility = {
		life		= props.life or 1000,			-- how long the power shall stay alive
		speed		= props.speed or 250,			-- how fast will this power move
		density		= props.density or 3,			-- density of this power
		friction 	= props.friction or 0.5,		-- friction of this power
		bounce 		= props.bounce or 1,			-- bounce of this power
		target		= props.target					-- target of the power
	}

	return setmetatable( newAbility, ability_mt )
end

-------------------------------------------------
-- use an ability base on the type
function ability:use(type)
	if type == "shield" then
		-- if shield, then use 20 mana and apply shield to target
		if self.target.mana > 0 and not self.target.hasShield then
			self.target.hasShield = true
			self.target.Shield = display.newCircle( self.target, 0, 5, 40 )
			self.target.Shield:setFillColor(1, 1, 0)
			self.target.Shield.alpha = 0.2
		end
	end
end

-------------------------------------------------
-- shoot the ability
function ability:Shoot(event)
	if "began" == event.phase and self.target.mana <= 0 and event.target == tTarget then
		audio.play( PoofSound )
	end
	if "began" == event.phase and self.target.mana > 0 and event.target == tTarget then
		audio.play( ShootSound )

		n = n + 1
		powers[n] = display.newImage(image, self.target.x, self.target.y)
		physics.addBody( powers[n], { density=self.density, friction=self.friction, bounce=self.bounce, filter=powerCollisionFilter } )
		powers[n].name = "power"
		deltaX = event.x - self.target.x
		deltaY = event.y - self.target.y
		normDeltaX = deltaX / math.sqrt(math.pow(deltaX,2) + math.pow(deltaY,2))
		normDeltaY = deltaY / math.sqrt(math.pow(deltaX,2) + math.pow(deltaY,2))
		powers[n]:setLinearVelocity( normDeltaX * self.speed, normDeltaY * self.speed )
		alivePowers[n] = n
		self.target.statusBar:setMana(-10)

		if self.target.hasShield and self.target.mana <= 0 then
			self.target.hasShield = false
			self.target:remove(self.target.Shield)
		end

		function delete()
			x = x + 1
			if (powers[alivePowers[x]]) then
				powers[alivePowers[x]]:removeSelf()
			end
		end
		timer.performWithDelay(self.life, delete)
		tTarget = nil
	elseif self.target.name == "enemy" then

		n = n + 1
		powers[n] = display.newImage(image, self.target.x, self.target.y)
		physics.addBody( powers[n], { density=0.0000000001, friction=self.friction, bounce=self.bounce, filter=enemyPowerCollisionFilter } )
		powers[n].name = "enemypower"
		deltaX = event.x - self.target.x
		deltaY = event.y - self.target.y
		normDeltaX = deltaX / math.sqrt(math.pow(deltaX,2) + math.pow(deltaY,2))
		normDeltaY = deltaY / math.sqrt(math.pow(deltaX,2) + math.pow(deltaY,2))
		powers[n]:setLinearVelocity( normDeltaX * self.speed, normDeltaY * self.speed )
		alivePowers[n] = n

		function delete()
			x = x + 1
			if (powers[alivePowers[x]]) then
				powers[alivePowers[x]]:removeSelf()
			end
		end
		timer.performWithDelay(self.life, delete)
	end
end
-------------------------------------------------

return ability
