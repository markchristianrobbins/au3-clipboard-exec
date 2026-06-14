#include-once
#include <AutoItConstants.au3>

; Include core elements for UI status messaging hooks
#include "_ui.au3"

; Global static root structures
Global Const $g_sZdotRoot = "C:\$data\zdoti"
Global Const $g_sCursorBin = "C:\Users\Mark\AppData\Local\Programs\cursor\Cursor.exe"

; ==============================================================================
; Public API: Resolves Zdot variants by seeking the strict 'z.' token inside text files
; ==============================================================================
Func _Handler_ResolveZdot($sOriginalPayload)
    Local $sSanitized = StringStripWS($sOriginalPayload, 3)

    ; 1. Isolate the absolute raw 14+ digit string block out of any prefix structure
    Local $sRawDigits = StringRegExpReplace($sSanitized, "(?i)^z[\.-]", "")
    If Not StringRegExp($sRawDigits, "^\d{14,20}$") Then
        Local $sErrFormat = "Zdot Error: Selected string is not a valid chronological timestamp token."
        ClipPut($sErrFormat)
        _UI_ShowToast("Zdot Engine", $sErrFormat)
        Return SetError(1, 0, False)
    EndIf

    ; CRITICAL SPECIFICATION ALIGNMENT: Source code text files always house exactly 'z.digits'
    Local $sStrictFileTargetMarker = "z." & $sRawDigits

    ; 2. Fragment the raw digit block into calendar paths to locate your register file
    Local $sYear  = StringMid($sRawDigits, 1, 4)
    Local $sMonth = StringMid($sRawDigits, 5, 2)
    Local $sDay   = StringMid($sRawDigits, 7, 2)
    Local $sRest  = StringMid($sRawDigits, 9)

    Local $sIndexFile = $g_sZdotRoot & "\" & $sYear & "\" & $sMonth & "\" & $sDay & "\" & $sRest & ".zdoti"

    ; Verify that your existing index tracker record file physically exists
    If Not FileExists($sIndexFile) Then
        Local $sErrIndex = "Zdot Error: Register index mapping marker not found on disk: " & $sIndexFile
        ClipPut($sErrIndex)
        _UI_ShowToast("Zdot Engine", $sErrIndex)
        Return SetError(2, 0, False)
    EndIf

    ; 3. Extract the target file path stored inside the localized .zdoti register file
    Local $hIndexFile = FileOpen($sIndexFile, 0) ; Read mode
    If $hIndexFile = -1 Then
        Local $sErrOpen = "Zdot Error: Failed to open system index register entry."
        ClipPut($sErrOpen)
        _UI_ShowToast("Zdot Engine", $sErrOpen)
        Return SetError(3, 0, False)
    EndIf

    Local $sTargetFilePath = StringStripWS(FileReadLine($hIndexFile, 1), 3)
    FileClose($hIndexFile)

    If $sTargetFilePath = "" Then
        Local $sErrPath = "Zdot Error: Reference register entry contains a blank source mapping line."
        ClipPut($sErrPath)
        _UI_ShowToast("Zdot Engine", $sErrPath)
        Return SetError(4, 0, False)
    EndIf

    ; Validate the file targeted by your index physically exists on the disk layout
    If Not FileExists($sTargetFilePath) Then
        Local $sErrMissingFile = "Zdot Error: Source file missing from disk allocation: " & $sTargetFilePath
        ClipPut($sErrMissingFile)
        _UI_ShowToast("Zdot Engine", $sErrMissingFile)
        Return SetError(5, 0, False)
    EndIf

    ; 4. Parse the target source file line-by-line to find the strict 'z.' marker location
    Local $hSourceFile = FileOpen($sTargetFilePath, 0) ; Read mode
    If $hSourceFile = -1 Then
        Local $sErrSrcOpen = "Zdot Error: Unable to access target source code file container tags."
        ClipPut($sErrSrcOpen)
        _UI_ShowToast("Zdot Engine", $sErrSrcOpen)
        Return SetError(6, 0, False)
    EndIf

    Local $iTargetLine = 1
    Local $iTargetCol = 1
    Local $bFound = False
    Local $iCurrentLineNum = 0
    Local $sLineText = ""

    While 1
        $sLineText = FileReadLine($hSourceFile)
        If @error = -1 Then ExitLoop ; End-of-file boundary reached
        $iCurrentLineNum += 1

        ; Strict lookups matching only your primary dot indicator matrix
        Local $iMatchPos = StringInStr($sLineText, $sStrictFileTargetMarker, 0)

        If $iMatchPos > 0 Then
            $iTargetLine = $iCurrentLineNum
            $iTargetCol = $iMatchPos
            $bFound = True
            ExitLoop
        EndIf
    WEnd
    FileClose($hSourceFile)

    ; 5. Assemble direct launching arguments and forward straight into the Cursor IDE environment
    Local $sCursorCommand = ' --goto "' & $sTargetFilePath & ':' & $iTargetLine & ':' & $iTargetCol & '"'
    
    If $bFound Then
        _UI_ShowToast("Zdot Sync Found", "Located target string: " & $sStrictFileTargetMarker & " on Row: " & $iTargetLine)
    Else
        _UI_ShowToast("Zdot Warning", "Index register matched, but tag missing inside file text contents. Opening row 1.")
    EndIf

    ShellExecute($g_sCursorBin, $sCursorCommand, "", "open", @SW_SHOWNORMAL)
    Return True
EndFunc

; modules\_handler_zdot.au3
