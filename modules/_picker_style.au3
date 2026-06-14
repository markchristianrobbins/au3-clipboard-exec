#include-once
; ==============================================================================
; File: _picker_style.au3
; Description: Generates dynamic focus, custom coloring schema, HSL/RGB math, and highlights.
; Functions:
;   - _Picker_GetBaseColor (Computes custom consistent folder coloring based on directory name hashing)
;   - _Picker_HueToRGB (Transforms fractional color hues into raw RGB values)
;   - _Picker_DimColor (Diminishes RGB intensity linearly for unselected rows)
;   - _Picker_UpdateFocusBorder (Re-positions and scales focus lines around current elements)
; ==============================================================================
#include <GUIConstantsEx.au3>

Func _Picker_GetBaseColor($sBaseName)
    Local $iLen = StringLen($sBaseName)
    If $iLen == 0 Then Return 0x007ACC
    
    Local $iSum = 0
    For $i = 1 To $iLen
        $iSum += Asc(StringMid($sBaseName, $i, 1))
    Next
    
    Local $fHue = Mod($iSum, 360) / 360
    Return _Picker_HueToRGB($fHue)
EndFunc

Func _Picker_HueToRGB($fHue)
    Local $fR = 0, $fG = 0, $fB = 0
    Local $fH = $fHue * 6
    Local $fI = Int($fH)
    Local $fF = $fH - $fI
    Local $fQ = 1 - $fF
    
    Switch $fI
        Case 0, 6
            $fR = 1; $fG = $fF; $fB = 0
        Case 1
            $fR = $fQ; $fG = 1; $fB = 0
        Case 2
            $fR = 0; $fG = 1; $fB = $fF
        Case 3
            $fR = 0; $fG = $fQ; $fB = 1
        Case 4
            $fR = $fF; $fG = 0; $fB = 1
        Case 5
            $fR = 1; $fG = 0; $fB = $fQ
    EndSwitch
    
    Local $iRed = Int(64 + ($fR * 191))
    Local $iGreen = Int(64 + ($fG * 191))
    Local $iBlue = Int(64 + ($fB * 191))
    Return BitOR(BitShift($iRed, -16), BitShift($iGreen, -8), $iBlue)
EndFunc

Func _Picker_DimColor($iColor, $fFactor)
    Local $iRed = BitAND(BitShift($iColor, 16), 0xFF)
    Local $iGreen = BitAND(BitShift($iColor, 8), 0xFF)
    Local $iBlue = BitAND($iColor, 0xFF)
    
    $iRed = Int($iRed * $fFactor)
    $iGreen = Int($iGreen * $fFactor)
    $iBlue = Int($iBlue * $fFactor)
    Return BitOR(BitShift($iRed, -16), BitShift($iGreen, -8), $iBlue)
EndFunc

Func _Picker_UpdateFocusBorder($hL, $hR, $hT, $hB, $iRowX, $iActiveTop, $iRowWidth, $iSpecColor, $bShow)
    If Not $bShow Then
        GUICtrlSetState($hL, $GUI_HIDE)
        GUICtrlSetState($hR, $GUI_HIDE)
        GUICtrlSetState($hT, $GUI_HIDE)
        GUICtrlSetState($hB, $GUI_HIDE)
    Else
        ; Left Border Line
        GUICtrlSetPos($hL, $iRowX, $iActiveTop, 1, 38)
        GUICtrlSetBkColor($hL, $iSpecColor)
        GUICtrlSetState($hL, $GUI_SHOW)
        
        ; Right Border Line
        GUICtrlSetPos($hR, $iRowX + $iRowWidth - 1, $iActiveTop, 1, 38)
        GUICtrlSetBkColor($hR, $iSpecColor)
        GUICtrlSetState($hR, $GUI_SHOW)
        
        ; Top Border Line
        GUICtrlSetPos($hT, $iRowX, $iActiveTop, $iRowWidth, 1)
        GUICtrlSetBkColor($hT, $iSpecColor)
        GUICtrlSetState($hT, $GUI_SHOW)
        
        ; Bottom Border Line
        GUICtrlSetPos($hB, $iRowX, $iActiveTop + 37, $iRowWidth, 1)
        GUICtrlSetBkColor($hB, $iSpecColor)
        GUICtrlSetState($hB, $GUI_SHOW)
    EndIf
EndFunc

; End of file: _picker_style.au3
