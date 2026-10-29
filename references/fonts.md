# Fonts in mimgui

Source: `lib/mimgui/imgui.lua`, `lib/mimgui/cdefs.lua`, `ScreenRecorder.lua`. Dear ImGui font API is exposed via the binding.

## Loading a font

Dear ImGui fonts are added to the global font atlas before the first frame. Typical pattern (from ImGui binding, names follow C API):

```lua
local io = imgui.GetIO()
local fonts = io.Fonts
local font = fonts:AddFontFromFileTTF(path, size, nil, glyphRanges)
```

- `AddFontFromFileTTF(filename, size_pixels, font_cfg, glyph_ranges)` returns an `ImFont*`.
- `glyph_ranges` is a pointer to an array of `ImWchar` pairs terminated by 0 (built with `ImFontGlyphRangesBuilder` or the built-in `GetGlyphRangesDefault/Cyrillic/ChineseFull/...`).
- `MergeMode` in `ImFontConfig` merges a second font into the first (useful for icon fonts or CJK fallback).

## Glyph ranges

- Default range covers Latin-1. Cyrillic, Greek, CJK need explicit ranges.
- Built-in helpers: `fonts:GetGlyphRangesDefault()`, `GetGlyphRangesCyrillic()`, `GetGlyphRangesChineseFull()`, `GetGlyphRangesJapanese()`, `GetGlyphRangesKorean()`, `GetGlyphRangesThai()`, `GetGlyphRangesVietnamese()`.
- For arbitrary ranges, use `ImFontGlyphRangesBuilder`.

## Displaying text with a font

- `imgui.PushFont(font)` / `imgui.PopFont()` around the draw calls.
- Font size is fixed at load; scale via `io.FontGlobalScale` or load multiple sizes.

## Non-Latin / emoji

- The TTF must contain the glyphs; the range must include their codepoints.
- Icon fonts (FontAwesome) are loaded as a merged font with a custom range (`faIcons.lua`, `fAwesome6.lua` in `lib/` provide codepoint constants).

## Gotchas

- Fonts must be added before the atlas is built; adding after `Build()` is a no-op unless you call `Clear()` + rebuild.
- On Android, file paths use the MonetLoader working directory; use `getWorkingDirectory()` to resolve.
- A missing glyph renders as `?` or a box; verify the range includes the codepoint.
- `ImFontConfig.MergeMode = true` is required when merging an icon font into the default.
- Font rebuilds invalidate all `ImFont*` pointers; do not cache across rebuilds.
