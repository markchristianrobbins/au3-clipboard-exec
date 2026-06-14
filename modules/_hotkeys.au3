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
; Helper: Routes raw paths and tokens based on prefix modifiers (+, -, @, #, -@, -#)
; ==============================================================================
Func _Handler_ExecuteDestination($sCleanPath, $sPrefix)
    Switch $sPrefix
        Case "+"
            ; Open in standard DOpus with new window
            Return _Handler_OpenInDOpus("+" & $sCleanPath, "DIRECTORY_FULL")
            
        Case "-"
            ; Open in standard DOpus reusing tab, but then close active DOpus tab (send ctrl+f4) and keep picker up
            Local $bRet = _Handler_OpenInDOpus($sCleanPath, "DIRECTORY_FULL")
            If $bRet Then
                Sleep(800) ; Wait for DOpus tab to activate
                Send("^{F4}") ; Send Ctrl+F4 to close tab
            EndIf
            Return True
            
        Case "@"
            ; Open/activate Cursor on directory
            Local $iOldMatchMode = Opt("WinTitleMatchMode", 2)
            Local $sBaseFolder = StringRegExpReplace($sCleanPath, "^.*\\", "")
            Local $hWnd = WinGetHandle($sBaseFolder & " - Cursor")
            If Not $hWnd Then $hWnd = WinGetHandle("Cursor")
            
            If $hWnd Then
                WinSetState($hWnd, "", @SW_RESTORE)
                WinActivate($hWnd)
            Else
                ; Try to execute cursor.exe
                ShellExecute("cursor.exe", '"' & $sCleanPath & '"')
            EndIf
            Opt("WinTitleMatchMode", $iOldMatchMode)
            Return True
            
        Case "-@"
            ; Activate and close Cursor
            Local $iOldMatchMode = Opt("WinTitleMatchMode", 2)
            Local $sBaseFolder = StringRegExpReplace($sCleanPath, "^.*\\", "")
            Local $hWnd = WinGetHandle($sBaseFolder & " - Cursor")
            If Not $hWnd Then $hWnd = WinGetHandle("Cursor")
            
            If $hWnd Then
                WinSetState($hWnd, "", @SW_RESTORE)
                WinActivate($hWnd)
                Sleep(400)
                WinClose($hWnd)
            EndIf
            Opt("WinTitleMatchMode", $iOldMatchMode)
            Return True
            
        Case "#"
            ; Open/activate Obsidian on directory
            ShellExecute("obsidian://open?path=" & $sCleanPath)
            Return True
            
        Case "-#"
            ; Activate and close Obsidian
            Local $iOldMatchMode = Opt("WinTitleMatchMode", 2)
            Local $hWnd = WinGetHandle("Obsidian")
            If $hWnd Then
                WinSetState($hWnd, "", @SW_RESTORE)
                WinActivate($hWnd)
                Sleep(400)
                WinClose($hWnd)
            Endif
            Opt("WinTitleMatchMode", $iOldMatchMode)
            Return True
            
        Case Else
            ; Default standard routing
            Local $sType = _Recognizer_Evaluate($sCleanPath)
            If $sType == "URL_LAUNCH" Then
                Local $sChromePath = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe", "")
                If @error Or $sChromePath == "" Then $sChromePath = "chrome.exe"
                Run('"' & $sChromePath & '" "' & $sCleanPath & '"')
            ElseIf $sType == "ZDOT" Then
                _Handler_ResolveZdot($sCleanPath)
            ElseIf $sType == "DOS_CMD" Then
                _Handler_ExecuteDOSCommand($sCleanPath)
            Else
                ; Check if it's a directory/file path that exists
                If FileExists($sCleanPath) Then
                    Local $bIsDir = StringInStr(FileGetAttrib($sCleanPath), "D") > 0
                    If $bIsDir Then
                        _Handler_OpenInDOpus($sCleanPath, "DIRECTORY_FULL")
                    Else
                        ; Open files in default shell associations
                        ShellExecute($sCleanPath)
                    EndIf
                Else
                    ; Default text log patterns
                    ClipPut($sCleanPath)
                    _UI_ShowToast("Clipboard Exec", "Logged to clipboard: " & StringLeft($sCleanPath, 40))
                EndIf
            EndIf
            Return True
    EndSwitch
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
    
    ; 1. Try to decompose the raw input line first
    Local $oTokens = _Recognizer_DecomposeLine($sClip)
    Local $iTokenCount = 0
    If IsObj($oTokens) Then $iTokenCount = $oTokens.Count
    
    If $iTokenCount == 0 Then
        ; Fallback to standard original routing
        Local $sType = _Recognizer_Evaluate($sClip)
        Select
            Case $sType = "URL_LAUNCH"
                _UI_ShowToast("Web Navigator Link", "Launching pathway in Google Chrome: " & StringLeft($sClip, 40))
                Local $sChromePath = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe", "")
                If @error Or $sChromePath == "" Then $sChromePath = "chrome.exe"
                Run('"' & $sChromePath & '" "' & $sClip & '"')

            Case $sType = "DIRECTORY_FULL"
                _UI_ShowToast("Routing Directory", "Opening in Directory Opus: " & $sClip)
                _Handler_OpenInDOpus($sClip, $sType)
                
            Case $sType = "ZDOT"
                _Handler_ResolveZdot($sClip)

            Case $sType = "DOS_CMD"
                _Handler_ExecuteDOSCommand($sClip)

            Case Default
                _UI_ShowToast("Pattern Evaluated", "Type Identified: " & $sType & @CRLF & "Payload: " & StringLeft($sClip, 40))
        EndSelect
        Return
    EndIf

    ; Process token actions
    Local $aKeys = $oTokens.Keys()
    
    If $iTokenCount == 1 Then
        Local $sTokenData = $oTokens.Item($aKeys[0])
        Local $aMeta = StringSplit($sTokenData, "|")
        ; Index positions: 1:Raw, 2:BaseWord, 3:Prefix, 4:Type, 5:InstanceCount, 6+:Instances...
        Local $sRaw = $aMeta[1]
        Local $sWord = $aMeta[2]
        Local $sPrefix = $aMeta[3]
        Local $sType = $aMeta[4]
        Local $iCount = Int($aMeta[5])
        
        ; Extract list of instances
        Local $sInstances = ""
        Local $iIdxLimit = $aMeta[0]
        For $idx = 6 To $iIdxLimit
            $sInstances &= $aMeta[$idx] & "|"
        Next
        If StringRight($sInstances, 1) == "|" Then $sInstances = StringTrimRight($sInstances, 1)
        
        If $iCount <= 1 Or $sType == "URL" Or $sType == "ZDOT" Then
            ; Execute direct routing
            _Handler_ExecuteDestination($sWord, $sPrefix)
            
            ; Re-trigger Picker if keep-up prefix was specified
            If $sPrefix == "-" Or $sPrefix == "-@" Or $sPrefix == "-#" Then
                _UI_ShowToast("Picker Return", "Re-spawning Search Picker...")
                Sleep(800)
                Run('"' & @AutoItExe & '" "' & @ScriptDir & '\modules\_picker_demo.au3"')
            EndIf
        Else
            ; Show instances picker
            Local $aInstancesArray = StringSplit($sInstances, "|")
            _ArrayDelete($aInstancesArray, 0) ; Eliminate size header cell
            Local $sTitle = "SELECT INSTANCE FOR: " & $sWord
            Local $sInstanceChosen = _Picker_ShowGUI($aInstancesArray, $sTitle, "")
            If $sInstanceChosen <> "" Then
                _Handler_ExecuteDestination($sInstanceChosen, $sPrefix)
                If $sPrefix == "-" Or $sPrefix == "-@" Or $sPrefix == "-#" Then
                    _UI_ShowToast("Picker Return", "Re-spawning Search Picker...")
                    Sleep(800)
                    Run('"' & @AutoItExe & '" "' & @ScriptDir & '\modules\_picker_demo.au3"')
                EndIf
            EndIf
        Endif
    Else
        ; MULTIPLE tokens available! Show tokens picker
        Local $aTokenDisplay[$iTokenCount]
        For $i = 0 To $iTokenCount - 1
            Local $sTokenData = $oTokens.Item($aKeys[$i])
            Local $aMeta = StringSplit($sTokenData, "|")
            Local $sRaw = $aMeta[1]
            Local $sType = $aMeta[4]
            Local $iCount = Int($aMeta[5])
            
            $aTokenDisplay[$i] = $sRaw & " (" & $sType & " - " & $iCount & " matches)"
        Next
        
        Local $sChosenDisplay = _Picker_ShowGUI($aTokenDisplay, "DECOMPOSED TOKENS PICKER", "")
        If $sChosenDisplay <> "" Then
            ; Find match in keys
            Local $sSelectedKey = ""
            For $i = 0 To $iTokenCount - 1
                If StringInStr($sChosenDisplay, $aKeys[$i]) == 1 Then
                    $sSelectedKey = $aKeys[$i]
                    ExitLoop
                EndIf
            Next
            
            If $sSelectedKey <> "" Then
                Local $sTokenData = $oTokens.Item($sSelectedKey)
                Local $aMeta = StringSplit($sTokenData, "|")
                Local $sWord = $aMeta[2]
                Local $sPrefix = $aMeta[3]
                Local $sType = $aMeta[4]
                Local $iCount = Int($aMeta[5])
                
                Local $sInstances = ""
                Local $iIdxLimit = $aMeta[0]
                For $idx = 6 To $iIdxLimit
                    $sInstances &= $aMeta[$idx] & "|"
                Next
                If StringRight($sInstances, 1) == "|" Then $sInstances = StringTrimRight($sInstances, 1)
                
                If $iCount <= 1 Or $sType == "URL" Or $sType == "ZDOT" Then
                    _Handler_ExecuteDestination($sWord, $sPrefix)
                    If $sPrefix == "-" Or $sPrefix == "-@" Or $sPrefix == "-#" Then
                        _UI_ShowToast("Picker Return", "Re-spawning Search Picker...")
                        Sleep(800)
                        Run('"' & @AutoItExe & '" "' & @ScriptDir & '\modules\_picker_demo.au3"')
                    EndIf
                Else
                    Local $aInstancesArray = StringSplit($sInstances, "|")
                    _ArrayDelete($aInstancesArray, 0)
                    Local $sInstanceChosen = _Picker_ShowGUI($aInstancesArray, "SELECT INSTANCE FOR: " & $sWord, "")
                    If $sInstanceChosen <> "" Then
                        _Handler_ExecuteDestination($sInstanceChosen, $sPrefix)
                        If $sPrefix == "-" Or $sPrefix == "-@" Or $sPrefix == "-#" Then
                            _UI_ShowToast("Picker Return", "Re-spawning Search Picker...")
                            Sleep(800)
                            Run('"' & @AutoItExe & '" "' & @ScriptDir & '\modules\_picker_demo.au3"')
                        EndIf
                    EndIf
                EndIf
            EndIf
        EndIf
    EndIf
EndFunc

; End of file: _hotkeys.au3
