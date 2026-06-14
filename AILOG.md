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
feat: implement periodic incremental indexing sweeps with GUID and ignore exclusions

- Created '_index.au3' implementing background periodic crawlers triggered in small, zero-lag batch slices.
- Placed indexing variables ('enabled', 'interval_ms', 'batch_size', 'ignore_dirs', 'ignore_guids') inside 'clipboard-exec.ini'.
- Implemented robust regex matching for standard and partial GUIDs to exclude matching names.
- Upgraded Search Picker launcher '_picker_demo.au3' to load the real crawled path indexes and route folders to Directory Opus.
```

## Log Entries

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
