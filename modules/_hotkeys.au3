#include-once

; Synchronized relative folder target inclusion tree mapping keys
#include "_ui.au3"
#include "_config.au3"
#include "_recognizer.au3"
#include "_picker.au3"
#include "_handler_dopus.au3"
#include "_handler_zdot.au3"
#include "_handler_cmd.au3"
#include "_utils.au3"

; ==============================================================================
; Hotkey: Win+Ctrl+Shift+Enter (Clean exit protocol)
; ==============================================================================
Func _Hotkey_Exit()
    _Util_PlaySystemSound(0x00000010)
    FileDelete(@ScriptDir & "\.instance.lock")
    Exit
EndFunc

; ==============================================================================
; Hotkey: Win+Alt+Enter (Active app window scanner)
; ==============================================================================
Func _Hotkey_ContextOp()
    _Util_PlaySystemSound(0x00000000)
    
    Local $hWndTarget = WinGetHandle("[ACTIVE]")

    ; Execute our safe window profiling engine
    Local $aAppProfile = _Config_GetActiveAppProfile()
    If @error Then
        Local $sErrMsg = "Context Error: Active window does not match tracking configurations."
        ClipPut($sErrMsg)
        _UI_ShowToast("Context Error", $sErrMsg)
        Return
    EndIf

    Local $sName   = $aAppProfile
    Local $sKeys   = $aAppProfile
    Local $sScript = $aAppProfile

    ; Clear clipboard before running macros to ensure fresh verification loops
    ClipPut("") 
    Sleep(30)

    If $sKeys <> "" Then
        Local $sCleanKeys = StringStripWS($sKeys, 3)
        
        ; Release physical modifier keys completely before typing to fix injection errors
        _Util_WaitForModifierRelease()
        _Util_PurgeStuckModifiers()
        
        ; Forcefully re-focus the targeted app window layout
        WinActivate($hWndTarget)
        WinWaitActive($hWndTarget, "", 1)
        Sleep(50)

        ; Send macro layout keys natively straight down focused global thread
        Send($sCleanKeys)
        
        ; Verification loop waiting for clipboard to catch text data
        Local $iTimer = TimerInit()
        Local $sCurrentClip = ""
        Local $bSuccess = False
        
        While TimerDiff($iTimer) < 2000
            $sCurrentClip = ClipGet()
            If Not @error And $sCurrentClip <> "" Then
                $bSuccess = True
                ExitLoop
            EndIf
            Sleep(50)
        WEnd
        
        If Not $bSuccess Then
            Local $sPipelineError = "Pipeline Error: Application failed to update clipboard. Keys sent: '" & $sCleanKeys & "'"
            ClipPut($sPipelineError)
            _UI_ShowToast("Pipeline Error", $sPipelineError)
            Return
        EndIf
    ElseIf $sScript <> "" Then 
        Local $iPID = Run('"' & @AutoItExe & '" "' & $sScript & '"')
        ProcessWaitClose($iPID, 3)
    EndIf
    
    ; --- TARGETED INTERCEPT ROUTE: LOCKED STRICTLY TO THE WIN+ALT+ENTER CONTEXT HOTKEY ---
    Local $sManualContextCheck = StringLower(StringStripWS(ClipGet(), 3))
    If $sManualContextCheck == "picker" Then
        _UI_ShowToast("Launcher Engine", "Spawning external demo workspace navigator process...")
        
        ; Launch the separate script file independently via the current AutoIt environment interpreter
        Run('"' & @AutoItExe & '" "' & @ScriptDir & '\modules\_picker_demo.au3"')
        Return ; Hard stop. Prevents routing down standard automatic background clip loops.
    EndIf
    ; -------------------------------------------------------------------------------------
    
    _Hotkey_ClipOp()
EndFunc

; ==============================================================================
; Hotkey: Win+Alt+Shift+Enter (Direct clipboard parser router)
; ==============================================================================
Func _Hotkey_ClipOp()
    _Util_PlaySystemSound(0x00000000)
    Local $sClip = ClipGet()
    If @error Or $sClip = "" Then
        Local $sClipError = "Clipboard Error: No text data discovered inside active pipeline buffer arrays."
        ClipPut($sClipError)
        _UI_ShowToast("Clipboard Empty", $sClipError)
        Return
    EndIf
    
    ; 1. Execute regular expression pattern resolution routing
    Local $sType = _Recognizer_Evaluate($sClip)
    
    ; 2. Fetch the cleaned clipboard text buffer block (after prefix removals)
    Local $sFinalPayload = ClipGet()
    
    ; 3. Core Engine Action Sub-Handler Router Switch Layout
    Select
        Case $sType = "DIRECTORY_FULL"
            _UI_ShowToast("Routing Directory", "Opening in Directory Opus: " & $sFinalPayload)
            _Handler_OpenInDOpus($sFinalPayload, $sType)
            
        Case $sType = "ZDOT"
            _Handler_ResolveZdot($sFinalPayload)

        Case $sType = "DOS_CMD"
            _Handler_ExecuteDOSCommand($sFinalPayload)

        Case Default
            _UI_ShowToast("Pattern Evaluated", "Type Identified: " & $sType & @CRLF & "Payload: " & StringLeft($sFinalPayload, 40))
    EndSelect
EndFunc

; modules\_hotkeys.au3
