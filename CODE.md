# Code

## Go to...
- ▪️[AGENTS.md](AGENTS.md)
- ▪️[AILOG.md](AILOG.md)
- ▪️[AITASKARCH.md](AITASKARCH.md)
- ▪️[AITASKS.md](AITASKS.md)
- ▪️[BUILD.md](BUILD.md)
- 🔸[CODE.md](CODE.md)
- ▪️[FEATURES.md](FEATURES.md)
- ▪️[MANUAL.md](MANUAL.md)
- ▪️[README.md](README.md)
- ▪️[SPEC.md](SPEC.md)
- ▪️[TESTING.md](TESTING.md)

## Implementation Guidelines
- **Encoding Safety**: Keep UTF-8 signatures verified without BOM headers unless executing localized file reads. Always avoid character conversion overrides when processing unicode paths.
- **Target Changes Only**: Avoid destructive code rewrites or removing developer comments. Maintain `#include-once` guards intact.

### Markdown Guidelines
- Use dashes (`-`) instead of asterisks (`*`) for Bullet list items.
- Ensure all filenames and system definitions are kept synced across references alphabetically.

### Formatting & Syntax Style
- **Indentation**: Standard 4 spaces per indentation level. Always ensure variables are aligned with matching comments safely.
- **Braces and Blocks**: Conditional blocks must contain clear termination tokens (`EndIf`, `EndSelect`, `EndFunc`, `WEnd`). Keep statement layout explicit. Never compress multiple nested logical conditions inline without spacing structure.
- **Naming Conventions**:
  - Global Constants: Capitalized starting with prefix `$g_s` (Global string), `$g_h` (Global handle), or similar.
  - Local Variables: CamelCase preceded by type qualifiers (e.g., `$sBaseName` for strings, `$hWnd` for handles, `$iPID` for integers, `$bSuccess` for bool metrics).
  - Public Functions: PascalCase starting with system prefixes (e.g., `_Config_GetActiveAppProfile`, `_Handler_OpenInDOpus`).

#### Global Function Ordering
- Arrange functions based on dependency flow within source containers:
  - Outer primary entry points are declared at the top of regions.
  - Sub-helpers are placed immediately beneath the parent processes depending on them.
  - Isolated standalone routines are organized alphabetically.

### Regions Division Style
- Wrap variables, handles, and custom handlers inside functional blocks to keep formatting structural.
- **Example Regions Map**:
  ```autoit
  ; #region _globals
  Global Const $g_sMainIni = "C:\$data\clipboard-exec.ini"
  Global $g_hInputField = 0
  ; #endregion

  ; #region _handlers
  ; #region _handler_Dopus
  Func _Handler_OpenInDOpus($sFullPath, $sType)
      ...
  EndFunc
  ; #endregion
  ; #endregion
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
