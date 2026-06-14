#include-once
#include <AutoItConstants.au3>

; ==============================================================================
; Public API: Evaluates clipboard string against priority regex filters
; ==============================================================================
Func _Recognizer_Evaluate($sClipText)
    ; Clean up leading and trailing whitespace blocks
    $sClipText = StringStripWS($sClipText, 3)
    If $sClipText = "" Then Return "EMPTY"

    ; 1. Match DOS Commands (e.g., "> dir")
    If StringLeft($sClipText, 1) = ">" Then Return "DOS_CMD"

    ; 2. Match Custom aip:// Protocol Links (e.g., aip://prompt_payload)
    If StringRegExp($sClipText, "(?i)^aip:[\\/]+") Then
        Local $sCleanPayload = StringRegExpReplace($sClipText, "(?i)^aip:[\\/]+", "")
        ClipPut($sCleanPayload)
        Return "AIP_PROTOCOL"
    EndIf

    ; 3. Match file:// protocol links (e.g., file:///C:/path/to/file.txt)
    If StringRegExp($sClipText, "(?i)^file:[\\/]+") Then
        Local $sCleanPath = StringRegExpReplace($sClipText, "(?i)^file:[\\/]+", "")
        $sCleanPath = StringReplace($sCleanPath, "/", "\")
        ClipPut($sCleanPath)
        
        If FileExists($sCleanPath) And StringInStr(FileGetAttrib($sCleanPath), "D") Then
            Return "DIRECTORY_FULL"
        EndIf
        Return "FILE_FULL"
    EndIf

    ; 4. Match Web URLs (e.g., https://google.com or ://google.com)
    Local $sUrlPattern = "(?i)^(https?|ftp)://|[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?([\\/].*)?$"
    If StringRegExp($sClipText, $sUrlPattern) Then Return "URL"

    ; 5. Match Zdots (e.g., "z.20260614...")
    If StringRegExp($sClipText, "(?i)^(z[\.-])?\d{14,18}") Then Return "ZDOT"

    ; 6. Match Registry Paths (e.g., HKEY_LOCAL_MACHINE\..., HKCU\...)
    Local $sRegPattern = "(?i)^(Computer\\)?(HKEY_|HKCR|HKCU|HKLM|HKU|HKCC)"
    If StringRegExp($sClipText, $sRegPattern) Then Return "REGISTRY"

    ; 7. Match Absolute Directory or File Paths (e.g., C:\..., or breakout paths like +C:\...)
    ; CRITICAL FIX: Added \+? operator to bypass window breakout markers during evaluation
    Local $sDrivePattern = "(?i)^\+?[A-Z]:[\\/]+"
    Local $sNetworkPattern = "^\+?[\\/]{2}"
    
    If StringRegExp($sClipText, $sDrivePattern) Or StringRegExp($sClipText, $sNetworkPattern) Then
        ; Clean up prefix momentarily just to run a safe filesystem type tracking attribute lookup
        Local $sCheckPath = $sClipText
        If StringLeft($sCheckPath, 1) = "+" Then $sCheckPath = StringStripWS(StringMid($sCheckPath, 2), 3)
        
        If FileExists($sCheckPath) And StringInStr(FileGetAttrib($sCheckPath), "D") Then
            Return "DIRECTORY_FULL"
        EndIf
        Return "FILE_FULL"
    EndIf

    ; 8. Match Explicit Window Titles (Contains a pipe separator like: filename|notepad)
    If StringInStr($sClipText, "|") Then Return "WINDOW_TITLE"

    ; Default Fallback: Assume it's a partial match name query for files/folders
    Return "PARTIAL_SEARCH"
EndFunc

; modules\_recognizer.au3
