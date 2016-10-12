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
  local statusBar = display.newGroup()
  -- HP BAR
  statusBar.HPB = display.newImage("images/EmptyBar.png", HPBx, HPBy)
  statusBar:insert(statusBar.HPB)
  statusBar.HPB:scale(.6,1)
  -- Circle for Beginning of Health Bar
  statusBar.HPB.begin = display.newCircle(-32,15.8,6.2)
  statusBar:insert(statusBar.HPB.begin)
  statusBar.HPB.begin:setFillColor(1,0,0)
  -- Middle of Health Bar
  statusBar.HPB.mid   = display.newRect(-31,16,106,12)
  statusBar:insert(statusBar.HPB.mid)
  statusBar.HPB.mid:setFillColor(1,0,0)
  statusBar.HPB.mid.anchorX = 0
  statusBar.HPB.mid.anchorY = 0.5
  -- Circle for End Of Health Bar
  statusBar.HPB.fin   = display.newCircle(73,15.8,6)
  statusBar:insert(statusBar.HPB.fin)
  statusBar.HPB.fin:setFillColor(1,0,0)
  statusBar.HPB:toFront()

  -- MANA BAR
  statusBar.MPB = display.newImage("images/EmptyBar.png", MPBx, MPBy)
  statusBar.MPB:scale(.6,1)
  statusBar:insert(statusBar.MPB)

  return statusBar
end

-- Update HP Bar
-- function statusBar:uHPB
-- end
