# Android / MonetLoader JNI

Source: `lib/android.lua`, `ScreenRecorder.lua` (usage), `recorder.dex`/`recorder-src/` (working .dex pattern).

## Availability

- `local JNI = require 'android'`. If `MONET_VERSION` is nil, the module returns a stub table whose methods are no-ops; check `MONET_VERSION ~= nil` before use.
- Globals from the loader: `getActivity()` and `getJNIEnv()` are provided by `lib/android.lua` via `gta._Z27NVEventGetPlatformAppHandlev()` and `gta._Z24NVThreadGetCurrentJNIEnvv()`.

## JNI object

`JNI` table fields: `env`, `classCache`, `methodCache`, `staticMethodCache`, `fieldCache`, `staticFieldCache`.

Methods:
- `JNI:context2(runnable, capacity)` — push/pop local frame; returns `runnable()` results.
- `JNI:checkForJNIException(skip)` — clears pending exception; errors unless skip.
- `JNI:throwable2string(throwable)`.
- `JNI:callVoidMethod(object, method, signature, ...)`, `callStaticVoidMethod(class, method, signature, ...)`.
- `JNI:callIntMethod`, `callStaticIntMethod`, `JNI:callLongMethod`, `callStaticLongMethod`.
- `JNI:callBooleanMethod`, `callStaticBooleanMethod`.
- `JNI:callObjectMethod`, `callStaticObjectMethod`.
- `JNI:getObjectField`, `setObjectField`, `setFloatField`, `getStaticObjectField`.
- `JNI:to_luastring(javastring)`, `to_javastring(luastring)`.
- `JNI:activityClassloader()` — caches the Activity's ClassLoader and `loadClass` method id.
- `JNI:findClass(class)` — dotted? uses slash form e.g. `"android/widget/Toast"`, caches global ref.
- `JNI:showToast(message, duration)` — duration 0 short, 1 long.
- `JNI:looperPrepare()` — prepare Looper if absent.
- `JNI:getAndroidID()`.

## Loading a .dex

Pattern (from `ScreenRecorder.lua` + `recorder.dex`):

```lua
local cl = JNI:activityClassloader()
local dexPath = "/sdcard/.../recorder.dex"
-- use DexClassLoader via JNI, or push path into classloader
local clazz = JNI:findClass("com/monet/screenrec/Recorder")
```

The deployed `.dex` lives at `/sdcard/Android/media/.../monetloader/recorder.dex` (or app-private). `recorder-src/` holds the Java source; rebuild with `javac --release 8` + D8 `--min-api 21`.

## JNI gotchas

- `JNIEnv` is thread-local. Call `getJNIEnv()` on the thread that uses it; the `android` module caches `JNI.env` at load — refresh after thread switches (ScreenRecorder calls `refreshJNI()`).
- Toast requires `Looper.prepare()` on the calling thread.
- JNI calls from the render thread can stall the game; move heavy work (MediaRecorder, MediaProjection) into a Java thread or a Lua thread with `wait()`.
- `findClass` uses the Activity classloader, so classes from a pushed `.dex` must be loaded through that loader.
- MonetLoader-specific: `MONET_VERSION` global; `MONET_VERSION >= 2008000` required by `monethook`.

## .dex guidance

- Keep the whole MediaProjection/MediaRecorder flow in Java; Lua only polls status.
- Intercept `onActivityResult` via `ActivityThread.mH.mCallback` because MonetLoader never forwards it to Lua.
- Run capture on a dedicated thread; post UI work via `Handler` on the main looper.
