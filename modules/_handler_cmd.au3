#include-once
#include <AutoItConstants.au3>

; Include core UI elements for status output delivery
#include "_ui.au3"

; ==============================================================================
; Public API: Invisible command interception layer with text payload captures
; ==============================================================================
Func _Handler_ExecuteDOSCommand($sCommandPayload)
    ; 1. Clean and parse out the driving trigger signifier operator
    Local $sRawCommand = StringStripWS($sCommandPayload, 3)
    If StringLeft($sRawCommand, 1) = ">" Then
        $sRawCommand = StringStripWS(StringMid($sRawCommand, 2), 3)
    EndIf

    If $sRawCommand = "" Then
        Local $sErrText = "DOS Error: Command execution string vector evaluates to completely blank."
        ClipPut($sErrText)
        _UI_ShowToast("Command Engine", $sErrText)
        Return SetError(1, 0, False)
    EndIf

    ; Notify visually that the system background thread is processing telemetry calculations
    _UI_ShowToast("Executing Command", "Running invisibly: " & $sRawCommand)

    ; 2. Construct the absolute background terminal execution string
    ; Using combination flags: $STDOUT_CHILD (0x2) + $STDERR_CHILD (0x4) to catch all outputs
    Local $iStreamFlags = BitOR($STDOUT_CHILD, $STDERR_CHILD)
    Local $iPID = Run(@ComSpec & ' /c "' & $sRawCommand & '"', "", @SW_HIDE, $iStreamFlags)

    If @error Or Not $iPID Then
        Local $sErrSpawn = "DOS Error: Critical failure initializing local terminal runtimes."
        ClipPut($sErrSpawn)
        _UI_ShowToast("Command Engine", $sErrSpawn)
        Return SetError(2, 0, False)
    EndIf

    ; 3. Establish strict blocking limits to await data capture stream terminations
    ProcessWaitClose($iPID, 10) ; Set a 10-second hard threshold to protect thread locking

    ; Read out all combined bytes buffered down the standard output pipes
    Local $sConsoleOutput = StdoutRead($iPID)
    Local $sConsoleError  = StderrRead($iPID)
    
    Local $sFinalResultText = ""

    ; Append tracking feedback streams chronologically
    If $sConsoleOutput <> "" Then $sFinalResultText &= $sConsoleOutput
    If $sConsoleError  <> "" Then 
        If $sFinalResultText <> "" Then $sFinalResultText &= @CRLF
        $sFinalResultText &= "=== DESKTOP TELEMETRY ERROR DATA STACK ===" & @CRLF & $sConsoleError
    EndIf

    ; If both pipelines return completely dry, deliver standard execution verification records
    If $sFinalResultText = "" Then $sFinalResultText = "Command completed with zero console output feedback returns."

    ; 4. Pipe raw system output text strings cleanly back into clipboard layout memory grids
    ClipPut($sFinalResultText)

    ; Trigger native finalization notification summary
    _UI_ShowToast("Execution Complete", "Output telemetry copied to your clipboard framework.")
    Return True
EndFunc

; modules\_handler_cmd.au3
