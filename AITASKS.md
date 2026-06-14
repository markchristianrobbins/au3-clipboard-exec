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
