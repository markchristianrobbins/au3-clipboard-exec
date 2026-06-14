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
- [x] Fix EndWhile syntax bug in background index crawler script loops
    - Replaced the erroneous 'EndWhile' statement with native AutoIt 'WEnd' loop terminator on line 423 of '_index.au3'.
- [x] Prioritize script-directory settings and profile files over central `C:\$data` fallbacks
    - Created unified helper function `_Config_GetIniPath()` and `_Config_GetAppsIniPath()` in `_config.au3` prioritizing `@ScriptDir & "\clipboard-exec.ini"` and `@ScriptDir & "\apps.ini"` over `C:\$data` paths.
    - Updated `_Config_GetActiveAppProfile()`, `_Picker_IsWindowExcluded()`, `_Picker_ShowMiniGUI()`, `_Index_ProcessQueueBatch()`, and `_Index_ForceReload()` to utilize the unified INI resolver function, preventing configuration path mismatch and redundant loops.
- [x] Consolidate window exclusion criteria under a single unified pipe-separated INI entry
    - Designed pipe-separated combined exclusions (`Title: ...|Class: ...|Process: ...=1`) matching the requested format.
    - Updated `_Picker_IsWindowExcluded` to read and parse the unified conditions dynamically using `IniReadSection` and short-circuit condition evaluation.
    - Updated picker mini's "Exclude Window" action to build the pipe-separated criteria key and store it with singular `IniWrite` call.
- [x] Implement robust real-time file-system diagnostic logging for indexing crawls
    - Created timestamped diagnostic logger appending detailed error metrics, directory states, and API return values to `clipboard-exec-diagnostics.txt` directly next to `clipboard-exec.au3`.
    - Integrated automatic path normalization using `_PathFull` for database and log registers.
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

## [x] Recent Session Changes (Context Menu Mini-Picker & Click Improvements)
- [x] Add Reload Index button to toolbar
    - Added "[Reload Index]" text block on the toolbar, handled click, and wired it to `_Index_ForceReload()`.
- [x] Ensure directories are included in combined picker results
    - Corrected `$g_aActiveBasePaths` sync issue inside `_picker.au3` when rebuilding combined matches or reloading, resolving the missing directories bug.
- [x] Prevent hover from focusing items
    - Disabled automatic focused indexing when hovering with the cursor.
- [x] Click to focus & double click to accept
    - Refactored click to select/focus rows, and double-click to run/accept them or navigate.
- [x] Replace context popup menus with miniature option search picker
    - Refactored `_Picker_Show_WinContextMenu` to spawn a custom-coded block-free searchable miniature picker with options: Copy Info, Minimize, Maximize, Restore, Close, Exclude Window.
- [x] Permanent window exclusions from INI
    - Configured "Exclude Window" to persistently match and bypass titles, classes, and process executables from harvested outcomes.
- [x] Checkbox-style toolbar options
    - Replaced the text on the toolbar with interactive checkmarks matching `[x]` (enabled) and `[ ]` (disabled).
- [x] Streamline miniature picker dimensions (menu-like, 300px width, no titlebar)
    - Designed super compact, border-focused popup GUI utilizing a streamlined 300px layout width.
- [x] Open/Activate windows on double click
    - Routed double click on list items of type window to wake up, restore, and focus the application handle cleanly.
- [x] Focus active window item on start
    - Prefetches active handle title prior to GUI creation and offsets scroll coordinates to highlight the matching listing.
- [x] Add "Activate" option to top of context options picker
    - Wired "Activate" to restore and activate the window handle, allowing swift item selection.
- [x] Audio warning feedback beep on Applications key "{APPS}"
    - Connected standard native high-frequency Beep(800, 150) signal to Apps menu secondary trigger.
- [x] Virtual high-contrast scrollbar
    - Added reactive scroll track and thumb labels to adjust visible thumb heights and positions dynamically during keyboard navigations.
- [x] Visual keyboard shortcut help overlay window
    - Created a modal HUD triggered by the F1 key, displaying standard shortcut combinations and command descriptions clearly.
- [x] Dynamic menu option allocation bounds fix
    - Corrected `$aTempList` allocation bounds inside `_picker_mini.au3` to size dynamically according to `UBound($aOptions)`, solving the out-of-bounds error on fuzzy queries.
- [x] Robust index database path alignment
    - Corrected indexing paths in `/modules/_index.au3` to save and load index metrics directly to `C:\_\au3-clipboard-exec\clipboard-exec-index.txt` instead of parent folders.
- [x] Ensure index file creation on start and fix root dirty flag clobbering
    - Configured `_Index_Initialize` to auto-create `clipboard-exec-index.txt` on startup if it is missing, guaranteeing the file is always created.
    - Moved `$g_bIndexDirty = False` before crawling configured root paths to prevent clobbering the dirty state, allowing newly found root folders to trigger a save.
- [x] Eliminate slow/restricted System.Collections.ArrayList COM dependency other OS-wide locks
    - Fully rewrote the `_Index_ForceReload()` BFS folder crawl using a 100% native, ultra-fast AutoIt linear array circular queue. This prevents script crashes/exceptions from missing, restricted, or corrupted .NET runtime bindings.
- [x] Clean double and single quote wrappers from INI root paths
    - Applied sanitizing `StringRegExpReplace` checks to strip surrounding quotes from paths matched in the INI file, resolving `FileExists()` directory checking failures.
- [x] Enforce index path alongside clipboard-exec.au3
    - Designed `_Index_GetIndexPath()` searcher that guarantees the `clipboard-exec-index.txt` database lives in the same folder as `clipboard-exec.au3` even when sub-modules are evaluated.
- [x] Mousewheel list scrolling
    - Registered custom Win32 `WM_MOUSEWHEEL` message callback to scroll list offsets upwards/downwards by 3 rows per wheel notch.
- [x] Seamless virtual scrollbar thumb drag and background click interactions
    - Implemented click-and-drag mouse tracking loops for the virtual scroll thumb and absolute scroll-to paging for clicks on the scroll track background.
- [x] Interactive high-contrast scrollbar up/down arrow buttons
    - Built and styled compact indicator arrows ("▲" and "▼") at the top/bottom of the scroll track and mapped clicks to scroll line-by-line.

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
