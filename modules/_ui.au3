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

; modules\_ui.au3
