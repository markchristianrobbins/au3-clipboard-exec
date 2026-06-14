#include-once
#include "_index.au3"
; ==============================================================================
; File: _recognizer.au3
; Paths: C:\_\au3-clipboard-exec\modules\_recognizer.au3
; Description: Evaluates raw clipboard strings against regular expression matrices.
; Functions:
;   - _Recognizer_Evaluate (Classifies text data strings into operational routing types)
; ==============================================================================

Func _Recognizer_Evaluate($sTextData)
    Local $sCleanText = StringLower(StringStripWS($sTextData, 3))
    If $sCleanText == "" Then Return "DEFAULT"

    ; 1. Check for web protocols and your custom programmatic asset syntax link keys
    If StringRegExp($sCleanText, "^(https?:|aip:)") Then
        Return "URL_LAUNCH"
    EndIf

    ; 2. Check for fully qualified local file system absolute pathways or file:/// URLs
    Local $sTestText = $sCleanText
    If StringLeft($sTestText, 1) == "+" Then $sTestText = StringStripWS(StringMid($sTestText, 2), 3)

    If StringRegExp($sTestText, "^[a-zA-Z]:\\") Or StringLeft($sTestText, 2) == "\\" Or StringRegExp($sTestText, "^file://") Then
        Return "DIRECTORY_FULL"
    EndIf

    ; 3. Check for virtual shortcut folder reference keyword tags or Zdot temporal tokens
    If StringLeft($sCleanText, 1) == "." Or StringLeft($sCleanText, 1) == "@" Or StringRegExp($sCleanText, "(?i)^z[\.-]?\d{14,20}$") Then
        Return "ZDOT"
    EndIf

    ; 4. Check for system terminal operations or command shell prefixes
    If StringLeft($sCleanText, 1) == ">" Or StringLeft($sCleanText, 4) == "cmd " Then
        Return "DOS_CMD"
    EndIf

    Return "DEFAULT"
EndFunc

; ==============================================================================
; Public API: Decomposes a full line of text into unique recognizable tokens
; ==============================================================================
Func _Recognizer_DecomposeLine($sLine)
    _Index_Initialize() ; Ensure static index database is loaded in memory
    
    ; We'll collect unique recognized tokens inside a Scripting.Dictionary to avoid duplicates.
    Local $oTokens = ObjCreate("Scripting.Dictionary")
    If Not IsObj($oTokens) Then Return Null
    $oTokens.CompareMode = 1
    
    ; 1. Match URLs via regex
    Local $aSRE = StringRegExp($sLine, '(?i)((?:https?://|file:///)[^\s"''<>|]+)', 3)
    If Not @error Then
        For $i = 0 To UBound($aSRE) - 1
            Local $sVal = $aSRE[$i]
            If Not $oTokens.Exists($sVal) Then
                ; Token format: Value | BaseValue | Prefix | Type | InstanceCount | InstancesList (delimited by pipe)
                $oTokens.Add($sVal, $sVal & "|" & $sVal & "||URL|1|" & $sVal)
            EndIf
        Next
    EndIf
    
    ; 2. Match Zdot patterns
    Local $aZdotSRE = StringRegExp($sLine, "(?i)(z[\.-]?\d{14,20})", 3)
    If Not @error Then
        For $i = 0 To UBound($aZdotSRE) - 1
            Local $sVal = $aZdotSRE[$i]
            If Not $oTokens.Exists($sVal) Then
                $oTokens.Add($sVal, $sVal & "|" & $sVal & "||ZDOT|1|" & $sVal)
            EndIf
        Next
    EndIf

    ; 3. Split the entire line into word-like chunks to check existence of paths, files or window titles
    ; First clean up line punctuation to isolate words
    Local $sCleanedLine = StringReplace($sLine, ",", " ")
    $sCleanedLine = StringReplace($sCleanedLine, ";", " ")
    $sCleanedLine = StringReplace($sCleanedLine, '"', " ")
    $sCleanedLine = StringReplace($sCleanedLine, "'", " ")
    $sCleanedLine = StringReplace($sCleanedLine, "]", " ")
    $sCleanedLine = StringReplace($sCleanedLine, "[", " ")
    $sCleanedLine = StringReplace($sCleanedLine, "(", " ")
    $sCleanedLine = StringReplace($sCleanedLine, ")", " ")
    $sCleanedLine = StringReplace($sCleanedLine, "{", " ")
    $sCleanedLine = StringReplace($sCleanedLine, "}", " ")
    
    Local $aWords = StringSplit($sCleanedLine, " " & @TAB)
    For $i = 1 To $aWords[0]
        Local $sRawWord = StringStripWS($aWords[$i], 3)
        If StringLen($sRawWord) < 3 Then ContinueLoop
        
        ; Extract possible prefixes from word
        Local $sPrefix = ""
        Local $sWord = $sRawWord
        
        If StringLeft($sWord, 2) == "-@" Then
            $sPrefix = "-@"
            $sWord = StringMid($sWord, 3)
        ElseIf StringLeft($sWord, 2) == "-#" Then
            $sPrefix = "-#"
            $sWord = StringMid($sWord, 3)
        ElseIf StringLeft($sWord, 1) == "+" Then
            $sPrefix = "+"
            $sWord = StringMid($sWord, 2)
        ElseIf StringLeft($sWord, 1) == "-" Then
            $sPrefix = "-"
            $sWord = StringMid($sWord, 2)
        ElseIf StringLeft($sWord, 1) == "@" Then
            $sPrefix = "@"
            $sWord = StringMid($sWord, 2)
        ElseIf StringLeft($sWord, 1) == "#" Then
            $sPrefix = "#"
            $sWord = StringMid($sWord, 2)
        EndIf
        
        ; Ensure the base word still qualifies
        If StringLen($sWord) < 3 Then ContinueLoop
        
        ; Check if this base word is already registered as a token in some form
        If $oTokens.Exists($sRawWord) Then ContinueLoop
        
        Local $bMatched = False
        Local $sInstances = ""
        Local $iCount = 0
        Local $sType = ""
        
        ; A. Is it a fully qualified or clean direct path that exists?
        If StringRegExp($sWord, "^[a-zA-Z]:\\") Or StringLeft($sWord, 2) == "\\" Then
            If FileExists($sWord) Then
                $bMatched = True
                $sType = "PATH_DIRECT"
                $iCount = 1
                $sInstances = $sWord
            EndIf
        EndIf
        
        ; B. Check inside the static Index database
        If Not $bMatched Then
            Local $aKeys = _Index_LoadIndexedPaths()
            For $k = 0 To UBound($aKeys) - 1
                If $aKeys[$k] == "" Then ContinueLoop
                Local $sPathLower = StringLower($aKeys[$k])
                Local $sWordLower = StringLower($sWord)
                ; Check if basename or full path contains the word
                Local $sBaseName = StringRegExpReplace($aKeys[$k], "^.*\\", "")
                If StringInStr(StringLower($sBaseName), $sWordLower) Or StringLower($sBaseName) == $sWordLower Then
                    $iCount += 1
                    If StringLen($sInstances) < 2000 Then ; buffer limit safeguard
                        $sInstances &= $aKeys[$k] & "|"
                    EndIf
                    $bMatched = True
                    $sType = "INDEX_MATCH"
                EndIf
            Next
            If $bMatched Then
                If StringRight($sInstances, 1) == "|" Then $sInstances = StringTrimRight($sInstances, 1)
            EndIf
        EndIf
        
        ; C. Check matches in currently Open Window Titles
        If Not $bMatched Then
            Local $aWinList = WinList()
            For $j = 1 To $aWinList[0][0]
                If $aWinList[$j][0] <> "" And BitAND(WinGetState($aWinList[$j][1]), 2) Then
                    Local $sWinTitle = $aWinList[$j][0]
                    If StringInStr(StringLower($sWinTitle), StringLower($sWord)) Then
                        $iCount += 1
                        If StringLen($sInstances) < 2000 Then
                            $sInstances &= $sWinTitle & "|"
                        EndIf
                        $bMatched = True
                        $sType = "WINDOW_MATCH"
                    EndIf
                Endif
            Next
            If $bMatched Then
                If StringRight($sInstances, 1) == "|" Then $sInstances = StringTrimRight($sInstances, 1)
            Endif
        EndIf
        
        ; Register token if matched any criteria
        If $bMatched Then
            $oTokens.Add($sRawWord, $sRawWord & "|" & $sWord & "|" & $sPrefix & "|" & $sType & "|" & $iCount & "|" & $sInstances)
        EndIf
    Next
    
    Return $oTokens
EndFunc

; End of file: _recognizer.au3
