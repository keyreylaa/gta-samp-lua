# GUI (mimgui)

Source: `lib/mimgui/imgui.lua` (auto-generated Dear ImGui binding), `lib/mimgui/cdefs.lua`, `lib/mimgui/init.lua`, `lib/ADDONS.lua`, `lib/widgets.lua`, `ScreenRecorder.lua` (working usage).

## Module

- `local imgui = require 'mimgui'` — fails if the binding is missing.
- The binding is auto-generated from Dear ImGui; function names drop the `ig` prefix and keep ImGui's C signature. Consult `lib/mimgui/imgui.lua` for exact signatures; do not guess parameter order.
- Helpers present in the binding: `imgui.ImVec2(x, y)`, `imgui.ImVec4(...)`, `imgui.U32(r, g, b, a)`, `imgui.FLT_MAX`.

## Render callback

MonetLoader/mimgui builds differ. Use the pattern from `ScreenRecorder.lua`:

```lua
if type(imgui.OnFrame) == "function" then
    local ok = pcall(function()
        imgui.OnFrame(function() return true end, function() drawUI() end)
    end)
    if not ok then
        imgui.OnDrawFrame = drawUI
    end
else
    imgui.OnDrawFrame = drawUI
end
```

- `imgui.OnFrame(conditionFn, drawFn)` — newer builds.
- `imgui.OnDrawFrame = drawUI` — older builds.
- `imgui.Process = false` disables input capture when no window needs it (set in `main()`).

## Window pattern

```lua
imgui.SetNextWindowPos(imgui.ImVec2(x, y), imgui.Cond.FirstUseEver)
imgui.SetNextWindowSize(imgui.ImVec2(w, h), imgui.Cond.FirstUseEver)
if imgui.Begin("Title", nil, flags) then
    imgui.Text("...")
    if imgui.Button("OK", imgui.ImVec2(60, 24)) then ... end
    imgui.End()
end
```

- Always pair `Begin`/`End`; `End` only if `Begin` returned true.
- Flags are additive: `imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize`.
- `imgui.Cond.FirstUseEver` / `Always` control initial layout.

## State

- Keep UI state in a Lua table (e.g. `S = { widget_x = ..., recording = false }`).
- Input buffers: `imgui.InputInt`, `imgui.InputText` take a buffer table; mutate `buf[0]`.

## Addons

- `lib/ADDONS.lua` (881 lines) and `lib/widgets.lua` (203 lines) wrap common widgets. Read them before reimplementing; they are project-local, not upstream.
- `lib/imgui_addons.lua` provides extra helpers.

## Gotchas

- Do not allocate `ImVec2`/`ImVec4` inside hot loops unnecessarily; reuse.
- ID collisions: unnamed items need `##` suffix or `PushID`/`PopID`.
- Font changes require rebuilding the atlas; see `references/fonts.md`.
- `imgui.Process = false` when no interactive window is open to avoid swallowing touch input on Android.
