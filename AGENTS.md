# AGENTS

## AI Primary Files
- 🔸[AGENTS.md](AGENTS.md)
- ▪️[AILOG.md](AILOG.md)
- ▪️[AITASKARCH.md](AITASKARCH.md)
- ▪️[AITASKS.md](AITASKS.md)
- ▪️[BUILD.md](BUILD.md)
- ▪️[CODE.md](CODE.md)
- ▪️[FEATURES.md](FEATURES.md)
- ▪️[MANUAL.md](MANUAL.md)
- ▪️[README.md](README.md)
- ▪️[SPEC.md](SPEC.md)
- ▪️[TESTING.md](TESTING.md)

## Application
- **Clipboard Exec Engine**: A highly-optimized companion system tray utility written in AutoIt v3 that captures system window context, intercepts hotkeys, and routes clipboard patterns (URLs, absolute paths, zdot temporal coordinates, DOS commands) down optimized target application pathways.

## Platform
- **Target OS**: Windows 10 / 11
- **Compilers**: AutoIt v3 Compiler (`Aut2Exe.exe`)
- **IDE / Environment**: Cursor, VS Code, AutoIt v3 Parser Engine (`AutoIt3.exe`)
- **Key Interceptors**: Shell Windows API Hooks & Native OS global hotkeys (`HotKeySet`)

## File Restrictions
- Always adhere strictly to the AutoIt structural module rules.
- Do not create unrequested scratch folders or temporary test scripts.
- Never modify critical IDE configs, lock-files, or compiler defaults.

### Do NOT alter Files
- `!🌐index.md`
- `!🏗️setup.md`
- `.gitignore`
- `metadata.json` (except to keep description synced)

### Inline Tasks
- Tasks or instructions from developers embedded within source files are denoted by standard comments matching the syntax: `; //! {instruction}`.

## Project Context
- **Workspace Dir**: `C:\_\au3-clipboard-exec\`
- **Database Index**: Generated static map compiled dynamically in `C:\_\au3-clipboard-exec\clipboard-exec-index.txt`.
- **System Configs**: Evaluated dynamically from central config locations:
  - Central App Profiles: `C:\$data\apps.ini`
  - Workspace Engine Settings: `C:\$data\clipboard-exec.ini`
  - Target Register Stores: `C:\$data\zdoti\`
  - Recent Folders History Cache: `@AppDataDir\OpusRecentFolders.txt`

## Build
- **Linter & Verification**: Ensure compilation with AutoIt3 Wrapper or Aut2Exe checks with zero syntax anomalies before closing cycles. Run simulated test launcher loops internally.

## Code Styling and Preferences
- See [CODE](./CODE.md)

---
## Go to...
- 🔸[AGENTS.md](AGENTS.md)
- ▪️[AILOG.md](AILOG.md)
- ▪️[AITASKS.md](AITASKS.md)
- ▪️[BUILD.md](BUILD.md)
- ▪️[CODE.md](CODE.md)
- ▪️[FEATURES.md](FEATURES.md)
- ▪️[MANUAL.md](MANUAL.md)
- ▪️[README.md](README.md)
- ▪️[SPEC.md](SPEC.md)
- ▪️[TESTING.md](TESTING.md)
