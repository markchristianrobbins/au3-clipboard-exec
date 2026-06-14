#include-once
; ==============================================================================
; File: _picker_help.au3
; Description: Custom help window GUI layout for picker navigation.
; ==============================================================================
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <StaticConstants.au3>

Func _Picker_ShowHelpGUI($hWndParent)
    Local $iWidth = 520
    Local $iHeight = 310
    
    ; Get parent position to center F1 help over
    Local $aPos = WinGetPos($hWndParent)
    Local $iX = @DesktopWidth / 2 - $iWidth / 2
    Local $iY = @DesktopHeight / 2 - $iHeight / 2
    If IsArray($aPos) Then
        $iX = $aPos[0] + ($aPos[2]/2) - ($iWidth/2)
        $iY = $aPos[1] + ($aPos[3]/2) - ($iHeight/2)
    EndIf
    
    Local $hWndHelp = GUICreate("PICKER HELP & HOTKEYS", $iWidth, $iHeight, $iX, $iY, $WS_POPUP, BitOR($WS_EX_TOPMOST, $WS_EX_TOOLWINDOW), $hWndParent)
    GUISetBkColor(0x151515, $hWndHelp)
    
    ; Blue/Cyan border for help
    Local $hL = GUICtrlCreateLabel("", 0, 0, 1, $iHeight)
    GUICtrlSetBkColor($hL, 0x007ACC)
    Local $hR = GUICtrlCreateLabel("", $iWidth - 1, 0, 1, $iHeight)
    GUICtrlSetBkColor($hR, 0x007ACC)
    Local $hT = GUICtrlCreateLabel("", 0, 0, $iWidth, 1)
    GUICtrlSetBkColor($hT, 0x007ACC)
    Local $hB = GUICtrlCreateLabel("", 0, $iHeight - 1, $iWidth, 1)
    GUICtrlSetBkColor($hB, 0x007ACC)
    
    Local $hTitle = GUICtrlCreateLabel("  SEARCH PICKER HELP & HOTKEYS GUIDE", 15, 12, $iWidth - 30, 24, $SS_CENTERIMAGE)
    GUICtrlSetFont($hTitle, 9, 700, 0, "Segoe UI")
    GUICtrlSetColor($hTitle, 0x007ACC)
    GUICtrlSetBkColor($hTitle, 0x111111)
    
    Local $hDivider = GUICtrlCreateLabel("", 15, 42, $iWidth - 30, 1)
    GUICtrlSetBkColor($hDivider, 0x3F3F46)
    
    Local $sHelpText = _
        "UP / DOWN             Navigate rows up and down list" & @CRLF & _
        "PGUP / PGDN           Scroll page up/down" & @CRLF & _
        "HOME / END            Jump block to first or last item" & @CRLF & _
        "ENTER                 Accept/Open selected directory or activate window" & @CRLF & _
        "CTRL + ENTER          Toggle subdirectory explore navigation mode" & @CRLF & _
        "ESC                   Close search picker / back out of explore mode" & @CRLF & _
        "ALT + H               Toolbar toggle: Display/hide hidden windows" & @CRLF & _
        "ALT + M               Toolbar toggle: Display/hide minimized windows" & @CRLF & _
        "APPS / SHIFT+F10      Show compact window options context mini-picker" & @CRLF & _
        "CTRL + INSERT         Copy active row's full window telemetry info" & @CRLF & _
        "F1                    Bring up this Help & Navigation manual window" & @CRLF & @CRLF & _
        "MOUSE NAVIGATION:" & @CRLF & _
        "  * Hover to preview / click once to focus active item row." & @CRLF & _
        "  * Click window options context button to open options popup picker." & @CRLF & _
        "  * Double-click any row to instantly accept & run / open the selection."
        
    Local $hContent = GUICtrlCreateLabel($sHelpText, 20, 55, $iWidth - 40, 215)
    GUICtrlSetFont($hContent, 8.5, 600, 0, "Consolas")
    GUICtrlSetColor($hContent, 0xCCCCCC)
    GUICtrlSetBkColor($hContent, $GUI_BKCOLOR_TRANSPARENT)
    
    Local $hFooter = GUICtrlCreateLabel("Press any key or click anywhere to exit help...", 20, 275, $iWidth - 40, 20, $SS_CENTER)
    GUICtrlSetFont($hFooter, 8.5, 400, 2, "Segoe UI")
    GUICtrlSetColor($hFooter, 0x888888)
    GUICtrlSetBkColor($hFooter, $GUI_BKCOLOR_TRANSPARENT)
    
    GUISetState(@SW_SHOW, $hWndHelp)
    
    ; Clear messages
    While GUIGetMsg() <> 0
        Sleep(5)
    WEnd
    
    ; Block loop for keypress or click to close
    While 1
        Local $iMsg = GUIGetMsg()
        If $iMsg == $GUI_EVENT_CLOSE Or $iMsg > 0 Then ExitLoop
        
        ; Double click or mouse single clicks trigger exit
        Local $aClickInfo = GUIGetCursorInfo($hWndHelp)
        If IsArray($aClickInfo) And ($aClickInfo[2] == 1 Or $aClickInfo[3] == 1) Then
            ExitLoop
        EndIf
        
        If WinActive($hWndHelp) == 0 Then ExitLoop
        Sleep(10)
    WEnd
    
    GUIDelete($hWndHelp)
EndFunc
