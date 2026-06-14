# Testing

You can use this interactive test sheet directly with VS Code / Cursor to verify that all systems in **Clipboard Exec Engine** are fully functional. Put your cursor on these checkbox lines, and mark them done!

---
## Back to...
- ▪️[AGENTS.md](AGENTS.md)
- ▪️[AILOG.md](AILOG.md)
- ▪️[AITASKARCH.md](AITASKARCH.md)
- ▪️[AITASKS.md](AITASKS.md)
- ▪️[BUILD.md](BUILD.md)
- ▪️[CODE.md](CODE.md)
- ▪️[FEATURES.md](FEATURES.md)
- ▪️[MANUAL.md](MANUAL.md)
- ▪️[README.md](README.md)
- ▪️[SPEC.md](SPEC.md)
- 🔸[TESTING.md](TESTING.md)

---

## 🔵 1. Setup & Environment Initializations
- [ ] **Dual-Instance Collision Safeguard**
    - **Instructions**: Launch `clipboard-exec.au3`, then attempt to launch a second instance.
    - **Expected Results**: The second instance detects the active lock file, terminates the first instance via PID, establishes its own lock, runs startup chimes, and initializes successfully.
- [ ] **Central Paths Configuration Check**
    - **Instructions**: Edit `C:\$data\clipboard-exec.ini` and verify variables are read cleanly without system crashes.
    - **Expected Results**: Values are loaded successfully of the active window profile.

## 🟢 2. Primary Functionality & Core Operations
- [ ] **Fuzzy Search Picker Launch (Demo mode)**
    - **Instructions**: Run `modules\_picker_demo.au3` to populate the list with 22 dummy directories.
    - **Expected Results**: Renders a dark-theme, borderless list popup with dynamic branding colors. Selecting a path outputs the result.
- [ ] **Silent DOS Command Interception**
    - **Instructions**: Copy the payload `> echo hello world` to the clipboard, then trigger the parser shortcut (`Win+Alt+Shift+Enter`).
    - **Expected Results**: Executes the command invisibly, captures standard output, writes it to the clipboard, and triggers a window notification toast.

## ⚡ 3. Granular Property Checks & Edge Boundaries
- [ ] **Directory Slash-Strip Boundaries**
    - **Instructions**: Copy `C:\$data\\` with trailing backslashes and trigger `Win+Alt+Shift+Enter`.
    - **Expected Results**: Safely cleans slashes, target directory-existence check passes, and folder opens in Directory Opus.
- [ ] **System Root Drive Exception**
    - **Instructions**: Copy partition root `C:` without backslashes and trigger folder routing.
    - **Expected Results**: Append single backslash `C:\` preventing OS crashes.

## 🕹️ 4. Layout, Rendering & States Loops
- [ ] **Directory Hash Branding Contrast**
    - **Instructions**: Highlight row items in the Search Picker list.
    - **Expected Results**: Dynamic ASCII branding color changes to high-contrast colors on hover/select, dimming unselected rows' colors by a factor of 65%.
- [ ] **Recursion Explorer Mode**
    - **Instructions**: Open the Search Picker and press `Ctrl+Enter` on a directory.
    - **Expected Results**: Lock-scrolls view into the folder, fetching subdirectories and displaying child counts. Pressing Backspace returns to grandparent directories.

## 🚀 5. Advanced Integrations & Performance Checks
- [ ] **Zdot IDE Coordinates Navigation**
    - **Instructions**: Copy temporal token `z.202606140317055140`, then trigger `Win+Alt+Shift+Enter`.
    - **Expected Results**: Locates calendar registers on disk, highlights the line index in target source file, and launches the Cursor editor with specific line focus.
- [ ] **Keyboard Modifiers Flush Verification**
    - **Instructions**: Press and hold `Win+Alt` while selecting elements in the list.
    - **Expected Results**: Utility halts execution until modifier keys are functionally cleared, preventing key overlap conflicts.

---
## Go Back to...
- ▪️[AGENTS.md](AGENTS.md)
- ▪️[AILOG.md](AILOG.md)
- ▪️[AITASKS.md](AITASKS.md)
- ▪️[BUILD.md](BUILD.md)
- ▪️[CODE.md](CODE.md)
- ▪️[FEATURES.md](FEATURES.md)
- ▪️[MANUAL.md](MANUAL.md)
- ▪️[README.md](README.md)
- ▪️[SPEC.md](SPEC.md)
- ▪️[TESTING.md](TESTING.md)
