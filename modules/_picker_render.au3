#include-once
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>

; ==============================================================================
; Public API: Programmatic layout renderer for all visible flat rows on screen
; ==============================================================================
Func _Picker_RenderVisibleList(ByRef $aIdx, ByRef $aBdr, ByRef $aBg, ByRef $aPre, ByRef $aPth, ByRef $aDph, ByRef $aFltr, $sQry, $iDisp, $iSel, $iScroll, $iMax)
    For $i = 0 To $iMax - 1
        Local $iAbsIdx = $iScroll + $i
        Local $hBorderCtrl = $aBdr[$i + 1]
        Local $hBgCtrl = $aBg[$i + 1]
        Local $hIdxCtrl = $aIdx[$i + 1]
        Local $hPreCtrl = $aPre[$i + 1]
        Local $hPathCtrl = $aPth[$i + 1]
        Local $hDepthInfoCtrl = $aDph[$i + 1]

        If $i < $iDisp And $iAbsIdx < UBound($aFltr) Then
            _Picker_HighlightRowDynamic($aIdx, $aBdr, $aBg, $aPre, $aPth, $aDph, $aFltr, $sQry, $i, $iAbsIdx, ($i == $iSel))
            
            GUICtrlSetState($hBgCtrl, $GUI_SHOW)
            GUICtrlSetState($hIdxCtrl, $GUI_SHOW)
            GUICtrlSetState($hPreCtrl, $GUI_SHOW)
            GUICtrlSetState($hPathCtrl, $GUI_SHOW)
            GUICtrlSetState($hDepthInfoCtrl, $GUI_SHOW)
        Else
            GUICtrlSetState($hBorderCtrl, $GUI_HIDE)
            GUICtrlSetState($hBgCtrl, $GUI_HIDE)
            GUICtrlSetState($hIdxCtrl, $GUI_HIDE)
            GUICtrlSetState($hPreCtrl, $GUI_HIDE)
            GUICtrlSetState($hPathCtrl, $GUI_HIDE)
            GUICtrlSetState($hDepthInfoCtrl, $GUI_HIDE)
        EndIf
    Next
EndFunc

; ==============================================================================
; Public API: Modulates individual flattened text paths and background states
; ==============================================================================
Func _Picker_HighlightRowDynamic(ByRef $aRowIdxCtrl, ByRef $aRowBorder, ByRef $aRowBg, ByRef $aRowPre, ByRef $aRowPath, ByRef $aRowDepthInfo, ByRef $aFilteredPaths, $sSearchTxt, $iVisualIndex, $iAbsoluteIndex, $bActive)
    Local $hIdxCtrl = $aRowIdxCtrl[$iVisualIndex + 1], $hBorderCtrl = $aRowBorder[$iVisualIndex + 1], $hBgCtrl = $aRowBg[$iVisualIndex + 1]
    Local $hPreCtrl = $aRowPre[$iVisualIndex + 1], $hPathCtrl = $aRowPath[$iVisualIndex + 1], $hDepthInfoCtrl = $aRowDepthInfo[$iVisualIndex + 1]

    Local $sFullPath = $aFilteredPaths[$iAbsoluteIndex]
    
    ; Extract pure folder name for clean presentation layer headers
    Local $sBaseName = $sFullPath
    If StringRight($sBaseName, 1) == "\" Then $sBaseName = StringTrimRight($sBaseName, 1)
    Local $iSlashPos = StringInStr($sBaseName, "\", 0, -1)
    If $iSlashPos > 0 Then $sBaseName = StringMid($sBaseName, $iSlashPos + 1)

    Local $aSplit = StringSplit($sFullPath, "\"), $iLevel = $aSplit
    Local $iRowX = 15, $iTopPos = 104 + 8 + ($iVisualIndex * 42)

    ; Push data strings straight to flat elements (bypasses alignment offset math completely)
    GUICtrlSetData($hIdxCtrl, $iAbsoluteIndex + 1)
    GUICtrlSetData($hPreCtrl, $sBaseName)
    GUICtrlSetData($hPathCtrl, $sFullPath)
    GUICtrlSetData($hDepthInfoCtrl, "[" & $iLevel & "]")

    ; CRITICAL FIX: Left alignments snap hard to left margins without folder icons or indents
    GUICtrlSetPos($hIdxCtrl, $iRowX + 6, $iTopPos + 13, 22, 14)
    GUICtrlSetPos($hPreCtrl, $iRowX + 42, $iTopPos + 4, 480, 18)
    GUICtrlSetPos($hPathCtrl, $iRowX + 42, $iTopPos + 22, 480, 15)
    GUICtrlSetPos($hDepthInfoCtrl, $iRowX + 530, $iTopPos + 13, 120, 16)

    If $bActive Then
        GUICtrlSetBkColor($hBgCtrl, 0x2D2D30)
        GUICtrlSetColor($hIdxCtrl, 0x999999)
        GUICtrlSetColor($hPreCtrl, 0x007ACC) 
        GUICtrlSetColor($hPathCtrl, 0xCCCCCC) 
        GUICtrlSetColor($hDepthInfoCtrl, 0x999999)
    Else
        GUICtrlSetBkColor($hBgCtrl, 0x1E1E1E)
        Local $iR = BitAND(BitShift(0x007ACC, 16), 0xFF) * 0.65, $iG = BitAND(BitShift(0x007ACC, 8), 0xFF) * 0.65, $iB = BitAND(0x007ACC, 0xFF) * 0.65
        Local $iDimColor = BitOR(BitShift(Int($iR), -16), BitShift(Int($iG), -8), Int($iB))
        GUICtrlSetColor($hIdxCtrl, 0x555555)
        GUICtrlSetColor($hPreCtrl, $iDimColor) 
        GUICtrlSetColor($hPathCtrl, 0x555555) 
        GUICtrlSetColor($hDepthInfoCtrl, 0x555555)
    EndIf
    GUICtrlSetState($hBorderCtrl, $GUI_HIDE) 
EndFunc

Func _Picker_UpdateFocusBorder($hL, $hR, $hT, $hB, $iRowX, $iActiveTop, $iRowWidth, $iSpecColor, $bShow)
    If Not $bShow Then
        GUICtrlSetState($hL, $GUI_HIDE)
        GUICtrlSetState($hR, $GUI_HIDE)
        GUICtrlSetState($hT, $GUI_HIDE)
        GUICtrlSetState($hB, $GUI_HIDE)
    Else
        GUICtrlSetPos($hL, $iRowX, $iActiveTop, 1, 38)
        GUICtrlSetBkColor($hL, $iSpecColor)
        GUICtrlSetState($hL, $GUI_SHOW)
        GUICtrlSetPos($hR, $iRowX + $iRowWidth - 1, $iActiveTop, 1, 38)
        GUICtrlSetBkColor($hR, $iSpecColor)
        GUICtrlSetState($hR, $GUI_SHOW)
        GUICtrlSetPos($hT, $iRowX, $iActiveTop, $iRowWidth, 1)
        GUICtrlSetBkColor($hT, $iSpecColor)
        GUICtrlSetState($hT, $GUI_SHOW)
        GUICtrlSetPos($hB, $iRowX, $iActiveTop + 37, $iRowWidth, 1)
        GUICtrlSetBkColor($hB, $iSpecColor)
        GUICtrlSetState($hB, $GUI_SHOW)
    EndIf
EndFunc

; modules\_picker_render.au3
