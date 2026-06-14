# Manual

This guide describes the structural architecture, module layout, internal algorithms, optimization behaviors, and technical specifications of the **Clipboard Exec Engine** codebase.

---
## Back to...
- ▪️[AGENTS.md](AGENTS.md)
- ▪️[AILOG.md](AILOG.md)
- ▪️[AITASKARCH.md](AITASKARCH.md)
- ▪️[AITASKS.md](AITASKS.md)
- ▪️[BUILD.md](BUILD.md)
- ▪️[CODE.md](CODE.md)
- ▪️[FEATURES.md](FEATURES.md)
- 🔸[MANUAL.md](MANUAL.md)
- ▪️[README.md](README.md)
- ▪️[SPEC.md](SPEC.md)
- ▪️[TESTING.md](TESTING.md)

## 🏗️ 1. Architecture Overview

The background operational loop interacting with specific sub-handlers and the Search Picker GUI:

```text
 +-----------------------------------------------------------------+
 |                    [Windows OS / Shell Env]                      |
 +-------------------------------+---------------------------------+
                                 |  Win+Alt+Enter / Win+Shift+Alt+Enter
                                 v
 +-------------------------------+---------------------------------+
 |                [clipboard-exec.au3: Core Engine]                 |
 +-----+-------------------------+---------------------------+-----+
       |                         |                           |
       v                         v                           v
 +-----+--------+         +------+-------+            +------+-----+
 |  _config.au3 |         | _recognizer  |            |  _utils.au3|
 |  (Window Map)|         | (Evaluator)  |            |  (Modifier)|
 +--------------+         +------+-------+            +------------+
                                 |
         +-----------------------+-----------------------+
         |                       |                       |
         v (URL/Path Match)      v (Zdot Token)          v (CommandLine)
 +-------+------+        +-------+------+        +-------+------+
 | _handler_dopus|       | _handler_zdot|        | _handler_cmd |
 |  (Opus Autom)|       | (Cursor Sync)|        | (Silent CLI) |
 +-------+------+        +--------------+        +--------------+
         |
         v (Wildcard Multiple Directory Match Trigger)
 +-------+---------------------------------------------------------+
 |                      [_picker.au3: UI Overlay]                  |
 +-----------------------------------------------------------------+
```

### Operational Lifecycle
1. **Startup**: `_Engine_UnloadExistingInstance()` looks up `.instance.lock`, terminates matches via PIDs, writes its own PID to log, and plays chime sound `0x00000040`.
2. **Hotkey Bindings**: Registers global keyboard interrupts via DLL user32 hooks.
3. **Context Sweep**: On pressing `Win+Alt+Enter`, the system extracts the foreground active window class information and sends keystroke sequences defined inside INI configurations to copy text.
4. **Evaluator**: `_Recognizer_Evaluate` executes regular expressions on copied values.
5. **Action Routing**: Runs specific handlers (e.g. executes silent CMD buffers or navigates DOpus paths).
6. **Fuzzy Search Picker**: If matches yield broad candidates, `_Picker_ShowGUI` renders a custom interactive dark-theme list where users can select paths or explore subfolders.

## 🧠 2. Core Modules & Systems

- **System Tray Loop (`clipboard-exec.au3`)**: Implements `TrayGetMsg()` polling with a 10ms CPU sleep guard to capture tray exit button callbacks.
- **Modifiers Buffer Manager (`_utils.au3`)**: Blocks main execution via `GetAsyncKeyState` until modifier keys (Alt, Win, Control) are cleared, flushing virtual state arrays cleanly.
- **High-Performance Pre-Allocated Row Pool (`_picker_gui.au3`)**: Creates 36 label rows upon GUI instantiation. The list controller (`_picker_render.au3`) updates existing labels directly to prevent window rendering stutter on rapid keystrokes.
- **Scripting.Dictionary Memory Indexes (`_picker_filter.au3`)**: Spawns high-speed Windows COM index dictionary arrays (`Scripting.Dictionary`) dynamically caching child and grandchild folder counts, avoiding recursion lag on deep folder navigations.

## 🔎 3. Core Algorithm & Mathematical Formulas

The Search Picker relies on a deterministic hashing algorithm that extracts folder base names and translates them into a distinctive background brand hue.

$$\text{ASCII\_Sum}(S) = \sum_{i=1}^{\text{Len}(S)} \text{Asc}(S_i)$$

$$\text{Hue\_Value} = \frac{\text{ASCII\_Sum}(S) \pmod{360}}{360}$$

Based on $\text{Hue\_Value}$, fractional RGB indices are calculated using piecewise linear hue transformations inside `_picker_style.au3`:

$$\text{Intensity}(fI) = \begin{cases} 
      1 & fI \in \{0, 6\} \\
      fF & fI = 0 \text{ (increasing)} \\
      1 - fF & fI = 1 \text{ (decreasing)} \\
      0 & \text{otherwise}
   \end{cases}$$

For rows that are unselected, RGB color channels are dimmed linearly via a factor parameter to keep background contrast balanced:

$$\text{RGB\_Dimmed} = \text{Floor}(\text{RGB\_Raw} \times 0.65)$$

## 🛰️ 4. Commands, Keybindings & Context Flags

- **Global Kill Intercept**:
  - **Key combination**: `Win+Ctrl+Shift+Enter` (AutoIt mapping: `#^+{ENTER}`)
  - **Logical callback**: Cleans lock files and terminates background runtime loops.
- **Context App Scanner**:
  - **Key combination**: `Win+Alt+Enter` (AutoIt mapping: `#!{ENTER}`)
  - **Logical callback**: Scans active PID titles, retrieves corresponding INI command keys, triggers copy sequences, and routes strings through the matcher.
- **Explicit Clipboard Router**:
  - **Key combination**: `Win+Alt+Shift+Enter` (AutoIt mapping: `#!+{ENTER}`)
  - **Logical callback**: Skips context copying and immediately routes active clipboard text contents to corresponding handler engines.

## 🔧 5. Workspace Build & Configuration

- **`C:\$data\apps.ini` (System Window Definitions)**:
  - Configures window attributes to map foreground executables to app profiles.
  ```ini
  [Cursor]
  class=chrome_widgetwin_1
  exe=cursor.exe
  titlematchmode=2
  ```
- **`C:\$data\clipboard-exec.ini` (Macro Execution Keys)**:
  - Maps profiles to target keys or `.au3` scripts.
  ```ini
  [Cursor]
  sendkeys={HOME}+{END}^c
  ```
- **`@AppDataDir\OpusRecentFolders.txt` (Directory History)**:
  - Text register storing a rolling log of up to 5 recently accessed folders.

---
## Go Back to...
- ▪️[AGENTS.md](AGENTS.md)
- ▪️[AILOG.md](AILOG.md)
- ▪️[AITASKS.md](AITASKS.md)
- ▪️[BUILD.md](BUILD.md)
- ▪️[CODE.md](CODE.md)
- ▪️[FEATURES.md](FEATURES.md)
- 🔸[MANUAL.md](MANUAL.md)
- ▪️[README.md](README.md)
- ▪️[SPEC.md](SPEC.md)
- ▪️[TESTING.md](TESTING.md)
