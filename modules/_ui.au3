#include-once
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

; ==============================================================================
; Public API: Centered & Extended Custom Toast Notification Window
; ==============================================================================
Func _UI_ShowToast($sTitle, $sMessage)
    Local $iWidth = 400, $iHeight = 90
    Local $iX = (@DesktopWidth - $iWidth) / 2
    Local $iY = (@DesktopHeight - $iHeight) / 2

    ; Create a borderless, always-on-top notification window frame
    Local $hToast = GUICreate($sTitle, $iWidth, $iHeight, $iX, $iY, $WS_POPUP, BitOR($WS_EX_TOPMOST, $WS_EX_TOOLWINDOW))
    GUISetBkColor(0x1F1F1F, $hToast)

    ; Render Text Elements
    GUICtrlCreateLabel($sTitle, 20, 15, $iWidth - 40, 22)
    GUICtrlSetFont(-1, 11, 800, 0, "Segoe UI")
    GUICtrlSetColor(-1, 0xFFFFFF)

    GUICtrlCreateLabel($sMessage, 20, 42, $iWidth - 40, 40)
    GUICtrlSetFont(-1, 10, 400, 0, "Segoe UI")
    GUICtrlSetColor(-1, 0xCCCCCC)

    ; Reveal the window layout without stealing keyboard focus from your text cursor
    GUISetState(@SW_SHOWNOACTIVATE, $hToast)

    ; Keep card visible for 6 seconds, then cleanly drop it from memory
    Sleep(6000)
    GUIDelete($hToast)
EndFunc

; ==============================================================================
; Public API: Centered, Custom Non-blocking Toast for application startup sequences
; ==============================================================================
Func _UI_ShowStartupToast($sTitle, $sMessage)
    Local $iWidth = 400, $iHeight = 90
    Local $iX = (@DesktopWidth - $iWidth) / 2
    Local $iY = (@DesktopHeight - $iHeight) / 2

    ; Create a borderless, always-on-top notification window frame
    Local $hToast = GUICreate($sTitle, $iWidth, $iHeight, $iX, $iY, $WS_POPUP, BitOR($WS_EX_TOPMOST, $WS_EX_TOOLWINDOW))
    GUISetBkColor(0x1F1F1F, $hToast)

    ; Render Title Label
    Local $idTitleLabel = GUICtrlCreateLabel($sTitle, 20, 15, $iWidth - 40, 22)
    GUICtrlSetFont(-1, 11, 800, 0, "Segoe UI")
    GUICtrlSetColor(-1, 0xFFFFFF)

    ; Render Message Label
    Local $idMsgLabel = GUICtrlCreateLabel($sMessage, 20, 42, $iWidth - 40, 40)
    GUICtrlSetFont(-1, 10, 400, 0, "Segoe UI")
    GUICtrlSetColor(-1, 0xCCCCCC)

    ; Reveal the window layout without stealing keyboard focus
    GUISetState(@SW_SHOWNOACTIVATE, $hToast)

    ; Return array containing the GUI window handle and the control IDs
    Local $aToastInfo[3] = [$hToast, $idTitleLabel, $idMsgLabel]
    Return $aToastInfo
EndFunc

; ==============================================================================
; Public API: Updates the text in the startup toast window dynamically
; ==============================================================================
Func _UI_UpdateStartupToast($aToastInfo, $sNewTitle, $sNewMessage)
    If Not IsArray($aToastInfo) Then Return
    GUICtrlSetData($aToastInfo[1], $sNewTitle)
    GUICtrlSetData($aToastInfo[2], $sNewMessage)
EndFunc

; ==============================================================================
; Public API: Closes and purges the startup toast window after an optional delay
; ==============================================================================
Func _UI_CloseStartupToast($aToastInfo, $iSleepMs = 0)
    If Not IsArray($aToastInfo) Then Return
    If $iSleepMs > 0 Then Sleep($iSleepMs)
    GUIDelete($aToastInfo[0])
EndFunc

; modules\_ui.au3
