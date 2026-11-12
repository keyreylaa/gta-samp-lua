-- examples/gui.lua
-- mimgui on MonetLoader (Android): a window, an image, a font size that follows
-- the display, and a style that is pushed and popped again.
-- Verified against dist/lib/mimgui on the 64-bit client.

local imgui = require 'mimgui'

-- MONET_DPI_SCALE is optional: fall back to the resolution when it is not set
local S = MONET_DPI_SCALE or math.max(1.0, (select(2, getScreenResolution()) or 720) / 720)

local open  = imgui.new.bool(false)
local alpha = imgui.new.float(1.0)
local icon  = nil -- ImTextureID, nil until the file is read

-- IM_COL32 packs the colour as 0xAABBGGRR
local function col32(r, g, b, a)
    return bit.bor(
        bit.lshift(math.floor(a * 255 + 0.5), 24),
        bit.lshift(math.floor(b * 255 + 0.5), 16),
        bit.lshift(math.floor(g * 255 + 0.5), 8),
        math.floor(r * 255 + 0.5))
end

-- the renderer exists only after the first frame, so the texture is read here
imgui.OnInitialize(function()
    local path = getWorkingDirectory() .. '/config/icon.png'
    if doesFileExist(path) then
        icon = mimgui.CreateTextureFromFile(path)
    end
end)

imgui.OnFrame(function()
    return open[0]
end, function()
    imgui.SetNextWindowSize(imgui.ImVec2(320 * S, 200 * S), imgui.Cond.FirstUseEver)

    imgui.PushStyleColorU32(imgui.Col.TitleBg, col32(0.16, 0.29, 0.48, 1.0))
    imgui.PushStyleVarFloat(imgui.StyleVar.WindowRounding, 0.0)

    if imgui.Begin('Example', open, imgui.WindowFlags.NoCollapse) then
        if icon then
            imgui.Image(icon, imgui.ImVec2(48 * S, 48 * S))
            imgui.SameLine()
        end
        imgui.TextUnformatted(string.format('alpha %.2f', alpha[0]))
        imgui.SliderFloat('Alpha', alpha, 0.0, 1.0, '%.2f')
        imgui.End()
    end

    imgui.PopStyleVar(1)
    imgui.PopStyleColor(1)
end)

function main()
    sampRegisterChatCommand('gui', function()
        open[0] = not open[0]
    end)
    print('type /gui')
    wait(-1)
end