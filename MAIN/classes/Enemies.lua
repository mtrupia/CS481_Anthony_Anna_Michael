local class = require 'libs.middleclass'
require 'classes.Bars'
local obj
local player

local enemyShootCount = 0
local enemyShootMax = 1
local epowers = {}
local n=0
local x=0
local ealivePowers = {}

-- Enemy
local enemySpriteOptions = {
	width = 29,
	height = 36,
	numFrames = 8
}
local enemySpriteSheet = graphics.newImageSheet("images/enemySprite.png", enemySpriteOptions)
local enemySpriteData = {
	{ name = "walk", start = 1, count = 8, time = 1000, loopCount = 1 }
}

local function damageEnemy(e, p)
	if e.hasShield then
		-- enemies with shields
		if e.name == "enemy" then
			e.hasShield = false
			e:remove(e.Shield)
		else
			e.statusBar:setMana(-10)
			if e.mana <= 0 then
				e.hasShield = false
				e:remove(e.Shield)
			end
		end
	else
		if e.name == "Enemy" then
			-- damage enemy
			e.statusBar:setHealth(p.damage)
			local spell = p.spell
			if spell == 'fireball' then
				useFireball(e)
			elseif spell == 'iceball' then
				useIceball(e)
			end
		else
			e.statusBar:setHealth(-10)
		end
	end
	-- check if dead
	isDead(e)
end
-- check if enemy is dead
function isDead(e)
	if e.health <= 0 then
		player.sprite.score = e.score + player.sprite.score
		if e.statusBar then
			e.statusBar:destroy()
			e.statusBar = nil
		end
		if e then
			display.remove(e)
		end
		e = nil
	else
		--allow att
		function allowAtt()
			e.attReady = true
		end
		timer.performWithDelay(100, allowAtt, 1)
	end
end
function FireOff(e)
	e.onFire = false
end
-- fireball dot lasts 3 secs
function useFireball(e)
	e.onFire = true
	function dot()
		if e then
			if e.statusBar then
				e.statusBar:setHealth(-10)
				isDead(e)
			end
		end
	end
	timer.performWithDelay(500, dot, 3)
	timer.performWithDelay(1500, function()
	FireOff(e)
end, 1)
end
function useIceball(e)
	local speed = e.speed
	e.speed = e.speed/3
	e.onIce = true
	assert(e.onIce == true) -- REMOVE FROM HERE EVENTUALLY
	function slow()
		e.speed = speed
		e.onIce = false
	end
	timer.performWithDelay(3000, slow)
end

Enemy = class('Enemy')
function Enemy:initialize(x,y)
	self.x = x
	self.y = y
	self.dmgReady = true
	self.attReady = true
	self.visible = false
	self.onFire = false
	self.onIce = false

end

function Enemy:visibility(player)
	local ready = false
	local x1 = self.sprite.x
	local y1 = self.sprite.y
	local x2 = player.sprite.x
	local y2 = player.sprite.y

	if math.sqrt(math.power((x2-x1),2)+math.pow((y2-y1),2)) < 400 then
		ready = true
	end
	if ready then
		self.sprite.visible = true
	else
		self.sprite.visible = false
	end
end

function Enemy:spawn()
	self.sprite = display.newGroup()
	enemySprite = display.newSprite(self.sprite, enemySpriteSheet, enemySpriteData)
	self.sprite.x = self.x
	self.sprite.y = self.y
	self.sprite.health = self.health
	self.sprite.damage = self.damage
	self.sprite.speed  = self.speed
	self.sprite.maxHealth = self.health
	self.sprite.dmgReady = true
	self.sprite.name = "Enemy"
	self.sprite.score = 100
	self.sprite[1]:setSequence("walk")
	self.sprite[1]:play()
	self.sprite.isFixedRotation = true
	self.sprite.onFire = self.onFire
	self.sprite.onIce = self.onIce
	physics.addBody(self.sprite, {filter = enemyCollisionFilter})
	self.sprite.statusBar = eBar:new({target = self.sprite})
	self.sprite.statusBar:show()
	obj = self
	self:setup()
	self.sprite:addEventListener("collision")
	return self.sprite
end

function Enemy:Damage(dmg)
	if self.sprite.health > 0 then
		self.sprite.statusBar:setHealth(dmg)
	end
	if self.sprite.health <= 0 then

		self:kill()
	else
		function allowAtt()
			self.attReady = true
		end
		timer.performWithDelay(100, allowAtt, 1)
	end
end

function Enemy:kill()

	if self.sprite then
		if self.sprite.statusBar then
			display.remove(self.sprite.statusBar.sprite)
			self.sprite.statusBar = nil
		end
		display.remove(self.sprite)
	end
end

-- Chaser
Chaser = class('Chaser', Enemy)
function Chaser:initialize(x,y, Player)
	self.speed = 1.5
	self.damage = 10
	self.health = 100
	self.name = "Enemy"
	player = Player
	Enemy:initialize(x, y)

	return Chaser.spawn(self)
end


function Chaser:setup()
	self.sprite.collision = function(self, event)
		Chaser.collision(self,event)
	end
end
function Chaser.collision(self, event)
	if event then
		if event.other.name == "power" then
			damageEnemy(self, event.other)

		end
	end
end

function Chaser:move()
	if self.sprite.x and self.sprite.y then
		if self.sprite.x > player.sprite.x then
			self.sprite.xScale = 1
			self.sprite[1]:play()
		elseif self.sprite.x < player.sprite.x then
			self.sprite.xScale = -1
			self.sprite[1]:play()
		end

		self.sprite.rotation = 0

		local hyp = math.sqrt((player.sprite.x - self.sprite.x)^2 + (player.sprite.y - self.sprite.y)^2)
		if self.sprite.statusBar then
			self.sprite.statusBar.x = self.sprite.x
			self.sprite.statusBar.y = self.sprite.y - 10
		end
		self.sprite.x = self.sprite.x + ((player.sprite.x-self.sprite.x)/hyp)*self.sprite.speed
		self.sprite.y = self.sprite.y + ((player.sprite.y-self.sprite.y)/hyp)*self.sprite.speed
	end
end

-- Ranger
Ranger = class('Ranger', Enemy)
function Ranger:initialize(x,y,Player)
	self.speed = 1.25
	self.damage = 20
	self.health = 50
	self.name = "Enemy"
	player = Player
	Enemy:initialize(x, y)
	return Ranger.spawn(self)
end

function Ranger:setup()
	self.sprite.collision = function(self, event)
		Ranger.collision(self,event)
	end
end

function Ranger.collision(self, event)
	if event then
		if event.other.name == "power" then
			damageEnemy(self, event.other)

		end
	end
end

function Ranger:move()
	if self.sprite.x and self.sprite.y then
		if self.sprite.x > player.sprite.x then
			self.sprite.xScale = 1
			self.sprite[1]:play()
		elseif self.sprite.x < player.sprite.x then
			self.sprite.xScale = -1
			self.sprite[1]:play()
		end

		self.sprite.rotation = 0
		local hyp = math.sqrt((player.sprite.x - self.sprite.x)^2 + (player.sprite.y - self.sprite.y)^2)
		local dist = 150
		if self.sprite.statusBar then
			self.sprite.statusBar.x = self.sprite.x
			self.sprite.statusBar.y = self.sprite.y - 10
		end
		if (hyp >= dist) then
			-- approach player
			self.sprite.x = self.sprite.x + ((player.sprite.x-self.sprite.x)/hyp)*self.sprite.speed
			self.sprite.y = self.sprite.y + ((player.sprite.y-self.sprite.y)/hyp)*self.sprite.speed
		else
			-- move away from player
			self.sprite.x = self.sprite.x - ((player.sprite.x-self.sprite.x)/hyp)*self.sprite.speed
			self.sprite.y = self.sprite.y - ((player.sprite.y-self.sprite.y)/hyp)*self.sprite.speed
		
			if enemyShootCount < enemyShootMax then
				enemyShootCount=enemyShootCount + 1
 		
				n = n + 1
				epowers[n] = display.newImage("images/brick.png", self.sprite.x, self.sprite.y)
				physics.addBody( epowers[n], { density=0.0000001, friction=0.00000001, bounce=0.00000001, filter=enemyPowerCollisionFilter } )		      
 		
				local edeltaX=player.sprite.x - self.sprite.x
				local edeltaY=player.sprite.y - self.sprite.y
				local enormDeltaX = edeltaX / math.sqrt(math.pow(edeltaX,2) + math.pow(edeltaY,2))
				local enormDeltaY = edeltaY / math.sqrt(math.pow(edeltaX,2) + math.pow(edeltaY,2))
				
				epowers[n]:setLinearVelocity( enormDeltaX * 200, enormDeltaY * 200 )
				ealivePowers[n] = n
  		  
				function delete()
					x = x + 1
					if (epowers[ealivePowers[x]]) then
						epowers[ealivePowers[x]]:removeSelf()
						enemyShootCount=enemyShootCount-1
					end
				end
				timer.performWithDelay(500, delete)
			end	
		
		end
	end
end

--  Trapper
Trapper = class('Trapper', Enemy)
function Trapper:initialize(x,y, Player)
	self.speed = 1.2
	self.damage = 10
	self.health = 50
	self.name = "Enemy"
	player = Player
	Enemy:initialize(x, y)
	return Trapper.spawn(self)
end

function Trapper:setup()
	self.sprite.collision = function(self, event)
		Trapper.collision(self,event)
	end
end
function Trapper.collision(self, event)
	if event then
		if event.other.name == "power" then
			damageEnemy(self, event.other)

		end
	end
end

function Trapper:move()
	if self.sprite.x and self.sprite.y then
		if self.sprite.x > player.sprite.x then
			self.sprite.xScale = 1
			self.sprite[1]:play()
		elseif self.sprite.x < player.sprite.x then
			self.sprite.xScale = -1
			self.sprite[1]:play()
		end

		self.sprite.rotation = 0
		local hyp 	= math.sqrt((player.sprite.x - self.sprite.x)^2 + (player.sprite.y - self.sprite.y)^2)
		local dist 	= 150
		if self.sprite.statusBar then
			self.sprite.statusBar.x = self.sprite.x
			self.sprite.statusBar.y = self.sprite.y - 10
		end
		if (hyp >= dist) then
			-- approach player
			self.sprite.x = self.sprite.x + ((player.sprite.x-self.sprite.x)/hyp)*self.sprite.speed
			self.sprite.y = self.sprite.y + ((player.sprite.y-self.sprite.y)/hyp)*self.sprite.speed
		else
			-- set trap

			-- move away from player
			self.sprite.x = self.sprite.x + ((player.sprite.x-self.sprite.x)/hyp)*self.sprite.speed
			self.sprite.y = self.sprite.y + ((player.sprite.y-self.sprite.y)/hyp)*self.sprite.speed
		end
	end
end

-- tank
Tank = class('Tank', Enemy)
function Tank:initialize(x,y, Player)
	self.speed = 1
	self.damage = 10
	self.health = 100
	self.name = "Enemy"
	player = Player
	Enemy:initialize(x, y)
	return Tank.spawn(self)
end

function Tank:setup()
	self.sprite.collision = function(self, event)
		Tank.collision(self,event)
	end
end

function Tank.collision(self, event)
	if event then
		if event.other.name == "power" then
			damageEnemy(self, event.other)

		end
	end
end

function Tank:move()
	if self.sprite.x and self.sprite.y then
		if self.sprite.x > player.sprite.x then
			self.sprite.xScale = 1
			self.sprite[1]:play()
		elseif self.sprite.x < player.sprite.x then
			self.sprite.xScale = -1
			self.sprite[1]:play()
		end

		self.sprite.rotation = 0
		local hyp = math.sqrt((player.sprite.x - self.sprite.x)^2 + (player.sprite.y - self.sprite.y)^2)
		if self.sprite.statusBar then
			self.sprite.statusBar.x = self.sprite.x
			self.sprite.statusBar.y = self.sprite.y - 10
		end
		self.sprite.x = self.sprite.x + ((player.sprite.x-self.sprite.x)/hyp)*self.sprite.speed
		self.sprite.y = self.sprite.y + ((player.sprite.y-self.sprite.y)/hyp)*self.sprite.speed
	end
end
