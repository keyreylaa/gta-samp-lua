# GUI (mimgui)

Verified against the MonetLoader build used by this client: `dist/lib/mimgui/{init,imgui,cdefs}.lua`.
The names below are the ones that exist there. Nothing else is documented here.

## Module and enums

```lua
local imgui = require 'mimgui'   -- assert MONET_VERSION ~= nil, the module is MonetLoader-only
```

`require 'mimgui'` returns the module of the loader (`init.lua`), and the module falls back
to the Dear ImGui binding (`imgui.lua`). The renderer lives on the module: `CreateTextureFromFile`,
`CreateTextureFromFileInMemory`, `ReleaseTexture`, `CreateFontsTexture`,
`InvalidateFontsTexture`, `OnFrame`, `OnInitialize`, `SwitchContext`, `GetRenderer`,
`IsInitialized`, `DisableInput`. The widgets live on the binding. A script usually names the
module `imgui`, so both spellings are found through that one name.

- Functions drop the `ig` prefix and keep ImGui's C signature: `igSliderFloat` → `imgui.SliderFloat`.
- Enum constants live in `imgui.lib` (`imgui.lib.ImGuiCol_WindowBg`) and are also reachable
  as `imgui.Col.WindowBg`, `imgui.StyleVar.WindowRounding`, `imgui.Cond.FirstUseEver`,
  `imgui.WindowFlags.NoCollapse`, `imgui.ColorEditFlags.NoInputs`.
- `imgui.ImVec2(x, y)`, `imgui.ImVec4(r, g, b, a)`.

## State (cdata)

Widgets take pointers, so the state has to be a cdata object and not a Lua value:

```lua
local open      = imgui.new.bool(false)
local life      = imgui.new.float(0.30)
local mode      = imgui.new.int(0)
local colour    = imgui.new.float[3](1.0, 0.35, 0.35)
open[0] = true
if open[0] then ... end
```

## The frame

```lua
imgui.OnFrame(condition, cbBefore, cbDraw)
```

- `condition` is a function; the callback runs only while it returns true.
- `cbBefore` runs before `NewFrame` (use it to prepare state), `cbDraw` runs between
  `NewFrame` and `EndFrame`. `cbDraw` may be omitted, then `cbBefore` is the draw function.
- Returns a subscription: `sub:Unsubscribe()`, `sub:IsActive()`, `sub.HideCursor`, `sub.LockPlayer`.

```lua
local frame
frame = imgui.OnFrame(function() return open[0] end, function()
    imgui.SetNextWindowPos(imgui.ImVec2(x, y), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowSize(imgui.ImVec2(w, h), imgui.Cond.FirstUseEver)
    imgui.Begin('Title', open, imgui.WindowFlags.NoCollapse)
    imgui.TextUnformatted('...')
    imgui.End()
end)
```

The frame is driven by the loader's render hook, so a callback must not block and must not
assume it runs before the game is loaded.

## Widgets

```lua
imgui.TextUnformatted(text)                 -- NOT imgui.Text(fmt, ...): the binding is variadic C
imgui.Text('plain string')                  -- no formatting, one argument only
imgui.Separator()
imgui.Checkbox('Enabled', flag)
imgui.SliderFloat('Lifetime', value, min, max, '%.2f')
imgui.Combo('Colour', idx, nameArray, #names)
imgui.ColorEdit3('Pick', colour, imgui.ColorEditFlags.NoInputs)
imgui.InputText('##name', buffer, ffi.sizeof(buffer))
imgui.Button('Save', imgui.ImVec2(150, 32))
imgui.SameLine()
```

`imgui.Combo` needs the item names as a `const char*` array; keep the array alive:

```lua
local names = { 'Solid', 'Rainbow' }
local nameArray = imgui.new['const char*'][#names](names)
imgui.Combo('Colour', idx, nameArray, #names)
```

## Style

Push and pop around your own window, so the other scripts keep their look:

```lua
local N_COLOR, N_VAR = 0, 0
local function push()
    imgui.PushStyleColorU32(imgui.Col.WindowBg, 0xF0060606) -- IM_COL32: 0xAABBGGRR
    imgui.PushStyleVarFloat(imgui.StyleVar.WindowRounding, 0.0)
    imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(10, 8))
end
local function pop()
    imgui.PopStyleVar(2)
    imgui.PopStyleColor(1)
end
```

The pop count must equal the push count. `PushStyleColorU32` takes the packed IM_COL32
value (alpha, blue, green, red); `PushStyleColor` takes an `ImVec4`.

## Images

```lua
local tex = imgui.CreateTextureFromFile(path)   -- ImTextureID, nil when the file cannot be read
imgui.Image(tex, imgui.ImVec2(w, h))
```

- The renderer exists only after the first frame. Calling this at script load raises
  "the renderer is not ready yet"; create textures inside `imgui.OnInitialize` or later.
- A failed load is `nil` (a NULL handle is treated as a failure). Check before drawing.
- In a draw list:

```lua
local dl = imgui.GetBackgroundDrawList()
dl:AddImage(tex, imgui.ImVec2(x1, y1), imgui.ImVec2(x2, y2), imgui.ImVec2(0, 0), imgui.ImVec2(1, 1), 0xFFFFFFFF)
```

- The texture is not released by the garbage collector: the draw list of the frame still
  points at it. Release it yourself with `imgui.ReleaseTexture(tex)` when the script is done.

## Drawing without a window

```lua
local dl = imgui.GetBackgroundDrawList()
dl:AddLine(a, b, colour, thickness)
dl:AddRectFilled(a, b, colour, rounding)
dl:AddTextFontPtr(imgui.GetFont(), size, pos, colour, text)
```

Inside a window, `imgui.GetWindowDrawList()` is the draw list of that window; its coordinates
are absolute screen pixels. `imgui.GetFont()` is the current font; the size is the pixel size
of that font.

## Gotchas

- No `imgui.Process`: the loader owns input. `imgui.DisableInput = true` turns the
  script's input handling off.
- No `imgui.OnDrawFrame` on this loader: it is the older MoonLoader API. Use `imgui.OnFrame`.
- Text with a format and arguments has taken the process down inside LuaJIT's ccall on this
  loader (SIGSEGV in `libluajit`, fault at a small address): `imgui.Text` is the variadic
  `igText(const char* fmt, ...)`. Build the line with `string.format` and draw it with
  `imgui.TextUnformatted`, which is not variadic.
- Do not cache `ImFont*` across a font rebuild; see `references/fonts.md`.
- `imgui.Begin` must be paired with `imgui.End` on every path, including the early returns.