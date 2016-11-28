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
			e.statusBar:setHealth(-50)
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

local player
Enemy = class('Enemy')
function Enemy:initialize(x,y)
	self.x = x
	self.y = y
	self.dmgReady = true
	self.attReady = true
	self.visible = false
end

function Enemy:visibility(self,player)
	local ready = true --check?
	local x1 = self.sprite.x - minX
	local y1 = self.sprite.y - minY
	local x2 = player.sprite.x - minX
	local y2 = player.sprite.y - minY
	
	local slope = (x2-x1)/(y2-y1)
	
	local inc = math.ceil(math.max(math.abs(x1-x2),math.abs(y1-y2))/20)
	
	if math.sqrt(math.pow((x2-x1),2)+math.pow((y2-y1),2)) < 400 then --in distance range
		print("~" .. inc .. "~" .. x2 .. " " .. y2 .. "~" .. x1 .. " " .. y1)
		for i=1, inc do
			local xcheck = math.floor(20 * i / math.sqrt(slope * slope + 1))
			local ycheck = math.floor(slope * xcheck)
			print(xcheck, ycheck)
			levelArr[xcheck][ycheck] =2
			if levelArr[xcheck-minX][ycheck-minY] == 1 then --blocked by wall	
				ready = false
			end
		end
		
		--loops to print level array
	
		local fpath = system.pathForFile('classes/help.txt', system.ResourceDirectory)
		local ffile = io.open(fpath, 'w')

		for i=0, maxX-minX do
			for j=0, maxY-minY do
				ffile:write(tostring(levelArr[i][j]) .. ' ')
			end
			ffile:write('\n')
		end
		ffile:write('\nstop\n')
		io.close(ffile)
		
		--end of testing code
	else
		ready = false
	end
	if ready then
		self.sprite.visible = true
		return true
	else
		self.sprite.visible = false
		return false
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
	self.sprite.dmgReady = true
	self.sprite.name = "Enemy"
	self.sprite[1]:setSequence("walk")
	self.sprite[1]:play()
	self.sprite.isFixedRotation = true
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
	self.speed = 1
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
	if self.sprite.x and self.sprite.y and Enemy:visibility(self,player) then
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
		self.sprite.x = self.sprite.x + (player.sprite.x-self.sprite.x)/hyp
		self.sprite.y = self.sprite.y + (player.sprite.y-self.sprite.y)/hyp
	end
end

-- Ranger
Ranger = class('Ranger', Enemy)
function Ranger:initialize(x,y,Player)
	self.speed = 0.55
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
	if self.sprite.x and self.sprite.y and Enemy:visibility(self,player) then
		if self.sprite.x > player.sprite.x then
			self.sprite.xScale = 1
			self.sprite[1]:play()
		elseif self.sprite.x < player.sprite.x then
			self.sprite.xScale = -1
			self.sprite[1]:play()
		end

		self.sprite.rotation = 0
		local hyp = math.sqrt((player.sprite.x - self.sprite.x)^2 + (player.sprite.y - self.sprite.y)^2)
		local dist = 200
		if self.sprite.statusBar then
			self.sprite.statusBar.x = self.sprite.x
			self.sprite.statusBar.y = self.sprite.y - 10
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
end

--  Trapper
Trapper = class('Trapper', Enemy)
function Trapper:initialize(x,y, Player)
	self.speed = 0.5
	self.damage = 10
	self.health = 75
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
	if self.sprite.x and self.sprite.y and Enemy:visibility(self,player) then
		if self.sprite.x > player.sprite.x then
			self.sprite.xScale = 1
			self.sprite[1]:play()
		elseif self.sprite.x < player.sprite.x then
			self.sprite.xScale = -1
			self.sprite[1]:play()
		end

		self.sprite.rotation = 0
		local hyp 	= math.sqrt((player.sprite.x - self.sprite.x)^2 + (player.sprite.y - self.sprite.y)^2)
		local dist 	= 200
		if self.sprite.statusBar then
			self.sprite.statusBar.x = self.sprite.x
			self.sprite.statusBar.y = self.sprite.y - 10
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
end

-- tank
Tank = class('Tank', Enemy)
function Tank:initialize(x,y, Player)
	self.speed = 0.25
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
		self.sprite.x = self.sprite.x + (player.sprite.x-self.sprite.x)/hyp
		self.sprite.y = self.sprite.y + (player.sprite.y-self.sprite.y)/hyp
	end
end