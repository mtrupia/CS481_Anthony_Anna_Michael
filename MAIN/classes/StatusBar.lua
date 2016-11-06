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
  statusBar.HPB = display.newImage("images/EmptyBar.png", HPBx, HPBy)
  HPB = statusBar.HPB
  statusBar:insert(HPB)
  HPB:scale(.6,1)
  -- Circle for Beginning of Health Bar
  HPB.begin = display.newCircle(-32,15.8,6.2)
  statusBar:insert(HPB.begin)
  HPB.begin:setFillColor(1,0,0)
  HPB.begin.isVisible = false
  -- Middle of Health Bar
  HPB.mid = display.newRect(-31,16,10,12)
  statusBar:insert(HPB.mid)
  HPB.mid:setFillColor(1,0,0)
  HPB.mid.isVisible = false
  HPB.mid.anchorX = 0
  HPB.mid.anchorY = 0.5
  -- Circle for End Of Health Bar
  HPB.fin   = display.newCircle(73,15.8,6)
  statusBar:insert(HPB.fin)
  HPB.fin:setFillColor(1,0,0)
  HPB.fin.isVisible = false
  HPB:toFront()

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

  -- increase HP Bar
  function statusBar:iHPB ()
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
      statusBar.HPB.mid.width = statusBar.HPB.mid.width - 12

    end
  end

  function statusBar:iMPB()
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
	if Player.mana < 0 then Player.mana = 0
	elseif Player.mana > 100 then Player.mana = 100 end

    --print("Function: statusBar:dMPB ran")
    if (Player.mana == 0) then
      MPB.begin.isVisible = false
    elseif(Player.mana == 10) then
      MPB.mid.isVisible = false
    elseif (Player.mana == 90) then
      MPB.fin.isVisible = false
    elseif (Player.mana < 100) then
      MPB.mid.width = MPB.mid.width - 12
      MPB.fin.isVisible = false
      statusBar.MPB.mid.width = statusBar.MPB.mid.width - 12
    end
  end
  function statusBar:destroy()
    self:removeSelf()
  end
  return statusBar
end
