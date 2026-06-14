#include-once

; ==============================================================================
; Public API: Direct call to the digital Win32 audio stream engine
; ==============================================================================
Func _Util_PlaySystemSound($iSoundType)
    DllCall("user32.dll", "bool", "MessageBeep", "uint", $iSoundType)
EndFunc

; ==============================================================================
; Public API: Pauses script pipeline execution until modifiers are cleared
; ==============================================================================
Func _Util_WaitForModifierRelease()
    Local $aDllRet
    While 1
        $aDllRet = DllCall("user32.dll", "short", "GetAsyncKeyState", "int", 0x5B)
        Local $bLWinDown = (BitAND($aDllRet, 0x8000) <> 0)
        $aDllRet = DllCall("user32.dll", "short", "GetAsyncKeyState", "int", 0x5C)
        Local $bRWinDown = (BitAND($aDllRet, 0x8000) <> 0)
        $aDllRet = DllCall("user32.dll", "short", "GetAsyncKeyState", "int", 0x12)
        Local $bAltDown = (BitAND($aDllRet, 0x8000) <> 0)
        
        If Not $bLWinDown And Not $bRWinDown And Not $bAltDown Then ExitLoop
        Sleep(20) 
    WEnd
    Sleep(50) 
EndFunc

; ==============================================================================
; Public API: Releases stuck keyboard modifiers to allow clean string macros
; ==============================================================================
Func _Util_PurgeStuckModifiers()
    ControlSend("[ACTIVE]", "", "", "{ALTUP}", 0)
    ControlSend("[ACTIVE]", "", "", "{LWINUP}", 0)
    ControlSend("[ACTIVE]", "", "", "{RWINUP}", 0)
    ControlSend("[ACTIVE]", "", "", "{SHIFTUP}", 0)
    ControlSend("[ACTIVE]", "", "", "{CTRLUP}", 0)
EndFunc

; ==============================================================================
; Public API: Checks if a window is an overlapped window using direct DLL call
; ==============================================================================
Func _Util_IsOverlappedWindow($hWnd)
    Local $aRet = DllCall("user32.dll", "long", "GetWindowLongW", "hwnd", $hWnd, "int", -16) ; -16 is $GWL_STYLE
    If @error Or Not IsArray($aRet) Then Return False
    Local $iStyle = $aRet[0]
    ; Overlapped windows have neither WS_CHILD (0x40000000) nor WS_POPUP (0x80000000) style
    Return (BitAND($iStyle, 0x40000000) == 0) And (BitAND($iStyle, 0x80000000) == 0)
EndFunc

; modules\_utils.au3
