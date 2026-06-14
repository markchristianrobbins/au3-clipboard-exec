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
    Local $iRowHeight = 42, $iInputAreaHeight = 104, $iMenuWidth = 700, $iRowWidth = 670, $iRowX = 15, $iMaxDisplayRows = 36
    Local $sCurrentQuery = GUICtrlRead($g_hInputField)
    $g_sLastQuery = $sCurrentQuery
    
    Local $aRecentPaths = _Picker_LoadRecents()
    $g_iRecentCount = 0
    
    ; CRITICAL FIX: Explicitly sizing the array to 5 items *before* writing to it via subscript index
    Local $aActualRecents[5]
    For $i = 0 To UBound($aRecentPaths) - 1
        If $aRecentPaths[$i] <> "" Then
            $aActualRecents[$g_iRecentCount] = $aRecentPaths[$i]
            $g_iRecentCount += 1
            If $g_iRecentCount >= 5 Then ExitLoop
        EndIf
    Next
    If $g_iRecentCount > 0 Then ReDim $aActualRecents[$g_iRecentCount]
    
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
    Local $iRowHeight = 42, $iInputAreaHeight = 104, $iMenuWidth = 700, $iRowWidth = 670, $iRowX = 15, $iMaxDisplayRows = 36
    
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

        Case Else
            _Picker_HandleKeyPress($iMsg, $aAllMatches)
            For $i = 1 To $g_iDisplayCount
                If $iMsg == $g_aRowIcon[$i] Or $iMsg == $g_aRowIdxCtrl[$i] Or $iMsg == $g_aRowBorder[$i] Or $iMsg == $g_aRowBg[$i] Or $iMsg == $g_aRowPre[$i] Or $iMsg == $g_aRowMatch[$i] Or $iMsg == $g_aRowPost[$i] Or $iMsg == $g_aRowPath[$i] Or $iMsg == $g_aRowDepthInfo[$i] Then
                    $g_sSelectedPath = $g_aFilteredPaths[$g_iScrollOffset + $i - 1]
                    Return True
                EndIf
            Next
    EndSelect
    
    Return False
EndFunc

; End of file: _picker_event.au3
