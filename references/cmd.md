# Commands (chat)

Source: `ScreenRecorder.lua` (working usage), MoonLoader/MonetLoader runtime.

## Registration

MonetLoader provides `sampRegisterChatCommand(name, callback)`. MoonLoader provides `addCommand(name, callback, description)`. Support both with a fallback:

```lua
local registered = false
if type(sampRegisterChatCommand) == "function" then
    local ok = pcall(sampRegisterChatCommand, "mycommand", handler)
    if ok then registered = true end
end
if not registered and type(addCommand) == "function" then
    pcall(addCommand, "mycommand", handler, "description")
    registered = true
end
```

- Command names are case-insensitive in SA-MP; register lowercase.
- Callback receives the argument string (may be `nil`/empty).

## Parsing arguments

```lua
local function handler(param)
    local args = {}
    for token in tostring(param or ""):gmatch("%S+") do
        args[#args + 1] = token
    end
    -- args[1], args[2], ...
end
```

- Do not assume a fixed argument count; check `#args`.
- Convert numbers with `tonumber`; reject `nil`.

## Removal

- `sampUnregisterChatCommand` exists in SAMPFUNCS on some builds; guard with `type(...) == "function"`.
- On script terminate, commands are removed automatically by the loader.

## Naming

- Keep names short, lowercase, no spaces: `/screenrec`, `/sc_debug`.
- Prefix project-specific commands to avoid collisions with other scripts.

## Gotchas

- Registering the same name twice may error or be ignored; guard with a flag.
- Commands registered before `main()` runs are fine, but JNI/ffi state may not be ready; defer heavy work.
- Do not block inside a command callback; spawn a thread or set a flag polled in `main()`.
