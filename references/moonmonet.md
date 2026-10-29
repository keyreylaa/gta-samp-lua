# MoonMonet

Source: `lib/MoonMonet/init.lua` (binary: `lib/MoonMonet/libmoonmonet_rs.so`).

- Rust-backed helper loaded as a shared library. Inspect `lib/MoonMonet/init.lua` for the exact Lua API before use; the .so provides the implementation.
- Marked as a MonetLoader-specific addon (Android). Treat all calls as Android-only.
- If the .so is missing or the ABI mismatches, `require 'MoonMonet'` fails; guard with pcall.
