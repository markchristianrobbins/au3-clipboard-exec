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
- [x] Enforce overlapped window selection and state tracking
    - Screen WinList outputs to allow ONLY overlapped windows style, filtering out unneeded systems/popups.
    - Suffix window titles dynamic states as `[window: minimized]`, `[window: hidden]`, or `[window: minimized & hidden]`.
- [x] Bind Ctrl+Insert to copy complete window metrics report
    - Map `^{INSERT}` to a dedicated dummy accelerator, gathering process PID/path, HWND handle, position coordinates, and style flags into a clean clipboard report.
- [x] Add right-click context menu options to manage window states
    - Intercept Mouse secondary right-clicks on window rows inside the interactive loop.
    - Construct standard native TrackPopupMenu menus listing: Copy Info, Minimize, Maximize, Restore, Close.
- [x] Correct indentation for window elements
    - Bypassed indent offsets inside list rows if the entry is of type window.
- [x] Connect the "Apps" key to invoke item context menus
    - Assigned {APPS} keyboard accelerator mapping and VM_CONTEXTMENU message hooks to trigger context menus at the mouse coordinate smoothly.
- [x] Support inclusive directory listings on Windows & Directories Combined Intelligent Picker
    - Correctly wired global combined picker active state flags, enabling clean merge, search, and dynamic filter rebuilds for directory entries.
- [x] Add dynamic state toggling toolbar above status bar
    - Rendered high-contrast toolbar below input fields, adjusting general application layout to accommodate additional height (124px area size) safely.
    - Clickable text regions and Alt+H / Alt+M hotkeys toggle Show Hidden and Show Minimized state filters securely.

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

## [x] Implement Advanced Token Classification on Decomposed Picker
- [x] Integrate Explicit Item Types:
    - Automatically classify and suffix discovered tokens as `[dir]`, `[file]`, or `[window]`.
    - Display the item type visually inside the item row rendering (`[dir]`, `[file]`, or `[window]`) in place of default folder stats.
- [x] Extract Real-Time Window Icons:
    - If the item is a window, dynamically query its PID and file coordinate location to fetch its native application icon binary.
- [x] Enhance Status Bar Detail:
    - Show precise process names and window classes for active windows, and sizes for direct files, inside the active status details bar.

## [x] Implement Search Picker for Windows and Directories
- [x] Remove Recents Feature:
    - Disabled storing of new paths to recents, and bypassed loading/merging of recent paths inside the interactive query handler completely.
- [x] Bind Win+Ctrl+Alt+Enter Combo:
    - Registered `#^!{ENTER}` within the main service loop.
    - Combined current desktop visible windows (`WinList`) and crawled system paths from indexes (`_Index_LoadIndexedPaths`) into a unified launcher, mapping appropriate action routes on selection.

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
