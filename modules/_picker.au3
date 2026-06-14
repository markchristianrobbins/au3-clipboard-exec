#include-once
; ==============================================================================
; File: _picker.au3
; Paths: C:\_\au3-clipboard-exec\modules\_picker.au3
; Description: Main execution orchestrator interface for the Search Picker GUI.
; Functions:
;   - _Picker_ShowGUI (Allocates local window structures and maintains message loop)
; ==============================================================================
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <StaticConstants.au3>
#include <StringConstants.au3>
#include <Array.au3>

; Sub-file structural module mapping trees
#include "_picker_globals.au3"
#include "_picker_helpers.au3"
#include "_picker_icons.au3"
#include "_picker_style.au3"
#include "_picker_recent.au3"
#include "_picker_filter.au3"
#include "_picker_render.au3"
#include "_picker_gui.au3"
#include "_picker_event.au3"
#include "_picker_keys.au3"

Func _Picker_ShowGUI(ByRef $aAllMatches, $sTitle = "SEARCH PICKER", $sSearchQuery = "")
    Local $iRowHeight = 42, $iInputAreaHeight = 104, $iMenuWidth = 700, $iRowWidth = 670, $iRowX = 15, $iMaxDisplayRows = 36
    Local $iMaxFitRows = Int((@DesktopHeight - $iInputAreaHeight - 80) / $iRowHeight)
    If $iMaxDisplayRows > $iMaxFitRows Then $iMaxDisplayRows = $iMaxFitRows
    If $iMaxDisplayRows < 5 Then $iMaxDisplayRows = 5
    
    If Not IsDeclared("oChildCount") Or Not IsDeclared("oGrandchildCount") Then 
        _Picker_BuildChildCounts($aAllMatches)
    EndIf
    
    Local $iMaxMenuHeight = $iInputAreaHeight + 8 + ($iMaxDisplayRows * $iRowHeight) + 12
    Local $iCenterX = (@DesktopWidth - $iMenuWidth) / 2, $iCenterY = (@DesktopHeight - $iMaxMenuHeight) / 2
    
    $g_hPickerGUI = _Picker_GUICreateWindow($iMenuWidth, $iMaxMenuHeight, $iCenterX, $iCenterY, $sTitle, $sSearchQuery)
    _Picker_GUICreateBorders($g_hPickerGUI, $iMenuWidth, $iMaxMenuHeight, $g_hBorderL, $g_hBorderR, $g_hBorderT, $g_hBorderB)
    
    Local $hTitleBg, $hTitleText
    _Picker_GUICreateTitleAndStatus($iMenuWidth, $sTitle, $hTitleBg, $hTitleText, $g_hStatusBg, $g_hStatusText)
    
    Local $hInputBg, $hDivider
    _Picker_GUICreateInputField($iMenuWidth, $sSearchQuery, $hInputBg, $g_hInputField, $hDivider)
    
    ReDim $g_aRowIcon[$iMaxDisplayRows + 1]
    ReDim $g_aRowIdxCtrl[$iMaxDisplayRows + 1]
    ReDim $g_aRowBorder[$iMaxDisplayRows + 1]
    ReDim $g_aRowBg[$iMaxDisplayRows + 1]
    ReDim $g_aRowPre[$iMaxDisplayRows + 1]
    ReDim $g_aRowMatch[$iMaxDisplayRows + 1]
    ReDim $g_aRowPost[$iMaxDisplayRows + 1]
    ReDim $g_aRowPath[$iMaxDisplayRows + 1]
    ReDim $g_aRowDepthInfo[$iMaxDisplayRows + 1]
    _Picker_GUICreateRowPool($iMaxDisplayRows, $iInputAreaHeight, $iRowHeight, $iRowX, $iRowWidth, $g_aRowIcon, $g_aRowIdxCtrl, $g_aRowBorder, $g_aRowBg, $g_aRowPre, $g_aRowMatch, $g_aRowPost, $g_aRowPath, $g_aRowDepthInfo)
    
    $g_hRowFocusL = GUICtrlCreateLabel("", 0, 0, 1, 1)
    $g_hRowFocusR = GUICtrlCreateLabel("", 0, 0, 1, 1)
    $g_hRowFocusT = GUICtrlCreateLabel("", 0, 0, 1, 1)
    $g_hRowFocusB = GUICtrlCreateLabel("", 0, 0, 1, 1)
    
    $g_hNoResults = GUICtrlCreateLabel("No matching directories found in index map", $iRowX, $iInputAreaHeight + 14, $iRowWidth, 36, BitOR($SS_CENTER, $SS_CENTERIMAGE))
    GUICtrlSetFont($g_hNoResults, 10, 400, 2, "Segoe UI")
    GUICtrlSetColor($g_hNoResults, 0x888888)
    GUICtrlSetBkColor($g_hNoResults, $GUI_BKCOLOR_TRANSPARENT)
    GUICtrlSetState($g_hNoResults, $GUI_HIDE)
    GUICtrlSetResizing($g_hNoResults, $GUI_DOCKALL)
    
    _Picker_GUISetUpAccelerators($g_hPickerGUI, $g_hDUp, $g_hDDown, $g_hDPgUp, $g_hDPgDn, $g_hDHome, $g_hDEnd, $g_hDEnter, $g_hDCtrlEnter, $g_hDEscape, $g_hDCopy, $g_hDBackspace, $g_hDCtrlBS)
    
    GUISetState(@SW_SHOW, $g_hPickerGUI)
    WinActivate($g_hPickerGUI)
    ControlFocus($g_hPickerGUI, "", $g_hInputField)
    
    $g_sSelectedPath = ""
    $g_bHasBeenActive = False
    $g_sLastQuery = "|||"
    $g_iLastMouseX = -1
    $g_iLastMouseY = -1
    
    ; CRITICAL RESOLUTION FIX: Replaced invalid mid-loop brace notation `[""]` with native cell index allocation
    Local $aInitialFilterSeed[1] = [""]
    $g_aFilteredPaths = $aInitialFilterSeed
    
    $g_iDisplayCount = 0
    $g_iSelectedIndex = 0
    $g_iScrollOffset = 0
    $g_iRecentCount = 0
    $g_bExploreMode = False
    $g_sExploreDir = ""
    $g_aActiveBasePaths = $aAllMatches
    $g_bRestoringState = False
    $g_sSavedQueryText = ""
    $g_iSavedSelectedIndex = 0
    $g_iSavedScrollOffset = 0
    Local $hTimer = TimerInit()
    
    While 1
        Local $iMsg = GUIGetMsg()
        If $iMsg == $GUI_EVENT_CLOSE Then ExitLoop
        
        Local $bActive = (WinActive($g_hPickerGUI) <> 0)
        If $bActive Then
            If Not $g_bHasBeenActive Then $g_bHasBeenActive = True
        Else
            If $g_bHasBeenActive Or TimerDiff($hTimer) > 3000 Then ExitLoop
        EndIf
        
        Local $sCurrentQuery = GUICtrlRead($g_hInputField)
        If $sCurrentQuery <> $g_sLastQuery Then _Picker_HandleQueryChange($aAllMatches)
        
        If $g_iDisplayCount > 0 Then
            Local $aCursorInfo = GUIGetCursorInfo($g_hPickerGUI)
            If IsArray($aCursorInfo) Then
                Local $iHoveredCtrlID = $aCursorInfo[4], $iMouseX = $aCursorInfo[0], $iMouseY = $aCursorInfo[1]
                If $iMouseX <> $g_iLastMouseX Or $iMouseY <> $g_iLastMouseY Then
                    $g_iLastMouseX = $iMouseX
                    $g_iLastMouseY = $iMouseY
                    For $i = 0 To $g_iDisplayCount - 1
                        If $iHoveredCtrlID == $g_aRowIcon[$i + 1] Or $iHoveredCtrlID == $g_aRowIdxCtrl[$i + 1] Or $iHoveredCtrlID == $g_aRowBorder[$i + 1] Or $iHoveredCtrlID == $g_aRowBg[$i + 1] Or $iHoveredCtrlID == $g_aRowPre[$i + 1] Or $iHoveredCtrlID == $g_aRowMatch[$i + 1] Or $iHoveredCtrlID == $g_aRowPost[$i + 1] Or $iHoveredCtrlID == $g_aRowPath[$i + 1] Or $iHoveredCtrlID == $g_aRowDepthInfo[$i + 1] Then
                            If $i <> $g_iSelectedIndex Then
                                _Picker_HighlightRowDynamic($g_aRowIcon, $g_aRowIdxCtrl, $g_aRowBorder, $g_aRowBg, $g_aRowPre, $g_aRowMatch, $g_aRowPost, $g_aRowPath, $g_aRowDepthInfo, $g_aFilteredPaths, $sCurrentQuery, $g_iSelectedIndex, $g_iScrollOffset + $g_iSelectedIndex, False, ($g_iScrollOffset + $g_iSelectedIndex < $g_iRecentCount), $g_bExploreMode, $g_sExploreDir, $iInputAreaHeight)
                                $g_iSelectedIndex = $i
                                _Picker_HighlightRowDynamic($g_aRowIcon, $g_aRowIdxCtrl, $g_aRowBorder, $g_aRowBg, $g_aRowPre, $g_aRowMatch, $g_aRowPost, $g_aRowPath, $g_aRowDepthInfo, $g_aFilteredPaths, $sCurrentQuery, $g_iSelectedIndex, $g_iScrollOffset + $g_iSelectedIndex, True, ($g_iScrollOffset + $g_iSelectedIndex < $g_iRecentCount), $g_bExploreMode, $g_sExploreDir, $iInputAreaHeight)
                                Local $iActiveTop = $iInputAreaHeight + 8 + ($g_iSelectedIndex * $iRowHeight)
                                Local $iSpecColor = _Picker_GetBaseColor(_Picker_GetBaseName($g_aFilteredPaths[$g_iScrollOffset + $g_iSelectedIndex]))
                                _Picker_UpdateFocusBorder($g_hRowFocusL, $g_hRowFocusR, $g_hRowFocusT, $g_hRowFocusB, $iRowX, $iActiveTop, $iRowWidth, $iSpecColor, True)
                                _Picker_UpdateStatusText($g_hStatusText, $g_hStatusBg, $g_aFilteredPaths, $g_iSelectedIndex, $g_iScrollOffset, $g_bExploreMode, $g_sExploreDir, UBound($g_aFilteredPaths) - $g_iRecentCount, $g_iRecentCount)
                            EndIf
                            ExitLoop
                        EndIf
                    Next
                EndIf
            EndIf
        EndIf
        
        If _Picker_ProcessMsg($iMsg, $aAllMatches) Then ExitLoop
        
        If $iMsg == $g_hDDown Or $iMsg == $g_hDUp Or $iMsg == $g_hDPgUp Or $iMsg == $g_hDPgDn Or $iMsg == $g_hDHome Or $iMsg == $g_hDEnd Then
            _Picker_UpdateStatusText($g_hStatusText, $g_hStatusBg, $g_aFilteredPaths, $g_iSelectedIndex, $g_iScrollOffset, $g_bExploreMode, $g_sExploreDir, UBound($g_aFilteredPaths) - $g_iRecentCount, $g_iRecentCount)
        EndIf
        
        Sleep(10)
    WEnd
    
    ; If $g_sSelectedPath <> "" Then _Picker_AddRecent($g_sSelectedPath)
    
    If IsDeclared("oChildCount") Then $oChildCount.RemoveAll()
    If IsDeclared("oGrandchildCount") Then $oGrandchildCount.RemoveAll()
    
    GUIDelete($g_hPickerGUI)
    Return $g_sSelectedPath
EndFunc

; End of file: _picker.au3
