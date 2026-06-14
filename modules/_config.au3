#include-once
#include <AutoItConstants.au3>
#include <WinAPIProc.au3>

; Global storage paths for configuration infrastructure
Global Const $g_sMainIni = "C:\$data\clipboard-exec.ini"

; ==============================================================================
; Public API: Simple, crash-proof active window profiling engine
; ==============================================================================
Func _Config_GetActiveAppProfile()
    ; Force allocate an explicit 3-element return array template layout boundary
    Local $aProfile[3]

    ; Extract the active window target process layout metadata cleanly via its PID
    Local $hWnd = WinGetHandle("[ACTIVE]")
    Local $iPID = WinGetProcess($hWnd)
    
    ; Query Windows directly for the executable name owning that active window handle
    Local $sFullPathExe = _WinAPI_GetProcessFileName($iPID)
    Local $iSlashPos = StringInStr($sFullPathExe, "\", 0, -1) 
    Local $sCurrentExe = StringLower(StringMid($sFullPathExe, $iSlashPos + 1))

    ; --- DIRECT ENGINE BYPASS PATHS ---
    ; CRITICAL FIX: Explicitly assign values to bracketed index cells, [1], and [2]
    If StringInStr($sCurrentExe, "cursor.exe") Or StringInStr($sCurrentExe, "autoit3.exe") Then
        $aProfile[0] = "Cursor"
        $aProfile[1] = IniRead($g_sMainIni, "Cursor", "sendkeys", "{HOME}+{END}^c")
        $aProfile[2] = ""
        Return $aProfile
    EndIf

    If StringInStr($sCurrentExe, "dopus.exe") Then
        $aProfile[0] = "DirectoryOpus"
        $aProfile[1] = IniRead($g_sMainIni, "DirectoryOpus", "sendkeys", "")
        $aProfile[2] = ""
        Return $aProfile
    EndIf

    Return SetError(2, 0, $aProfile)
EndFunc

; modules\_config.au3
