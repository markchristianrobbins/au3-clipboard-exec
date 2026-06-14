#include-once
; ==============================================================================
; File: _picker_helpers.au3
; Description: Pure string processing and metrics inquiry helper methods.
; Functions:
;   - _Picker_GetBaseName (Retrieves trailing path segments safely)
;   - _Picker_GetParentPath (Extracts structural parent directories)
;   - _Picker_GetPathLevel (Counts directory separators in path hierarchy)
;   - _Picker_IsUIDName (Checks if folders represent programmatic identifiers)
;   - _Picker_GetChildCount (Queries subdirectory cache counts)
;   - _Picker_GetGrandchildCount (Queries deep directory child counts)
; ==============================================================================
#include "_picker_globals.au3"
#include "_ui.au3"


Func _Picker_GetBaseName($sFullPath)
    If StringRight($sFullPath, 1) == "\" And StringLen($sFullPath) > 3 Then
        $sFullPath = StringTrimRight($sFullPath, 1)
    EndIf
    Local $sBase = StringRegExpReplace($sFullPath, "^.*\\", "")
    If $sBase == "" Then $sBase = $sFullPath
    Return $sBase
EndFunc

Func _Picker_GetParentPath($sFullPath)
    If StringRight($sFullPath, 1) == "\" And StringLen($sFullPath) > 3 Then
        $sFullPath = StringTrimRight($sFullPath, 1)
    EndIf
    Local $sParent = StringRegExpReplace($sFullPath, "\\[^\\]+$", "")
    If $sParent == "" Then Return $sFullPath
    Return $sParent
EndFunc

Func _Picker_GetPathLevel($sFullPath)
    If StringRight($sFullPath, 1) == "\" And StringLen($sFullPath) > 3 Then
        $sFullPath = StringTrimRight($sFullPath, 1)
    EndIf
    Local $sClean = $sFullPath
    Local $iCount = 1
    Local $iPos = 1
    While 1
        $iPos = StringInStr($sClean, "\", 0, 1, $iPos)
        If $iPos == 0 Then ExitLoop
        $iCount += 1
        $iPos += 1
    WEnd
    Return $iCount
EndFunc

Func _Picker_IsUIDName($sName)
    If StringRegExp($sName, "(?i)^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$") Then Return True
    If StringRegExp($sName, "(?i)[a-z]+-*[0-9]+-*[a-z]+-*[0-9]+") Then Return True
    If StringRegExp($sName, "(?i)[0-9]+-*[a-z]+-*[0-9]+-*[a-z]+") Then Return True
    Return False
EndFunc

Func _Picker_GetChildCount($sPath)
    If StringRight($sPath, 1) == "\" And StringLen($sPath) > 3 Then
        $sPath = StringTrimRight($sPath, 1)
    EndIf
    If IsObj($oChildCount) And $oChildCount.Exists($sPath) Then
        Return $oChildCount.Item($sPath)
    EndIf
    Return 0
EndFunc

Func _Picker_GetGrandchildCount($sPath)
    If StringRight($sPath, 1) == "\" And StringLen($sPath) > 3 Then
        $sPath = StringTrimRight($sPath, 1)
    EndIf
    If IsObj($oGrandchildCount) And $oGrandchildCount.Exists($sPath) Then
        Return $oGrandchildCount.Item($sPath)
    EndIf
    Return 0
EndFunc

; ==============================================================================
; Public API: Gathers full window metrics and copies detailed block to clipboard
; ==============================================================================
Func _Picker_CopyWindowInfo($sWinTitle)
    Local $hWnd = WinGetHandle($sWinTitle)
    If Not $hWnd Then
        ClipPut("Title: " & $sWinTitle & @CRLF & "Error: Window handle not found.")
        Return "Title: " & $sWinTitle & " (Handle not found)"
    EndIf
    
    ; Direct DLL or built-in calls to ensure smooth running
    Local $sClass = ""
    Local $aClassDll = DllCall("user32.dll", "int", "GetClassNameW", "hwnd", $hWnd, "wstr", "", "int", 512)
    If Not @error And IsArray($aClassDll) Then
        $sClass = $aClassDll[2]
    EndIf
    
    Local $iPID = WinGetProcess($hWnd)
    Local $sExePath = ""
    If $iPID > 0 Then
        Local $aProcDll = DllCall("kernel32.dll", "hwnd", "OpenProcess", "dword", 0x0410, "bool", False, "dword", $iPID) ; PROCESS_QUERY_INFORMATION | PROCESS_VM_READ
        If Not @error And IsArray($aProcDll) And $aProcDll[0] Then
            Local $hProcess = $aProcDll[0]
            Local $aPathDll = DllCall("psapi.dll", "dword", "GetModuleFileNameExW", "hwnd", $hProcess, "hwnd", 0, "wstr", "", "dword", 1024)
            If Not @error And IsArray($aPathDll) Then
                $sExePath = $aPathDll[3]
            EndIf
            DllCall("kernel32.dll", "bool", "CloseHandle", "hwnd", $hProcess)
        EndIf
    EndIf
    
    Local $aPos = WinGetPos($hWnd)
    Local $sPosStr = "Unknown"
    If IsArray($aPos) Then
        $sPosStr = "Left: " & $aPos[0] & ", Top: " & $aPos[1] & ", Width: " & $aPos[2] & ", Height: " & $aPos[3]
    EndIf
    
    Local $iState = WinGetState($hWnd)
    Local $sStateStr = "State Code: " & $iState
    If $iState > 0 Then
        Local $sStates = ""
        If BitAND($iState, 1) Then $sStates &= "Exists, "
        If BitAND($iState, 2) Then $sStates &= "Visible, "
        If BitAND($iState, 4) Then $sStates &= "Enabled, "
        If BitAND($iState, 8) Then $sStates &= "Active, "
        If BitAND($iState, 16) Then $sStates &= "Minimized, "
        If BitAND($iState, 32) Then $sStates &= "Maximized, "
        If StringRight($sStates, 2) == ", " Then $sStates = StringTrimRight($sStates, 2)
        $sStateStr &= " (" & $sStates & ")"
    EndIf
    
    Local $sText = "WINDOW INFO REPORT" & @CRLF & _
                   "------------------" & @CRLF & _
                   "Title: " & $sWinTitle & @CRLF & _
                   "Handle: " & String($hWnd) & @CRLF & _
                   "Class Name: " & $sClass & @CRLF & _
                   "Window Position: " & $sPosStr & @CRLF & _
                   "Process ID: " & $iPID & @CRLF & _
                   "Process Executable Path: " & $sExePath & @CRLF & _
                   "State Flags: " & $sStateStr & @CRLF
                   
    ClipPut($sText)
    Return "📋 COPIED WINDOW INFO of: " & $sWinTitle
EndFunc

; ==============================================================================
; Public API: Displays a custom context menu for window items at mouse cursor
; ==============================================================================
Func _Picker_Show_WinContextMenu($hWndGUI, $sWinTitle)
    Local $hWndTarget = WinGetHandle($sWinTitle)
    If Not $hWndTarget Then
        _UI_ShowToast("Window Error", "Unable to target window: " & $sWinTitle)
        Return
    EndIf

    ; Create a Win32 Popup Menu
    Local $hMenu = DllCall("user32.dll", "handle", "CreatePopupMenu")
    If @error Or Not $hMenu[0] Then Return
    $hMenu = $hMenu[0]
    
    ; Define menu command IDs
    Local $iCmdCopyInfo = 1001
    Local $iCmdMinimize = 1002
    Local $iCmdMaximize = 1003
    Local $iCmdRestore = 1004
    Local $iCmdClose = 1005
    
    ; Append items
    DllCall("user32.dll", "bool", "AppendMenuW", "handle", $hMenu, "uint", 0, "uint_ptr", $iCmdCopyInfo, "wstr", "Copy Info")
    DllCall("user32.dll", "bool", "AppendMenuW", "handle", $hMenu, "uint", 0x0800, "uint_ptr", 0, "wstr", "") ; MF_SEPARATOR
    DllCall("user32.dll", "bool", "AppendMenuW", "handle", $hMenu, "uint", 0, "uint_ptr", $iCmdMinimize, "wstr", "Minimize")
    DllCall("user32.dll", "bool", "AppendMenuW", "handle", $hMenu, "uint", 0, "uint_ptr", $iCmdMaximize, "wstr", "Maximize")
    DllCall("user32.dll", "bool", "AppendMenuW", "handle", $hMenu, "uint", 0, "uint_ptr", $iCmdRestore, "wstr", "Restore")
    DllCall("user32.dll", "bool", "AppendMenuW", "handle", $hMenu, "uint", 0, "uint_ptr", $iCmdClose, "wstr", "Close")
    
    ; Get cursor position (screen coordinates)
    Local $tPoint = DllStructCreate("long X;long Y;")
    DllCall("user32.dll", "bool", "GetCursorPos", "struct*", $tPoint)
    Local $iX = DllStructGetData($tPoint, "X")
    Local $iY = DllStructGetData($tPoint, "Y")
    
    ; Track pop up menu (TPM_RETURNCMD = 0x0100)
    Local $aRet = DllCall("user32.dll", "uint", "TrackPopupMenu", "handle", $hMenu, "uint", 0x0100, "int", $iX, "int", $iY, "int", 0, "hwnd", $hWndGUI, "ptr", 0)
    Local $iSelectedCmd = 0
    If Not @error And IsArray($aRet) Then
        $iSelectedCmd = $aRet[0]
    EndIf
    
    ; Destroy menu
    DllCall("user32.dll", "bool", "DestroyMenu", "handle", $hMenu)
    
    If $iSelectedCmd == 0 Then Return
    
    Select
        Case $iSelectedCmd == $iCmdCopyInfo
            Local $sStatusText = _Picker_CopyWindowInfo($sWinTitle)
            _UI_ShowToast("Copied", $sStatusText)
            ; Show result in Picker status bar too if it's open
            If IsDeclared("g_hStatusText") Then GUICtrlSetData($g_hStatusText, $sStatusText)
            
        Case $iSelectedCmd == $iCmdMinimize
            WinSetState($hWndTarget, "", @SW_MINIMIZE)
            _UI_ShowToast("Window", "Window minimized: " & $sWinTitle)
            
        Case $iSelectedCmd == $iCmdMaximize
            WinSetState($hWndTarget, "", @SW_MAXIMIZE)
            _UI_ShowToast("Window", "Window maximized: " & $sWinTitle)
            
        Case $iSelectedCmd == $iCmdRestore
            WinSetState($hWndTarget, "", @SW_RESTORE)
            _UI_ShowToast("Window", "Window restored: " & $sWinTitle)
            
        Case $iSelectedCmd == $iCmdClose
            WinClose($hWndTarget)
            _UI_ShowToast("Window", "Sent close command to window: " & $sWinTitle)
            
    EndSelect
EndFunc

; End of file: _picker_helpers.au3
