#include-once
; ==============================================================================
; File: _hotkeys.au3
; Paths: C:\_\au3-clipboard-exec\modules\_hotkeys.au3
; Description: Intercepts system hotkeys and routes extracted tokens down execution channels.
; ==============================================================================

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
    
    ; CRITICAL ENTRY GUARD FIX: Check clipboard instantly *before* any variables are initialized.
    ; This enables manual execution of the picker demo from any application window context.
    Local $sImmediateClipCheck = StringLower(StringStripWS(ClipGet(), 3))
    If $sImmediateClipCheck == "picker" Then
        _UI_ShowToast("Launcher Engine", "Spawning external demo workspace navigator process...")
        Run('"' & @AutoItExe & '" "' & @ScriptDir & '\modules\_picker_demo.au3"')
        Return
    EndIf
    
    ; 1. Try to copy highlighted text to the clipboard as a fallback fallback strategy
    _Util_WaitForModifierRelease()
    _Util_PurgeStuckModifiers()
    Send("^c")
    Sleep(50)
    
    ; Re-evaluate immediately post-copy to capture manual highlights inside unlisted tools
    Local $sPostCopyCheck = StringLower(StringStripWS(ClipGet(), 3))
    If $sPostCopyCheck == "picker" Then
        _UI_ShowToast("Launcher Engine", "Spawning external demo workspace navigator process...")
        Run('"' & @AutoItExe & '" "' & @ScriptDir & '\modules\_picker_demo.au3"')
        Return
    EndIf
    
    Local $hWndTarget = WinGetHandle("[ACTIVE]")

    ; Execute our safe window profiling engine
    Local $aAppProfile = _Config_GetActiveAppProfile()
    
    ; Ensure $aAppProfile is a valid array before attempting subscript indexing
    If @error Or Not IsArray($aAppProfile) Then
        Local $sErrMsg = "Context Error: Active window does not match tracking configurations."
        ClipPut($sErrMsg)
        _UI_ShowToast("Context Error", $sErrMsg)
        Return
    EndIf

    ; Restored the explicit array subscript brackets to extract variables safely
    Local $sName   = $aAppProfile[0]
    Local $sKeys   = $aAppProfile[1]
    Local $sScript = $aAppProfile[2]

    ; Clear clipboard before running macro key combinations to guarantee fresh feedback verification loops
    ClipPut("") 
    Sleep(30)

    If $sKeys <> "" Then
        Local $sCleanKeys = StringStripWS($sKeys, 3)
        
        WinActivate($hWndTarget)
        WinWaitActive($hWndTarget, "", 1)
        Sleep(50)

        ; Send macro layout keys natively straight down focused window container thread
        Send($sCleanKeys)
        
        ; Verification loop waiting for clipboard to catch text data strings
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
    
    ; Secondary intercept sweep if application automation successfully output the keyword "picker"
    Local $sFinalContextCheck = StringLower(StringStripWS(ClipGet(), 3))
    If $sFinalContextCheck == "picker" Then
        _UI_ShowToast("Launcher Engine", "Spawning external demo workspace navigator process...")
        Run('"' & @AutoItExe & '" "' & @ScriptDir & '\modules\_picker_demo.au3"')
        Return
    EndIf
    
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
    
    ; 2. Fetch the cleaned clipboard text buffer block
    Local $sFinalPayload = ClipGet()
    
    ; 3. Core Engine Action Sub-Handler Router Switch Layout
    Select
        Case $sType = "URL_LAUNCH"
            _UI_ShowToast("Web Navigator Link", "Launching pathway in Google Chrome: " & StringLeft($sFinalPayload, 40))
            Local $sChromePath = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe", "")
            If @error Or $sChromePath == "" Then $sChromePath = "chrome.exe"
            Run('"' & $sChromePath & '" "' & $sFinalPayload & '"')

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

; End of file: _hotkeys.au3
