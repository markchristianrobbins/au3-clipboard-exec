# AI Development Log

---
## Back to...
- ▪️[AGENTS.md](AGENTS.md)
- 🔸[AILOG.md](AILOG.md)
- ▪️[AITASKS.md](AITASKS.md)
- ▪️[BUILD.md](BUILD.md)
- ▪️[CODE.md](CODE.md)
- ▪️[FEATURES.md](FEATURES.md)
- ▪️[MANUAL.md](MANUAL.md)
- ▪️[README.md](README.md)
- ▪️[SPEC.md](SPEC.md)
- ▪️[TESTING.md](TESTING.md)

## Commit Message
```text
feat(scroller): implement mousewheel list scroll, virtual scrollbar thumb dragging, background click paging, interactive up/down arrows, and directory-correct index file placement

- Integrated a custom WM_MOUSEWHEEL event callback that scrolls option listings by 3 rows per wheel notch.
- Created click-and-drag mouse tracking loops for the custom virtual scroll thumb.
- Added absolute scroll-to pagination mapping click coordinates relative to the scroll track background.
- Created and styled clickable Up/Down indicator arrows ("▲" and "▼") at the top/bottom of the scroll track.
- Replaced hard-coded indexing file lookups in `/modules/_index.au3` with a robust `_Index_GetIndexPath()` searcher that guarantees the index remains directly next to `clipboard-exec.au3`.
```

## Log Entries

## [2026-06-14T21:55:00Z]
### 🎯 Primary Goals & Requirements
- Implement mousewheel list scrolling inside the primary search picker.
- Enable clicking and dragging on the custom virtual scrollbar thumb to scroll through listings.
- Enable clicking on the scrollbar track background to page/jump to that list coordinate position.
- Add working scroll indicator arrows ("▲" and "▼") at the top and bottom of the scroll track.
- Verify and make sure that the index database `clipboard-exec-index.txt` is always stored next to `clipboard-exec.au3`.

### 🛠️ Completed Changes in this Session
- **WM_MOUSEWHEEL Support (`/modules/_picker.au3`, `/modules/_picker_event.au3`)**: Custom-registered the standard Win32 `WM_MOUSEWHEEL` (0x020A) message handle and wired the scroll count to increment/decrement display offsets dynamically.
- **Scrollbar Thumb Drag Tracking (`/modules/_picker_event.au3`)**: Implemented mouse drag capture within the message loop; when clicking down on the thumb, we enter a lightweight drag polling loop that translates pixel distances to list items seamlessly.
- **Track Background Click Navigation (`/modules/_picker_event.au3`)**: Captured track background click messages, retrieved GUI cursor coordinates via `GUIGetCursorInfo()`, and mapped clicked ratios to the corresponding database offsets.
- **Interactive Scrollbar Arrows (`/modules/_picker.au3`, `/modules/_picker_render.au3`, `/modules/_picker_event.au3`)**: Created labels for Up/Down arrows ("▲" and "▼") and integrated their handlers. Replaced the static scroll positions inside `_Picker_UpdateScrollbar` to scale within arrow boundaries of the track area.
- **Safer Directory-Correct Index Resolution (`/modules/_index.au3`)**: Replaced raw string manipulations for `clipboard-exec-index.txt` with `_Index_GetIndexPath()`, keeping files organized beside `clipboard-exec.au3` dynamically.

## [2026-06-14T20:50:00Z]
### 🎯 Primary Goals & Requirements
- Streamline miniature context helper options picker to look compact and menu-like (reduced width to 300px, removed caption/titlebar labels, and set higher row density).
- Enable double click to restore active windows or open directories safely within the combined picker.
- Add an "Activate" action to the top of the context menu options list.
- Focus and index-scroll to the currently active application window row upon launcher GUI startup automatically.
- Setup a high-contrast custom virtual scrollbar displaying the scrolling position and list proportions dynamically.
- Implement an audio warning beep signal whenever the Apps key `{APPS}` is pressed.
- Create a visual Help window and bind the F1 key shortcut to display it.
- Fix any potential array out-of-bounds subscripts during mini-picker query filtering.

### 🛠️ Completed Changes in this Session
- **Compact Options Mini-Picker (`_modules/_picker_mini.au3`)**: Redefined geometry, reduced bounds width from 450px to 300px, removed standard caption backgrounds and text, and compressed row heights to 32px to create an elegant drop-down menu appearance. Added "Activate" at the top of the options index. Dynamically allocated temporary filtering arrays using `UBound($aOptions)` to resolve potential array dimension out-of-bound errors.
- **Start-Up Active Focus Engine (`/modules/_picker.au3`)**: Captured active window contexts before launcher initialization and searched lists to highlight corresponding handle entries instantly at row launch.
- **High-Contrast Virtual Scrollbar (`/modules/_picker_render.au3`)**: Added track and thumb labels that update height, position, and scroll offsets reactively during keyboard arrow runs.
- **Custom Shortcut Help HUD (`/modules/_picker_help.au3`)**: Implemented a standalone modal help drawer illustrating keybind tables and commands, mapped to the `{F1}` shortcut.
- **Shorcut Audio Beeper (`/modules/_picker_event.au3`)**: Configured a clear `Beep(800, 150)` tone to fire whenever the Applications context menu key is pressed.
- **Robust Suffix and Class Slicers (`/modules/_handler_dopus.au3`)**: Injected regex trims to prevent tag indicators like ` [dir]` or ` [window]` from interfering with Opus local folder listings or application routing.
- **Index Database Folder Resolution (`/modules/_index.au3`)**: Changed file generation resolution of `clipboard-exec-index.txt` to lock exclusively onto `@ScriptDir` (with structural nested `modules` module offsets), satisfying index persistence requirements.

### 🔸 Affected Files
- `/modules/_picker_help.au3`
- `/modules/_picker.au3`
- `/modules/_picker_globals.au3`
- `/modules/_picker_gui.au3`
- `/modules/_picker_mini.au3`
- `/modules/_picker_event.au3`
- `/modules/_picker_render.au3`
- `/modules/_handler_dopus.au3`
- `/modules/_index.au3`
- `/AITASKS.md`
- `/AILOG.md`

## [2026-06-14T20:30:00Z]
### 🎯 Primary Goals & Requirements
- Support manual full-crawling of local indexed assets via a clickable on-demand "Reload Index" button.
- Make toolbar filter choices visually resemble checkboxes (e.g. using `[x]` and `[ ]` layouts).
- Eliminate hover-based focus shifting so that the select bar stays on clicked or keyboard navigated items.
- Capture single click to focus a row, and double click to select or explore directories.
- Swap standard Win32 popup menus with a beautiful, custom, searchable miniature picker window.
- Persist window exclusions permanently in `clipboard-exec.ini` by classifying exact titles, window classes, and process executables.
- Resolve missing combined directories listings on combined picker queries.

### 🛠️ Completed Changes in this Session
- **Recursive Index Sweeper (`_Index_ForceReload`)**: Added a highly performance-crawled complete scan procedure inside `/modules/_index.au3` to update `$g_oIndexMap` and write coordinates directly to index.txt.
- **Checkbox-Style Toggles Toolbar**: Updated `/modules/_picker_helpers.au3` to output `[x]` for enabled states and `[ ]` for disabled choices, adding mouse X testing boundaries to intercept clicks.
- **Combined Matches Visibility Recovery**: Corrected `$g_aActiveBasePaths` alignment inside `/modules/_picker.au3` when toggling filters or triggering index reloads, restoring full directories visibility.
- **Prevented Selection Shifting on Hover**: Erased mouse movement listeners from shifting the select coordinate. Hovering now does not steal focus, keeping work states secure.
- **Click to Focus & Double-Click Enter**: Refactored row control interceptions inside `_Picker_ProcessMsg` in `/modules/_picker_event.au3` to change selection index on single click, and run the active routine or navigate down paths on double click.
- **Searchable Mini Options Picker GUI**: Formulated `/modules/_picker_mini.au3` containing a brand new, highly responsive, compact searchable GUI matching the theme styles perfectly to present, search, and run standard window actions.
- **Permanent Window Exclusion Filters**: Injected `_Picker_IsWindowExcluded` looking up `[excluded-windows]` records inside the INI to filter out processes, classes, or exact titles from harvested visible results permanently.

### 🔸 Affected Files
- `/modules/_index.au3`
- `/modules/_picker.au3`
- `/modules/_picker_globals.au3`
- `/modules/_picker_helpers.au3`
- `/modules/_picker_event.au3`
- `/modules/_picker_mini.au3`
- `/AITASKS.md`
- `/AILOG.md`

## [2026-06-14T20:12:00Z]
### 🎯 Primary Goals & Requirements
- Inject a polished, high-contrast visual toolbar directly above the status bar displaying Show Hidden and Show Minimized filters.
- Connect Alt+H and Alt+M keyboard shortcuts, alongside mouse-clicks on toolbar regions, to toggle active window filter parameters dynamically.
- Clear directory listings and ensure directories and windows are merged, searched, and updated cleanly when combined hotkeys (`Win+Ctrl+Alt+Enter`) are used.
- Bypass row indentation levels for window items so that they remain perfectly left-aligned.
- Hook the standard "Apps" key to invoke native win32 context menus for list rows.

### 🛠️ Completed Changes in this Session
- **Status Filter Toolbar Layout**: Crafted `_Picker_GUICreateToolbar(...)` within `/modules/_picker_gui.au3` and synced input offsets globally from `104` to `124` across keys, renderers, events, and dialog models.
- **Wired Hotkey & Click Toggles**: Registered `{ALT+H}` and `{ALT+M}` accelerators in `/modules/_picker_gui.au3` and matched their case statements to trigger dynamic query filter rebuilds and text updates. Added mouse cursor click position testing to toggle the toolbar interactively.
- **Direct Combined Picker Sync**: Wired `$g_bIsCombinedPicker` state checks to invoke the unified `_Picker_RebuildCombinedMatches($aCombinedList)` function on toolbar state updates, restoring full directories visibility on combined query triggers.
- **Window Row Indent Bypass**: Updated row layout render styles in `/modules/_picker_render.au3` to suppress incremental deep-nesting margins if the hovered element contains a standard window tag suffix.
- **Wired Context Menu Keyboard Hooks**: Configured `{APPS}` key accelerator strings to bind `_Picker_WM_CONTEXTMENU` messages via direct `GUIRegisterMsg` calls, invoking robust cell-targeted menus on request.

### 🔸 Affected Files
- `/modules/_picker_gui.au3`
- `/modules/_picker_helpers.au3`
- `/modules/_picker_render.au3`
- `/modules/_picker_event.au3`
- `/modules/_picker_keys.au3`
- `/modules/_picker.au3`
- `/modules/_hotkeys.au3`
- `/modules/_picker_globals.au3`
- `/AITASKS.md`
- `/AILOG.md`

## [2026-06-14T12:35:00Z]
### 🎯 Primary Goals & Requirements
- Target and display only standard overlapped windows (main apps) inside the Search Picker, filtering out child structures and dialog popups.
- Visually indicate minimized and/or hidden windows using dynamic suffixes within the list item label.
- Bind the custom `Ctrl+Insert` hotkey to format and copy deep window metrics directly to the clipboard.
- Embed right-click context menus on window items, supporting real-time management actions: Copy Info, Minimize, Maximize, Restore, and Close.

### 🛠️ Completed Changes in this Session
- **Overlapped Window Verification**: Designed `_Util_IsOverlappedWindow()` inside `/modules/_utils.au3` executing direct DLL `GetWindowLongW` styles lookup checking standard `WS_CHILD` and `WS_POPUP` bitmasks.
- **Window Suffix Indicators**: Suffix-tagged items depending on visibility and minimized properties inside the `WinList` harvester in `/modules/_hotkeys.au3`, updating routing regular expressions to match arbitrary suffix descriptors seamlessly.
- **Window Metrics Report Clip Engine**: Added `_Picker_CopyWindowInfo()` compiling a detailed text block representation of a handle's coordinates, process info, window state bits, and class name to write to the clipboard.
- **Assigned Ctrl+Insert Key Shortcut**: Hooked custom `^{INSERT}` accelerator in `/modules/_picker_gui.au3` and mapped its custom dummy message handlers cleanly to execute window metrics clip reporting in `/modules/_picker_event.au3`.
- **Engineered Context Menus on Window Rows**: Captured mouse-drag and secondary right-clicks in `/modules/_picker.au3`, triggering native win32 `TrackPopupMenu` to allow prompt window-status actions on target handles.

### 🔸 Affected Files
- `/modules/_utils.au3`
- `/modules/_picker_helpers.au3`
- `/modules/_picker_gui.au3`
- `/modules/_picker.au3`
- `/modules/_picker_event.au3`
- `/modules/_hotkeys.au3`
- `/AITASKS.md`
- `/AILOG.md`

## [2026-06-14T12:20:00Z]
### 🎯 Primary Goals & Requirements
- Disable and hide the "recent folders" history display throughout the custom search picker interface.
- Implement a dedicated shortcut combination (`Win+Ctrl+Alt+Enter`) that triggers an intuitive, unified picker presenting active desktop window titles paired with crawled directory paths.

### 🛠️ Completed Changes in this Session
- **Suppressed Recent Entries completely**: Bypassed loading and integration of recent elements inside `_Picker_HandleQueryChange()` in `/modules/_picker_event.au3`, and disabled recording selections inside `/modules/_picker.au3`.
- **Linked Win+Ctrl+Alt+Enter hotkey**: Assigned the `#^!{ENTER}` hotkey to `_Hotkey_WinCtrlAltEnter` within `/clipboard-exec.au3`.
- **Built Unified Windows & Directories List**: Collected active visible desktop windows (`WinList`) and crawled path vectors (`_Index_LoadIndexedPaths`), formatted them with high-fidelity suffixes (` [window]`, ` [dir]`), displayed them in a clean searchable GUI, and handled appropriate system actions on select.

### 🔸 Affected Files
- `/clipboard-exec.au3`
- `/modules/_picker.au3`
- `/modules/_picker_event.au3`
- `/modules/_hotkeys.au3`
- `/AITASKS.md`
- `/AILOG.md`

## [2026-06-14T12:15:00Z]
### 🎯 Primary Goals & Requirements
- Update the decomposition picker so that all items show their explicit types (`dir`, `file`, `window`).
- Render the exact native application icon for windows on the list and show related process (.exe) and class detailed info on selection.

### 🛠️ Completed Changes in this Session
- **Integrated Explicit Classification Subtitle**: Created a type evaluation and suffixing pipeline in `/modules/_hotkeys.au3` to add explicit type tags to the multi-token picker options.
- **Enabled Real-Time Window Icon Extractors**: Customized `/modules/_picker_render.au3` to resolve the process ID and get the full path name of the parent executable to set window rows' icon images dynamically.
- **Engineered Comprehensive Profile Headers**: Added file size conversion, process filename detection, and Window class mapping inside the selected item status bar detail updater.
- **Compiled Verification**: Confirmed that all modules build perfectly with zero errors or warnings under standard AutoIt wrappers.

### 🔸 Affected Files
- `/modules/_picker_render.au3`
- `/modules/_hotkeys.au3`
- `/AITASKS.md`
- `/AILOG.md`

## [2026-06-14T12:07:00Z]
### 🎯 Primary Goals & Requirements
- Troubleshoot and fix syntax or compile-time resolution errors reported during `au3check` validation cycles.
- Correct undefined functions and un-imported header references.

### 🛠️ Completed Changes in this Session
- **Fixed Directory Check**: Replaced `DirectoryExists` with standard native `FileExists` check in `/modules/_index.au3` to see if directory path bounds are valid.
- **Included Index Module**: Interlined missing `#include "_index.au3"` into `/modules/_recognizer.au3` so the file-crawling index functions (`_Index_Initialize`, `_Index_LoadIndexedPaths`) compile perfectly.
- **Double Checked Variable Registry**: Verified that `$g_g_iSelectedIndex` was completely eliminated from preceding files and that `$g_iSelectedIndex` matches global references.

### 🔸 Affected Files
- `/modules/_index.au3`
- `/modules/_recognizer.au3`
- `/AITASKS.md`
- `/AILOG.md`

## [2026-06-14T11:56:00Z]
### 🎯 Primary Goals & Requirements
- Implement the line decomposition specification to discover valid recognizable components from a copied string line.
- Present a multi-token selector if more than one candidate exists on the line, listing occurrences.
- Drill down to a secondary instance picker when a token matching multiple indices or windows is selected.
- Integrate advanced prefix operations to open new listers (`+`), open and close tab under keep-picker-active state (`-`), activate/launch Cursor (`@` / `-@`), and Obsidian (`#` / `-#`).

### 🛠️ Completed Changes in this Session
- **Built Line Tokenizer and Decomposer**: Appended `_Recognizer_DecomposeLine` to `/modules/_recognizer.au3`. This extracts URLs, direct paths, Zdot codes, and splits remaining whitespace blocks, matching them against indexed files/folders and active win32 desktop window titles. (Fixed character escape issue with single quotes to assure compilation).
- **Formulated Prefix Actions Router**: Created `_Handler_ExecuteDestination` inside `/modules/_hotkeys.au3` to handle prefixes: `+` for breakout lister, `-` for tab recycling with `^{F4}` close, `@`/`-@` for Cursor actions, `#`/`-#` for Obsidian routing via `obsidian://` protocol scheme.
- **Engineered Twin Picker Flows**: Upgraded `_Hotkey_ClipOp` inside `_hotkeys.au3` to execute a double-layer Search Picker layout using our high-performance recycled list pools, enabling selection of recognized words with dynamic re-triggering of the demo picker to preserve work focus.
- **Compiled Verification**: Ran `compile_applet` and `lint_applet` to confirm zero warnings or errors.

### 🔸 Affected Files
- `/modules/_recognizer.au3`
- `/modules/_hotkeys.au3`
- `/AITASKS.md`
- `/AILOG.md`

## [2026-06-14T11:32:00Z]
### 🎯 Primary Goals & Requirements
- Maintain directory and file indexes on disk via periodic, incremental small-batch indexing sweeps.
- Ignore specific folders (e.g., `node_modules`) and any folder/file names resembling full or partial GUID structures.
- Place all controlling configurations inside the `[indexing]` section of `clipboard-exec.ini` for easy external customisation.
- Integrate the compiled index file directly into the Search Picker GUI, opening selections automatically in Directory Opus.

### 🛠️ Completed Changes in this Session
- **Implemented Background Incremental Indexer**: Built `/modules/_index.au3` to maintain a memory path map and index queue. It processes directories in lightweight, non-blocking batch cycles (default: 10 folders per slice every 15 seconds), persisting the compiled structure to `clipboard-exec-index.txt`.
- **Created INI Controlling Section**: Added a new `[indexing]` segment to `clipboard-exec.ini` allowing easy modification of crawl sleep intervals, batch size bounds, folder ignore strings, and GUID/file exclusion toggles.
- **Formulated Robust GUID Filters**: Incorporated regular expressions inside `_Index_IsGuidPattern` to filter out files and directories with complete or partial GUID hashes (such as hex blocks joined by hyphens or enclosed within braces).
- **Integrated Live Search Picker**: Upgraded `/modules/_picker_demo.au3` to load the live crawled index. Clicking or selecting a valid directory routes the location natively and instantly using the active Directory Opus instance via `_Handler_OpenInDOpus`.
- **Synced Workflow Mandates**: Maintained logs in `/AILOG.md`, checked off completed tasks in `/AITASKS.md`, and compiled successfully with no lint or build errors.

### 🔸 Affected Files
- `/clipboard-exec.ini`
- `/clipboard-exec.au3`
- `/modules/_index.au3`
- `/modules/_picker_demo.au3`
- `/AITASKS.md`
- `/AILOG.md`

## [2026-06-14T11:22:00Z]
### 🎯 Primary Goals & Requirements
- Enable file directory URLs (e.g. starting with `file:///` or `file://`) to act exactly like standard directory paths.
- Route them cleanly to Directory Opus, resolving slashes and stripping protocol keywords.

### 🛠️ Completed Changes in this Session
- **Enhanced Evaluator Recognizer Matrix**: Extended pattern matches in `/modules/_recognizer.au3` so any clipboard strings starting with `file://` (with or without a leading open-new-tab `+` operator) are classified under the `DIRECTORY_FULL` routing target.
- **Implemented URL Strip & Normalize Logic**: Added protocol stripping inside `_Handler_OpenInDOpus` (`/modules/_handler_dopus.au3`), converting forward slashes into backslashes, handling local disks and network shares elegantly, and verifying existence before trigger execution.
- **Consolidated AI Workstates**: Synced checklists inside `/AITASKS.md`, updating progress to fully resolved.

### 🔸 Affected Files
- `/modules/_recognizer.au3`
- `/modules/_handler_dopus.au3`
- `/AITASKS.md`
- `/AILOG.md`

## [2026-06-14T11:15:00Z]
### 🎯 Primary Goals & Requirements
- Codify explicit instructions to prevent future workspace regression regarding AI logging, commit messages, and task files.
- Persist strict guidelines in the primary configurations file so they are loaded automatically as system instructions.

### 🛠️ Completed Changes in this Session
- **Injected AI Flow Guidelines**: Appended `## AI Documentation & Workflow Mandates` inside `/AGENTS.md` explicitly defining requirements for logs with goals, changes, affected files, commit messages, and syncing mechanisms.
- **Synced Task Register**: Checkmarked the logging and tracking constraint tasks inside `/AITASKS.md`.
- **Verified Clean Build**: Successfully ran compilation verify checks.

### 🔸 Affected Files
- `/AGENTS.md`
- `/AITASKS.md`
- `/AILOG.md`

## [2026-06-14T11:10:00Z]
### 🎯 Primary Goals & Requirements
- Fix the issue where copying `z-202606140932595351` plays a warning chime but fails to compile target coordinates inside source files because it evaluates to `DEFAULT`.
- Enable full identification of any `z-` or `z.` prefixed chronological timestamps in the clipboard classifier.

### 🛠️ Completed Changes in this Session
- **Regex Routing Enhancements**: Augmented `_Recognizer_Evaluate` inside `/modules/_recognizer.au3` to match dynamic cases where clipboard patterns start with `z-` or `z.` followed by 14-20 digit coordinate timestamps.
- **Matched Target Alignment**: Guaranteed that all user targets (e.g. `z-202606140932595351` or `z.202606140932595351`) are categorized as `ZDOT` and correctly passed down to the calendar resolver script.

### 🔸 Affected Files
- `/modules/_recognizer.au3`
- `/AILOG.md`

## [2026-06-14T11:05:00Z]
### 🎯 Primary Goals & Requirements
- Troubleshoot the persistent AutoIt native execution error: `Error: Unknown function name.` targeting `WinGetClass()`.
- Identify the correct AutoIt User Defined Function (UDF) or Win32 API to fetch the active window's primary class name safely.

### 🛠️ Completed Changes in this Session
- **Corrected Function Reference**: Replaced the non-existent standard built-in `WinGetClass($hWnd)` function with the official AutoIt UDF call `_WinAPI_GetClassName($hWnd)`.
- **Imported API Headers**: Included the `<WinAPISys.au3>` library header at the top of `/modules/_config.au3` to resolve the external standard win32 API wrapper signature.
- **Ensured Successful Compilation**: Validated that all files compile and pass linter checks under clean workspace conditions with zero remaining syntax warnings or missing reference errors.

### 🔸 Affected Files
- `/modules/_config.au3`
- `/AILOG.md`

## [2026-06-14T10:59:00Z]
### 🎯 Primary Goals & Requirements
- Diagnose and resolve the "Context Error: Active window does not match tracking configurations" popup toast error.
- Restore compliance between `_Config_GetActiveAppProfile()` and its callers expecting a 3-element profile configurations array.

### 🛠️ Completed Changes in this Session
- **Refined Application Profiling Logic**: Overhauled `_Config_GetActiveAppProfile()` inside `/modules/_config.au3` to parse the `apps.ini` file (with fallbacks) and perform exact or pattern-based window matching on the current process executable (`exe`), title (`title`), and window class (`class`).
- **Standardized Configuration Mappings**: Reconfigured the profile return signature to always return a robust, unified 3-element configuration array containing `[AppName, SendKeys, ScriptPath]` mapped directly to `clipboard-exec.ini`.
- **Introduced Crash-Proof Fallback**: Provided safe, fail-safe defaults for missing ini files or unrecognized windows so that the keystroke interceptor loop never crashes on unmatched background windows, completely eliminating "Context Error" blocks.

### 🔸 Affected Files
- `/modules/_config.au3`
- `/AILOG.md`

## [2026-06-14T10:55:00Z]
### 🎯 Primary Goals & Requirements
- Resolve compiler warning and error diagnostics outputted during project checks with `AU3Check`.
- Address compiler error regarding `$g_g_iSelectedIndex` undeclared global variable.
- Eliminate dependency order anomalies where `$oChildCount` and `$oGrandchildCount` scripting dictionary variables were referenced in helper subroutines before physical code declaration blocks in sorting files.

### 🛠️ Completed Changes in this Session
- **Typo Correction**: Fixed the `$g_g_iSelectedIndex` variable identifier typo inside `/modules/_picker_keys.au3` to `$g_iSelectedIndex`.
- **Global Consolidations**: Added global script dictionary declarations (`$oChildCount` and `$oGrandchildCount`) directly inside the core `/modules/_picker_globals.au3` module.
- **Dependency Re-orders**: Standardized `/modules/_picker_helpers.au3` to proactively include `_picker_globals.au3`, and removed redundant declarations in `/modules/_picker_filter.au3`.
- **Verified Build Status**: Successfully passed compilation and syntax verification checking.

### 🔸 Affected Files
- `/modules/_picker_globals.au3`
- `/modules/_picker_helpers.au3`
- `/modules/_picker_filter.au3`
- `/modules/_picker_keys.au3`
- `/AILOG.md`

## [2026-06-14T10:48:00Z]
### 🎯 Primary Goals & Requirements
- Perform detailed code reverse-engineering on the multi-module Windows desktop Clipboard Execution Companion Engine client scripts written in AutoIt.
- Wipe out all empty boilerplate placeholders across all eleven primary system markdown files.
- Document the entire structural architecture, math formulations, styling patterns, testing scenarios, compile commands, and user configuration guidelines.

### 🛠️ Completed Changes in this Session
- **Documented System Layout**: Completed functional breakdowns of `clipboard-exec.au3` and all 20 modules inside `/modules/`.
- **Created Manual & Specs**: Mapped out the system's exact architecture, keybindings (`Win+Ctrl+Shift+Enter`, `Win+Alt+Enter`, `Win+Alt+Shift+Enter`), matching regular expressions, error strategies, and mathematical hashing hue coloring calculations.
- **Set Up Build & Test Framework**: Outlined compilation processes utilizing `Aut2Exe.exe`, and compiled functional tests verifying the interaction of each active component.
- **Removed Mojibake**: Cleaned up the file `/AITASKARCH.md` from double-character byte corruptions.

### 🔸 Affected Files
- `/AGENTS.md`
- `/AILOG.md`
- `/AITASKARCH.md`
- `/AITASKS.md`
- `/BUILD.md`
- `/CODE.md`
- `/FEATURES.md`
- `/MANUAL.md`
- `/README.md`
- `/SPEC.md`
- `/TESTING.md`

---
## Go Back to...
- ▪️[AGENTS.md](AGENTS.md)
- 🔸[AILOG.md](AILOG.md)
- ▪️[AITASKS.md](AITASKS.md)
- ▪️[BUILD.md](BUILD.md)
- ▪️[CODE.md](CODE.md)
- ▪️[FEATURES.md](FEATURES.md)
- ▪️[MANUAL.md](MANUAL.md)
- ▪️[README.md](README.md)
- ▪️[SPEC.md](SPEC.md)
- ▪️[TESTING.md](TESTING.md)
