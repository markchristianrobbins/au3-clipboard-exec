#include-once
; ==============================================================================
; File: _picker_filter.au3
; Description: Handles path filtering, descendant lookup, and sorting of matches.
; Functions:
;   - _Picker_FilterPathsByFuzzyScore (Filters an array of paths by search query basename matching)
;   - _Picker_SortPathsByLevelAndAlphabet (Alphabetically sorts paths by hierarchy level)
;   - _Picker_GetDescendants (Returns all structural descendants under a directory)
;   - _Picker_BuildChildCounts (Caches child and grandchild subdirectory counts)
; ==============================================================================
#include "_picker_helpers.au3"

Func _Picker_FilterPathsByFuzzyScore($aMatchesList, $sSearchTxt)
    If $sSearchTxt == "" Then Return $aMatchesList
    
    Local $iMasterSize = UBound($aMatchesList)
    Local $aResults[$iMasterSize]   
    Local $iCount = 0
    
    For $i = 0 To $iMasterSize - 1
        Local $sFullPath = $aMatchesList[$i]
        Local $sCleanPath = $sFullPath
        If StringRight($sCleanPath, 1) == "\" And StringLen($sCleanPath) > 3 Then
            $sCleanPath = StringTrimRight($sCleanPath, 1)
        EndIf
        
        Local $iLastSl = StringInStr($sCleanPath, "\", 0, -1)
        Local $sBaseName = $sCleanPath
        If $iLastSl > 0 Then $sBaseName = StringMid($sCleanPath, $iLastSl + 1)
        
        If StringInStr(StringLower($sBaseName), StringLower($sSearchTxt), 0) Then
            $aResults[$iCount] = $sFullPath
            $iCount += 1
        EndIf
    Next
    
    If $iCount == 0 Then
        Local $aEmpty = [""]
        Return $aEmpty
    EndIf
    
    ReDim $aResults[$iCount]
    Return $aResults
EndFunc

Func _Picker_SortPathsByLevelAndAlphabet(ByRef $aPaths)
    Local $iSize = UBound($aPaths)
    If $iSize <= 1 Then Return

    Local $aLevels[$iSize]
    For $i = 0 To $iSize - 1
        $aLevels[$i] = _Picker_GetPathLevel($aPaths[$i])
    Next

    ; Shell Sort algorithm
    Local $iGap = Int($iSize / 2)
    While $iGap > 0
        For $i = $iGap To $iSize - 1
            Local $sTempPath = $aPaths[$i]
            Local $iTempLevel = $aLevels[$i]
            Local $j = $i
            While $j >= $iGap
                Local $bSwap = False
                If $aLevels[$j - $iGap] > $iTempLevel Then
                    $bSwap = True
                ElseIf $aLevels[$j - $iGap] == $iTempLevel Then
                    If StringCompare($aPaths[$j - $iGap], $sTempPath, 0) > 0 Then
                        $bSwap = True
                    EndIf
                EndIf
                
                If Not $bSwap Then ExitLoop
                
                $aPaths[$j] = $aPaths[$j - $iGap]
                $aLevels[$j] = $aLevels[$j - $iGap]
                $j -= $iGap
            WEnd
            $aPaths[$j] = $sTempPath
            $aLevels[$j] = $iTempLevel
        Next
        $iGap = Int($iGap / 2)
    WEnd
EndFunc

Func _Picker_GetDescendants(ByRef $aPaths, $sExploreDir)
    Local $iSize = UBound($aPaths)
    Local $aTemp[$iSize]
    Local $iCount = 0
    
    Local $sCleanExplore = $sExploreDir
    If StringRight($sCleanExplore, 1) == "\" And StringLen($sCleanExplore) > 3 Then
        $sCleanExplore = StringTrimRight($sCleanExplore, 1)
    EndIf
    Local $iLen = StringLen($sCleanExplore)

    For $i = 0 To $iSize - 1
        Local $sPath = $aPaths[$i]
        If StringRight($sPath, 1) == "\" And StringLen($sPath) > 3 Then
            $sPath = StringTrimRight($sPath, 1)
        EndIf
        
        If $sPath == $sCleanExplore Then ContinueLoop
        
        If StringLeft($sPath, $iLen) == $sCleanExplore Then
            If StringRight($sCleanExplore, 1) == "\" Then
                $aTemp[$iCount] = $aPaths[$i]
                $iCount += 1
            ElseIf StringMid($sPath, $iLen + 1, 1) == "\" Then
                $aTemp[$iCount] = $aPaths[$i]
                $iCount += 1
            EndIf
        EndIf
    Next
    
    If $iCount == 0 Then
        Local $aEmpty = [""]
        Return $aEmpty
    Endif
    
    ReDim $aTemp[$iCount]
    Return $aTemp
EndFunc

Func _Picker_BuildChildCounts(ByRef $aPaths)
    If Not IsObj($oChildCount) Then
        Global $oChildCount = ObjCreate("Scripting.Dictionary")
        $oChildCount.CompareMode = 1
    EndIf
    If Not IsObj($oGrandchildCount) Then
        Global $oGrandchildCount = ObjCreate("Scripting.Dictionary")
        $oGrandchildCount.CompareMode = 1
    EndIf
    
    $oChildCount.RemoveAll()
    $oGrandchildCount.RemoveAll()
    
    Local $iSize = UBound($aPaths)
    For $i = 0 To $iSize - 1
        Local $sPath = $aPaths[$i]
        If StringRight($sPath, 1) == "\" And StringLen($sPath) > 3 Then
            $sPath = StringTrimRight($sPath, 1)
        EndIf
        
        Local $sParent = _Picker_GetParentPath($sPath)
        If $sParent <> $sPath Then
            If $oChildCount.Exists($sParent) Then
                $oChildCount.Item($sParent) = $oChildCount.Item($sParent) + 1
            Else
                $oChildCount.Item($sParent) = 1
            EndIf
            
            Local $sGrandparent = _Picker_GetParentPath($sParent)
            If $sGrandparent <> $sParent Then
                If $oGrandchildCount.Exists($sGrandparent) Then
                    $oGrandchildCount.Item($sGrandparent) = $oGrandchildCount.Item($sGrandparent) + 1
                Else
                    $oGrandchildCount.Item($sGrandparent) = 1
                EndIf
            EndIf
        EndIf
    Next
EndFunc

; End of file: _picker_filter.au3
