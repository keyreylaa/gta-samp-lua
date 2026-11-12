# Fonts in mimgui

Verified against `dist/lib/mimgui/{init,imgui,cdefs}.lua`.

## The font that is already there

`mimgui` builds its renderer on the first frame and adds `lib/mimgui/trebucbd.ttf`
(Trebuchet MS Bold) at `14 * MONET_DPI_SCALE` pixels. A script that only draws text needs
to do nothing: that font is the default of the atlas.

`MONET_DPI_SCALE` is the display density of the device divided by 200, never below 1. It is
`1.346` on a 269 dpi phone. It is a loader global, not a constant of the script.

## Adding another font

Fonts are added to the atlas while the atlas is being built, so the call belongs in
`imgui.OnInitialize`:

```lua
imgui.OnInitialize(function()
    local io = imgui.GetIO()
    local builder = imgui.ImFontGlyphRangesBuilder()
    builder:AddText([[‚„…†‡€‰‹‘’“”•–—™›]])
    builder:AddRanges(io.Fonts:GetGlyphRangesCyrillic())
    local ranges = imgui.ImVector_ImWchar()
    builder:BuildRanges(ranges)          -- keep the vector alive, the atlas points into it
    io.Fonts:AddFontFromFileTTF(
        getWorkingDirectory() .. '/lib/mimgui/trebucbd.ttf',
        14 * MONET_DPI_SCALE, nil, ranges[0].Data)
    imgui.CreateFontsTexture()          -- upload the new atlas to the GPU
end)
```

- `AddFontFromFileTTF(filename, size_pixels, font_cfg, glyph_ranges)`.
- `AddFontFromMemoryTTF(data, size_bytes, size_pixels, font_cfg, glyph_ranges)`.
- `font_cfg` may be `nil`; use `imgui.ImFontConfig()` when you need `MergeMode`,
  `PixelSnapH`, `FontDataOwnedByAtlas`.
- `imgui.ImVector_ImWchar()` is the `ImWchar*` holder; pass `vec[0].Data`.
- `imgui.InvalidateFontsTexture()` drops the uploaded texture; call it before
  `CreateFontsTexture()` when the atlas changes after the first frame.

## Icon fonts (merged)

An icon font is added **after** the text font with `MergeMode = true`, and the codepoints
must be in the glyph range:

```lua
imgui.OnInitialize(function()
    local io = imgui.GetIO()
    local cfg = imgui.ImFontConfig()
    cfg.MergeMode = true
    cfg.PixelSnapH = true
    local builder = imgui.ImFontGlyphRangesBuilder()
    for _, cp in pairs(ICON_RANGES) do builder:AddText(utf8.char(cp)) end
    local ranges = imgui.ImVector_ImWchar()
    builder:BuildRanges(ranges)
    ICONS = io.Fonts:AddFontFromMemoryCompressedBase85TTF(data85, 16 * MONET_DPI_SCALE, cfg, ranges[0].Data)
    io.FontDefault = ICONS or io.FontDefault
    imgui.CreateFontsTexture()
end)
```

## Size of the text

- The size is baked into the atlas. Different sizes mean different `ImFont*` values.
- `io.FontGlobalScale` scales the glyphs at draw time. It is read when the frame starts, so
  setting it inside a draw callback has no effect until the next frame, and it applies to
  every mimgui window of the process. Set it once, in `imgui.OnInitialize`.

## Gotchas

- Adding a font after the atlas is built is ignored. Either use `imgui.OnInitialize` or
  rebuild with `imgui.CreateFontsTexture()`.
- A font pointer survives only until the next rebuild. Do not cache it in a config file or
  across a reload.
- A glyph that is not in the range renders as `?` or an empty box. Check the range.
- A TTF that cannot be read makes the atlas fail; guard with `doesFileExist(path)` before
  adding it.
- Paths are resolved from the working directory: `getWorkingDirectory()` on Android points
  at the media folder of the game (`/storage/emulated/0/Android/media/<pkg>/monetloader`).