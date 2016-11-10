--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:16ddaa4899473d1435d924cfd0017caf:c931673211d222a94a8d50a444613a17:5db34015c54be37cca754b909a06ce20$
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
            -- 5
            x=1,
            y=34,
            width=26,
            height=27,

        },
        {
            -- 6
            x=1,
            y=132,
            width=25,
            height=32,

        },
        {
            -- 7
            x=1,
            y=271,
            width=24,
            height=34,

        },
        {
            -- 8
            x=1,
            y=233,
            width=24,
            height=36,

        },
        {
            -- 9
            x=1,
            y=166,
            width=25,
            height=32,

        },
        {
            -- 10
            x=1,
            y=200,
            width=25,
            height=31,

        },
        {
            -- 11
            x=1,
            y=98,
            width=25,
            height=32,

        },
        {
            -- 12
            x=1,
            y=63,
            width=25,
            height=33,

        },
        {
            -- 13
            x=1,
            y=1,
            width=26,
            height=31,

        },
    },

    sheetContentWidth = 28,
    sheetContentHeight = 306
}

SheetInfo.frameIndex =
{

    ["1"] = 1,
    ["2"] = 2,
    ["3"] = 3,
    ["4"] = 4,
    ["5"] = 5,
    ["6"] = 6,
    ["7"] = 7,
    ["8"] = 8,
    ["9"] = 9,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
