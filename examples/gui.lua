-- examples/gui.lua
-- Verified pattern: mimgui window with OnFrame/OnDrawFrame fallback.
local imgui = require 'mimgui'

local state = { visible = true }

local function drawUI()
    if not state.visible then return end
    if imgui.Begin("Example", nil, 0) then
        imgui.Text("Hello")
        if imgui.Button("Toggle", imgui.ImVec2(80, 24)) then
            state.visible = false
        end
        imgui.End()
    end
end

if type(imgui.OnFrame) == "function" then
    pcall(function()
        imgui.OnFrame(function() return true end, drawUI)
    end)
else
    imgui.OnDrawFrame = drawUI
end

function main()
    imgui.Process = false
    while true do wait(0) end
end
