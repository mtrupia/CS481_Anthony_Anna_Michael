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
  statusBar.HPB:scale(.6,1)
  statusBar:insert(statusBar.HPB)
  -- MANA BAR
  statusBar.MPB = display.newImage("images/EmptyBar.png", MPBx, MPBy)
  statusBar.MPB:scale(.6,1)
  statusBar:insert(statusBar.MPB)

  statusBar.HPB.begin = display.newCircle(68,15,6)
  return statusBar
end

-- Update HP Bar
-- function statusBar:uHPB
-- end
