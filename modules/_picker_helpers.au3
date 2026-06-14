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
#include "_config.au3"


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

    Local $sOpt = _Picker_ShowMiniGUI($hWndGUI, $sWinTitle)
    If $sOpt == "Exclude Window" Or $sOpt == "Close" Or $sOpt == "Minimize" Or $sOpt == "Maximize" Or $sOpt == "Restore" Then
        ; Rebuild match items if combined picker is active!
        If $g_bIsCombinedPicker Then
            _Picker_RebuildCombinedMatches($g_aActiveBasePaths)
            _Picker_HandleQueryChange($g_aActiveBasePaths)
        EndIf
    EndIf
EndFunc

; ==============================================================================
; Public API: Checks if a window is persistently excluded from harvested results
; ==============================================================================
Func _Picker_IsWindowExcluded($sTitle, $hWnd)
    Local $sConfigIni = _Config_GetIniPath()
    
    Local $aExclusions = IniReadSection($sConfigIni, "excluded-windows")
    If @error Or Not IsArray($aExclusions) Then Return False
    
    Local $sClass = ""
    Local $sExeName = ""
    If $hWnd Then
        $sClass = _WinAPI_GetClassName($hWnd)
        Local $iPID = WinGetProcess($hWnd)
        If $iPID > 0 Then
            Local $sExePath = _WinAPI_GetProcessFileName($iPID)
            $sExeName = _Picker_GetBaseName($sExePath)
        EndIf
    EndIf
    
    For $i = 1 To $aExclusions[0][0]
        Local $sKey = $aExclusions[$i][0]
        Local $sValue = $aExclusions[$i][1]
        If $sValue <> "1" Then ContinueLoop
        
        Local $aParts = StringSplit($sKey, "|")
        Local $bAllMatch = True
        Local $iConditionsCount = 0
        
        For $j = 1 To $aParts[0]
            Local $sPart = StringStripWS($aParts[$j], 3)
            If StringLeft(StringLower($sPart), 6) == "title:" Then
                Local $sVal = StringStripWS(StringMid($sPart, 7), 3)
                $iConditionsCount += 1
                If StringLower($sTitle) <> StringLower($sVal) Then
                    $bAllMatch = False
                    ExitLoop
                EndIf
            ElseIf StringLeft(StringLower($sPart), 6) == "class:" Then
                Local $sVal = StringStripWS(StringMid($sPart, 7), 3)
                $iConditionsCount += 1
                If StringLower($sClass) <> StringLower($sVal) Then
                    $bAllMatch = False
                    ExitLoop
                EndIf
            ElseIf StringLeft(StringLower($sPart), 8) == "process:" Then
                Local $sVal = StringStripWS(StringMid($sPart, 9), 3)
                $iConditionsCount += 1
                If StringLower($sExeName) <> StringLower($sVal) Then
                    $bAllMatch = False
                    ExitLoop
                EndIf
            EndIf
        Next
        
        If $iConditionsCount > 0 And $bAllMatch Then Return True
    Next
    
    Return False
EndFunc

; ==============================================================================
; Public API: Dynamically updates the text display on the toolbar element
; ==============================================================================
Func _Picker_UpdateToolbarText()
    Local $sHiddenBox = "[ ]"
    If $g_bShowHidden Then $sHiddenBox = "[x]"
    Local $sMinBox = "[ ]"
    If $g_bShowMinimized Then $sMinBox = "[x]"
    Local $sText = "  Toolbar:  " & $sHiddenBox & " Show Hidden (Alt+H)      " & $sMinBox & " Show Minimized (Alt+M)      [Reload Index]"
    GUICtrlSetData($g_hToolbarText, $sText)
EndFunc

; ==============================================================================
; Public API: Re-queries windows and index directories based on active toggles
; ==============================================================================
Func _Picker_RebuildCombinedMatches(ByRef $aAllMatches)
    ; 1. Load directory paths from index
    _Index_Initialize()
    Local $aDirs = _Index_LoadIndexedPaths()
    If UBound($aDirs) == 0 Or (UBound($aDirs) == 1 And $aDirs[0] == "") Then
        Local $aFallback[4] = ["C:\", "D:\", @MyDocumentsDir, @UserProfileDir]
        $aDirs = $aFallback
    Endif
    
    ; 2. Extract active windows reflecting toolbar toggles
    Local $aWinList = WinList()
    Local $aWindows[UBound($aWinList)]
    Local $iWinCount = 0
    Local $oSeenWins = ObjCreate("Scripting.Dictionary")
    $oSeenWins.CompareMode = 1
    
    For $i = 1 To $aWinList[0][0]
        Local $sTitle = $aWinList[$i][0]
        Local $hWnd = $aWinList[$i][1]
        
        If $sTitle <> "" And $sTitle <> "Program Manager" And $hWnd <> $g_hPickerGUI And _Util_IsOverlappedWindow($hWnd) And Not _Picker_IsWindowExcluded($sTitle, $hWnd) Then
            Local $iState = WinGetState($hWnd)
            Local $bIsVisible = (BitAND($iState, 2) > 0)
            Local $bIsMinimized = (BitAND($iState, 16) > 0)
            
            ; Active toggles boundaries
            If Not $g_bShowHidden And Not $bIsVisible Then ContinueLoop
            If Not $g_bShowMinimized And $bIsMinimized Then ContinueLoop
            
            Local $sSuffix = " [window]"
            If Not $bIsVisible And $bIsMinimized Then
                $sSuffix = " [window: minimized & hidden]"
            ElseIf Not $bIsVisible Then
                $sSuffix = " [window: hidden]"
            ElseIf $bIsMinimized Then
                $sSuffix = " [window: minimized]"
            EndIf
            
            Local $sItemTitle = $sTitle & $sSuffix
            If Not $oSeenWins.Exists(StringLower($sItemTitle)) Then
                $oSeenWins.Add(StringLower($sItemTitle), 1)
                $aWindows[$iWinCount] = $sItemTitle
                $iWinCount += 1
            EndIf
        EndIf
    Next
    If $iWinCount > 0 Then ReDim $aWindows[$iWinCount]
    
    Local $iDirsCount = UBound($aDirs)
    Local $aFormattedDirs[$iDirsCount]
    Local $iDirCount = 0
    For $i = 0 To $iDirsCount - 1
        If $aDirs[$i] <> "" Then
            $aFormattedDirs[$iDirCount] = $aDirs[$i] & " [dir]"
            $iDirCount += 1
        EndIf
    Next
    If $iDirCount > 0 Then ReDim $aFormattedDirs[$iDirCount]
    
    Local $iTotalSize = $iWinCount + $iDirCount
    If $iTotalSize == 0 Then
        Local $aEmpty[1] = [""]
        $aAllMatches = $aEmpty
        Return
    EndIf
    
    Local $aCombined[ $iTotalSize ]
    Local $iIdx = 0
    For $i = 0 To $iWinCount - 1
        $aCombined[$iIdx] = $aWindows[$i]
        $iIdx += 1
    Next
    For $i = 0 To $iDirCount - 1
        $aCombined[$iIdx] = $aFormattedDirs[$i]
        $iIdx += 1
    Next
    
    $aAllMatches = $aCombined
EndFunc

; End of file: _picker_helpers.au3
