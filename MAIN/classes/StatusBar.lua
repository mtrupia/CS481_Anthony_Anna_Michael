module (..., package.seeall)
-- HEALTH BAR LOCATION
local HPBx =  display.contentWidth  - 460
local HPBy =  display.contentHeight - 300
-- MANA BAR LOCATION
local MPBx =  display.contentWidth  - 335
local MPBy =  display.contentHeight - 300
local options = {
  width = 60,
  height = 20,
  numFrames = 6
}

function iniStatusBar(player)
  statusBar = display.newGroup()
  statusBar.count = 1
  -- HP BAR
  if player.myName == "player" then
	  if (player.myName == "player") then
		statusBar.HPB = display.newImage("images/EmptyBar.png", HPBx, HPBy)
	  else
		statusBar.HPB = display.newImage("images/EmptyBar.png", HPBx-20, HPBy-40)
	  end
	  HPB = statusBar.HPB
	  statusBar:insert(HPB)
	  if (player.myName == "player") then
		HPB:scale(.6,1)
	  else
		HPB:scale(.18,.5)
	  end

	  -- Circle for Beginning of Health Bar
	  if (player.myName == "player") then
		b1=-32
		b2=15.8
		b3=6.2
	  else
		b1=HPBx+460
		b2=HPBy+300
		--print(b1)
		--print(b2)
		--print("")
		b3=50
	  end

	  HPB.begin = display.newCircle(b1,b2,b3)
	  statusBar:insert(HPB.begin)
	  HPB.begin:setFillColor(1,0,0)
	  HPB.begin.isVisible = false

	  -- Middle of Health Bar
	  m1=-31
	  m2=16
	  m3=10
	  m4=12

	  HPB.mid = display.newRect(m1,m2,m3,m4)
	  statusBar:insert(HPB.mid)
	  HPB.mid:setFillColor(1,0,0)
	  HPB.mid.isVisible = false
	  HPB.mid.anchorX = 0
	  HPB.mid.anchorY = 0.5

	  -- Circle for End Of Health Bar
	  e1=73
	  e2=15.8
	  e3=6

	  HPB.fin   = display.newCircle(e1,e2,e3)
	  statusBar:insert(HPB.fin)
	  HPB.fin:setFillColor(1,0,0)
	  HPB.fin.isVisible = false
	  HPB:toFront()
	end

  if (player.myName == "player") then
		-- MANA BAR
		statusBar.MPB = display.newImage("images/EmptyBar.png", MPBx, MPBy)
		MPB = statusBar.MPB
		MPB:scale(.6,1)
		statusBar:insert(MPB)
		-- Circle for Beginning of Mana Bar
		MPB.begin = display.newCircle(93,15.8,6.2)
		statusBar:insert(MPB.begin)
		MPB.begin:setFillColor(0,0,1)
		MPB.begin.isVisible = false
		-- Middle of Mana Bar
		MPB.mid   = display.newRect(94,16,10,12)
		statusBar:insert(MPB.mid)
		MPB.mid:setFillColor(0,0,1)
		MPB.mid.isVisible = false
		MPB.mid.anchorX = 0
		MPB.mid.anchorY = 0.5
		-- Circle for End Of Mana Bar
		MPB.fin   = display.newCircle(198,15.8,6)
		statusBar:insert(MPB.fin)
		MPB.fin:setFillColor(0,0,1)
		MPB.fin.isVisible = false
		MPB:toFront()
	  -- KEY
	  statusBar.key = display.newImage("images/Key.png", 220, 15)
	  statusBar:insert(statusBar.key)
	  statusBar.key:scale(0.5,0.5)
	  statusBar.key.isVisible = false

	  -- BOMB
	  statusBar.bomb = display.newImage("images/Bomb.png", 420, 15)
	  statusBar:insert(statusBar.bomb)
	  statusBar.bomb:scale(0.5,0.5)
	  statusBar.bomb.count = display.newText("x" .. statusBar.count, 420,15)
	  statusBar:insert(statusBar.bomb.count)
  end

  -- increase HP Bar
  function statusBar:iHPB (player)
    player.hp = player.hp + 10
    if player.hp < 0 then player.hp = 0
    elseif player.hp > 100 then player.hp = 100 end

    --print("Function: statusBar:iHPB ran")
    if (player.hp == 10) then
      HPB.begin.isVisible = true
    elseif (player.hp == 20) then
      HPB.mid.isVisible = true
    elseif (player.hp < 100) then
      HPB.mid.width = HPB.mid.width + 12
    elseif (player.hp == 100) then
      HPB.begin.isVisible = true
      HPB.mid.isVisible = true
      HPB.mid.width = 103
      HPB.fin.isVisible = true
    end
  end
  -- decrease HP Bar
  function statusBar:dHPB(player)
    player.hp = player.hp - 10
    if player.hp < 0 then player.hp = 0
    elseif player.hp > 100 then player.hp = 100 end

    --print("Function: statusBar:dHPB ran")
    if (player.hp == 0) then
      HPB.begin.isVisible = false
    elseif(player.hp == 10) then
      HPB.mid.isVisible = false
    elseif (player.hp == 90) then
      HPB.fin.isVisible = false
    elseif (player.hp < 100) then
      HPB.mid.width = HPB.mid.width - 12
      HPB.fin.isVisible = false
    end
  end

  function statusBar:iMPB(player)
    player.mana = player.mana + 10
    if player.mana < 0 then player.mana = 0
    elseif player.mana > 100 then player.mana = 100 end

    --print("Function: statusBar:iMPB ran")
    if (player.mana == 10) then
      MPB.begin.isVisible = true

    elseif (player.mana == 20) then
      MPB.mid.isVisible = true
    elseif (player.mana < 100) then
      MPB.mid.width = MPB.mid.width + 12
    elseif (player.hp == 100) then
      MPB.begin.isVisible = true
      MPB.mid.isVisible = true
      MPB.mid.width = 103
      MPB.fin.isVisible = true
    end
  end

  function statusBar:dMPB(player)
    player.mana = player.mana - 10
    if player.mana < 0 then player.mana = 0
    elseif player.mana > 100 then player.mana = 100 end
    if (player.mana == 0) then
      MPB.begin.isVisible = false
    elseif(player.mana == 10) then
      MPB.mid.isVisible = false
    elseif (player.mana == 90) then
      MPB.fin.isVisible = false
    elseif (player.mana < 100) then
      MPB.mid.width = MPB.mid.width - 12
      MPB.fin.isVisible = false
    end
  end
  function statusBar:destroy()
	self:removeSelf()
  end
  return statusBar
end
