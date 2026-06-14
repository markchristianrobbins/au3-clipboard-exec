#include-once
; ==============================================================================
; File: _picker_icons.au3
; Paths: C:\_\au3-clipboard-exec\modules\_picker_icons.au3
; Description: Handles high-performance system icons and specialized folder caches.
; Functions:
;   - _Picker_GetFolderIconCached (Queries or populates a dictionary mapping path names to shell indices)
;   - _Picker_GetFolderIconPathAndIndex (Deduces representative Windows icons based on keywords/patterns)
; ==============================================================================
#include "_picker_helpers.au3"

; Global declaration to establish object variable scope safely before evaluation checks
Global $oIconCache = 0

Func _Picker_GetFolderIconCached($sFolderPath)
    ; CRITICAL RESOLUTION FIX: Switched variable presence check to IsDeclared string syntax to stop compiler crash
    If Not IsDeclared("oIconCache") Or Not IsObj($oIconCache) Then
        Global $oIconCache = ObjCreate("Scripting.Dictionary")
        $oIconCache.CompareMode = 1
    EndIf
    
    If $oIconCache.Exists($sFolderPath) Then
        Return StringSplit($oIconCache.Item($sFolderPath), "|")
    EndIf
    
    Local $aIconInfo = _Picker_GetFolderIconPathAndIndex($sFolderPath)
    Local $sValue = $aIconInfo[0] & "|" & $aIconInfo[1]
    $oIconCache.Add($sFolderPath, $sValue)
    Return $aIconInfo
EndFunc

Func _Picker_GetFolderIconPathAndIndex($sFolderPath)
    Local $aRet[2] = ["shell32.dll", 3]
    Local $sBase = _Picker_GetBaseName($sFolderPath)
    
    If StringInStr($sFolderPath, "Start Menu") Or StringInStr($sFolderPath, "Programs") Then
        $aRet[0] = "shell32.dll"
        $aRet[1] = 164
        Return $aRet
    EndIf
    
    If _Picker_IsUIDName($sBase) Then
        $aRet[0] = "shell32.dll"
        $aRet[1] = 134
        Return $aRet
    EndIf
    
    Switch StringLower($sBase)
        Case "_au3", "_ahk", "code", "src", "git"
            $aRet[0] = "imageres.dll"
            $aRet[1] = 117
        Case "_lnk", "shortcuts"
            $aRet[0] = "shell32.dll"
            $aRet[1] = 29
        Case "_o", "download", "downloads"
            $aRet[0] = "imageres.dll"
            $aRet[1] = 184
        Case "_s", "system", "bin"
            $aRet[0] = "shell32.dll"
            $aRet[1] = 71
        Case "_t", "temp", "tmp"
            $aRet[0] = "shell32.dll"
            $aRet[1] = 141
        Case "_data", "$data", "db", "database"
            $aRet[0] = "shell32.dll"
            $aRet[1] = 175
        Case "_res", "$res", "resources", "assets"
            $aRet[0] = "imageres.dll"
            $aRet[1] = 3
    EndSwitch
    Return $aRet
EndFunc

; End of file: _picker_icons.au3
