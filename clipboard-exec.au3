#NoTrayIcon
#include <TrayConstants.au3>
#include <AutoItConstants.au3>

; Core Architecture Module Mapping Links (Relative paths from project root)
#include "modules\_utils.au3"
#include "modules\_ui.au3"
#include "modules\_config.au3"
#include "modules\_recognizer.au3"
#include "modules\_handler_dopus.au3"
#include "modules\_handler_zdot.au3"
#include "modules\_handler_cmd.au3"
#include "modules\_engine.au3"
#include "modules\_index.au3"
#include "modules\_hotkeys.au3"

; Initialize structural singleton background process bounds checking routines
_Engine_UnloadExistingInstance()
_Util_PlaySystemSound(0x00000040) ; Startup initialization chime

Opt("TrayAutoPause", 0)
Opt("TrayMenuMode", 3)
Opt("SendKeyDelay", 15)

; Initialize System Tray Interface Framework
TraySetIcon("shell32.dll", -16)
TraySetToolTip("Clipboard Exec Engine")
Local $idExit = TrayCreateItem("Exit")

; Map Application System Hook Modifiers Natively
_Engine_RegisterHotkey("#^+{ENTER}", "_Hotkey_Exit")       ; Win+Ctrl+Shift+Enter
_Engine_RegisterHotkey("#!{ENTER}", "_Hotkey_ContextOp")   ; Win+Alt+Enter
_Engine_RegisterHotkey("#!+{ENTER}", "_Hotkey_ClipOp")     ; Win+Alt+Shift+Enter

_UI_ShowToast("Clipboard Exec", "Engine initialized and listening for hotkeys.")

; Persistent Main Application Non-Blocking Loop
While 1
    Local $msg = TrayGetMsg()
    Select
        Case $msg = $idExit
            _Hotkey_Exit()
    EndSelect
    
    _Index_ProcessQueueBatch()
    Sleep(10)
WEnd

; clipboard-exec.au3
