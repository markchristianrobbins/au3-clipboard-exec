# Features

---
## Back to...
- ▪️[AGENTS.md](AGENTS.md)
- ▪️[AILOG.md](AILOG.md)
- ▪️[AITASKARCH.md](AITASKARCH.md)
- ▪️[AITASKS.md](AITASKS.md)
- ▪️[BUILD.md](BUILD.md)
- ▪️[CODE.md](CODE.md)
- 🔸[FEATURES.md](FEATURES.md)
- ▪️[MANUAL.md](MANUAL.md)
- ▪️[README.md](README.md)
- ▪️[SPEC.md](SPEC.md)
- ▪️[TESTING.md](TESTING.md)

Welcome to **Clipboard Exec Engine**! This utility acts as a background automation controller that hooks system actions to active window profiles, watches global hotkeys, parses raw clipboard queries with Regular Expression matching, and fires direct pathways to editors, and file listers.

## Project Name
- clipboard-exec
## Project Language
- AutoIt v3 (AU3)
## Project Location
- `C:\_\au3-clipboard-exec\`

## Project Modules
The modular structural layout dividing functions across decoupled components:

### Main Orchestrator
* **`clipboard-exec.au3`**
  * Spawns singleton instances, manages the persistent tray event loop, and registers global hotkeys (`Win+Ctrl+Shift+Enter`, `Win+Alt+Enter`, `Win+Alt+Shift+Enter`).

### Core Modules
* **`modules\_config.au3` (Configuration & UI Profile Scanner)**
  * Returns active application window coordinates, titles, and processes. Returns context-specific keystroke macros.
* **`modules\_recognizer.au3` (Regex Clipboard Classifier)**
  * Evaluates raw copied text patterns to dispatch URLs with custom schemes, directories, commands, and temporal shortcuts.
* **`modules\_ui.au3` (Dynamic Notifications)**
  * Displays borderless always-on-top custom feedback toasts cleanly without interrupting user workspace typing flow.
* **`modules\_utils.au3` (Win32 Keyboard & Audio Helpers)**
  * Flushes physical Alt/Shift/Ctrl/Win states before sending key sequences, preventing layout locks.

### Action Handlers
* **`modules\_handler_cmd.au3` (CMD Interceptor Engine)**
  * Executes silent command sequences invisibly. Spawns hidden subprocesses and redirects Standard Output (stdout/stderr) blocks directly back into the system clipboard.
* **`modules\_handler_dopus.au3` (Directory Opus Automator)**
  * Directly manages `dopusrt.exe` connections. Sanitizes trailing backslash inputs, targets directory lister reuse tab configurations, or opens new isolated windows.
* **`modules\_handler_zdot.au3` (Zdot IDE Synchronization)**
  * Resolves chronological timestamp markers of files. Inspects nested directory index blocks under `C:\$data\zdoti\`, parses targeted scripts, and calls Cursor IDE directly highlighting specific lines.

### Interactive Search Picker
* **`modules\_picker.au3`** (Central Orchestrator)
* **`modules\_picker_gui.au3`** (Pre-allocated Control Structures)
* **`modules\_picker_render.au3`** (Fuzzy Sub-Match Renderer)
* **`modules\_picker_filter.au3`** (Fuzzy Sieve Scoring & Word Levels Sort)
* **`modules\_picker_style.au3`** (Dynamic Directory Hashing Hues & Contrast Math)
* **`modules\_picker_event.au3`** (Interactive Messages Loop)
* **`modules\_picker_keys.au3`** (Responsive Bound Key Offsets)
* **`modules\_picker_recent.au3`** (External Recent History Persistence)
* **`modules\_picker_globals.au3`** (Global States)
* **`modules\_picker_helpers.au3`** (String Separator Parsers)
* **`modules\_picker_icons.au3`** (Shell Folder Icon Type Dictionary Map)

---

## Feature Groups

### 📦 1. Input Recognition & Action Routers
<a id="z1" name="z.1"></a>
Defines the background modules scanning active window states, checking clipboard data types, and routing strings down action channels.
- **[Clipboard Format Classifiers](#clipboard-format-classifiers)** - Evaluates URL, Directory, ZDot, or Commands regular expressions.
- **[Silent CMD Interceptor](#silent-cmd-interceptor)** - Resolves console operations invisibly and captures output logs.
- **[Directory Opus Automator](#directory-opus-automator)** - Opens full paths, reusing active views or instantiating new windows.
- **[Zdot Temporal Coordinates Sync](#zdot-temporal-coordinates-sync)** - Locates file registers across chronological folders on disk.

### 🎨 2. Custom Search Picker UI
<a id="z2" name="z.2"></a>
An interface overlay built from scratch rendering matching paths, highlighting letter subsets, and persisting selection history.
- **[Pre-Allocated Row Pool](#pre-allocated-row-pool)** - Eliminates UI creation lag by recycling list labels.
- **[Fuzzy Sub-Match Highlight](#fuzzy-sub-match-highlight)** - Displays typing matches with custom color styles.
- **[Dynamic Directory Hashing Hues](#dynamic-directory-hashing-hues)** - Generates unique branding colors derived from folder names.
- **[Recursive Explore Sub-Mode](#recursive-explore-sub-mode)** - Navigates nested directory trees with interactive controls.

---

## All Features

### Clipboard Format Classifiers
- Group: [Input Recognition & Action Routers](#z1)
Uses regularized expressions to classify raw string clips. Automatically launches default web browsers for URL patterns (`https:`, `http:`, or `aip:` protocol schemes), filters valid drive/UNC structures for full folder paths, maps dot notations (`.`, `@`) straight to the Zdot engine, and intercept terminal blocks (`>`, `cmd `) to invoke the console handler.

### Silent CMD Interceptor
- Group: [Input Recognition & Action Routers](#z1)
Processes trailing arguments of text blocks initiated with the `>` operator. Automatically compiles executable vectors invisibly under hidden `@SW_HIDE` states, registers a hard wait limit of 10 seconds to avoid locking active threads, reads raw bytes out of child process memory channels, and pipes combined logs (StdOut + StdErr) directly back into system clipboard structures.

### Directory Opus Automator
- Group: [Input Recognition & Action Routers](#z1)
Targets GPSoftware's Directory Opus. Translates path layouts, safely guards raw partition drive indicators, and runs `dopusrt.exe` arguments. Maps the prefix marker `+` to breakout new directory containers, and defaults to standard lister tab recycling configurations `NEWTAB=findexisting,tofront` before focusing window sheets to the front stack.

### Zdot Temporal Coordinates Sync
- Group: [Input Recognition & Action Routers](#z1)
Resolves numerical markers that correspond to source file changes. Extracts 14-digit timestamps, locates custom calendar registers in `C:\$data\zdoti\YYYY\MM\DD\*.zdoti`, parses local entries to extract target script filenames, performs quick substring matching to isolate row indexes, and spawns the Cursor editor directly highlighting specified lines via `--goto` arguments.

### Pre-Allocated Row Pool
- Group: [Custom Search Picker UI](#z2)
Eliminates interface drawing lag. Spawns 36 recycled label elements on initial startup, dynamically positioning and modifying properties of existing elements rather than constructing controls inside change loops.

### Fuzzy Sub-Match Highlight
- Group: [Custom Search Picker UI](#z2)
Compares search queries with folder base names. Splits characters into three visual parts (Pre-Match, Highlight, Post-Match) on row renders to output elegant Segoe UI font selections alongside high-contrast colors, updating letter bounds dynamically as users type.

### Dynamic Directory Hashing Hues
- Group: [Custom Search Picker UI](#z2)
Generates folder branding colors. Converts characters of parent folders into unified numbers via ASCII sums, translates values to fractional angles across Hue spectrum grids, converts values to RGB matrices, and dims values on secondary rows to keep contrast elegant.

### Recursive Explore Sub-Mode
- Group: [Custom Search Picker UI](#z2)
Enables quick folder exploration. Pressing `Ctrl+Enter` lock-scrolls directories as parents, updates active dictionaries with nested child counts, and parses subdirectories. Backspace returns to grandparent directories, and escaping exits explore layers without losing search states.

---
## Go Back to...
- ▪️[AGENTS.md](AGENTS.md)
- ▪️[AILOG.md](AILOG.md)
- ▪️[AITASKS.md](AITASKS.md)
- ▪️[BUILD.md](BUILD.md)
- ▪️[CODE.md](CODE.md)
- 🔸[FEATURES.md](FEATURES.md)
- ▪️[MANUAL.md](MANUAL.md)
- ▪️[README.md](README.md)
- ▪️[SPEC.md](SPEC.md)
- ▪️[TESTING.md](TESTING.md)
