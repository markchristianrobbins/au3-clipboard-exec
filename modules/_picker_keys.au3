#include-once
; ==============================================================================
; File: _picker_keys.au3
; Description: Intercepts keyboard triggers and performs list index offsets & bounds checks.
; Functions:
;   - _Picker_HandleKeyPress (Responds to navigation keys for index manipulation, PGUP/PGDN, and HOME/END)
; ==============================================================================
#include <GUIConstantsEx.au3>
#include "_picker_globals.au3"
#include "_picker_helpers.au3"
#include "_picker_filter.au3"
#include "_picker_render.au3"
#include "_picker_style.au3"

Func _Picker_HandleKeyPress($iMsg, ByRef $aAllMatches)
    Local $iRowHeight = 42, $iInputAreaHeight = 104, $iMenuWidth = 700, $iRowWidth = 670, $iRowX = 15, $iMaxDisplayRows = 36
    Local $sCurrentQuery = GUICtrlRead($g_hInputField)
    
    Select
        Case $iMsg == $g_hDDown And $g_iDisplayCount > 0
            Local $iTotalMatches = UBound($g_aFilteredPaths), $iOldAbsoluteIndex = $g_iScrollOffset + $g_iSelectedIndex, $iNewAbsoluteIndex = Mod($iOldAbsoluteIndex + 1, $iTotalMatches)
            If $iNewAbsoluteIndex == 0 Then
                _Picker_HighlightRowDynamic($g_aRowIcon, $g_aRowIdxCtrl, $g_aRowBorder, $g_aRowBg, $g_aRowPre, $g_aRowMatch, $g_aRowPost, $g_aRowPath, $g_aRowDepthInfo, $g_aFilteredPaths, $sCurrentQuery, $g_iSelectedIndex, $iOldAbsoluteIndex, False, ($iOldAbsoluteIndex < $g_iRecentCount), $g_bExploreMode, $g_sExploreDir, $iInputAreaHeight)
                $g_iScrollOffset = 0
                $g_iSelectedIndex = 0
                _Picker_RenderVisibleList($g_aRowIcon, $g_aRowIdxCtrl, $g_aRowBorder, $g_aRowBg, $g_aRowPre, $g_aRowMatch, $g_aRowPost, $g_aRowPath, $g_aRowDepthInfo, $g_aFilteredPaths, $sCurrentQuery, $g_iDisplayCount, $g_iSelectedIndex, $g_iScrollOffset, $iMaxDisplayRows, $g_iRecentCount, $g_bExploreMode, $g_sExploreDir, $iInputAreaHeight)
            Else
                If $g_iSelectedIndex < $g_iDisplayCount - 1 Then
                    _Picker_HighlightRowDynamic($g_aRowIcon, $g_aRowIdxCtrl, $g_aRowBorder, $g_aRowBg, $g_aRowPre, $g_aRowMatch, $g_aRowPost, $g_aRowPath, $g_aRowDepthInfo, $g_aFilteredPaths, $sCurrentQuery, $g_iSelectedIndex, $iOldAbsoluteIndex, False, ($iOldAbsoluteIndex < $g_iRecentCount), $g_bExploreMode, $g_sExploreDir, $iInputAreaHeight)
                    $g_iSelectedIndex += 1
                    _Picker_HighlightRowDynamic($g_aRowIcon, $g_aRowIdxCtrl, $g_aRowBorder, $g_aRowBg, $g_aRowPre, $g_aRowMatch, $g_aRowPost, $g_aRowPath, $g_aRowDepthInfo, $g_aFilteredPaths, $sCurrentQuery, $g_iSelectedIndex, $iNewAbsoluteIndex, True, ($iNewAbsoluteIndex < $g_iRecentCount), $g_bExploreMode, $g_sExploreDir, $iInputAreaHeight)
                Else
                    _Picker_HighlightRowDynamic($g_aRowIcon, $g_aRowIdxCtrl, $g_aRowBorder, $g_aRowBg, $g_aRowPre, $g_aRowMatch, $g_aRowPost, $g_aRowPath, $g_aRowDepthInfo, $g_aFilteredPaths, $sCurrentQuery, $g_iSelectedIndex, $iOldAbsoluteIndex, False, ($iOldAbsoluteIndex < $g_iRecentCount), $g_bExploreMode, $g_sExploreDir, $iInputAreaHeight)
                    $g_iScrollOffset += 1
                    _Picker_RenderVisibleList($g_aRowIcon, $g_aRowIdxCtrl, $g_aRowBorder, $g_aRowBg, $g_aRowPre, $g_aRowMatch, $g_aRowPost, $g_aRowPath, $g_aRowDepthInfo, $g_aFilteredPaths, $sCurrentQuery, $g_iDisplayCount, $g_iSelectedIndex, $g_iScrollOffset, $iMaxDisplayRows, $g_iRecentCount, $g_bExploreMode, $g_sExploreDir, $iInputAreaHeight)
                EndIf
            EndIf
            Local $iActiveTop = $iInputAreaHeight + 8 + ($g_iSelectedIndex * $iRowHeight)
            Local $iSpecColor = _Picker_GetBaseColor(_Picker_GetBaseName($g_aFilteredPaths[$g_iScrollOffset + $g_iSelectedIndex]))
            _Picker_UpdateFocusBorder($g_hRowFocusL, $g_hRowFocusR, $g_hRowFocusT, $g_hRowFocusB, $iRowX, $iActiveTop, $iRowWidth, $iSpecColor, True)
            
        Case $iMsg == $g_hDUp And $g_iDisplayCount > 0
            Local $iTotalMatches = UBound($g_aFilteredPaths), $iOldAbsoluteIndex = $g_iScrollOffset + $g_iSelectedIndex, $iNewAbsoluteIndex = $iOldAbsoluteIndex - 1
            If $iNewAbsoluteIndex < 0 Then
                _Picker_HighlightRowDynamic($g_aRowIcon, $g_aRowIdxCtrl, $g_aRowBorder, $g_aRowBg, $g_aRowPre, $g_aRowMatch, $g_aRowPost, $g_aRowPath, $g_aRowDepthInfo, $g_aFilteredPaths, $sCurrentQuery, $g_iSelectedIndex, $iOldAbsoluteIndex, False, ($iOldAbsoluteIndex < $g_iRecentCount), $g_bExploreMode, $g_sExploreDir, $iInputAreaHeight)
                $g_iScrollOffset = ($iTotalMatches - $iMaxDisplayRows < 0) ? 0 : $iTotalMatches - $iMaxDisplayRows
                $g_iSelectedIndex = $iTotalMatches - 1 - $g_iScrollOffset
                _Picker_RenderVisibleList($g_aRowIcon, $g_aRowIdxCtrl, $g_aRowBorder, $g_aRowBg, $g_aRowPre, $g_aRowMatch, $g_aRowPost, $g_aRowPath, $g_aRowDepthInfo, $g_aFilteredPaths, $sCurrentQuery, $g_iDisplayCount, $g_iSelectedIndex, $g_iScrollOffset, $iMaxDisplayRows, $g_iRecentCount, $g_bExploreMode, $g_sExploreDir, $iInputAreaHeight)
            Else
                If $g_iSelectedIndex > 0 Then
                    _Picker_HighlightRowDynamic($g_aRowIcon, $g_aRowIdxCtrl, $g_aRowBorder, $g_aRowBg, $g_aRowPre, $g_aRowMatch, $g_aRowPost, $g_aRowPath, $g_aRowDepthInfo, $g_aFilteredPaths, $sCurrentQuery, $g_iSelectedIndex, $iOldAbsoluteIndex, False, ($iOldAbsoluteIndex < $g_iRecentCount), $g_bExploreMode, $g_sExploreDir, $iInputAreaHeight)
                    $g_iSelectedIndex -= 1
                    _Picker_HighlightRowDynamic($g_aRowIcon, $g_aRowIdxCtrl, $g_aRowBorder, $g_aRowBg, $g_aRowPre, $g_aRowMatch, $g_aRowPost, $g_aRowPath, $g_aRowDepthInfo, $g_aFilteredPaths, $sCurrentQuery, $g_iSelectedIndex, $iNewAbsoluteIndex, True, ($iNewAbsoluteIndex < $g_iRecentCount), $g_bExploreMode, $g_sExploreDir, $iInputAreaHeight)
                Else
                    _Picker_HighlightRowDynamic($g_aRowIcon, $g_aRowIdxCtrl, $g_aRowBorder, $g_aRowBg, $g_aRowPre, $g_aRowMatch, $g_aRowPost, $g_aRowPath, $g_aRowDepthInfo, $g_aFilteredPaths, $sCurrentQuery, $g_iSelectedIndex, $iOldAbsoluteIndex, False, ($iOldAbsoluteIndex < $g_iRecentCount), $g_bExploreMode, $g_sExploreDir, $iInputAreaHeight)
                    $g_iScrollOffset -= 1
                    _Picker_RenderVisibleList($g_aRowIcon, $g_aRowIdxCtrl, $g_aRowBorder, $g_aRowBg, $g_aRowPre, $g_aRowMatch, $g_aRowPost, $g_aRowPath, $g_aRowDepthInfo, $g_aFilteredPaths, $sCurrentQuery, $g_iDisplayCount, $g_iSelectedIndex, $g_iScrollOffset, $iMaxDisplayRows, $g_iRecentCount, $g_bExploreMode, $g_sExploreDir, $iInputAreaHeight)
                Endif
            EndIf
            Local $iActiveTop = $iInputAreaHeight + 8 + ($g_iSelectedIndex * $iRowHeight)
            Local $iSpecColor = _Picker_GetBaseColor(_Picker_GetBaseName($g_aFilteredPaths[$g_iScrollOffset + $g_iSelectedIndex]))
            _Picker_UpdateFocusBorder($g_hRowFocusL, $g_hRowFocusR, $g_hRowFocusT, $g_hRowFocusB, $iRowX, $iActiveTop, $iRowWidth, $iSpecColor, True)
            
        Case $iMsg == $g_hDPgUp And $g_iDisplayCount > 0
            Local $iOldAbsoluteIndex = $g_iScrollOffset + $g_iSelectedIndex, $iNewAbsoluteIndex = ($iOldAbsoluteIndex - $g_iDisplayCount < 0) ? 0 : $iOldAbsoluteIndex - $g_iDisplayCount
            _Picker_HighlightRowDynamic($g_aRowIcon, $g_aRowIdxCtrl, $g_aRowBorder, $g_aRowBg, $g_aRowPre, $g_aRowMatch, $g_aRowPost, $g_aRowPath, $g_aRowDepthInfo, $g_aFilteredPaths, $sCurrentQuery, $g_iSelectedIndex, $iOldAbsoluteIndex, False, ($iOldAbsoluteIndex < $g_iRecentCount), $g_bExploreMode, $g_sExploreDir, $iInputAreaHeight)
            If $iNewAbsoluteIndex < $g_iSelectedIndex Then
                $g_iScrollOffset = 0
                $g_iSelectedIndex = $iNewAbsoluteIndex
            Else
                $g_iScrollOffset = $iNewAbsoluteIndex - $g_iSelectedIndex
            EndIf
            _Picker_RenderVisibleList($g_aRowIcon, $g_aRowIdxCtrl, $g_aRowBorder, $g_aRowBg, $g_aRowPre, $g_aRowMatch, $g_aRowPost, $g_aRowPath, $g_aRowDepthInfo, $g_aFilteredPaths, $sCurrentQuery, $g_iDisplayCount, $g_iSelectedIndex, $g_iScrollOffset, $iMaxDisplayRows, $g_iRecentCount, $g_bExploreMode, $g_sExploreDir, $iInputAreaHeight)
            Local $iActiveTop = $iInputAreaHeight + 8 + ($g_iSelectedIndex * $iRowHeight)
            Local $iSpecColor = _Picker_GetBaseColor(_Picker_GetBaseName($g_aFilteredPaths[$g_iScrollOffset + $g_iSelectedIndex]))
            _Picker_UpdateFocusBorder($g_hRowFocusL, $g_hRowFocusR, $g_hRowFocusT, $g_hRowFocusB, $iRowX, $iActiveTop, $iRowWidth, $iSpecColor, True)

        Case $iMsg == $g_hDPgDn And $g_iDisplayCount > 0
            Local $iTotalMatches = UBound($g_aFilteredPaths), $iOldAbsoluteIndex = $g_iScrollOffset + $g_iSelectedIndex, $iNewAbsoluteIndex = ($iOldAbsoluteIndex + $g_iDisplayCount >= $iTotalMatches) ? $iTotalMatches - 1 : $iOldAbsoluteIndex + $g_iDisplayCount
            _Picker_HighlightRowDynamic($g_aRowIcon, $g_aRowIdxCtrl, $g_aRowBorder, $g_aRowBg, $g_aRowPre, $g_aRowMatch, $g_aRowPost, $g_aRowPath, $g_aRowDepthInfo, $g_aFilteredPaths, $sCurrentQuery, $g_iSelectedIndex, $iOldAbsoluteIndex, False, ($iOldAbsoluteIndex < $g_iRecentCount), $g_bExploreMode, $g_sExploreDir, $iInputAreaHeight)
            If $iNewAbsoluteIndex >= $iTotalMatches - ($g_iDisplayCount - $g_iSelectedIndex) Then
                $g_iScrollOffset = ($iTotalMatches - $g_iDisplayCount < 0) ? 0 : $iTotalMatches - $g_iDisplayCount
                $g_iSelectedIndex = $iNewAbsoluteIndex - $g_iScrollOffset
            Else
                $g_iScrollOffset = $iNewAbsoluteIndex - $g_iSelectedIndex
            EndIf
            _Picker_RenderVisibleList($g_aRowIcon, $g_aRowIdxCtrl, $g_aRowBorder, $g_aRowBg, $g_aRowPre, $g_aRowMatch, $g_aRowPost, $g_aRowPath, $g_aRowDepthInfo, $g_aFilteredPaths, $sCurrentQuery, $g_iDisplayCount, $g_iSelectedIndex, $g_iScrollOffset, $iMaxDisplayRows, $g_iRecentCount, $g_bExploreMode, $g_sExploreDir, $iInputAreaHeight)
            Local $iActiveTop = $iInputAreaHeight + 8 + ($g_iSelectedIndex * $iRowHeight)
            Local $iSpecColor = _Picker_GetBaseColor(_Picker_GetBaseName($g_aFilteredPaths[$g_iScrollOffset + $g_iSelectedIndex]))
            _Picker_UpdateFocusBorder($g_hRowFocusL, $g_hRowFocusR, $g_hRowFocusT, $g_hRowFocusB, $iRowX, $iActiveTop, $iRowWidth, $iSpecColor, True)
    EndSelect
EndFunc

; End of file: _picker_keys.au3
