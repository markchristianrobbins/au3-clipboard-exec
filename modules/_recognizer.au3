#include-once
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

; End of file: _recognizer.au3
