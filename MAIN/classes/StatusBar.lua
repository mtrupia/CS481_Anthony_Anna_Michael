-- Created File For StatusBar


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

function iniStatusBar(Player)
  statusBar = display.newGroup()

  -- HP BAR
  if (Player.myName == "player") then
	statusBar.HPB = display.newImage("images/EmptyBar.png", HPBx, HPBy)
  else
	statusBar.HPB = display.newImage("images/EmptyBar.png", HPBx-20, HPBy-40)
  end
  HPB = statusBar.HPB
  statusBar:insert(HPB)
  if (Player.myName == "player") then
	HPB:scale(.6,1)
  else
	HPB:scale(.18,.5)
  end
  
  -- Circle for Beginning of Health Bar
  if (Player.myName == "player") then
	b1=-32
	b2=15.8
	b3=6.2
  else
	b1=HPBx+460
	b2=HPBy+300
	print(b1)
	print(b2)
	print(" ")
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

  if (Player.myName == "player") then
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
		statusBar:insert(statusBar.key)
		statusBar.bomb:scale(0.5,0.5)
  end
  -- increase HP Bar
  function statusBar:iHPB ()
    Player.hp = Player.hp + 10
    if Player.hp < 0 then Player.hp = 0
    elseif Player.hp > 100 then Player.hp = 100 end

    --print("Function: statusBar:iHPB ran")
    if (Player.hp == 10) then
      HPB.begin.isVisible = true
    elseif (Player.hp == 20) then
      HPB.mid.isVisible = true
    elseif (Player.hp < 100) then
      HPB.mid.width = HPB.mid.width + 12
    elseif (Player.hp == 100) then
      HPB.begin.isVisible = true
      HPB.mid.isVisible = true
      HPB.mid.width = 103
      HPB.fin.isVisible = true
    end
  end
  -- decrease HP Bar
  function statusBar:dHPB()
    Player.hp = Player.hp - 10
    if Player.hp < 0 then Player.hp = 0
    elseif Player.hp > 100 then Player.hp = 100 end

    --print("Function: statusBar:dHPB ran")
    if (Player.hp == 0) then
      HPB.begin.isVisible = false
    elseif(Player.hp == 10) then
      HPB.mid.isVisible = false
    elseif (Player.hp == 90) then
      HPB.fin.isVisible = false
    elseif (Player.hp < 100) then
      HPB.mid.width = HPB.mid.width - 12
      HPB.fin.isVisible = false
    end
  end

  function statusBar:iMPB()
    Player.mana = Player.mana + 10
    if Player.mana < 0 then Player.mana = 0
    elseif Player.mana > 100 then Player.mana = 100 end

    --print("Function: statusBar:iMPB ran")
    if (Player.mana == 10) then
      MPB.begin.isVisible = true

    elseif (Player.mana == 20) then
      MPB.mid.isVisible = true
    elseif (Player.mana < 100) then
      MPB.mid.width = MPB.mid.width + 12
    elseif (Player.hp == 100) then
      MPB.begin.isVisible = true
      MPB.mid.isVisible = true
      MPB.mid.width = 103
      MPB.fin.isVisible = true
    end
  end

  function statusBar:dMPB()
    Player.mana = Player.mana - 10
    print("Player's Mana = " .. Player.mana)
    if Player.mana < 0 then Player.mana = 0
    elseif Player.mana > 100 then Player.mana = 100 end
    if (Player.mana == 0) then
      MPB.begin.isVisible = false
    elseif(Player.mana == 10) then
      MPB.mid.isVisible = false
    elseif (Player.mana == 90) then
      MPB.fin.isVisible = false
    elseif (Player.mana < 100) then
      MPB.mid.width = MPB.mid.width - 12
      MPB.fin.isVisible = false
    end
  end
  function statusBar:destroy()
    self:removeSelf()
  end
  return statusBar
end
