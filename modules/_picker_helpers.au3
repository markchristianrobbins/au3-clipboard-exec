#include-once
; ==============================================================================
; File: _picker_helpers.au3
; Description: Pure string processing and metrics inquiry helper methods.
; Functions:
;   - _Picker_GetBaseName (Retrieves trailing path segments safely)
;   - _Picker_GetParentPath (Extracts structural parent directories)
;   - _Picker_GetPathLevel (Counts directory separators in path hierarchy)
;   - _Picker_IsUIDName (Checks if folders represent programmatic identifiers)
;   - _Picker_GetChildCount (Queries subdirectory cache counts)
;   - _Picker_GetGrandchildCount (Queries deep directory child counts)
; ==============================================================================
#include "_picker_globals.au3"


Func _Picker_GetBaseName($sFullPath)
    If StringRight($sFullPath, 1) == "\" And StringLen($sFullPath) > 3 Then
        $sFullPath = StringTrimRight($sFullPath, 1)
    EndIf
    Local $sBase = StringRegExpReplace($sFullPath, "^.*\\", "")
    If $sBase == "" Then $sBase = $sFullPath
    Return $sBase
EndFunc

Func _Picker_GetParentPath($sFullPath)
    If StringRight($sFullPath, 1) == "\" And StringLen($sFullPath) > 3 Then
        $sFullPath = StringTrimRight($sFullPath, 1)
    EndIf
    Local $sParent = StringRegExpReplace($sFullPath, "\\[^\\]+$", "")
    If $sParent == "" Then Return $sFullPath
    Return $sParent
EndFunc

Func _Picker_GetPathLevel($sFullPath)
    If StringRight($sFullPath, 1) == "\" And StringLen($sFullPath) > 3 Then
        $sFullPath = StringTrimRight($sFullPath, 1)
    EndIf
    Local $sClean = $sFullPath
    Local $iCount = 1
    Local $iPos = 1
    While 1
        $iPos = StringInStr($sClean, "\", 0, 1, $iPos)
        If $iPos == 0 Then ExitLoop
        $iCount += 1
        $iPos += 1
    WEnd
    Return $iCount
EndFunc

Func _Picker_IsUIDName($sName)
    If StringRegExp($sName, "(?i)^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$") Then Return True
    If StringRegExp($sName, "(?i)[a-z]+-*[0-9]+-*[a-z]+-*[0-9]+") Then Return True
    If StringRegExp($sName, "(?i)[0-9]+-*[a-z]+-*[0-9]+-*[a-z]+") Then Return True
    Return False
EndFunc

Func _Picker_GetChildCount($sPath)
    If StringRight($sPath, 1) == "\" And StringLen($sPath) > 3 Then
        $sPath = StringTrimRight($sPath, 1)
    EndIf
    If IsObj($oChildCount) And $oChildCount.Exists($sPath) Then
        Return $oChildCount.Item($sPath)
    EndIf
    Return 0
EndFunc

Func _Picker_GetGrandchildCount($sPath)
    If StringRight($sPath, 1) == "\" And StringLen($sPath) > 3 Then
        $sPath = StringTrimRight($sPath, 1)
    EndIf
    If IsObj($oGrandchildCount) And $oGrandchildCount.Exists($sPath) Then
        Return $oGrandchildCount.Item($sPath)
    EndIf
    Return 0
EndFunc

; End of file: _picker_helpers.au3
