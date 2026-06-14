#include-once
#include <AutoItConstants.au3>
#include <WinAPIProc.au3>

; Global storage paths for configuration infrastructure
Global Const $g_sMainIni = "C:\$data\clipboard-exec.ini"

; ==============================================================================
; Public API: Simple, crash-proof active window profiling engine
; ==============================================================================
Func _Config_GetActiveAppProfile()
    ; Extract the active window target process layout metadata cleanly via its PID
    Local $hWnd = WinGetHandle("[ACTIVE]")
    Local $iPID = WinGetProcess($hWnd)
    
    ; Query Windows directly for the executable name owning that active window handle
    Local $sFullPathExe = _WinAPI_GetProcessFileName($iPID)
    Local $iSlashPos = StringInStr($sFullPathExe, "\", 0, -1) 
    Local $sCurrentExe = StringLower(StringMid($sFullPathExe, $iSlashPos + 1))

    ; --- DIRECT ENGINE BYPASS PATHS ---
    ; Returns the exact SendKeys string macro directly as a raw string text payload
    If StringInStr($sCurrentExe, "cursor.exe") Or StringInStr($sCurrentExe, "autoit3.exe") Then
        Local $sKeys = IniRead($g_sMainIni, "Cursor", "sendkeys", "{HOME}+{END}^c")
        If $sKeys == "" Then $sKeys = "{HOME}+{END}^c"
        Return $sKeys
    EndIf

    If StringInStr($sCurrentExe, "dopus.exe") Then
        Local $sKeys = IniRead($g_sMainIni, "DirectoryOpus", "sendkeys", "")
        Return $sKeys
    EndIf

    Return "{HOME}+{END}^c" ; Universal absolute fallback macro
EndFunc

; modules\_config.au3
