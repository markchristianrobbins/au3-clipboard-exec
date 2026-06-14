#include-once
#include <AutoItConstants.au3>

; Include the UI module so this file can access _UI_ShowToast()
#include "_ui.au3"

; Global path setup for Directory Opus runtime command runner
Global Const $g_sDOpusRt = "C:\Program Files\GPSoftware\Directory Opus\dopusrt.exe"

; ==============================================================================
; Public API: Executes Directory Opus automation layout with tab reuse or breakout
; ==============================================================================
Func _Handler_OpenInDOpus($sFullPath, $sType)
    Local $bNewWindow = False
    Local $sCleanPath = StringStripWS($sFullPath, 3)

    ; ORDER OF OPERATIONS FIX 1: Detect and slice off the breakout prefix operator first
    If StringLeft($sCleanPath, 1) = "+" Then
        $bNewWindow = True
        $sCleanPath = StringStripWS(StringMid($sCleanPath, 2), 3) 
    EndIf

    ; ORDER OF OPERATIONS FIX 2: Strip ALL trailing backslashes/forward slashes safely
    While StringRight($sCleanPath, 1) == "\" Or StringRight($sCleanPath, 1) == "/"
        $sCleanPath = StringTrimRight($sCleanPath, 1)
    WEnd

    ; Re-append slash if targeting root level drive structures to prevent OS crashes (e.g., "C:")
    If StringRight($sCleanPath, 1) == ":" Then $sCleanPath &= "\"

    ; ORDER OF OPERATIONS FIX 3: Now that the path is perfectly clean, validate it exists
    If Not FileExists($sCleanPath) Then
        Local $sErrText = "DOpus Routing Error: Path does not exist on disk: '" & $sCleanPath & "'"
        ClipPut($sErrText)
        _UI_ShowToast("DOpus Error", $sErrText)
        Return SetError(1, 0, False)
    EndIf

    ; Isolate the base folder name for title matching routines (e.g., "C:\$data" -> "$data")
    Local $sBaseName = StringRegExpReplace($sCleanPath, "^.*\\", "")
    If $sBaseName == "" Then $sBaseName = $sCleanPath

    ; Construct parameters following your tab reuse blueprint
    Local $sCommandArgs = '/cmd Go "' & $sCleanPath & '"'
    
    If $bNewWindow Then
        $sCommandArgs &= " NEW=nodrop,nodrive,noactivate"
    Else
        $sCommandArgs &= " NEWTAB=findexisting,tofront"
    EndIf

    ; Execute the instruction invisibly via Shell
    ShellExecute($g_sDOpusRt, $sCommandArgs, "", "open", @SW_HIDE)

    ; Delay to provide window initialization window boundaries
    Sleep(250)

    ; Manage frame foreground visibility snap states
    Local $iOldMatchMode = Opt("WinTitleMatchMode", 1) 
    Local $sTargetWindowTitle = $sBaseName & " - Directory Opus"
    Local $sTargetWindowTitle2 = $sBaseName

    If WinExists($sTargetWindowTitle) Then
        _Handler_FocusDOpusWindow($sTargetWindowTitle)
    ElseIf WinExists($sTargetWindowTitle2) Then
        _Handler_FocusDOpusWindow($sTargetWindowTitle2)
    EndIf

    Opt("WinTitleMatchMode", $iOldMatchMode) 
    Return True
EndFunc

; ==============================================================================
; Private Helper: Pushes the targeted window layer to the front focus stack
; ==============================================================================
Func _Handler_FocusDOpusWindow($sTitle)
    WinSetState($sTitle, "", @SW_RESTORE)
    WinActivate($sTitle)
    Local $hWnd = WinGetHandle($sTitle)
    DllCall("user32.dll", "bool", "SetForegroundWindow", "hwnd", $hWnd)
EndFunc

; modules\_handler_dopus.au3
