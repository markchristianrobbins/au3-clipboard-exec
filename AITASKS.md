# AI Tasks

---
## Back to...
- ▪️[AGENTS.md](AGENTS.md)
- ▪️[AILOG.md](AILOG.md)
- ▪️[AITASKARCH.md](AITASKARCH.md)
- 🔸[AITASKS.md](AITASKS.md)
- ▪️[BUILD.md](BUILD.md)
- ▪️[CODE.md](CODE.md)
- ▪️[FEATURES.md](FEATURES.md)
- ▪️[MANUAL.md](MANUAL.md)
- ▪️[README.md](README.md)
- ▪️[SPEC.md](SPEC.md)
- ▪️[TESTING.md](TESTING.md)

## [x] Incoming tasks from chat
- [x] Reverse engineer full AutoIt application codebase
    - Unraveled `clipboard-exec.au3` hotkey binding routes and main loops.
    - Reverse engineered directory matching criteria, regular expressions, and handlers.
    - Unraveled the Search Picker GUI design specs, custom hashing algorithms, colors, and key interceptors.
- [x] Document code metrics and update structural markdown files
    - Overwrote AGENTS, AILOG, AITASKARCH, AITASKS, BUILD, CODE, FEATURES, MANUAL, README, SPEC, and TESTING.
- [x] Resolve active window tracking match / profile configuration crash
    - Refined configuration lookup logic in `_config.au3` and resolved native win32 API call using `_WinAPI_GetClassName` safely.
- [x] Improve Zdot regex routing and temporal token matching
    - Enabled seamless identification of both `z-` and `z.` prefixed chronological timestamps in clipboard evaluated states, seeking `z.` target markers correctly inside the indexed source files.
- [x] Codify explicit AI logger and chat tracking instruction rules in AGENTS.md
    - Formalized strict workflow parameters requiring `AILOG.md` edits, updated commit message registries, and inline `AITASKS.md` checklists for every turn.
- [x] Support folder file:/// URLs in directory router
    - Enabled identification and parsing of file:/// and file:// addresses (including local and network shares) to behave exactly like standard native paths in Directory Opus.

## [x] Implement New Specifications (Line Decomposition & Prefixes)
- [x] Implement Line Decomposition logic on Win+Alt+Enter input:
    - Extract multiple tokens (URLs, paths, words referencing files or directories from indexes / disk, or window titles).
    - Design a multi-token Picker overlay showing recognized tokens and their occurrences.
    - Launch a secondary Picker (instances list) upon choosing a decomposed token.
- [x] Integrate Advanced Prefix-based App Routers:
    - Support `+` prefix: open directory in a new Directory Opus window instance.
    - Support `-` prefix: reuse active Directory Opus tab, issue close command (`^f4`), and keep Picker open.
    - Support `@` and `-@` prefixes: open/activate or close Cursor on target directories.
    - Support `#` and `-#` prefixes: open/activate or close Obsidian on target directories.

## [x] Resolve au3check Compiler and Function Declarations Bugs
- [x] Correct undefined `DirectoryExists` reference:
    - Replaced with standard compatible native `FileExists` check inside `_index.au3`.
- [x] Resolve undeclared variables:
    - Verified complete clearance of `$g_g_iSelectedIndex` double-g prefixes within `_picker_keys.au3`.
- [x] Fix undefined references:
    - Appended `#include "_index.au3"` into `_recognizer.au3` to resolve compiled bindings of `_Index_Initialize()` and `_Index_LoadIndexedPaths()`.

## [ ] New Changes
- [ ] Migrate central app configurations inside `.ini` layouts to JSON
    - Define robust schemas for mapping application names to window behaviors.
- [x] Implement incremental indexing sweeps in `_index.au3`
    - Created a highly optimized background file and directory scanner with INI-controlled periodic timers, batch size bounding, and robust filtering for node_modules and GUID-like structures.
- [x] Integrate production-ready Search Picker with real index file loading
    - Reconfigured the interactive Search Picker to load directly from the crawled system indices and route selection entries directly to Directory Opus.

## [ ] New Settings
- [ ] `sendkeys` under `[Cursor]` profile
    - Value: `"{HOME}+{END}^c"` (controls editor string selection macros).
- [ ] `$g_sDOpusRt` under `modules\_handler_dopus.au3`
    - Value: `C:\Program Files\GPSoftware\Directory Opus\dopusrt.exe` (points to lister launcher runtime).

## [ ] New Commands
- [ ] Command: `> [DOS Command]`
    - Inline CLI interception mapping standard capture outputs back straight into clipboard structures.

## [ ] New Bindings
- [ ] Binding: `Win+Alt+Enter`
    - Call context checks matching profiles configuration metrics, evaluating active window titles and invoking specific actions.

## [ ] New Features
- [ ] Directory Hashing Hue Branding
    - Generate distinct visual branding dynamic hues mapped on directory base names using character ASCII sums.

---
## Historical Registry

### Settings
- [x] `C:\$data\clipboard-exec.ini` - Main settings parser storage coordinates.
- [x] `C:\$data\apps.ini` - Window class metadata descriptors registry.

### Commands
- [x] Windows Shell Invoker: `StdOut` pipeline scanner capturing CMD console feedback invisibly.

### Bindings
- [x] `Win+Ctrl+Shift+Enter` - Global exit process and lock file purge routine.
- [x] `Win+Alt+Shift+Enter` - Direct clipboard routing regular expression validator.

### Features
- [x] Responsive Keyboard Navigation - Full bind mappings wrapping arrow navigations, scrolling offsets, and page increments.
- [x] Subdirectory Explorer Overlay - Fast layout context breakout of subdirectory lists utilizing Scripting Dictionary counts.

---
## Go Back to...
- ▪️[AGENTS.md](AGENTS.md)
- ▪️[AILOG.md](AILOG.md)
- 🔸[AITASKS.md](AITASKS.md)
- ▪️[BUILD.md](BUILD.md)
- ▪️[CODE.md](CODE.md)
- ▪️[FEATURES.md](FEATURES.md)
- ▪️[MANUAL.md](MANUAL.md)
- ▪️[README.md](README.md)
- ▪️[SPEC.md](SPEC.md)
- ▪️[TESTING.md](TESTING.md)
