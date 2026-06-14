#include-once
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <StaticConstants.au3>

; CRITICAL INCLUDE LINK MAP
#include "_picker_render.au3"

; ==============================================================================
; Public API: Displays an elegant, VS-Code themed selection picker GUI panel
; ==============================================================================
Func _Picker_ShowGUI(ByRef $aAllMatches, $sTitle = "SEARCH PICKER SELECTION NAVIGATOR", $sSearchQuery = "")
    Local $iRowHeight = 42, $iInputAreaHeight = 104, $iMenuWidth = 700, $iRowWidth = 670, $iRowX = 15
    Local $iMaxDisplayRows = 36, $iMaxFitRows = Int((@DesktopHeight - $iInputAreaHeight - 80) / $iRowHeight)
    If $iMaxDisplayRows > $iMaxFitRows Then $iMaxDisplayRows = $iMaxFitRows
    If $iMaxDisplayRows < 5 Then $iMaxDisplayRows = 5 
    
    Local $iMaxMenuHeight = $iInputAreaHeight + 8 + ($iMaxDisplayRows * $iRowHeight) + 12
    Local $iCenterX = (@DesktopWidth - $iMenuWidth) / 2, $iCenterY = (@DesktopHeight - $iMaxMenuHeight) / 2

    Local $hPickerGUI = GUICreate("", $iMenuWidth, $iMaxMenuHeight, $iCenterX, $iCenterY, $WS_POPUP, BitOR($WS_EX_TOPMOST, $WS_EX_TOOLWINDOW))
    GUISetBkColor(0x1E1E1E, $hPickerGUI)

    Local $hBorderL = GUICtrlCreateLabel("", 0, 0, 1, $iMaxMenuHeight)
    GUICtrlSetBkColor($hBorderL, 0x007ACC)
    Local $hBorderR = GUICtrlCreateLabel("", $iMenuWidth - 1, 0, 1, $iMaxMenuHeight)
    GUICtrlSetBkColor($hBorderR, 0x007ACC)
    Local $hBorderT = GUICtrlCreateLabel("", 0, 0, $iMenuWidth, 1)
    GUICtrlSetBkColor($hBorderT, 0x007ACC)
    Local $hBorderB = GUICtrlCreateLabel("", 0, $iMaxMenuHeight - 1, $iMenuWidth, 1)
    GUICtrlSetBkColor($hBorderB, 0x007ACC)

    Local $hTitleText = GUICtrlCreateLabel("  " & StringUpper($sTitle), 20, 14, $iMenuWidth - 40, 18)
    GUICtrlSetFont($hTitleText, 9, 700, 0, "Segoe UI")
    GUICtrlSetColor($hTitleText, 0x007ACC)
    
    Local $hStatusBg = GUICtrlCreateLabel("", 15, 34, $iMenuWidth - 30, 20)
    GUICtrlSetBkColor($hStatusBg, 0x1A1A1A)
    Local $hStatusText = GUICtrlCreateLabel("", 20, 36, $iMenuWidth - 40, 16)
    GUICtrlSetFont($hStatusText, 8, 400, 0, "Segoe UI")
    GUICtrlSetColor($hStatusText, 0x888888)

    Local $hInputField = GUICtrlCreateInput($sSearchQuery, 25, 64, $iMenuWidth - 50, 24, $ES_AUTOHSCROLL)
    GUICtrlSetFont($hInputField, 11, 400, 0, "Segoe UI")
    GUICtrlSetColor($hInputField, 0xFFFFFF)
    GUICtrlSetBkColor($hInputField, 0x252526)

    Local $aRowIdxCtrl[$iMaxDisplayRows + 1], $aRowBorder[$iMaxDisplayRows + 1]
    Local $aRowBg[$iMaxDisplayRows + 1], $aRowPre[$iMaxDisplayRows + 1]
    Local $aRowPath[$iMaxDisplayRows + 1], $aRowDepthInfo[$iMaxDisplayRows + 1]

    For $i = 0 To $iMaxDisplayRows - 1
        Local $iTopPos = $iInputAreaHeight + 8 + ($i * $iRowHeight)
        $aRowBorder[$i + 1] = GUICtrlCreateLabel("", $iRowX, $iTopPos, $iRowWidth, 38)
        GUICtrlSetState(-1, $GUI_HIDE)
        $aRowBg[$i + 1] = GUICtrlCreateLabel("", $iRowX + 1, $iTopPos + 1, $iRowWidth - 2, 36, BitOR($SS_LEFT, $SS_CENTERIMAGE))
        GUICtrlSetCursor(-1, 0)
        GUICtrlSetState(-1, $GUI_HIDE)
        $aRowIdxCtrl[$i + 1] = GUICtrlCreateLabel("", $iRowX + 4, $iTopPos + 12, 22, 14, $SS_RIGHT)
        GUICtrlSetFont(-1, 8, 400, 0, "Segoe UI")
        GUICtrlSetColor(-1, 0x555555)
        GUICtrlSetState(-1, $GUI_HIDE)
        $aRowPre[$i + 1] = GUICtrlCreateLabel("", $iRowX + 54, $iTopPos + 3, 1, 18)
        GUICtrlSetFont(-1, 10, 400, 0, "Segoe UI") 
        GUICtrlSetState(-1, $GUI_HIDE)
        $aRowPath[$i + 1] = GUICtrlCreateLabel("", $iRowX + 54, $iTopPos + 21, $iRowWidth - 70, 15, $SS_LEFT)
        GUICtrlSetFont(-1, 8, 400, 0, "Segoe UI")
        GUICtrlSetState(-1, $GUI_HIDE)
        $aRowDepthInfo[$i + 1] = GUICtrlCreateLabel("", $iRowX + $iRowWidth - 140, $iTopPos + 5, 120, 16, $SS_RIGHT)
        GUICtrlSetFont(-1, 8, 400, 0, "Segoe UI")
        GUICtrlSetColor(-1, 0x555555)
        GUICtrlSetState(-1, $GUI_HIDE)
    Next

    Local $hRowFocusL = GUICtrlCreateLabel("", 0, 0, 1, 1)
    Local $hRowFocusR = GUICtrlCreateLabel("", 0, 0, 1, 1)
    Local $hRowFocusT = GUICtrlCreateLabel("", 0, 0, 1, 1)
    Local $hRowFocusB = GUICtrlCreateLabel("", 0, 0, 1, 1)
    GUICtrlSetState($hRowFocusL, $GUI_HIDE)
    GUICtrlSetState($hRowFocusR, $GUI_HIDE)
    GUICtrlSetState($hRowFocusT, $GUI_HIDE)
    GUICtrlSetState($hRowFocusB, $GUI_HIDE)

    Local $hNoResults = GUICtrlCreateLabel("No matching entries found inside data registers", $iRowX, $iInputAreaHeight + 14, $iRowWidth, 36, BitOR($SS_CENTER, $SS_CENTERIMAGE))
    GUICtrlSetFont($hNoResults, 10, 400, 2, "Segoe UI")
    GUICtrlSetColor($hNoResults, 0x888888)
    GUICtrlSetState($hNoResults, $GUI_HIDE)

    Local $aFilteredPaths = $aAllMatches, $iDisplayCount = (UBound($aAllMatches) < $iMaxDisplayRows) ? UBound($aAllMatches) : $iMaxDisplayRows
    Local $iSelectedIndex = 0, $iScrollOffset = 0, $sLastQuery = "|||"

    Local $hDummyUp = GUICtrlCreateDummy(), $hDummyDown = GUICtrlCreateDummy(), $hDummyEscape = GUICtrlCreateDummy(), $hDummyEnter = GUICtrlCreateDummy()
    Local $aAccelTable = [["{DOWN}", $hDummyDown], ["{UP}", $hDummyUp], ["{ESC}", $hDummyEscape], ["{ENTER}", $hDummyEnter]]
    GUISetAccelerators($aAccelTable, $hPickerGUI)

    GUISetState(@SW_SHOW, $hPickerGUI)
    WinActivate($hPickerGUI)
    ControlFocus($hPickerGUI, "", $hInputField)

    Local $sSelectedPath = "", $bHasBeenActive = False, $hTimer = TimerInit()

    While 1
        Local $iMsg = GUIGetMsg()
        If $iMsg == $GUI_EVENT_CLOSE Or $iMsg == $hDummyEscape Then ExitLoop
        
        Local $bIsActive = (WinActive($hPickerGUI) <> 0)
        If $bIsActive Then
            If Not $bHasBeenActive Then $bHasBeenActive = True
        Else
            If $bHasBeenActive Or TimerDiff($hTimer) > 3000 Then ExitLoop
        EndIf

        Local $sCurrentQuery = GUICtrlRead($hInputField)
        If $sCurrentQuery <> $sLastQuery Then
            $sLastQuery = $sCurrentQuery
            $aFilteredPaths = $aAllMatches
            $iDisplayCount = (UBound($aFilteredPaths) < $iMaxDisplayRows) ? UBound($aFilteredPaths) : $iMaxDisplayRows
            $iSelectedIndex = 0
            $iScrollOffset = 0

            Local $iNewHeight = 0
            If $iDisplayCount == 0 Then
                GUICtrlSetState($hNoResults, $GUI_SHOW)
                _Picker_UpdateFocusBorder($hRowFocusL, $hRowFocusR, $hRowFocusT, $hRowFocusB, 0, 0, 0, 0, False)
                $iNewHeight = $iInputAreaHeight + 64
            Else
                GUICtrlSetState($hNoResults, $GUI_HIDE)
                _Picker_RenderVisibleList($aRowIdxCtrl, $aRowBorder, $aRowBg, $aRowPre, $aRowPath, $aRowDepthInfo, $aFilteredPaths, $sCurrentQuery, $iDisplayCount, $iSelectedIndex, $iScrollOffset, $iMaxDisplayRows)
                Local $iActiveTop = $iInputAreaHeight + 8 + ($iSelectedIndex * $iRowHeight)
                _Picker_UpdateFocusBorder($hRowFocusL, $hRowFocusR, $hRowFocusT, $hRowFocusB, $iRowX, $iActiveTop, $iRowWidth, 0x007ACC, True)
                $iNewHeight = $iInputAreaHeight + 8 + ($iDisplayCount * $iRowHeight) + 12
            EndIf
            
            GUICtrlSetPos($hBorderL, 0, 0, 1, $iNewHeight)
            GUICtrlSetPos($hBorderR, $iMenuWidth - 1, 0, 1, $iNewHeight)
            GUICtrlSetPos($hBorderB, 0, $iNewHeight - 1, $iMenuWidth, 1)
            WinMove($hPickerGUI, "", $iCenterX, $iCenterY, $iMenuWidth, $iNewHeight)
        EndIf

        Select
            Case $iMsg == $hDummyDown And $iDisplayCount > 0
                If $iSelectedIndex < $iDisplayCount - 1 Then
                    $iSelectedIndex += 1
                    _Picker_RenderVisibleList($aRowIdxCtrl, $aRowBorder, $aRowBg, $aRowPre, $aRowPath, $aRowDepthInfo, $aFilteredPaths, $sCurrentQuery, $iDisplayCount, $iSelectedIndex, $iScrollOffset, $iMaxDisplayRows)
                    Local $iActiveTop = $iInputAreaHeight + 8 + ($iSelectedIndex * $iRowHeight)
                    _Picker_UpdateFocusBorder($hRowFocusL, $hRowFocusR, $hRowFocusT, $hRowFocusB, $iRowX, $iActiveTop, $iRowWidth, 0x007ACC, True)
                EndIf
            Case $iMsg == $hDummyUp And $iDisplayCount > 0
                If $iSelectedIndex > 0 Then
                    $iSelectedIndex -= 1
                    _Picker_RenderVisibleList($aRowIdxCtrl, $aRowBorder, $aRowBg, $aRowPre, $aRowPath, $aRowDepthInfo, $aFilteredPaths, $sCurrentQuery, $iDisplayCount, $iSelectedIndex, $iScrollOffset, $iMaxDisplayRows)
                    Local $iActiveTop = $iInputAreaHeight + 8 + ($iSelectedIndex * $iRowHeight)
                    _Picker_UpdateFocusBorder($hRowFocusL, $hRowFocusR, $hRowFocusT, $hRowFocusB, $iRowX, $iActiveTop, $iRowWidth, 0x007ACC, True)
                EndIf
            Case $iMsg == $hDummyEnter And $iDisplayCount > 0
                $sSelectedPath = $aFilteredPaths[$iScrollOffset + $iSelectedIndex]
                ExitLoop
        EndSelect
        Sleep(10)
    WEnd

    GUIDelete($hPickerGUI)
    Return $sSelectedPath
EndFunc

; modules\_picker.au3
