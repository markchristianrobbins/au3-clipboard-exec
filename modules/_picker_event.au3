#include-once
; ==============================================================================
; File: _picker_event.au3
; Paths: C:\_\au3-clipboard-exec\modules\_picker_event.au3
; Description: Handles events, query changes, and messages within the GUI loop.
; ==============================================================================
#include <GUIConstantsEx.au3>
#include "_picker_globals.au3"
#include "_picker_helpers.au3"
#include "_picker_recent.au3"
#include "_picker_filter.au3"
#include "_picker_render.au3"
#include "_picker_style.au3"

#ignorefunc _OpenInOpus
#ignorefunc _Picker_HandleKeyPress

Func _Picker_HandleQueryChange(ByRef $aAllMatches)
    Local $iRowHeight = 42, $iInputAreaHeight = 124, $iMenuWidth = 700, $iRowWidth = 670, $iRowX = 15, $iMaxDisplayRows = 36
    Local $sCurrentQuery = GUICtrlRead($g_hInputField)
    $g_sLastQuery = $sCurrentQuery
    
    ; Recents disabled per user request
    $g_iRecentCount = 0
    Local $aActualRecents[1] = [""]
    
    Local $aSearchMatches = _Picker_FilterPathsByFuzzyScore($g_aActiveBasePaths, $sCurrentQuery)
    If $sCurrentQuery <> "" And UBound($aSearchMatches) <= 3000 Then _Picker_SortPathsByLevelAndAlphabet($aSearchMatches)
    
    Local $iMaxSearchSize = UBound($aSearchMatches)
    Local $aCombined[$iMaxSearchSize + $g_iRecentCount]
    Local $iCombIdx = 0
    
    For $i = 0 To $g_iRecentCount - 1
        $aCombined[$iCombIdx] = $aActualRecents[$i]
        $iCombIdx += 1
    Next
    For $i = 0 To $iMaxSearchSize - 1
        If $aSearchMatches[$i] <> "" Then
            Local $bDuplicate = False
            For $j = 0 To $g_iRecentCount - 1
                If $aSearchMatches[$i] == $aActualRecents[$j] Then
                    $bDuplicate = True
                    ExitLoop
                EndIf
            Next
            If Not $bDuplicate Then
                $aCombined[$iCombIdx] = $aSearchMatches[$i]
                $iCombIdx += 1
            EndIf
        EndIf
    Next
    
    If $iCombIdx == 0 Then
        Local $aEmpty = [""]
        $g_aFilteredPaths = $aEmpty
        $g_iDisplayCount = 0
    Else
        ReDim $aCombined[$iCombIdx]
        $g_aFilteredPaths = $aCombined
        $g_iDisplayCount = ($iCombIdx < $iMaxDisplayRows) ? $iCombIdx : $iMaxDisplayRows
        If UBound($g_aFilteredPaths) <= 3000 Then
            _Picker_BuildChildCounts($g_aFilteredPaths)
        Else
            If IsObj($oChildCount) Then $oChildCount.RemoveAll()
            If IsObj($oGrandchildCount) Then $oGrandchildCount.RemoveAll()
        EndIf
    EndIf
    
    If $g_bRestoringState Then
        $g_iSelectedIndex = $g_iSavedSelectedIndex
        $g_iScrollOffset = $g_iSavedScrollOffset
        $g_bRestoringState = False
    Else
        $g_iSelectedIndex = 0
        $g_iScrollOffset = 0
    EndIf
    
    _Picker_UpdateStatusText($g_hStatusText, $g_hStatusBg, $g_aFilteredPaths, $g_iSelectedIndex, $g_iScrollOffset, $g_bExploreMode, $g_sExploreDir, UBound($aSearchMatches), $g_iRecentCount)
    
    Local $iNewHeight = 0
    If $g_iDisplayCount == 0 Then
        GUICtrlSetState($g_hNoResults, $GUI_SHOW)
        _Picker_RenderVisibleList($g_aRowIcon, $g_aRowIdxCtrl, $g_aRowBorder, $g_aRowBg, $g_aRowPre, $g_aRowMatch, $g_aRowPost, $g_aRowPath, $g_aRowDepthInfo, $g_aFilteredPaths, $sCurrentQuery, 0, 0, 0, $iMaxDisplayRows, 0, $g_bExploreMode, $g_sExploreDir, $iInputAreaHeight)
        _Picker_UpdateFocusBorder($g_hRowFocusL, $g_hRowFocusR, $g_hRowFocusT, $g_hRowFocusB, 0, 0, 0, 0, False)
        $iNewHeight = $iInputAreaHeight + 64
    Else
        GUICtrlSetState($g_hNoResults, $GUI_HIDE)
        _Picker_RenderVisibleList($g_aRowIcon, $g_aRowIdxCtrl, $g_aRowBorder, $g_aRowBg, $g_aRowPre, $g_aRowMatch, $g_aRowPost, $g_aRowPath, $g_aRowDepthInfo, $g_aFilteredPaths, $sCurrentQuery, $g_iDisplayCount, $g_iSelectedIndex, $g_iScrollOffset, $iMaxDisplayRows, $g_iRecentCount, $g_bExploreMode, $g_sExploreDir, $iInputAreaHeight)
        Local $iActiveTop = $iInputAreaHeight + 8 + ($g_iSelectedIndex * $iRowHeight)
        Local $iSpecColor = _Picker_GetBaseColor(_Picker_GetBaseName($g_aFilteredPaths[$g_iScrollOffset + $g_iSelectedIndex]))
        _Picker_UpdateFocusBorder($g_hRowFocusL, $g_hRowFocusR, $g_hRowFocusT, $g_hRowFocusB, $iRowX, $iActiveTop, $iRowWidth, $iSpecColor, True)
        $iNewHeight = $iInputAreaHeight + 8 + ($g_iDisplayCount * $iRowHeight) + 12
    EndIf
    
    GUICtrlSetPos($g_hBorderL, 0, 0, 1, $iNewHeight)
    GUICtrlSetPos($g_hBorderR, $iMenuWidth - 1, 0, 1, $iNewHeight)
    GUICtrlSetPos($g_hBorderB, 0, $iNewHeight - 1, $iMenuWidth, 1)
    
    Local $iCenterX = (@DesktopWidth - $iMenuWidth) / 2
    Local $iCenterY = (@DesktopHeight - $iNewHeight) / 2
    WinMove($g_hPickerGUI, "", $iCenterX, $iCenterY, $iMenuWidth, $iNewHeight)
EndFunc
; MORE...

; End of file: _picker_event.au3 (Part 1)
Func _Picker_ProcessMsg($iMsg, ByRef $aAllMatches)
    Local $iRowHeight = 42, $iInputAreaHeight = 124, $iMenuWidth = 700, $iRowWidth = 670, $iRowX = 15, $iMaxDisplayRows = 36
    
    Select
        Case $iMsg == $g_hDEnter
            If $g_iDisplayCount > 0 And ($g_iScrollOffset + $g_iSelectedIndex) < UBound($g_aFilteredPaths) Then
                Local $sFocusedPath = $g_aFilteredPaths[$g_iScrollOffset + $g_iSelectedIndex]
                If $g_bExploreMode Then
                    Local $aNewPaths = _Picker_GetDescendants($aAllMatches, $sFocusedPath)
                    ; FIXED: Targeted explicit cell evaluation index to resolve runtime array casting crash
                    If UBound($aNewPaths) > 0 And $aNewPaths[0] <> "" Then
                        $g_sExploreDir = $sFocusedPath
                        $g_aActiveBasePaths = $aNewPaths
                        GUICtrlSetData($g_hInputField, "")
                        $g_sLastQuery = "|||FORCED|||"
                    EndIf
                Else
                    $g_sSelectedPath = $sFocusedPath
                    Return True
                EndIf
            EndIf
            
        Case $iMsg == $g_hDCtrlEnter
            If $g_iDisplayCount > 0 And ($g_iScrollOffset + $g_iSelectedIndex) < UBound($g_aFilteredPaths) Then
                Local $sFocusedPath = $g_aFilteredPaths[$g_iScrollOffset + $g_iSelectedIndex]
                If Not $g_bExploreMode Then
                    $g_sSavedQueryText = GUICtrlRead($g_hInputField)
                    $g_iSavedSelectedIndex = $g_iSelectedIndex
                    $g_iSavedScrollOffset = $g_iScrollOffset
                    $g_bExploreMode = True
                    $g_sExploreDir = $sFocusedPath
                    $g_aActiveBasePaths = _Picker_GetDescendants($aAllMatches, $g_sExploreDir)
                    GUICtrlSetData($g_hInputField, "")
                    $g_sLastQuery = "|||FORCED|||"
                Else
                    _OpenInOpus($sFocusedPath)
                    Sleep(100)
                    WinActivate($g_hPickerGUI)
                    ControlFocus($g_hPickerGUI, "", $g_hInputField)
                EndIf
            EndIf

        Case $iMsg == $g_hDBackspace
            Local $sTxt = GUICtrlRead($g_hInputField)
            If $sTxt <> "" Then
                GUICtrlSetData($g_hInputField, StringTrimRight($sTxt, 1))
            ElseIf $g_bExploreMode Then
                Local $sParent = _Picker_GetParentPath($g_sExploreDir)
                If $sParent <> $g_sExploreDir Then
                    $g_sExploreDir = $sParent
                    $g_aActiveBasePaths = _Picker_GetDescendants($aAllMatches, $g_sExploreDir)
                    GUICtrlSetData($g_hInputField, "")
                    $g_sLastQuery = "|||FORCED|||"
                EndIf
            EndIf

        Case $iMsg == $g_hDCtrlBS
            If $g_bExploreMode Then
                $g_bExploreMode = False
                $g_sExploreDir = ""
                $g_aActiveBasePaths = $aAllMatches
                $g_bRestoringState = True
                GUICtrlSetData($g_hInputField, $g_sSavedQueryText)
                $g_sLastQuery = "|||FORCED|||"
            Else
                Local $sTxt = GUICtrlRead($g_hInputField)
                If $sTxt <> "" Then
                    Local $iLen = StringLen($sTxt), $iLastSpace = StringInStr($sTxt, " ", 0, -1), $iLastSlash = StringInStr($sTxt, "\", 0, -1)
                    Local $iCut = ($iLastSlash > $iLastSpace) ? $iLastSlash : $iLastSpace
                    GUICtrlSetData($g_hInputField, ($iCut > 0) ? StringLeft($sTxt, $iCut - 1) : "")
                EndIf
            EndIf

        Case $iMsg == $g_hDEscape
            If $g_bExploreMode Then
                $g_bExploreMode = False
                $g_sExploreDir = ""
                $g_aActiveBasePaths = $aAllMatches
                $g_bRestoringState = True
                GUICtrlSetData($g_hInputField, $g_sSavedQueryText)
                $g_sLastQuery = "|||FORCED|||"
            Else
                Return True
            EndIf

        Case $iMsg == $g_hDCopy
            If $g_iDisplayCount > 0 And ($g_iScrollOffset + $g_iSelectedIndex) < UBound($g_aFilteredPaths) Then
                Local $sCopyPath = $g_aFilteredPaths[$g_iScrollOffset + $g_iSelectedIndex]
                ClipPut($sCopyPath)
                Local $sOriginalStatus = GUICtrlRead($g_hStatusText)
                GUICtrlSetData($g_hStatusText, "📋 COPIED: " & $sCopyPath)
                Sleep(700)
                GUICtrlSetData($g_hStatusText, $sOriginalStatus)
            EndIf

        Case $iMsg == $g_hDCtrlInsert
            If $g_iDisplayCount > 0 And ($g_iScrollOffset + $g_iSelectedIndex) < UBound($g_aFilteredPaths) Then
                Local $sCopyPath = $g_aFilteredPaths[$g_iScrollOffset + $g_iSelectedIndex]
                Local $sMsgStatus = ""
                If StringInStr($sCopyPath, " [window") > 0 Then
                    Local $sCleanWin = StringRegExpReplace($sCopyPath, "(?i)\s+\[window(?::[^\]]+)?\]\s*$", "")
                    $sMsgStatus = _Picker_CopyWindowInfo($sCleanWin)
                Else
                    ClipPut($sCopyPath)
                    $sMsgStatus = "📋 COPIED: " & $sCopyPath
                EndIf
                Local $sOriginalStatus = GUICtrlRead($g_hStatusText)
                GUICtrlSetData($g_hStatusText, $sMsgStatus)
                Sleep(1000)
                GUICtrlSetData($g_hStatusText, $sOriginalStatus)
            EndIf

        Case $iMsg == $g_hDAltH
            $g_bShowHidden = Not $g_bShowHidden
            _Picker_UpdateToolbarText()
            If $g_bIsCombinedPicker Then
                _Picker_RebuildCombinedMatches($aAllMatches)
                _Picker_HandleQueryChange($aAllMatches)
            EndIf

        Case $iMsg == $g_hDAltM
            $g_bShowMinimized = Not $g_bShowMinimized
            _Picker_UpdateToolbarText()
            If $g_bIsCombinedPicker Then
                _Picker_RebuildCombinedMatches($aAllMatches)
                _Picker_HandleQueryChange($aAllMatches)
            EndIf

        Case $iMsg == $g_hDApps
            Beep(800, 150)
            If $g_iDisplayCount > 0 And ($g_iScrollOffset + $g_iSelectedIndex) < UBound($g_aFilteredPaths) Then
                Local $sSelectedPathVal = $g_aFilteredPaths[$g_iScrollOffset + $g_iSelectedIndex]
                If StringInStr($sSelectedPathVal, " [window") > 0 Then
                    Local $sCleanWinText = StringRegExpReplace($sSelectedPathVal, "(?i)\s+\[window(?::[^\]]+)?\]\s*$", "")
                    Local $sMiniChoice = _Picker_Show_WinContextMenu($g_hPickerGUI, $sCleanWinText)
                    If $sMiniChoice == "Activate" Then
                        $g_sSelectedPath = $sSelectedPathVal
                        Return True
                    EndIf
                EndIf
            EndIf

        Case $iMsg == $g_hDF1
            _Picker_ShowHelpGUI($g_hPickerGUI)

        Case $iMsg == $g_hScrollUp
            _Picker_ScrollBy(-1)
            
        Case $iMsg == $g_hScrollDown
            _Picker_ScrollBy(1)
            
        Case $iMsg == $g_hScrollTrack
            Local $aCursorInfo = GUIGetCursorInfo($g_hPickerGUI)
            If IsArray($aCursorInfo) Then
                Local $iClickY = $aCursorInfo[1]
                Local $iTrackTop = $iInputAreaHeight + 8 + 14
                Local $iTrackHeight = ($g_iDisplayCount * $iRowHeight) - 28
                If $iTrackHeight > 0 Then
                    Local $fFraction = ($iClickY - $iTrackTop) / $iTrackHeight
                    If $fFraction < 0 Then $fFraction = 0
                    If $fFraction > 1 Then $fFraction = 1
                    
                    Local $iTotalItems = UBound($g_aFilteredPaths)
                    Local $iMaxScrollOffset = $iTotalItems - $iMaxDisplayRows
                    If $iMaxScrollOffset < 0 Then $iMaxScrollOffset = 0
                    
                    Local $iTargetOffset = Round($fFraction * $iMaxScrollOffset)
                    _Picker_ScrollTo($iTargetOffset)
                EndIf
            EndIf
            
        Case $iMsg == $g_hScrollThumb
            Local $aCursorInfo = GUIGetCursorInfo($g_hPickerGUI)
            If IsArray($aCursorInfo) Then
                Local $iInitialMouseY = $aCursorInfo[1]
                Local $iInitialScrollOffset = $g_iScrollOffset
                Local $iTrackHeight = ($g_iDisplayCount * $iRowHeight) - 28
                
                Local $iTotalItems = UBound($g_aFilteredPaths)
                Local $iMaxScrollOffset = $iTotalItems - $iMaxDisplayRows
                If $iMaxScrollOffset < 0 Then $iMaxScrollOffset = 0
                
                Local $iThumbHeight = ($iMaxDisplayRows / $iTotalItems) * $iTrackHeight
                If $iThumbHeight < 16 Then $iThumbHeight = 16
                If $iThumbHeight > $iTrackHeight Then $iThumbHeight = $iTrackHeight
                
                Local $iScrollRangePixels = $iTrackHeight - $iThumbHeight
                If $iScrollRangePixels > 0 Then
                    While 1
                        Local $aDragInfo = GUIGetCursorInfo($g_hPickerGUI)
                        If Not IsArray($aDragInfo) Or $aDragInfo[2] == 0 Then ExitLoop ; Left mouse released
                        
                        Local $iCurrentMouseY = $aDragInfo[1]
                        Local $iDeltaY = $iCurrentMouseY - $iInitialMouseY
                        
                        Local $fItemDelta = ($iDeltaY / $iScrollRangePixels) * $iMaxScrollOffset
                        Local $iNewOffset = Round($iInitialScrollOffset + $fItemDelta)
                        
                        _Picker_ScrollTo($iNewOffset)
                        
                        Sleep(10)
                    WEnd
                EndIf
            EndIf

        Case Else
            _Picker_HandleKeyPress($iMsg, $aAllMatches)
            For $i = 1 To $g_iDisplayCount
                If $iMsg == $g_aRowIcon[$i] Or $iMsg == $g_aRowIdxCtrl[$i] Or $iMsg == $g_aRowBorder[$i] Or $iMsg == $g_aRowBg[$i] Or $iMsg == $g_aRowPre[$i] Or $iMsg == $g_aRowMatch[$i] Or $iMsg == $g_aRowPost[$i] Or $iMsg == $g_aRowPath[$i] Or $iMsg == $g_aRowDepthInfo[$i] Then
                    Local $iClickedIdx = $i - 1
                    If $iClickedIdx <> $g_iSelectedIndex Then
                         ; Focus/select clicked row
                        _Picker_HighlightRowDynamic($g_aRowIcon, $g_aRowIdxCtrl, $g_aRowBorder, $g_aRowBg, $g_aRowPre, $g_aRowMatch, $g_aRowPost, $g_aRowPath, $g_aRowDepthInfo, $g_aFilteredPaths, GUICtrlRead($g_hInputField), $g_iSelectedIndex, $g_iScrollOffset + $g_iSelectedIndex, False, ($g_iScrollOffset + $g_iSelectedIndex < $g_iRecentCount), $g_bExploreMode, $g_sExploreDir, $iInputAreaHeight)
                        $g_iSelectedIndex = $iClickedIdx
                        _Picker_HighlightRowDynamic($g_aRowIcon, $g_aRowIdxCtrl, $g_aRowBorder, $g_aRowBg, $g_aRowPre, $g_aRowMatch, $g_aRowPost, $g_aRowPath, $g_aRowDepthInfo, $g_aFilteredPaths, GUICtrlRead($g_hInputField), $g_iSelectedIndex, $g_iScrollOffset + $g_iSelectedIndex, True, ($g_iScrollOffset + $g_iSelectedIndex < $g_iRecentCount), $g_bExploreMode, $g_sExploreDir, $iInputAreaHeight)
                        
                        Local $iActiveTop = $iInputAreaHeight + 8 + ($g_iSelectedIndex * $iRowHeight)
                        Local $iSpecColor = _Picker_GetBaseColor(_Picker_GetBaseName($g_aFilteredPaths[$g_iScrollOffset + $g_iSelectedIndex]))
                        _Picker_UpdateFocusBorder($g_hRowFocusL, $g_hRowFocusR, $g_hRowFocusT, $g_hRowFocusB, $iRowX, $iActiveTop, $iRowWidth, $iSpecColor, True)
                        _Picker_UpdateStatusText($g_hStatusText, $g_hStatusBg, $g_aFilteredPaths, $g_iSelectedIndex, $g_iScrollOffset, $g_bExploreMode, $g_sExploreDir, UBound($g_aFilteredPaths) - $g_iRecentCount, $g_iRecentCount)
                        
                        $g_iLastClickedRow = $g_iSelectedIndex
                        $g_hClickTimer = TimerInit()
                    Else
                        ; Double click check
                        If TimerDiff($g_hClickTimer) < 400 And $g_iLastClickedRow == $g_iSelectedIndex Then
                            ; Equivalent to Enter key
                            Local $sFocusedPath = $g_aFilteredPaths[$g_iScrollOffset + $g_iSelectedIndex]
                            If $g_bExploreMode Then
                                Local $aNewPaths = _Picker_GetDescendants($aAllMatches, $sFocusedPath)
                                If UBound($aNewPaths) > 0 And $aNewPaths[0] <> "" Then
                                    $g_sExploreDir = $sFocusedPath
                                    $g_aActiveBasePaths = $aNewPaths
                                    GUICtrlSetData($g_hInputField, "")
                                    $g_sLastQuery = "|||FORCED|||"
                                EndIf
                            Else
                                $g_sSelectedPath = $sFocusedPath
                                Return True
                            Endif
                        Else
                            $g_hClickTimer = TimerInit()
                        EndIf
                    EndIf
                    ExitLoop
                EndIf
            Next
    EndSelect
    
    Return False
EndFunc

; ==============================================================================
; Public API: Handles the WM_CONTEXTMENU Win32 message for the picker window
; ==============================================================================
Func _Picker_WM_CONTEXTMENU($hWnd, $iMsg, $wParam, $lParam)
    #forceref $iMsg, $wParam, $lParam
    If $hWnd <> $g_hPickerGUI Then Return "GUI_RUNDEFMSG"
    
    If $g_iDisplayCount > 0 And ($g_iScrollOffset + $g_iSelectedIndex) < UBound($g_aFilteredPaths) Then
        Local $sSelectedPathVal = $g_aFilteredPaths[$g_iScrollOffset + $g_iSelectedIndex]
        If StringInStr($sSelectedPathVal, " [window") > 0 Then
            Local $sCleanWinText = StringRegExpReplace($sSelectedPathVal, "(?i)\s+\[window(?::[^\]]+)?\]\s*$", "")
            _Picker_Show_WinContextMenu($g_hPickerGUI, $sCleanWinText)
            Return 0
        EndIf
    EndIf
    Return "GUI_RUNDEFMSG"
EndFunc

; ==============================================================================
; Public API: Handles the WM_MOUSEWHEEL Win32 message for scroll events
; ==============================================================================
Func _Picker_WM_MOUSEWHEEL($hWnd, $iMsg, $wParam, $lParam)
    #forceref $iMsg, $lParam
    If $hWnd <> $g_hPickerGUI Then Return "GUI_RUNDEFMSG"
    
    Local $iDelta = BitShift($wParam, 16)
    If BitAND($iDelta, 0x8000) Then $iDelta = BitOR($iDelta, 0xFFFF0000)
    
    If $iDelta > 0 Then
        _Picker_ScrollBy(-3) ; Scroll Up 3 rows
    ElseIf $iDelta < 0 Then
        _Picker_ScrollBy(3)  ; Scroll Down 3 rows
    EndIf
    
    Return 0
EndFunc

; ==============================================================================
; Public API Helper: Relocates viewport offset to an absolute index coordinates point
; ==============================================================================
Func _Picker_ScrollTo($iTargetOffset)
    Local $iMaxDisplayRows = UBound($g_aRowBg) - 1
    Local $iTotalItems = UBound($g_aFilteredPaths)
    Local $iMaxScrollOffset = $iTotalItems - $iMaxDisplayRows
    If $iMaxScrollOffset < 0 Then $iMaxScrollOffset = 0
    
    Local $iOldScrollOffset = $g_iScrollOffset
    $g_iScrollOffset = $iTargetOffset
    If $g_iScrollOffset < 0 Then $g_iScrollOffset = 0
    If $g_iScrollOffset > $iMaxScrollOffset Then $g_iScrollOffset = $iMaxScrollOffset
    
    If $g_iScrollOffset <> $iOldScrollOffset Then
        Local $iInputAreaHeight = 124
        _Picker_RenderVisibleList($g_aRowIcon, $g_aRowIdxCtrl, $g_aRowBorder, $g_aRowBg, $g_aRowPre, $g_aRowMatch, $g_aRowPost, $g_aRowPath, $g_aRowDepthInfo, $g_aFilteredPaths, GUICtrlRead($g_hInputField), $g_iDisplayCount, $g_iSelectedIndex, $g_iScrollOffset, $iMaxDisplayRows, $g_iRecentCount, $g_bExploreMode, $g_sExploreDir, $iInputAreaHeight)
        
        Local $iActiveTop = $iInputAreaHeight + 8 + ($g_iSelectedIndex * 42)
        Local $iRowWidth = 670, $iRowX = 15
        Local $iSpecColor = _Picker_GetBaseColor(_Picker_GetBaseName($g_aFilteredPaths[$g_iScrollOffset + $g_iSelectedIndex]))
        _Picker_UpdateFocusBorder($g_hRowFocusL, $g_hRowFocusR, $g_hRowFocusT, $g_hRowFocusB, $iRowX, $iActiveTop, $iRowWidth, $iSpecColor, True)
        _Picker_UpdateStatusText($g_hStatusText, $g_hStatusBg, $g_aFilteredPaths, $g_iSelectedIndex, $g_iScrollOffset, $g_bExploreMode, $g_sExploreDir, UBound($g_aFilteredPaths) - $g_iRecentCount, $g_iRecentCount)
    EndIf
EndFunc

; ==============================================================================
; Public API Helper: Shifts viewport offset up/down by a given offset increment delta
; ==============================================================================
Func _Picker_ScrollBy($iDeltaOffset)
    _Picker_ScrollTo($g_iScrollOffset + $iDeltaOffset)
EndFunc

; End of file: _picker_event.au3
