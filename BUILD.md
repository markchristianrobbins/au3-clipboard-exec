# Build

## Go to...
- ▪️[AGENTS.md](AGENTS.md)
- ▪️[AILOG.md](AILOG.md)
- ▪️[AITASKARCH.md](AITASKARCH.md)
- ▪️[AITASKS.md](AITASKS.md)
- 🔸[BUILD.md](BUILD.md)
- ▪️[CODE.md](CODE.md)
- ▪️[FEATURES.md](FEATURES.md)
- ▪️[MANUAL.md](MANUAL.md)
- ▪️[README.md](README.md)
- ▪️[SPEC.md](SPEC.md)
- ▪️[TESTING.md](TESTING.md)

---

## 🛠️ Build & Packaging Pipeline

The compilation pipeline translates modular AutoIt (`.au3`) source files into a unified high-performance machine code executable (`.exe`). The system utilizes the AutoIt3 compiler compiler backend.

```text
  [Main Orchestrator au3] + [Included modules\_*.au3]
                          |
                          v
         [AutoIt Library Preprocessor (Obfuscator)]
                          |
                          v
  [Standard Aut2Exe Compiler (Translates to Executable)]
                          |
                          v
   [Compiled Binary (.exe) + Embedded Icons & Metadata]
```

### Step-by-Step Build Pipeline
1. **Source Pre-Processing**: AutoIt preprocessor parses `#include` and `#include-once` directives starting from `clipboard-exec.au3`, validating dependencies alphabetically.
2. **Resource Compression**: Embeds Windows manifest controls, application descriptions, and high-DPI execution icons (`shell32.dll` assets) of the target executable.
3. **PE Creation**: The `Aut2Exe` compiler combines tokenized intermediate scripts with the standard Interpreter runtime engine to output a standalone Windows Portable Executable (PE).

### 📦 Key Components
- **`clipboard-exec.au3`**: Main executable container script parsing main loop messages.
- **`Aut2Exe.exe`**: Standard AutoIt compiler bin converting script files into native PE binaries.
- **`apps.ini` & `clipboard-exec.ini`**: Desktop custom configurations initializing system states.
- **`modules\_picker_demo.au3`**: Standalone mock directory selection launcher demonstrating picker features.

## 🚀 Execution & Packing Commands

To manage and build the application on developer workstations, use the following terminal commands:

- **Run in Development Mode**:
  ```bash
  # Execute the persistent tray script directly via the interpreter binary
  "C:\Program Files (x86)\AutoIt3\AutoIt3.exe" "./clipboard-exec.au3"
  ```
- **Local Dev Simulation (Launch Demo Picker)**:
  ```bash
  # Initiates the demo environment populating sample mock paths and displaying the UI
  "C:\Program Files (x86)\AutoIt3\AutoIt3.exe" "./modules/_picker_demo.au3"
  ```
- **Syntax Check / Verification**:
  ```bash
  # Check for syntax anomalies using the AU3Check utility
  "C:\Program Files (x86)\AutoIt3\AU3Check.exe" "./clipboard-exec.au3"
  ```
- **Binary Distribution Compiler**:
  ```bash
  # Compiles the modular script into a 64-bit standalone executable with optimized flags
  "C:\Program Files (x86)\AutoIt3\Aut2Exe\Aut2Exe_x64.exe" /In "./clipboard-exec.au3" /Out "./dist/clipboard-exec.exe" /Icon "./assets/engine.ico" /Comp 4
  ```

---
## Go back to...
- ▪️[AGENTS.md](AGENTS.md)
- ▪️[AILOG.md](AILOG.md)
- ▪️[AITASKS.md](AITASKS.md)
- 🔸[BUILD.md](BUILD.md)
- ▪️[CODE.md](CODE.md)
- ▪️[FEATURES.md](FEATURES.md)
- ▪️[MANUAL.md](MANUAL.md)
- ▪️[README.md](README.md)
- ▪️[SPEC.md](SPEC.md)
- ▪️[TESTING.md](TESTING.md)
