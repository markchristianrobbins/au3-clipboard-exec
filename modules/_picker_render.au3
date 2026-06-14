#include-once
; ==============================================================================
; File: _picker_render.au3
; Description: Visual list rendering, styling, indentation levels, and active row indicators.
; Functions:
;   - _Picker_HighlightRowDynamic (Controls individual list elements, labels, fonts, and colors)
;   - _Picker_RenderVisibleList (Redraws all display elements, handling clipping bounds)
;   - _Picker_UpdateStatusText (Updates the details status context bar based on search state)
; ==============================================================================
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WinAPIProc.au3>
#include <WinAPISys.au3>
#include "_picker_helpers.au3"
#include "_picker_icons.au3"
#include "_picker_style.au3"

Func _Picker_HighlightRowDynamic(ByRef $aRowIcon, ByRef $aRowIdxCtrl, ByRef $aRowBorder, ByRef $aRowBg, ByRef $aRowPre, ByRef $aRowMatch, ByRef $aRowPost, ByRef $aRowPath, ByRef $aRowDepthInfo, ByRef $aFilteredPaths, $sSearchTxt, $iVisualIndex, $iAbsoluteIndex, $bActive, $bIsRecent, $bExploreMode, $sExploreDir, $iInputAreaHeight)
    Local $hIconCtrl = $aRowIcon[$iVisualIndex + 1]
    Local $hIdxCtrl = $aRowIdxCtrl[$iVisualIndex + 1]
    Local $hBorderCtrl = $aRowBorder[$iVisualIndex + 1]
    Local $hBgCtrl = $aRowBg[$iVisualIndex + 1]
    Local $hPreCtrl = $aRowPre[$iVisualIndex + 1]
    Local $hMatchCtrl = $aRowMatch[$iVisualIndex + 1]
    Local $hPostCtrl = $aRowPost[$iVisualIndex + 1]
    Local $hPathCtrl = $aRowPath[$iVisualIndex + 1]
    Local $hDepthInfoCtrl = $aRowDepthInfo[$iVisualIndex + 1]

    Local $sFullPath = $aFilteredPaths[$iAbsoluteIndex]
    Local $sBaseName = _Picker_GetBaseName($sFullPath)

    If $bIsRecent Then $sBaseName = "★ " & $sBaseName

    Local $sLowerBase = StringLower($sBaseName)
    Local $sLowerSearch = StringLower($sSearchTxt)
    Local $iMatchPos = 0
    If $sSearchTxt <> "" Then $iMatchPos = StringInStr($sLowerBase, $sLowerSearch)

    Local $sPre = "", $sMatch = "", $sPost = $sBaseName
    If $iMatchPos > 0 Then
        $sPre = StringLeft($sBaseName, $iMatchPos - 1)
        $sMatch = StringMid($sBaseName, $iMatchPos, StringLen($sSearchTxt))
        $sPost = StringMid($sBaseName, $iMatchPos + StringLen($sSearchTxt))
    EndIf

    ; Process type detection
    Local $bIsWindow = False
    Local $bIsDir = False
    Local $bIsFile = False
    
    If StringInStr($sFullPath, " [window]") > 0 Then
        $bIsWindow = True
    ElseIf StringInStr($sFullPath, " [dir]") > 0 Then
        $bIsDir = True
    ElseIf StringInStr($sFullPath, " [file]") > 0 Then
        $bIsFile = True
    Else
        ; Clean suffix and fallback to environmental check
        Local $sCleanPath = $sFullPath
        $sCleanPath = StringRegExpReplace($sCleanPath, "(?i)\s+\(\d+\s+matches\)\s*$", "")
        $sCleanPath = StringRegExpReplace($sCleanPath, "(?i)\s+\[(?:dir|file|window)\]\s*$", "")
        
        If FileExists($sCleanPath) Then
            If StringInStr(FileGetAttrib($sCleanPath), "D") > 0 Then
                $bIsDir = True
            Else
                $bIsFile = True
            EndIf
        Else
            If WinExists($sCleanPath) Then
                $bIsWindow = True
            Else
                $bIsDir = True ; Default fallback
            EndIf
        EndIf
    EndIf

    Local $iLevel = _Picker_GetPathLevel($sFullPath)
    Local $iBaseLevel = 1
    If $bExploreMode Then $iBaseLevel = _Picker_GetPathLevel($sExploreDir)
    Local $iRelativeLevel = $iLevel - $iBaseLevel
    If $iRelativeLevel < 0 Then $iRelativeLevel = 0
    Local $iIndent = $iRelativeLevel * 12
    If $iIndent > 150 Then $iIndent = 150

    Local $iRowX = 15, $iRowHeight = 42
    Local $iTopPos = $iInputAreaHeight + 8 + ($iVisualIndex * $iRowHeight)
    Local $iStartTextX = $iRowX + 54 + $iIndent
    Local $iCharWidth = 8.1

    Local $wPre = StringLen($sPre) * $iCharWidth
    Local $wMatch = StringLen($sMatch) * $iCharWidth

    GUICtrlSetData($hIdxCtrl, $iAbsoluteIndex + 1)
    GUICtrlSetData($hPreCtrl, $sPre)
    GUICtrlSetData($hMatchCtrl, $sMatch)
    GUICtrlSetData($hPostCtrl, $sPost)

    ; Resolve icon and path details dynamically
    Local $sCleanPathForIcon = $sFullPath
    $sCleanPathForIcon = StringRegExpReplace($sCleanPathForIcon, "(?i)\s+\(\d+\s+matches\)\s*$", "")
    $sCleanPathForIcon = StringRegExpReplace($sCleanPathForIcon, "(?i)\s+\[(?:dir|file|window)\]\s*$", "")

    If $bIsWindow Then
        Local $hWnd = WinGetHandle($sCleanPathForIcon)
        Local $sExePath = ""
        If $hWnd Then
            Local $iPID = WinGetProcess($hWnd)
            If $iPID > 0 Then
                $sExePath = _WinAPI_GetProcessFileName($iPID)
            EndIf
        EndIf
        
        If $sExePath <> "" Then
            GUICtrlSetData($hPathCtrl, $sExePath)
            If FileExists($sExePath) Then
                GUICtrlSetImage($hIconCtrl, $sExePath, 0)
            Else
                GUICtrlSetImage($hIconCtrl, "shell32.dll", 2)
            EndIf
        Else
            GUICtrlSetData($hPathCtrl, "Active Desktop Window Handle")
            GUICtrlSetImage($hIconCtrl, "shell32.dll", 2)
        EndIf
    ElseIf $bIsFile Then
        GUICtrlSetData($hPathCtrl, _Picker_GetParentPath($sCleanPathForIcon))
        If FileExists($sCleanPathForIcon) Then
            GUICtrlSetImage($hIconCtrl, $sCleanPathForIcon, 0)
        Else
            GUICtrlSetImage($hIconCtrl, "shell32.dll", 1)
        Endif
    Else
        GUICtrlSetData($hPathCtrl, _Picker_GetParentPath($sFullPath))
        Local $aIconInfo = _Picker_GetFolderIconCached($sCleanPathForIcon)
        GUICtrlSetImage($hIconCtrl, $aIconInfo[0], $aIconInfo[1])
    EndIf

    Local $sInfoText = ""
    If $bIsWindow Then
        $sInfoText = "[window]"
    ElseIf $bIsFile Then
        $sInfoText = "[file]"
    Else
        Local $iChildren = _Picker_GetChildCount($sFullPath)
        Local $iGrandchildren = _Picker_GetGrandchildCount($sFullPath)
        $sInfoText = "[dir] [" & $iLevel & "] " & $iChildren & " " & $iGrandchildren
    EndIf
    GUICtrlSetData($hDepthInfoCtrl, $sInfoText)

    GUICtrlSetPos($hIdxCtrl, $iRowX + 4, $iTopPos + 12, 22, 14)
    GUICtrlSetPos($hPreCtrl, $iStartTextX, $iTopPos + 3, $wPre, 18)
    GUICtrlSetPos($hMatchCtrl, $iStartTextX + $wPre, $iTopPos + 3, $wMatch, 18)
    GUICtrlSetPos($hPostCtrl, $iStartTextX + $wPre + $wMatch, $iTopPos + 3, 500 - $iIndent, 18)
    GUICtrlSetPos($hPathCtrl, $iStartTextX, $iTopPos + 21, 590 - $iIndent, 15)

    GUICtrlSetPos($hIconCtrl, $iRowX + 32 + $iIndent, $iTopPos + 11, 16, 16)

    Local $iMainColor = _Picker_GetBaseColor(_Picker_GetBaseName($sFullPath))

    If $bActive Then
        GUICtrlSetBkColor($hBgCtrl, 0x2D2D30)
        GUICtrlSetColor($hIdxCtrl, 0x999999)
        GUICtrlSetColor($hPreCtrl, $iMainColor)
        GUICtrlSetColor($hMatchCtrl, 0xFFC107)
        GUICtrlSetColor($hPostCtrl, $iMainColor)
        GUICtrlSetColor($hDepthInfoCtrl, 0x999999)
        GUICtrlSetColor($hPathCtrl, 0x999999)
    Else
        GUICtrlSetBkColor($hBgCtrl, 0x1E1E1E)
        Local $iDimColor = _Picker_DimColor($iMainColor, 0.65)
        GUICtrlSetColor($hIdxCtrl, 0x555555)
        GUICtrlSetColor($hPreCtrl, $iDimColor)
        GUICtrlSetColor($hMatchCtrl, 0xFFC107)
        GUICtrlSetColor($hPostCtrl, $iDimColor)
        GUICtrlSetColor($hDepthInfoCtrl, 0x555555)
        GUICtrlSetColor($hPathCtrl, 0x555555)
    EndIf

    If $bIsRecent Then
        GUICtrlSetBkColor($hBorderCtrl, 0xFFFFFF)
        GUICtrlSetState($hBorderCtrl, $GUI_SHOW)
    Else
        GUICtrlSetState($hBorderCtrl, $GUI_HIDE)
    EndIf
EndFunc

Func _Picker_RenderVisibleList(ByRef $aRowIcon, ByRef $aRowIdxCtrl, ByRef $aRowBorder, ByRef $aRowBg, ByRef $aRowPre, ByRef $aRowMatch, ByRef $aRowPost, ByRef $aRowPath, ByRef $aRowDepthInfo, ByRef $aFilteredPaths, $sCurrentQuery, $iDisplayCount, $iSelectedIndex, $iScrollOffset, $iMaxDisplayRows, $iRecentCount, $bExploreMode, $sExploreDir, $iInputAreaHeight)
    For $i = 0 To $iMaxDisplayRows - 1
        Local $hBgCtrl = $aRowBg[$i + 1]
        If $i < $iDisplayCount Then
            Local $bIsRecent = ($iScrollOffset + $i < $iRecentCount)
            _Picker_HighlightRowDynamic($aRowIcon, $aRowIdxCtrl, $aRowBorder, $aRowBg, $aRowPre, $aRowMatch, $aRowPost, $aRowPath, $aRowDepthInfo, $aFilteredPaths, $sCurrentQuery, $i, $iScrollOffset + $i, ($i == $iSelectedIndex), $bIsRecent, $bExploreMode, $sExploreDir, $iInputAreaHeight)
            If $bIsRecent Then
                GUICtrlSetState($aRowBorder[$i + 1], $GUI_SHOW)
            Else
                GUICtrlSetState($aRowBorder[$i + 1], $GUI_HIDE)
            EndIf
            GUICtrlSetState($hBgCtrl, $GUI_SHOW)
            GUICtrlSetState($aRowIdxCtrl[$i + 1], $GUI_SHOW)
            GUICtrlSetState($aRowIcon[$i + 1], $GUI_SHOW)
            GUICtrlSetState($aRowPre[$i + 1], $GUI_SHOW)
            GUICtrlSetState($aRowMatch[$i + 1], $GUI_SHOW)
            GUICtrlSetState($aRowPost[$i + 1], $GUI_SHOW)
            GUICtrlSetState($aRowPath[$i + 1], $GUI_SHOW)
            GUICtrlSetState($aRowDepthInfo[$i + 1], $GUI_SHOW)
        Else
            GUICtrlSetState($aRowBorder[$i + 1], $GUI_HIDE)
            GUICtrlSetState($hBgCtrl, $GUI_HIDE)
            GUICtrlSetState($aRowIdxCtrl[$i + 1], $GUI_HIDE)
            GUICtrlSetState($aRowIcon[$i + 1], $GUI_HIDE)
            GUICtrlSetState($aRowPre[$i + 1], $GUI_HIDE)
            GUICtrlSetState($aRowMatch[$i + 1], $GUI_HIDE)
            GUICtrlSetState($aRowPost[$i + 1], $GUI_HIDE)
            GUICtrlSetState($aRowPath[$i + 1], $GUI_HIDE)
            GUICtrlSetState($aRowDepthInfo[$i + 1], $GUI_HIDE)
        EndIf
    Next
EndFunc

Func _Picker_UpdateStatusText($hStatusText, $hStatusBg, ByRef $aFilteredPaths, $iSelectedIndex, $iScrollOffset, $bExploreMode, $sExploreDir, $iMatchesFound, $iRecentCount)
    Local $sStatusTextVal = ""
    Local $sSelectedDetails = ""
    
    If UBound($aFilteredPaths) > 0 And $aFilteredPaths[0] <> "" And ($iScrollOffset + $iSelectedIndex) < UBound($aFilteredPaths) Then
        Local $sFullPath = $aFilteredPaths[$iScrollOffset + $iSelectedIndex]
        
        Local $bIsWindow = StringInStr($sFullPath, " [window]") > 0
        ; Strip metadata to check direct active window state
        Local $sCleanForCheck = $sFullPath
        $sCleanForCheck = StringRegExpReplace($sCleanForCheck, "(?i)\s+\(\d+\s+matches\)\s*$", "")
        $sCleanForCheck = StringRegExpReplace($sCleanForCheck, "(?i)\s+\[(?:dir|file|window)\]\s*$", "")
        
        If Not $bIsWindow And Not FileExists($sCleanForCheck) And WinExists($sCleanForCheck) Then $bIsWindow = True
        
        If $bIsWindow Then
            Local $hWnd = WinGetHandle($sCleanForCheck)
            Local $sExeName = "Unknown Process"
            Local $sExePath = ""
            Local $sClass = ""
            If $hWnd Then
                Local $iPID = WinGetProcess($hWnd)
                If $iPID > 0 Then
                    $sExePath = _WinAPI_GetProcessFileName($iPID)
                    Local $iSlashPos = StringInStr($sExePath, "\", 0, -1)
                    If $iSlashPos > 0 Then
                        $sExeName = StringMid($sExePath, $iSlashPos + 1)
                    Else
                        $sExeName = $sExePath
                    EndIf
                EndIf
                $sClass = _WinAPI_GetClassName($hWnd)
            EndIf
            
            $sSelectedDetails = "  |  Sel Window: " & $sCleanForCheck & " (Process: " & $sExeName & ", Class: " & $sClass & ")"
        Else
            Local $bIsFile = StringInStr($sFullPath, " [file]") > 0
            If Not $bIsFile And FileExists($sCleanForCheck) And (StringInStr(FileGetAttrib($sCleanForCheck), "D") == 0) Then $bIsFile = True
            
            If $bIsFile Then
                Local $iSize = FileGetSize($sCleanForCheck)
                Local $sSizeStr = "Unknown Size"
                If $iSize > 0 Then
                    If $iSize < 1024 Then
                        $sSizeStr = $iSize & " bytes"
                    ElseIf $iSize < 1048576 Then
                        $sSizeStr = Round($iSize / 1024, 1) & " KB"
                    Else
                        $sSizeStr = Round($iSize / 1048576, 1) & " MB"
                    EndIf
                Endif
                
                $sSelectedDetails = "  |  Sel File: " & _Picker_GetBaseName($sCleanForCheck) & " (" & $sSizeStr & ")"
            Else
                Local $sCleanFolder = $sCleanForCheck
                If StringRight($sCleanFolder, 1) <> "\" Then $sCleanFolder &= "\"
                
                Local $bSelectedHasGit = FileExists($sCleanFolder & ".git")
                Local $bSelectedHasObsidian = FileExists($sCleanFolder & ".obsidian")
                
                Local $iLevel = _Picker_GetPathLevel($sCleanForCheck)
                Local $iChildren = _Picker_GetChildCount($sCleanForCheck)
                
                $sSelectedDetails = "  |  Sel Dir: " & _Picker_GetBaseName($sCleanForCheck)
                If $iChildren > 0 Then $sSelectedDetails &= " (" & $iChildren & " subdirs, level " & $iLevel & ")"
                If $bSelectedHasGit Then
                    $sSelectedDetails &= " [Repo: .git]"
                ElseIf $bSelectedHasObsidian Then
                    $sSelectedDetails &= " [Vault: .obsidian]"
                EndIf
            EndIf
        EndIf
    EndIf

    If $bExploreMode Then
        Local $sDispDir = $sExploreDir
        If $sDispDir == "" Then $sDispDir = "Root Selection"
        $sStatusTextVal = "🔍 EXPLORE MODE  |  In: " & _Picker_GetBaseName($sDispDir) & " (" & $iMatchesFound & " subdirs)" & $sSelectedDetails & "  |  Ctrl+BS: Exit  |  Esc: Back"
        GUICtrlSetColor($hStatusText, 0x00FF66)
        GUICtrlSetBkColor($hStatusBg, 0x152E1B)
    Else
        $sStatusTextVal = "Search: " & $iMatchesFound & " found" & $sSelectedDetails & "  |  Ctrl+Enter: Explore  |  Esc: Close"
        GUICtrlSetColor($hStatusText, 0x888888)
        GUICtrlSetBkColor($hStatusBg, 0x1A1A1A)
    EndIf
    
    GUICtrlSetData($hStatusText, $sStatusTextVal)
EndFunc

; End of file: _picker_render.au3
