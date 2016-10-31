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
  statusBar:insert(statusBar.HPB)
  statusBar.HPB:scale(.6,1)
  -- Circle for Beginning of Health Bar
  statusBar.HPB.begin = display.newCircle(-32,15.8,6.2)
  statusBar:insert(statusBar.HPB.begin)
  statusBar.HPB.begin:setFillColor(1,0,0)
  statusBar.HPB.begin.isVisible = false
  -- Middle of Health Bar
  statusBar.HPB.mid = display.newRect(-31,16,10,12)
  statusBar:insert(statusBar.HPB.mid)
  statusBar.HPB.mid:setFillColor(1,0,0)
  statusBar.HPB.mid.isVisible = false
  statusBar.HPB.mid.anchorX = 0
  statusBar.HPB.mid.anchorY = 0.5
  -- Circle for End Of Health Bar
  statusBar.HPB.fin   = display.newCircle(73,15.8,6)
  statusBar:insert(statusBar.HPB.fin)
  statusBar.HPB.fin:setFillColor(1,0,0)
  statusBar.HPB.fin.isVisible = false
  statusBar.HPB:toFront()

  -- MANA BAR
  statusBar.MPB = display.newImage("images/EmptyBar.png", MPBx, MPBy)
  statusBar.MPB:scale(.6,1)
  statusBar:insert(statusBar.MPB)
  -- Circle for Beginning of Mana Bar
  statusBar.MPB.begin = display.newCircle(93,15.8,6.2)
  statusBar:insert(statusBar.MPB.begin)
  statusBar.MPB.begin:setFillColor(0,0,1)
  statusBar.MPB.begin.isVisible = false
  -- Middle of Mana Bar
  statusBar.MPB.mid   = display.newRect(94,16,10,12)
  statusBar:insert(statusBar.MPB.mid)
  statusBar.MPB.mid:setFillColor(0,0,1)
  statusBar.MPB.mid.isVisible = false
  statusBar.MPB.mid.anchorX = 0
  statusBar.MPB.mid.anchorY = 0.5
  -- Circle for End Of Mana Bar
  statusBar.MPB.fin   = display.newCircle(198,15.8,6)
  statusBar:insert(statusBar.MPB.fin)
  statusBar.MPB.fin:setFillColor(0,0,1)
  statusBar.MPB.fin.isVisible = false
  statusBar.MPB:toFront()

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
      statusBar.HPB.begin.isVisible = true
    elseif (Player.hp == 20) then
      statusBar.HPB.mid.isVisible = true
    elseif (Player.hp < 100) then
      statusBar.HPB.mid.width = statusBar.HPB.mid.width + 12
    elseif (Player.hp == 100) then
      statusBar.HPB.begin.isVisible = true
      statusBar.HPB.mid.isVisible = true
      statusBar.HPB.mid.width = 103
      statusBar.HPB.fin.isVisible = true
    end
  end
  -- decrease HP Bar
  function statusBar:dHPB()
	if Player.hp < 0 then Player.hp = 0
	elseif Player.hp > 100 then Player.hp = 100 end
  
    --print("Function: statusBar:dHPB ran")
    if (Player.hp == 0) then
      statusBar.HPB.begin.isVisible = false
    elseif(Player.hp == 10) then
      statusBar.HPB.mid.isVisible = false
    elseif (Player.hp == 90) then
      statusBar.HPB.fin.isVisible = false
    elseif (Player.hp < 100) then
      statusBar.HPB.mid.width = statusBar.HPB.mid.width - 12
    end
  end

  function statusBar:iMPB()
	if Player.mana < 0 then Player.mana = 0
	elseif Player.mana > 100 then Player.mana = 100 end
  
    --print("Function: statusBar:iMPB ran")
    if (Player.mana == 10) then
      statusBar.MPB.begin.isVisible = true

    elseif (Player.mana == 20) then
      statusBar.MPB.mid.isVisible = true
    elseif (Player.mana < 100) then
      statusBar.MPB.mid.width = statusBar.MPB.mid.width + 12
    elseif (Player.hp == 100) then
      statusBar.MPB.begin.isVisible = true
      statusBar.MPB.mid.isVisible = true
      statusBar.MPB.mid.width = 103
      statusBar.MPB.fin.isVisible = true
    end
  end

  function statusBar:dMPB()
	if Player.mana < 0 then Player.mana = 0
	elseif Player.mana > 100 then Player.mana = 100 end
  
    --print("Function: statusBar:dMPB ran")
    if (Player.mana == 0) then
      statusBar.MPB.begin.isVisible = false
    elseif(Player.mana == 10) then
      statusBar.MPB.mid.isVisible = false
    elseif (Player.mana == 90) then
      statusBar.MPB.fin.isVisible = false
    elseif (Player.mana < 100) then
      statusBar.MPB.mid.width = statusBar.MPB.mid.width - 12
    end
  end
  function statusBar:destroy()
    self:removeSelf()
  end
  return statusBar
end
