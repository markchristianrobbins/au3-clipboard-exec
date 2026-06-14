#include-once
; ==============================================================================
; File: _picker_mini.au3
; Paths: C:\_\au3-clipboard-exec\modules\_picker_mini.au3
; Description: Miniature context menu replacement search picker GUI interface.
; Functions:
;   - _Picker_ShowMiniGUI (Draws options window and blocks until option selected)
; ==============================================================================
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <StaticConstants.au3>
#include <Array.au3>
#include "_picker_style.au3"
#include "_ui.au3"
#include "_config.au3"

Func _Picker_ShowMiniGUI($hWndParent, $sWinTitle)
    Local $hWndTarget = WinGetHandle($sWinTitle)
    If Not $hWndTarget Then
        _UI_ShowToast("Window Error", "Unable to target window: " & $sWinTitle)
        Return ""
    EndIf

    Local $sConfigIni = _Config_GetIniPath()

    Local $aOptions[7] = ["Activate", "Copy Info", "Minimize", "Maximize", "Restore", "Close", "Exclude Window"]
    Local $aOptionIcons[7] = [4, 134, 24, 21, 22, 112, 109] ; shell32.dll icons matching actions

    Local $iWidth = 300
    Local $iRowHeight = 32
    Local $iInputAreaHeight = 48
    Local $iRowX = 10
    Local $iRowWidth = 280
    Local $iMaxRows = 7

    Local $iHeight = $iInputAreaHeight + 8 + ($iMaxRows * $iRowHeight) + 10
    
    ; Get current mouse position to spawn mini picker close to mouse
    Local $tPoint = DllStructCreate("long X;long Y;")
    DllCall("user32.dll", "bool", "GetCursorPos", "struct*", $tPoint)
    Local $iX = DllStructGetData($tPoint, "X") - ($iWidth / 2)
    Local $iY = DllStructGetData($tPoint, "Y") - 30
    
    If $iX < 0 Then $iX = 10
    If $iY < 0 Then $iY = 10
    If $iX + $iWidth > @DesktopWidth Then $iX = @DesktopWidth - $iWidth - 10
    If $iY + $iHeight > @DesktopHeight Then $iY = @DesktopHeight - $iHeight - 10

    Local $hWndMini = GUICreate("", $iWidth, $iHeight, $iX, $iY, $WS_POPUP, BitOR($WS_EX_TOPMOST, $WS_EX_TOOLWINDOW), $hWndParent)
    GUISetBkColor(0x1E1E1E, $hWndMini)

    ; Borders
    Local $hL = GUICtrlCreateLabel("", 0, 0, 1, $iHeight)
    GUICtrlSetBkColor($hL, 0xFF5500) ; Orange/Amber border indicator for context mode
    Local $hR = GUICtrlCreateLabel("", $iWidth - 1, 0, 1, $iHeight)
    GUICtrlSetBkColor($hR, 0xFF5500)
    Local $hT = GUICtrlCreateLabel("", 0, 0, $iWidth, 1)
    GUICtrlSetBkColor($hT, 0xFF5500)
    Local $hB = GUICtrlCreateLabel("", 0, $iHeight - 1, $iWidth, 1)
    GUICtrlSetBkColor($hB, 0xFF5500)

    ; Input Background
    Local $hInputBg = GUICtrlCreateLabel("", 10, 10, $iWidth - 20, 30)
    GUICtrlSetBkColor($hInputBg, 0x252526)
    GUICtrlSetState($hInputBg, $GUI_DISABLE)

    Local $hInputFieldMini = GUICtrlCreateInput("", 18, 13, $iWidth - 36, 24, $ES_AUTOHSCROLL)
    GUICtrlSetFont($hInputFieldMini, 10, 400, 0, "Segoe UI")
    GUICtrlSetColor($hInputFieldMini, 0xFFFFFF)
    GUICtrlSetBkColor($hInputFieldMini, 0x252526)

    Local $hDivider = GUICtrlCreateLabel("", 10, 46, $iWidth - 20, 1)
    GUICtrlSetBkColor($hDivider, 0x3F3F46)
    GUICtrlSetState($hDivider, $GUI_DISABLE)

    ; Focus helpers
    Local $hFocusL = GUICtrlCreateLabel("", 0, 0, 1, 1)
    Local $hFocusR = GUICtrlCreateLabel("", 0, 0, 1, 1)
    Local $hFocusT = GUICtrlCreateLabel("", 0, 0, 1, 1)
    Local $hFocusB = GUICtrlCreateLabel("", 0, 0, 1, 1)

    ; No matches label
    Local $hNoResultsMini = GUICtrlCreateLabel("No matching operations found", $iRowX, $iInputAreaHeight + 14, $iRowWidth, 30, BitOR($SS_CENTER, $SS_CENTERIMAGE))
    GUICtrlSetFont($hNoResultsMini, 9, 400, 2, "Segoe UI")
    GUICtrlSetColor($hNoResultsMini, 0x888888)
    GUICtrlSetBkColor($hNoResultsMini, $GUI_BKCOLOR_TRANSPARENT)
    GUICtrlSetState($hNoResultsMini, $GUI_HIDE)

    ; Allocate Row Controls
    Local $aRowBgMini[$iMaxRows]
    Local $aRowIconMini[$iMaxRows]
    Local $aRowTextMini[$iMaxRows]
    Local $aRowValMini[$iMaxRows]

    For $i = 0 To $iMaxRows - 1
        Local $iTopPos = $iInputAreaHeight + 8 + ($i * $iRowHeight)
        
        $aRowBgMini[$i] = GUICtrlCreateLabel("", $iRowX, $iTopPos, $iRowWidth, $iRowHeight - 2)
        GUICtrlSetCursor($aRowBgMini[$i], 0)
        GUICtrlSetState($aRowBgMini[$i], $GUI_HIDE)

        $aRowIconMini[$i] = GUICtrlCreateIcon("shell32.dll", 3, $iRowX + 10, $iTopPos + 7, 16, 16)
        GUICtrlSetBkColor($aRowIconMini[$i], $GUI_BKCOLOR_TRANSPARENT)
        GUICtrlSetState($aRowIconMini[$i], $GUI_HIDE)

        $aRowTextMini[$i] = GUICtrlCreateLabel("", $iRowX + 34, $iTopPos + 7, $iRowWidth - 44, 18)
        GUICtrlSetFont($aRowTextMini[$i], 9, 600, 0, "Segoe UI")
        GUICtrlSetBkColor($aRowTextMini[$i], $GUI_BKCOLOR_TRANSPARENT)
        GUICtrlSetState($aRowTextMini[$i], $GUI_HIDE)
    Next

    ; Accelerators mapping
    Local $hDUp = GUICtrlCreateDummy()
    Local $hDDown = GUICtrlCreateDummy()
    Local $hDEnter = GUICtrlCreateDummy()
    Local $hDEscape = GUICtrlCreateDummy()
    Local $hDBackspace = GUICtrlCreateDummy()

    Local $aAccelTable = [ _
        [ "{DOWN}", $hDDown ], _
        [ "{UP}", $hDUp ], _
        [ "{ENTER}", $hDEnter ], _
        [ "{ESC}", $hDEscape ], _
        [ "{BS}", $hDBackspace ] _
    ]
    GUISetAccelerators($aAccelTable, $hWndMini)

    GUISetState(@SW_SHOW, $hWndMini)
    ControlFocus($hWndMini, "", $hInputFieldMini)

    Local $sLastQueryMini = "|||"
    Local $g_iSelectedIndexMini = 0
    Local $g_iDisplayCountMini = 0
    Local $aFilteredOptions[1] = [""]
    
    ; Mouse timing trackers (mini version)
    Local $iLastClickedOpRow = -1
    Local $hClickOpTimer = 0

    While 1
        Local $iMsg = GUIGetMsg()
        If $iMsg == $GUI_EVENT_CLOSE Then ExitLoop

        ; Automatically close if parent or mini becomes inactive
        If WinActive($hWndMini) == 0 Then ExitLoop

        Local $sCurrentQuery = GUICtrlRead($hInputFieldMini)
        If $sCurrentQuery <> $sLastQueryMini Then
            $sLastQueryMini = $sCurrentQuery
            
            ; Fuzzy match options
            Local $aTempList[UBound($aOptions)]
            Local $iCount = 0
            For $i = 0 To UBound($aOptions) - 1
                If $sCurrentQuery == "" Or StringInStr(StringLower($aOptions[$i]), StringLower($sCurrentQuery)) > 0 Then
                    $aTempList[$iCount] = $aOptions[$i]
                    $iCount += 1
                EndIf
            Next

            If $iCount == 0 Then
                $g_iDisplayCountMini = 0
                GUICtrlSetState($hNoResultsMini, $GUI_SHOW)
                For $i = 0 To $iMaxRows - 1
                    GUICtrlSetState($aRowBgMini[$i], $GUI_HIDE)
                    GUICtrlSetState($aRowIconMini[$i], $GUI_HIDE)
                    GUICtrlSetState($aRowTextMini[$i], $GUI_HIDE)
                Next
                _Picker_UpdateFocusBorder($hFocusL, $hFocusR, $hFocusT, $hFocusB, 0, 0, 0, 0, False)
            Else
                GUICtrlSetState($hNoResultsMini, $GUI_HIDE)
                ReDim $aTempList[$iCount]
                $aFilteredOptions = $aTempList
                $g_iDisplayCountMini = $iCount
                $g_iSelectedIndexMini = 0

                ; Render matching rows
                For $i = 0 To $iMaxRows - 1
                    If $i < $iCount Then
                        ; Find original index to load match icon
                        Local $iOrigIdx = 0
                        For $j = 0 To UBound($aOptions) - 1
                            If $aOptions[$j] == $aFilteredOptions[$i] Then
                                $iOrigIdx = $j
                                ExitLoop
                            EndIf
                        Next

                        GUICtrlSetData($aRowTextMini[$i], $aFilteredOptions[$i])
                        GUICtrlSetImage($aRowIconMini[$i], "shell32.dll", $aOptionIcons[$iOrigIdx])
                        $aRowValMini[$i] = $aFilteredOptions[$i]

                        GUICtrlSetState($aRowBgMini[$i], $GUI_SHOW)
                        GUICtrlSetState($aRowIconMini[$i], $GUI_SHOW)
                        GUICtrlSetState($aRowTextMini[$i], $GUI_SHOW)

                        ; Apply unselected theme colors
                        GUICtrlSetBkColor($aRowBgMini[$i], 0x1E1E1E)
                        GUICtrlSetColor($aRowTextMini[$i], 0xBBBBBB)
                    Else
                        GUICtrlSetState($aRowBgMini[$i], $GUI_HIDE)
                        GUICtrlSetState($aRowIconMini[$i], $GUI_HIDE)
                        GUICtrlSetState($aRowTextMini[$i], $GUI_HIDE)
                    EndIf
                Next

                ; Highlight top item
                GUICtrlSetBkColor($aRowBgMini[0], 0x2D2D30)
                GUICtrlSetColor($aRowTextMini[0], 0xFF5500)
                
                Local $iActiveTop = $iInputAreaHeight + 8
                _Picker_UpdateFocusBorder($hFocusL, $hFocusR, $hFocusT, $hFocusB, $iRowX, $iActiveTop, $iRowWidth, 0xFF5500, True)
            Endif
        Endif

        ; Check keyboard input messages
        Select
            Case $iMsg == $hDDown
                If $g_iDisplayCountMini > 1 Then
                    ; Unhighlight old
                    GUICtrlSetBkColor($aRowBgMini[$g_iSelectedIndexMini], 0x1E1E1E)
                    GUICtrlSetColor($aRowTextMini[$g_iSelectedIndexMini], 0xBBBBBB)

                    $g_iSelectedIndexMini += 1
                    If $g_iSelectedIndexMini >= $g_iDisplayCountMini Then $g_iSelectedIndexMini = 0

                    ; Highlight new
                    GUICtrlSetBkColor($aRowBgMini[$g_iSelectedIndexMini], 0x2D2D30)
                    GUICtrlSetColor($aRowTextMini[$g_iSelectedIndexMini], 0xFF5500)

                    Local $iActiveTop = $iInputAreaHeight + 8 + ($g_iSelectedIndexMini * $iRowHeight)
                    _Picker_UpdateFocusBorder($hFocusL, $hFocusR, $hFocusT, $hFocusB, $iRowX, $iActiveTop, $iRowWidth, 0xFF5500, True)
                EndIf

            Case $iMsg == $hDUp
                If $g_iDisplayCountMini > 1 Then
                    ; Unhighlight old
                    GUICtrlSetBkColor($aRowBgMini[$g_iSelectedIndexMini], 0x1E1E1E)
                    GUICtrlSetColor($aRowTextMini[$g_iSelectedIndexMini], 0xBBBBBB)

                    $g_iSelectedIndexMini -= 1
                    If $g_iSelectedIndexMini < 0 Then $g_iSelectedIndexMini = $g_iDisplayCountMini - 1

                    ; Highlight new
                    GUICtrlSetBkColor($aRowBgMini[$g_iSelectedIndexMini], 0x2D2D30)
                    GUICtrlSetColor($aRowTextMini[$g_iSelectedIndexMini], 0xFF5500)

                    Local $iActiveTop = $iInputAreaHeight + 8 + ($g_iSelectedIndexMini * $iRowHeight)
                    _Picker_UpdateFocusBorder($hFocusL, $hFocusR, $hFocusT, $hFocusB, $iRowX, $iActiveTop, $iRowWidth, 0xFF5500, True)
                EndIf

            Case $iMsg == $hDEnter
                If $g_iDisplayCountMini > 0 And $g_iSelectedIndexMini < $g_iDisplayCountMini Then
                    Local $sSelect = $aFilteredOptions[$g_iSelectedIndexMini]
                    GUIDelete($hWndMini)
                    _Picker_ExecuteMiniAction($sSelect, $sWinTitle, $hWndTarget)
                    Return $sSelect
                EndIf

            Case $iMsg == $hDEscape
                ExitLoop

            Case $iMsg == $hDBackspace
                Local $sTxt = GUICtrlRead($hInputFieldMini)
                If $sTxt <> "" Then
                    GUICtrlSetData($hInputFieldMini, StringTrimRight($sTxt, 1))
                EndIf

            Case Else
                ; Mouse clicks on rows
                For $i = 0 To $g_iDisplayCountMini - 1
                    If $iMsg == $aRowBgMini[$i] Or $iMsg == $aRowIconMini[$i] Or $iMsg == $aRowTextMini[$i] Then
                        If $i <> $g_iSelectedIndexMini Then
                            ; Single Click - Focus
                            GUICtrlSetBkColor($aRowBgMini[$g_iSelectedIndexMini], 0x1E1E1E)
                            GUICtrlSetColor($aRowTextMini[$g_iSelectedIndexMini], 0xBBBBBB)

                            $g_iSelectedIndexMini = $i

                            GUICtrlSetBkColor($aRowBgMini[$g_iSelectedIndexMini], 0x2D2D30)
                            GUICtrlSetColor($aRowTextMini[$g_iSelectedIndexMini], 0xFF5500)

                            Local $iActiveTop = $iInputAreaHeight + 8 + ($g_iSelectedIndexMini * $iRowHeight)
                            _Picker_UpdateFocusBorder($hFocusL, $hFocusR, $hFocusT, $hFocusB, $iRowX, $iActiveTop, $iRowWidth, 0xFF5500, True)

                            $iLastClickedOpRow = $g_iSelectedIndexMini
                            $hClickOpTimer = TimerInit()
                        Else
                            ; Single Click on already focused - Check Double Click
                            If TimerDiff($hClickOpTimer) < 400 And $iLastClickedOpRow == $g_iSelectedIndexMini Then
                                Local $sSelect = $aFilteredOptions[$g_iSelectedIndexMini]
                                GUIDelete($hWndMini)
                                _Picker_ExecuteMiniAction($sSelect, $sWinTitle, $hWndTarget)
                                Return $sSelect
                            Else
                                $hClickOpTimer = TimerInit()
                            EndIf
                        EndIf
                        ExitLoop
                    EndIf
                Next
        EndSelect

        Sleep(10)
    WEnd

    GUIDelete($hWndMini)
    Return ""
EndFunc

; ==============================================================================
; Local Helper: Executes targeted operation and triggers toasts and system signals
; ==============================================================================
Func _Picker_ExecuteMiniAction($sActionName, $sWinTitle, $hWndTarget)
    Select
        Case $sActionName == "Activate"
            WinSetState($hWndTarget, "", @SW_RESTORE)
            _UI_ShowToast("Window Activated", "Activated window: " & $sWinTitle)
            WinActivate($hWndTarget)

        Case $sActionName == "Copy Info"
            Local $sStatus = _Picker_CopyWindowInfo($sWinTitle)
            _UI_ShowToast("Copied", $sStatus)
            If IsDeclared("g_hStatusText") Then GUICtrlSetData($g_hStatusText, $sStatus)

        Case $sActionName == "Minimize"
            WinSetState($hWndTarget, "", @SW_MINIMIZE)
            _UI_ShowToast("Window minimized", "Minimized window: " & $sWinTitle)

        Case $sActionName == "Maximize"
            WinSetState($hWndTarget, "", @SW_MAXIMIZE)
            _UI_ShowToast("Window maximized", "Maximized window: " & $sWinTitle)

        Case $sActionName == "Restore"
            WinSetState($hWndTarget, "", @SW_RESTORE)
            _UI_ShowToast("Window restored", "Restored window: " & $sWinTitle)

        Case $sActionName == "Close"
            WinClose($hWndTarget)
            _UI_ShowToast("Window closed", "Sent close instruction to window: " & $sWinTitle)

        Case $sActionName == "Exclude Window"
            Local $sConfigIni = _Config_GetIniPath()
            
            Local $sKey = "Title: " & $sWinTitle
            Local $sClass = _WinAPI_GetClassName($hWndTarget)
            If $sClass <> "" Then
                $sKey &= "|Class: " & $sClass
            EndIf
            Local $iPID = WinGetProcess($hWndTarget)
            If $iPID > 0 Then
                Local $sExePath = _WinAPI_GetProcessFileName($iPID)
                Local $sExeName = _Picker_GetBaseName($sExePath)
                If $sExeName <> "" Then
                    $sKey &= "|Process: " & $sExeName
                EndIf
            EndIf
            
            IniWrite($sConfigIni, "excluded-windows", $sKey, "1")
            
            _UI_ShowToast("Window Excluded", "Excluded window forever! Saved criteria details in INI.")
    EndSelect
EndFunc
