local class = require 'libs.middleclass'
require 'classes.Bars'
local obj
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

local player
Enemy = class('Enemy')
function Enemy:initialize(x,y)
	self.x = x
	self.y = y
	self.dmgReady = true
	self.attReady = true
	self.visible = false
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
	self.speed = 1
	self.damage = 10
	self.health = 100
	self.name = "Chaser"
	player = Player
	Enemy:initialize(x, y)

	return Chaser.spawn(self)
end

function Chaser.spawn(self)
	local pot = self
	pot.sprite = display.newSprite(enemySpriteSheet, enemySpriteData)
	pot.sprite.x = self.x
	pot.sprite.y = self.y
	pot.sprite.health = self.health
	pot.sprite:setSequence("walk")
	pot.sprite:play()
	pot.sprite.isFixedRotation = true
	physics.addBody(pot.sprite, {filter = enemyCollisionFilter})
	pot.sprite.statusBar = eBar:new({target = self.sprite})
	pot.sprite.statusBar:show()
	obj = self
	pot.sprite.collision = function(self, event)
		Chaser.collision(pot,event)
	end
	pot.sprite:addEventListener("collision", self.collision, self)
	return pot.sprite
end

function Chaser.collision()
	
end


function Chaser:move()
	if self.sprite.x and self.sprite.y then
		local hyp = math.sqrt((player.sprite.x - self.sprite.x)^2 + (player.sprite.y - self.sprite.y)^2)
		if self.statusBar then
			self.statusBar.x = self.sprite.x
			self.statusBar.y = self.sprite.y - 10
		end
		self.sprite.x = self.sprite.x + (player.sprite.x-self.sprite.x)/hyp
		self.sprite.y = self.sprite.y + (player.sprite.y-self.sprite.y)/hyp
	end
end

function Enemy:print()
	print("Print Function Called")
end

-- Ranger
Ranger = class('Ranger', Enemy)
function Ranger:initialize(x,y,Player)
	self.speed = 0.55
	self.damage = 20
	self.health = 50
	self.name = "Ranger"
	player = Player
	Enemy:initialize(x, y)
	return Ranger.spawn(self)
end

function Ranger:spawn()
	self.sprite = display.newSprite(enemySpriteSheet, enemySpriteData)
	self.sprite.x = self.x
	self.sprite.y = self.y
	self.sprite:setSequence("walk")
	self.sprite:play()
	self.sprite.isFixedRotation = true
	physics.addBody(self.sprite, {filter = enemyCollisionFilter})
	--self.power = Ability.new({target = self.sprite, bounce = 0, friction = 0, density = 0, life = 600})
	self.statusBar = Bar.new({target = self.sprite})
	self.statusBar:show()
	self.sprite.collision = function(self, event)
		Ranger.collision(self,event)
	end
	self.sprite:addEventListener("collision")
end

function Ranger.collision(self, event)
	if event.other.name == "power" then
		audio.play(HitSound)
		if self.attReady then
			self.attReady = false
			Enemy.damage(self)
		end
	end
end

function Ranger:move()
	local hyp = math.sqrt((player.sprite.x - self.sprite.x)^2 + (player.sprite.y - self.sprite.y)^2)
	local dist = 200
	if self.statusBar then
		self.statusBar.x = self.sprite.x
		self.statusBar.y = self.sprite.y - 10
	end
	if (hyp >= dist) then
		-- approach player
		self.sprite.x = self.sprite.x + (player.sprite.x-self.sprite.x)/hyp
		self.sprite.y = self.sprite.y + (player.sprite.y-self.sprite.y)/hyp
	else
		-- move away from player
		self.sprite.x = self.sprite.x - (player.sprite.x-self.sprite.x)/hyp
		self.sprite.y = self.sprite.y - (player.sprite.y-self.sprite.y)/hyp
	end
end

--  Trapper
Trapper = class('Trapper', Enemy)
function Trapper:initialize(x,y, Player)
	self.speed = 0.5
	self.damage = 10
	self.health = 75
	self.name = "Trapper"
	player = Player
	Enemy:initialize(x, y)
	return Trapper.spawn(self)
end

function Trapper:spawn()
	self.sprite = display.newSprite(enemySpriteSheet, enemySpriteData)
	self.sprite.x = self.x
	self.sprite.y = self.y
	self.sprite:setSequence("walk")
	self.sprite:play()
	self.sprite.isFixedRotation = true
	physics.addBody(self.sprite, {filter = enemyCollisionFilter})
	self.statusBar = BarLib.new({target = self.sprite})
	self.statusBar:show()
	self.sprite.collision = function(self, event)
		Trapper.collision(self,event)
	end
	self.sprite:addEventListener("collision")
end

function Trapper.collision(self, event)
	if event.other.name == "power" then
		audio.play(HitSound)
		if self.attReady then
			self.attReady = false
			Enemy.damage(self)
		end
	end
end

function Trapper:move()
	local hyp 	= math.sqrt((player.sprite.x - self.sprite.x)^2 + (player.sprite.y - self.sprite.y)^2)
	local dist 	= 200
	if self.statusBar then
		self.statusBar.x = self.sprite.x
		self.statusBar.y = self.sprite.y - 10
	end
	if (hyp >= dist) then
		-- approach player
		self.sprite.x = self.sprite.x + (player.sprite.x-self.sprite.x)/hyp
		self.sprite.y = self.sprite.y + (player.sprite.y-self.sprite.y)/hyp
	else
		-- set trap

		-- move away from player
		self.sprite.x = self.sprite.x - (player.sprite.x-self.sprite.x)/hyp
		self.sprite.y = self.sprite.y - (player.sprite.y-self.sprite.y)/hyp
	end
end

-- tank
Tank = class('Tank', Enemy)
function Tank:initialize(x,y, Player)
	self.speed = 0.25
	self.damage = 10
	self.health = 100
	self.name = "Tank"
	player = Player
	Enemy:initialize(x, y)
	return Tank.spawn(self)
end

function Tank.collision(self, event)
	if event.other.name == "power" then
		audio.play(HitSound)
		if self.attReady then
			self.attReady = false
			Enemy.damage(self)
		end
	end
end

function Tank:spawn()
	self.sprite = display.newSprite(enemySpriteSheet, enemySpriteData)
	self.sprite.x = self.x
	self.sprite.y = self.y
	self.sprite:setSequence("walk")
	self.sprite:play()
	self.sprite.isFixedRotation = true
	physics.addBody(self.sprite, {filter = enemyCollisionFilter})
	self.statusBar = BarLib.new({target = self.sprite})
	self.statusBar:show()
	self.sprite.collision = function(self, event)
		Tank.collision(self,event)
	end
	self.sprite:addEventListener("collision")
end

function Tank:move()
	local hyp = math.sqrt((player.sprite.x - self.sprite.x)^2 + (player.sprite.y - self.sprite.y)^2)
	if self.statusBar then
		self.statusBar.x = self.sprite.x
		self.statusBar.y = self.sprite.y - 10
	end
	self.sprite.x = self.sprite.x + (player.sprite.x-self.sprite.x)/hyp
	self.sprite.y = self.sprite.y + (player.sprite.y-self.sprite.y)/hyp
end
