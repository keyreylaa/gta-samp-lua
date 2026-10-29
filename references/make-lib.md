# Making your own library

Source: patterns visible in `lib/` modules (e.g. `lib/moonloader.lua`, `lib/monetloader.lua`, `lib/samp/events/utils.lua`, `lib/vector3d.lua`).

## When to split into a lib

- Logic reused across scripts, or stateful helpers (config, cache, hooks).
- Anything that needs cleanup on unload (hooks, threads, files).
- Keep single-use, short scripts inline.

## Module shape

```lua
-- lib/mylib.lua
local mylib = {}

function mylib.doThing(x)
    return x + 1
end

return mylib
```

- Return a table; never rely on globals.
- Use `local` for all internal state and helpers.
- Prefix internal helpers with the module name or keep them local.

## Naming and versioning

- File name = module name: `lib/mylib.lua` -> `require 'mylib'`.
- Submodules: `lib/mylib/core.lua` -> `require 'mylib.core'`.
- Add `MODULEINFO = { name = '...', version = N }` (as in `lib/samp/raknet.lua`) for diagnostics.
- Increment version on breaking changes.

## Cleanup

Register `onScriptTerminate` inside the module only if it owns resources; otherwise let the caller manage. If the module spawns threads or hooks, track them and stop on terminate (see `lib/monethook.lua`).

## Require and paths

- `require 'name'` resolves to `lib/name.lua` then `lib/name/init.lua`.
- Avoid `package.path` hacks; place files under `lib/`.
- Guard optional deps with `pcall(require, name)`.

## Anti-patterns

- Do not leak globals (`_G.x = ...`) unless the module is a constants module like `sampfuncs`.
- Do not wrap a single function in a module.
- Do not create layers that only call other layers.
- Do not use `pcall` around every line; handle errors where they can occur.
- Keep one responsibility per function; name functions for what they do.
