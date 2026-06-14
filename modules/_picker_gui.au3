#include-once
; ==============================================================================
; File: _picker_gui.au3
; Description: Direct control generation and initialization functions for the GUI layout.
; Functions:
;   - _Picker_GUICreateWindow (Positions and initializes the borderless tool window)
;   - _Picker_GUICreateBorders (Sets colored decorative window boundaries)
;   - _Picker_GUICreateTitleAndStatus (Constructs headers and the mode/detail status bar)
;   - _Picker_GUICreateInputField (Produces the text input field with styled backdrops)
;   - _Picker_GUICreateRowPool (Pre-allocates UI list items / rows to avoid frame stutter)
;   - _Picker_GUISetUpAccelerators (Binds navigation hotkeys like Arrows, Enter, Pages, BS)
; ==============================================================================
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <StaticConstants.au3>

Func _Picker_GUICreateWindow($iMenuWidth, $iMaxMenuHeight, $iCenterX, $iCenterY, $sTitleTextStr, $sSearchQueryText)
    Local $hWnd = GUICreate("", $iMenuWidth, $iMaxMenuHeight, $iCenterX, $iCenterY, $WS_POPUP, BitOR($WS_EX_TOPMOST, $WS_EX_TOOLWINDOW))
    GUISetBkColor(0x1E1E1E, $hWnd)
    Return $hWnd
EndFunc

Func _Picker_GUICreateBorders($hWnd, $iMenuWidth, $iMaxMenuHeight, ByRef $hL, ByRef $hR, ByRef $hT, ByRef $hB)
    $hL = GUICtrlCreateLabel("", 0, 0, 1, $iMaxMenuHeight)
    GUICtrlSetBkColor($hL, 0x007ACC)
    GUICtrlSetResizing($hL, $GUI_DOCKALL)
    
    $hR = GUICtrlCreateLabel("", $iMenuWidth - 1, 0, 1, $iMaxMenuHeight)
    GUICtrlSetBkColor($hR, 0x007ACC)
    GUICtrlSetResizing($hR, $GUI_DOCKALL)
    
    $hT = GUICtrlCreateLabel("", 0, 0, $iMenuWidth, 1)
    GUICtrlSetBkColor($hT, 0x007ACC)
    GUICtrlSetResizing($hT, $GUI_DOCKALL)
    
    $hB = GUICtrlCreateLabel("", 0, $iMaxMenuHeight - 1, $iMenuWidth, 1)
    GUICtrlSetBkColor($hB, 0x007ACC)
    GUICtrlSetResizing($hB, $GUI_DOCKALL)
EndFunc

Func _Picker_GUICreateTitleAndStatus($iMenuWidth, $sTitleTextStr, ByRef $hTitleBg, ByRef $hTitleText, ByRef $hStatusBg, ByRef $hStatusText)
    $hTitleBg = GUICtrlCreateLabel("", 15, 10, $iMenuWidth - 30, 24)
    GUICtrlSetBkColor($hTitleBg, 0x111111)
    GUICtrlSetResizing($hTitleBg, $GUI_DOCKALL)
    GUICtrlSetState($hTitleBg, $GUI_DISABLE)
    
    $hTitleText = GUICtrlCreateLabel("  " & $sTitleTextStr, 20, 14, $iMenuWidth - 40, 18)
    GUICtrlSetFont($hTitleText, 9, 700, 0, "Segoe UI")
    GUICtrlSetColor($hTitleText, 0x007ACC)
    GUICtrlSetBkColor($hTitleText, $GUI_BKCOLOR_TRANSPARENT)
    GUICtrlSetResizing($hTitleText, $GUI_DOCKALL)
    
    $hStatusBg = GUICtrlCreateLabel("", 15, 34, $iMenuWidth - 30, 20)
    GUICtrlSetBkColor($hStatusBg, 0x1A1A1A)
    GUICtrlSetResizing($hStatusBg, $GUI_DOCKALL)
    GUICtrlSetState($hStatusBg, $GUI_DISABLE)
    
    $hStatusText = GUICtrlCreateLabel("", 20, 36, $iMenuWidth - 40, 16)
    GUICtrlSetFont($hStatusText, 8, 400, 0, "Segoe UI")
    GUICtrlSetColor($hStatusText, 0x888888)
    GUICtrlSetBkColor($hStatusText, $GUI_BKCOLOR_TRANSPARENT)
    GUICtrlSetResizing($hStatusText, $GUI_DOCKALL)
EndFunc

Func _Picker_GUICreateInputField($iMenuWidth, $sSearchQueryText, ByRef $hInputBg, ByRef $hInputField, ByRef $hDivider)
    $hInputBg = GUICtrlCreateLabel("", 15, 58, $iMenuWidth - 30, 36)
    GUICtrlSetBkColor($hInputBg, 0x252526)
    GUICtrlSetState($hInputBg, $GUI_DISABLE)
    GUICtrlSetResizing($hInputBg, $GUI_DOCKALL)

    $hInputField = GUICtrlCreateInput($sSearchQueryText, 25, 64, $iMenuWidth - 50, 24, $ES_AUTOHSCROLL)
    GUICtrlSetFont($hInputField, 11, 400, 0, "Segoe UI")
    GUICtrlSetColor($hInputField, 0xFFFFFF)
    GUICtrlSetBkColor($hInputField, 0x252526)
    GUICtrlSetResizing($hInputField, $GUI_DOCKALL)

    $hDivider = GUICtrlCreateLabel("", 15, 102, $iMenuWidth - 30, 1)
    GUICtrlSetBkColor($hDivider, 0x3F3F46)
    GUICtrlSetState($hDivider, $GUI_DISABLE)
    GUICtrlSetResizing($hDivider, $GUI_DOCKALL)
EndFunc

Func _Picker_GUICreateRowPool($iMaxDisplayRows, $iInputAreaHeight, $iRowHeight, $iRowX, $iRowWidth, ByRef $aRowIcon, ByRef $aRowIdxCtrl, ByRef $aRowBorder, ByRef $aRowBg, ByRef $aRowPre, ByRef $aRowMatch, ByRef $aRowPost, ByRef $aRowPath, ByRef $aRowDepthInfo)
    For $i = 0 To $iMaxDisplayRows - 1
        Local $iTopPos = $iInputAreaHeight + 8 + ($i * $iRowHeight)
        
        $aRowBorder[$i + 1] = GUICtrlCreateLabel("", $iRowX, $iTopPos, $iRowWidth, 38)
        GUICtrlSetResizing($aRowBorder[$i + 1], $GUI_DOCKALL)
        GUICtrlSetState($aRowBorder[$i + 1], $GUI_HIDE)

        $aRowBg[$i + 1] = GUICtrlCreateLabel("", $iRowX + 1, $iTopPos + 1, $iRowWidth - 2, 36, BitOR($SS_LEFT, $SS_CENTERIMAGE))
        GUICtrlSetCursor($aRowBg[$i + 1], 0)
        GUICtrlSetState($aRowBg[$i + 1], $GUI_HIDE)
        GUICtrlSetResizing($aRowBg[$i + 1], $GUI_DOCKALL)

        $aRowIdxCtrl[$i + 1] = GUICtrlCreateLabel("", $iRowX + 4, $iTopPos + 12, 22, 14, $SS_RIGHT)
        GUICtrlSetFont($aRowIdxCtrl[$i + 1], 8, 400, 0, "Segoe UI")
        GUICtrlSetColor($aRowIdxCtrl[$i + 1], 0x555555)
        GUICtrlSetBkColor($aRowIdxCtrl[$i + 1], $GUI_BKCOLOR_TRANSPARENT)
        GUICtrlSetResizing($aRowIdxCtrl[$i + 1], $GUI_DOCKALL)
        GUICtrlSetState($aRowIdxCtrl[$i + 1], $GUI_HIDE)

        $aRowIcon[$i + 1] = GUICtrlCreateIcon("shell32.dll", 3, $iRowX + 32, $iTopPos + 11, 16, 16)
        GUICtrlSetResizing($aRowIcon[$i + 1], $GUI_DOCKALL)
        GUICtrlSetBkColor($aRowIcon[$i + 1], $GUI_BKCOLOR_TRANSPARENT)
        GUICtrlSetState($aRowIcon[$i + 1], $GUI_HIDE)

        $aRowPre[$i + 1] = GUICtrlCreateLabel("", $iRowX + 54, $iTopPos + 3, 1, 18)
        GUICtrlSetFont($aRowPre[$i + 1], 10, 400, 0, "Consolas")
        GUICtrlSetBkColor($aRowPre[$i + 1], $GUI_BKCOLOR_TRANSPARENT)
        GUICtrlSetState($aRowPre[$i + 1], $GUI_HIDE)
        GUICtrlSetResizing($aRowPre[$i + 1], $GUI_DOCKALL)

        $aRowMatch[$i + 1] = GUICtrlCreateLabel("", $iRowX + 54, $iTopPos + 3, 1, 18)
        GUICtrlSetFont($aRowMatch[$i + 1], 10, 700, 0, "Consolas")
        GUICtrlSetBkColor($aRowMatch[$i + 1], $GUI_BKCOLOR_TRANSPARENT)
        GUICtrlSetState($aRowMatch[$i + 1], $GUI_HIDE)
        GUICtrlSetResizing($aRowMatch[$i + 1], $GUI_DOCKALL)

        $aRowPost[$i + 1] = GUICtrlCreateLabel("", $iRowX + 54, $iTopPos + 3, 1, 18)
        GUICtrlSetFont($aRowPost[$i + 1], 10, 400, 0, "Consolas")
        GUICtrlSetBkColor($aRowPost[$i + 1], $GUI_BKCOLOR_TRANSPARENT)
        GUICtrlSetState($aRowPost[$i + 1], $GUI_HIDE)
        GUICtrlSetResizing($aRowPost[$i + 1], $GUI_DOCKALL)

        $aRowPath[$i + 1] = GUICtrlCreateLabel("", $iRowX + 54, $iTopPos + 21, $iRowWidth - 70, 15, $SS_LEFT)
        GUICtrlSetFont($aRowPath[$i + 1], 8, 400, 0, "Segoe UI")
        GUICtrlSetBkColor($aRowPath[$i + 1], $GUI_BKCOLOR_TRANSPARENT)
        GUICtrlSetState($aRowPath[$i + 1], $GUI_HIDE)
        GUICtrlSetResizing($aRowPath[$i + 1], $GUI_DOCKALL)

        $aRowDepthInfo[$i + 1] = GUICtrlCreateLabel("", $iRowX + $iRowWidth - 140, $iTopPos + 5, 120, 16, $SS_RIGHT)
        GUICtrlSetFont($aRowDepthInfo[$i + 1], 8, 400, 0, "Segoe UI")
        GUICtrlSetColor($aRowDepthInfo[$i + 1], 0x555555)
        GUICtrlSetBkColor($aRowDepthInfo[$i + 1], $GUI_BKCOLOR_TRANSPARENT)
        GUICtrlSetResizing($aRowDepthInfo[$i + 1], $GUI_DOCKALL)
        GUICtrlSetState($aRowDepthInfo[$i + 1], $GUI_HIDE)
    Next
EndFunc

Func _Picker_GUISetUpAccelerators($hWnd, ByRef $hDUp, ByRef $hDDown, ByRef $hDPgUp, ByRef $hDPgDn, ByRef $hDHome, ByRef $hDEnd, ByRef $hDEnter, ByRef $hDCtrlEnter, ByRef $hDEscape, ByRef $hDCopy, ByRef $hDBackspace, ByRef $hDCtrlBS)
    $hDUp = GUICtrlCreateDummy()
    $hDDown = GUICtrlCreateDummy()
    $hDPgUp = GUICtrlCreateDummy()
    $hDPgDn = GUICtrlCreateDummy()
    $hDHome = GUICtrlCreateDummy()
    $hDEnd = GUICtrlCreateDummy()
    $hDEnter = GUICtrlCreateDummy()
    $hDCtrlEnter = GUICtrlCreateDummy()
    $hDEscape = GUICtrlCreateDummy()
    $hDCopy = GUICtrlCreateDummy()
    $hDBackspace = GUICtrlCreateDummy()
    $hDCtrlBS = GUICtrlCreateDummy()

    Local $aAccelTable = [ _
        [ "{DOWN}", $hDDown ], _
        [ "{UP}", $hDUp ], _
        [ "{PGUP}", $hDPgUp ], _
        [ "{PGDN}", $hDPgDn ], _
        [ "{HOME}", $hDHome ], _
        [ "{END}", $hDEnd ], _
        [ "{ENTER}", $hDEnter ], _
        [ "^{ENTER}", $hDCtrlEnter ], _
        [ "{ESC}", $hDEscape ], _
        [ "{BS}", $hDBackspace ], _
        [ "^{BS}", $hDCtrlBS ], _
        [ "^c", $hDCopy ], _
        [ "^{INSERT}", $hDCopy ] _
    ]
    GUISetAccelerators($aAccelTable, $hWnd)
EndFunc

; End of file: _picker_gui.au3
