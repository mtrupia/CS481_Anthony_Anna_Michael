--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:c91bd337d4e18c7f0f8e2ddafd8e7e6d:b6941dfe1566145f1e24014b70964f6e:fdfcba2b7a8b734906d1400bae1668b7$
--
-- local sheetInfo = require("mysheet")
-- local myImageSheet = graphics.newImageSheet( "mysheet.png", sheetInfo:getSheet() )
-- local sprite = display.newSprite( myImageSheet , {frames={sheetInfo:getFrameIndex("sprite")}} )
--

local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {
    
        {
            -- Bomb
            x=1,
            y=1,
            width=130,
            height=130,

            sourceX = 12,
            sourceY = 9,
            sourceWidth = 144,
            sourceHeight = 140
        },
        {
            -- Bomb1
            x=133,
            y=1,
            width=130,
            height=130,

            sourceX = 12,
            sourceY = 9,
            sourceWidth = 144,
            sourceHeight = 140
        },
        {
            -- Bomb2
            x=265,
            y=1,
            width=130,
            height=130,

            sourceX = 12,
            sourceY = 9,
            sourceWidth = 144,
            sourceHeight = 140
        },
        {
            -- Bomb3
            x=397,
            y=1,
            width=130,
            height=130,

            sourceX = 12,
            sourceY = 9,
            sourceWidth = 144,
            sourceHeight = 140
        },
    },
    
    sheetContentWidth = 528,
    sheetContentHeight = 132
}

SheetInfo.frameIndex =
{

    ["Bomb"] = 1,
    ["Bomb1"] = 2,
    ["Bomb2"] = 3,
    ["Bomb3"] = 4,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
