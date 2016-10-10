--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:1e614a10e0495b6af318edf4e712df37:7771849834f09d776b1572a0e205fd22:a2af45fe12e9e6045e9140ab147665e5$
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
            -- button-over
            x=1,
            y=1,
            width=154,
            height=40,

        },
        {
            -- button
            x=157,
            y=1,
            width=154,
            height=40,

        },
    },
    
    sheetContentWidth = 312,
    sheetContentHeight = 42
}

SheetInfo.frameIndex =
{

    ["button-over"] = 1,
    ["button"] = 2,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
