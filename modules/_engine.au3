#include-once
#include <MsgBoxConstants.au3>

; ==============================================================================
; Public API: Safely handles single-instance termination protocols
; ==============================================================================
Func _Engine_UnloadExistingInstance()
    Local $sLockFile = @ScriptDir & "\.instance.lock"
    If FileExists($sLockFile) Then
        Local $iOldPID = Int(FileRead($sLockFile))
        If $iOldPID > 0 And ProcessExists($iOldPID) And $iOldPID <> @AutoItPID Then
            ProcessClose($iOldPID)
        EndIf
    EndIf
    Local $hFile = FileOpen($sLockFile, 2)
    If $hFile <> -1 Then
        FileWrite($hFile, @AutoItPID)
        FileClose($hFile)
    EndIf
EndFunc

; ==============================================================================
; Public API: Registers hotkeys while protecting against system conflicts
; ==============================================================================
Func _Engine_RegisterHotkey($sKeyCombination, $sFunctionName)
    Local $iResult = HotKeySet($sKeyCombination, $sFunctionName)
    If $iResult = 0 Then
        MsgBox(BitOR($MB_ICONSTOP, $MB_TOPMOST), "Hotkey Error", "Failed to register hotkey: " & $sKeyCombination)
        Exit
    EndIf
EndFunc

; modules\_engine.au3
