# UNVERIFIED.md — what is not covered by this skill

The items below were flagged as unverified in earlier revisions. The ones that could be
checked against the loader sources of this client are now documented in `references/`;
the rest is listed here so a future agent does not trust it blindly.

## Verified against the MonetLoader sources of this client

- mimgui API used by the references: `imgui.OnFrame`, `imgui.new.*`, `imgui.Image`,
  `imgui.Combo`, `imgui.SliderFloat`, `imgui.ColorEdit3`, `imgui.TextUnformatted`,
  `imgui.PushStyleColorU32` / `PushStyleVarFloat` / `PushStyleVarVec2` and their pops,
  the enum tables (`imgui.Col`, `imgui.StyleVar`, `imgui.Cond`, `imgui.WindowFlags`),
  `mimgui.CreateTextureFromFile`, `mimgui.ReleaseTexture`, `mimgui.CreateFontsTexture`,
  `mimgui.InvalidateFontsTexture`, `imgui.OnInitialize`.
- Font model: `lib/mimgui/trebucbd.ttf` added at `14 * MONET_DPI_SCALE` on the first frame,
  `AddFontFromFileTTF`, `AddFontFromMemoryTTF`, `ImFontGlyphRangesBuilder`,
  `ImVector_ImWchar`, `MergeMode`.
- Globals: `MONET_VERSION`, `MONET_DPI_SCALE`, `MONET_GTASA_BASE`, `PLAYER_PED`,
  `PLAYER_HANDLE`.
- `inicfg` writes sections only; a value at the top of the table makes `save` assert.
- Bullet sync is the packet `PACKET.BULLET_SYNC` (206) with `BulletSyncData` (40 bytes),
  handled by `onSendBulletSync` / `onBulletSync`.

## Still unverified

- The complete list of mimgui functions: `imgui.lua` is an auto-generated binding of the
  whole Dear ImGui API. Read it before using a function this skill does not name.
- Font behaviour when a device has no TTF at `lib/mimgui/`: the loader asserts on a missing
  font file, so a loader without it does not reach the scripts.
- `.dex` loading on this client: `MoonMonet` is a 32-bit `.so` in the shipped modules and
  cannot be loaded by the 64-bit client. No verified `.dex` path on 64-bit yet.
- `isKeyDown`: the loader has no keyboard state; a script that reads the keyboard needs an
  event from the client that does not exist yet.
- `getFolderPath(id)`: the ids of the 32-bit build do not apply.
- Camera angles for PC-style scripts: the offsets of the PC build (`0xB6F248`/`0xB6F258`) are
  not the ones of this client; the camera object of the 64-bit build is `TheCamera`
  (`0xBBA8D0`) with the angles at `+0x220`/`+0x230`. There is no loader API for them yet.

## Conventions to keep

- This skill documents the loader of this client and of MoonLoader on PC. A different loader
  version can rename or drop an API: check the `lib/` of that installation first.
- Never present an unverified offset as fact. Dump the offsets of the build at hand
  (`dump-gtasa-offsets.lua`) instead of copying them from a forum post.