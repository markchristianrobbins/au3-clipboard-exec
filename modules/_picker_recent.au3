#include-once
; ==============================================================================
; File: _picker_recent.au3
; Description: Interacts with external text logs to preserve and load recent directories.
; Functions:
;   - _Picker_LoadRecents (Extracts recently accessed items from storage, de-duplicating entries)
;   - _Picker_AddRecent (Pre-appends or cycles selection into recent historical paths)
; ==============================================================================
#include <File.au3>

Func _Picker_LoadRecents()
    Local $sFile = @AppDataDir & "\OpusRecentFolders.txt"
    If IsDeclared("sRecentFile") Then $sFile = Eval("sRecentFile")
    
    Local $aRet[1] = [""]
    If Not FileExists($sFile) Then Return $aRet
    
    Local $aLines
    _FileReadToArray($sFile, $aLines)
    If @error Then Return $aRet
    
    Local $iCount = 0
    Local $aClean[5]
    For $i = $aLines[0] To 1 Step -1
        Local $sLine = StringStripWS($aLines[$i], 3)
        If $sLine <> "" And FileExists($sLine) Then
            Local $bDup = False
            For $j = 0 To $iCount - 1
                If $aClean[$j] == $sLine Then
                    $bDup = True
                    ExitLoop
                EndIf
            Next
            If Not $bDup Then
                $aClean[$iCount] = $sLine
                $iCount += 1
                If $iCount >= 5 Then ExitLoop
            EndIf
        EndIf
    Next
    
    If $iCount == 0 Then Return $aRet
    
    ReDim $aClean[$iCount]
    Return $aClean
EndFunc

Func _Picker_AddRecent($sSelected)
    If $sSelected == "" Or Not FileExists($sSelected) Then Return
    
    Local $sFile = @AppDataDir & "\OpusRecentFolders.txt"
    If IsDeclared("sRecentFile") Then $sFile = Eval("sRecentFile")
    
    Local $sAllContent = ""
    If FileExists($sFile) Then $sAllContent = FileRead($sFile)
    
    If Not StringInStr($sAllContent, $sSelected) Then
        FileWriteLine($sFile, $sSelected)
    Else
        Local $aLines
        _FileReadToArray($sFile, $aLines)
        If Not @error Then
            Local $hFile = FileOpen($sFile, 2)
            If $hFile <> -1 Then
                For $i = 1 To $aLines[0]
                    Local $sLine = StringStripWS($aLines[$i], 3)
                    If $sLine <> "" And $sLine <> $sSelected Then
                        FileWriteLine($hFile, $sLine)
                    EndIf
                Next
                FileWriteLine($hFile, $sSelected)
                FileClose($hFile)
            EndIf
        EndIf
    EndIf
EndFunc

; End of file: _picker_recent.au3
