-------------------------------------------------
--
-- npc.lua
--
-- Controls player and enemy 
--
-------------------------------------------------

local npc = {}
local npc_mt = { __index = npc }	-- metatable

-------------------------------------------------
-- PRIVATE FUNCTIONS
-------------------------------------------------
-- sounds
local HitSound = audio.loadSound("sounds/Hit.wav")

-- sprites
local playerSpriteOptions = {
	height = 64,
	width = 64,
	numFrames = 273
}
local playerSpriteSheet = graphics.newImageSheet("images/playerSprite.png", playerSpriteOptions)
local playerSpriteData = {
	{name = "forward", 			frames={105,106,107,108,109,110,111,112}, 		time = 500, loopCount = 1},
	{name = "right", 			frames={144,145,146,147,148,149,150,151,152}, 	time = 500, loopCount = 1},
	{name = "back", 			frames={131,132,133,134,135,136,137,138,139}, 	time = 500, loopCount = 1},
	{name = "left", 			frames={118,119,120,121,122,123,124,125,126}, 	time = 500, loopCount = 1},
	{name = "attackForward", 	frames={157,158,159,160,161,162,157}, 			time = 400, loopCount = 1},
	{name = "attackRight", 		frames={196,197,198,199,200,201,196}, 			time = 400, loopCount = 1},
	{name = "attackBack", 		frames={183,184,185,186,187,188,183}, 			time = 400, loopCount = 1},
	{name = "attackLeft", 		frames={170,171,172,173,174,175,170}, 			time = 400, loopCount = 1},
	{name = "death", 			frames={261,262,263,264,265,266}, 				time = 500, loopCount = 1}
}

local enemySpriteOptions = {
	width = 29,
	height = 36,
	numFrames = 8
}
local enemySpriteSheet = graphics.newImageSheet("images/enemySprite.png", enemySpriteOptions)
local enemySpriteData = {
	{ name = "walk", start = 1, count = 8, time = 1000, loopCount = 1 }
}

-------------------------------------------------
-- set enemy stats base on enemy type
local function setEnemyStats( e )
	t = e.enemyType
	if t == "tank" then
		e.speed		= 0.25
		e.damage	= 10
		e.hp		= 100
	elseif t == "ranger" then
		e.speed		= 0.55
		e.damage	= 20
		e.hp		= 50
	elseif t == "trapper" then
		e.speed		= 0.5
		e.damage	= 10
		e.hp		= 75
	elseif t == "chaser" then
		e.speed		= 1
		e.damage	= 10
		e.hp		= 100
	end
end

-------------------------------------------------
-- check if player is visible for an enemy
local function visibility( self, p )
	local ready = false
	
	x1 = self.sprite.x
	y1 = self.sprite.y
	
	x2 = p.sprite.x
	y2 = p.sprite.y
	
	if math.sqrt(math.pow((x2-x1),2)+math.pow((y2-y1),2)) < 400 then
		ready = true
	end
	
	if ready then
		self.sprite.visible = true
	else
		self.sprite.visible = false
	end
end

-------------------------------------------------
-- move enemy base on enemy type
local function enemyMove( self, p )
	hyp = math.sqrt((p.sprite.x - self.sprite.x)^2 + (p.sprite.y - self.sprite.y)^2)
	dist = 200
	
	if self.sprite.statusBar then
		self.sprite.statusBar.x = self.sprite.x
		self.sprite.statusBar.y = self.sprite.y - 10
	end

	if self.enemyType == "chaser" then
		self.sprite.x = self.sprite.x + (p.sprite.x-self.sprite.x)/hyp
		self.sprite.y = self.sprite.y + (p.sprite.y-self.sprite.y)/hyp
	elseif self.enemyType == "ranger" then
		if (hyp >= dist) then
			-- approach player
			self.sprite.x = self.sprite.x + (p.sprite.x-self.sprite.x)/hyp
			self.sprite.y = self.sprite.y + (p.sprite.y-self.sprite.y)/hyp
		else
			-- move away from player
			self.sprite.x = self.sprite.x - (p.sprite.x-self.sprite.x)/hyp
			self.sprite.y = self.sprite.y - (p.sprite.y-self.sprite.y)/hyp
		end
	elseif self.enemyType == "trapper" then
		if (hyp >= dist) then
			-- approach player
			self.sprite.x = self.sprite.x + (p.sprite.x-self.sprite.x)/hyp
			self.sprite.y = self.sprite.y + (p.sprite.y-self.sprite.y)/hyp
		else
			-- set trap
		
			-- move away from player
			self.sprite.x = self.sprite.x - (p.sprite.x-self.sprite.x)/hyp
			self.sprite.y = self.sprite.y - (p.sprite.y-self.sprite.y)/hyp
		end
	elseif self.enemyType == "tank" then
		self.sprite.x = self.sprite.x + (p.sprite.x-self.sprite.x)/hyp
		self.sprite.y = self.sprite.y + (p.sprite.y-self.sprite.y)/hyp
	end
end

-------------------------------------------------
-- damage the player base on enemy attack dmg
local function damagePlayer(p, e)
	if p.hasShield then
		p.statusBar:setMana(-e.damage)
		if p.mana <= 0 then
			p.hasShield = false
			p:remove(p.Shield)
		end
	else
		p.statusBar:setHealth(-e.damage)
	end
	
	e.dmgReady = false
	function allowDmg()
		e.dmgReady = true
	end
	timer.performWithDelay(250, allowDmg, 1)
end

-------------------------------------------------
-- damage the enemy base on power dmg
local function damageEnemy(e, p)
	if e.hasShield then
		-- enemies with shields
	else
		if e.name == "enemy" then
			-- damage enemy
			e.statusBar:setHealth(-100)
		else
			e.statusBar:setHealth(-10)
		end
	end
	-- check if dead
	if e.health <= 0 then
		e.statusBar:destroy()
		e:removeSelf()
		e = nil
	else
		--allow att
		function allowAtt()
			e.attReady = true
		end
		timer.performWithDelay(100, allowAtt, 1)
	end
end

-------------------------------------------------
-- enemy collision with player and powers
local function onGlobalCollision(event)
	local o1 = event.object1
	local o2 = event.object2
	-- if power hits enemy, damage it :/ 
	if (o1.name == "enemy" or o2.name == "enemy") and (o1.name == "power" or o2.name == "power") then
		audio.play(HitSound)
		if o1.name == "power" then
			if o2.attReady then
				o2.attReady = false
				damageEnemy( o2, o1 )
			end
		else
			if o1.attReady then
				o1.attReady = false
				damageEnemy ( o1, o2 )
			end
		end
	elseif (o1.name == "enemy" or o2.name =="enemy") and (o1.name == "player" or o2.name == "player") and (o1.dmgReady or o2.dmgReady) then
		if o1.name == "player" then
			damagePlayer(o1, o2)
		else
			damagePlayer(o2,o1)
		end
	elseif (o1.name == "player" or o2.name == "player") and (o1.name == "enemypower" or o2.name == "enemypower") then
		audio.play(HitSound)
		if o1.name == "player" then
			if o1.attReady then
				o1.attReady = false
				damageEnemy( o1, o2 )
			end
		else
			if o2.attReady then
				o2.attReady = false
				damageEnemy( o2, o1)
			end
		end
	end
end

-------------------------------------------------
-- PUBLIC FUNCTIONS
-------------------------------------------------
-- create new npc (player or enemy)
function npc.new( type, props )	
		
	local newNpc
	
	if type == "player" then
		newNpc = {
			x			= props.x or halfW,
			y 			= props.y or halfH,
			angle		= props.angle or 0,
			health 		= props.health or 100,
			mana		= props.mana or 100,
			score		= props.score or 0,
			name		= props.name or "player",
			hasShield	= props.hasShield or false,
			dmgReady	= props.dmgReady or false,
			speed		= props.speed or 3,
			attReady	= props.attReady or true,
			power		= props.power,
			items		= props.items,
			sprite		= props.sprite
		}
	else -- enemy
		newNpc = {
			x			= props.x or halfW,
			y 			= props.y or halfH,
			health 		= props.health or 100,
			name		= props.name or "enemy",
			hasShield	= props.hasShield or false,
			dmgReady	= props.dmgReady or true,
			attReady	= props.attReady or true,
			visible		= props.visible or false,
			index		= props.index or 0,
			enemyType	= props.enemyType or "chaser",
			damage		= props.damage or 10,
			speed		= props.speed or 1,
			shootReady	= props.shootReady or true,
			power		= props.power,
			sprite		= props.sprite
		}
		
		setEnemyStats( newNpc )
	end
	
	return setmetatable( newNpc, npc_mt )
end

-------------------------------------------------
-- spawn npc
function npc:spawn()
	if self.sprite then
		if self.name == "player" then
			playerSprite = display.newSprite(self.sprite, playerSpriteSheet, playerSpriteData)
			playerSprite:setSequence("forward")
			physics.addBody(self.sprite, {filter = playerCollisionFilter} )
			
			-- let the player have status bars
			self.sprite.statusBar = BarLib.new({target = self.sprite})
			self.sprite.statusBar:show()
			
			-- let the player have powers!
			self.power = AbilityLib.new({target = self.sprite})
			local function Shoot(event)
				if self.power then
					self.power:Shoot(event)
				end
			end
			Runtime:addEventListener("touch", Shoot)
		else
			enemySprite = display.newSprite(self.sprite, enemySpriteSheet, enemySpriteData)
			enemySprite:setSequence("walk")
			enemySprite:play()
			enemySprite.isFixedRotation = true
			physics.addBody(self.sprite, {filter = enemyCollisionFilter} )
			
			-- let only rangers have powers!
			if self.enemyType == "ranger" then
				self.power = AbilityLib.new({target = self.sprite, bounce = 0, friction = 0, density = 0, life = 600})
			end
			
			-- let the enemy have status bars
			self.sprite.statusBar = BarLib.new({target = self.sprite})
			self.sprite.statusBar:show()
			
			Runtime:addEventListener("collision", onGlobalCollision)
		end
	else
		self.sprite = display.newGroup()
		
		self.sprite.x 			= self.x
		self.sprite.y			= self.y
		self.sprite.name 		= self.name
		self.sprite.mana 		= self.mana
		self.sprite.hasShield 	= self.hasShield
		self.sprite.dmgReady 	= self.dmgReady
		self.sprite.damage		= self.damage
		self.sprite.health		= self.health
		self.sprite.angle		= self.angle
		self.sprite.speed		= self.speed
		self.sprite.attReady	= self.attReady
		self.sprite.shootReady	= self.shootReady
		
		self:spawn()
	end
end

-------------------------------------------------
-- use power
function npc:useAbility( type )
	if self.name == "player" then
		self.power:use(type)
	else
		print(self.enemyType .. " uses ability")
	end
end

-------------------------------------------------
-- damage player/enemy
function npc:attack( amt )
	self.health = self.health - amt
	if self.health <= 0 then
		self:kill()
	end
end

-------------------------------------------------
-- kill player/enemy
function npc:kill()
	if self.name == "player" then 
		if self.power then
			Runtime:removeEventListener("touch", Shoot)
			self.power = nil
		end
	end

	if self.sprite then
		if self.sprite.statusBar then
			self.sprite.statusBar:destroy()
			self.sprite.statusBar = nil
		end
		if self.sprite[1] then
			self.sprite:removeSelf()
			self.sprite = nil
		end
	end
end

-------------------------------------------------
-- kill player/enemy
function npc:destroy()
	self:kill()
end

-------------------------------------------------
-- move player base on joystick movements, or enemy base on player position and player visibility (obj = joystick or player)
function npc:move( obj )
	if self.name == "player" then
		if self.sprite and obj then
			obj:move(self.sprite, self.speed, false)
			self.sprite.rotation = 0
			
			self.sprite.angle = obj:getAngle()
			angle = self.sprite.angle
			moving = obj:getMoving()
			
			if angle <= 45 or angle > 315 then
				seq = "forward"
			elseif angle <= 135 and angle > 45 then
				seq = "right"
			elseif angle <= 225 and angle > 135 then
				seq = "back"
			elseif angle <= 315 and angle > 225 then
				seq = "left"
			end
			
			if (not (seq == self.sprite[1].sequence) and moving) then
				self.sprite[1]:setSequence(seq)
			end
			
			if moving then
				self.sprite[1]:play()
			end
		end
	else
		if self.sprite then
			if self.sprite[1] then
				visibility( self, obj )
				if self.sprite.visible then
					if self.sprite.x > obj.sprite.x then
						self.sprite[1].xScale = 1
						self.sprite[1]:play()
					elseif self.sprite.x < obj.sprite.x then
						self.sprite[1].xScale = -1
						self.sprite[1]:play()
					end 
					
					if self.sprite[1] and obj then
						self.sprite.rotation = 0
						
						if self.enemyType == "ranger" then
							if self.sprite.shootReady then
								self.power:Shoot(obj.sprite)
								self.sprite.shootReady = false
								function allowShoot()
									if self then
										if self.sprite then
											self.sprite.shootReady = true
										end
									end
								end
								timer.performWithDelay(2000, allowShoot, 1)
							end
						end
						
						enemyMove( self, obj )
					end
				end
			end
		end
	end
end

-------------------------------------------------

return npc