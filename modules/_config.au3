#include-once
#include <AutoItConstants.au3>
#include <WinAPIProc.au3>
#include <WinAPISys.au3>

; Global storage paths for configuration infrastructure
Global Const $g_sMainIni = "C:\$data\clipboard-exec.ini"

; ==============================================================================
; Public API: Simple, crash-proof active window profiling engine
; ==============================================================================
Func _Config_GetActiveAppProfile()
    Local $sAppsIni = "C:\$data\apps.ini"
    If Not FileExists($sAppsIni) Then $sAppsIni = @ScriptDir & "\apps.ini"
    If Not FileExists($sAppsIni) Then $sAppsIni = "apps.ini" ; Fallback to current directory

    Local $sConfigIni = "C:\$data\clipboard-exec.ini"
    If Not FileExists($sConfigIni) Then $sConfigIni = @ScriptDir & "\clipboard-exec.ini"
    If Not FileExists($sConfigIni) Then $sConfigIni = "clipboard-exec.ini"

    Local $hWnd = WinGetHandle("[ACTIVE]")
    If @error Or $hWnd == 0 Then
        ; Fail-safe default
        Local $aFailSafe[3] = ["Universal", "{HOME}+{END}^c", ""]
        Return $aFailSafe
    EndIf

    Local $iPID = WinGetProcess($hWnd)
    Local $sFullPathExe = _WinAPI_GetProcessFileName($iPID)
    Local $iSlashPos = StringInStr($sFullPathExe, "\", 0, -1) 
    Local $sCurrentExe = StringLower(StringMid($sFullPathExe, $iSlashPos + 1))
    
    ; Also get the active window class and title for matching
    Local $sPrimaryClass = StringLower(_WinAPI_GetClassName($hWnd))
    Local $sCurrentClass = StringLower(WinGetClassList($hWnd))
    Local $sCurrentTitle = WinGetTitle($hWnd)

    ; Read all section names from the apps definition file
    Local $aSections = IniReadSectionNames($sAppsIni)
    If @error Then
        ; Fallback profiles when files are missing
        Local $aFallback[3]
        If StringInStr($sCurrentExe, "cursor.exe") Or StringInStr($sCurrentExe, "autoit3.exe") Then
            $aFallback[0] = "Cursor"
            $aFallback[1] = "{HOME}+{END}^c"
            $aFallback[2] = ""
            Return $aFallback
        ElseIf StringInStr($sCurrentExe, "dopus.exe") Then
            $aFallback[0] = "DirectoryOpus"
            $aFallback[1] = ""
            $aFallback[2] = ""
            Return $aFallback
        EndIf
        
        $aFallback[0] = "Universal"
        $aFallback[1] = "{HOME}+{END}^c"
        $aFallback[2] = ""
        Return $aFallback
    EndIf

    ; Loop through all application profiles defined in apps.ini
    For $i = 1 To $aSections[0]
        Local $sSection = $aSections[$i]
        
        Local $sTargetClass = StringLower(IniRead($sAppsIni, $sSection, "class", ""))
        Local $sTargetExe   = StringLower(IniRead($sAppsIni, $sSection, "exe", ""))
        Local $sTargetTitle = IniRead($sAppsIni, $sSection, "title", "")
        Local $sMatchMode   = IniRead($sAppsIni, $sSection, "titlematchmode", "2")

        Local $bMatch = True

        ; If exe is defined, it must match
        If $sTargetExe <> "" And Not StringInStr($sCurrentExe, $sTargetExe) Then
            $bMatch = False
        EndIf

        ; If class is defined, it must match the primary class or be in the class list
        If $bMatch And $sTargetClass <> "" Then
            If $sPrimaryClass <> $sTargetClass And Not StringInStr($sCurrentClass, $sTargetClass) Then
                $bMatch = False
            EndIf
        EndIf

        ; If title is defined, it must match based on match mode
        If $bMatch And $sTargetTitle <> "" Then
            Local $bTitleMatch = False
            Select
                Case $sMatchMode == "1" ; Match from start
                    If StringLeft($sCurrentTitle, StringLen($sTargetTitle)) = $sTargetTitle Then $bTitleMatch = True
                Case $sMatchMode == "2" ; Substring match
                    If StringInStr($sCurrentTitle, $sTargetTitle) > 0 Then $bTitleMatch = True
                Case $sMatchMode == "3" ; Exact match
                    If $sCurrentTitle = $sTargetTitle Then $bTitleMatch = True
            EndSelect
            If Not $bTitleMatch Then $bMatch = False
        EndIf

        If $bMatch Then
            ; We found a matching window profile! Let's query its keys and scripts
            Local $sKeys = IniRead($sConfigIni, $sSection, "sendkeys", "")
            Local $sScript = IniRead($sConfigIni, $sSection, "script", "")

            ; Fallback defaults for Cursor if empty
            If $sSection == "Cursor" And $sKeys == "" Then $sKeys = "{HOME}+{END}^c"

            Local $aProfile[3]
            $aProfile[0] = $sSection
            $aProfile[1] = $sKeys
            $aProfile[2] = $sScript
            Return $aProfile
        EndIf
    Next

    ; Fallback default profile when no defined rules match the active window target
    Local $aDefault[3]
    $aDefault[0] = "Universal"
    $aDefault[1] = "{HOME}+{END}^c"
    $aDefault[2] = ""
    Return $aDefault
EndFunc

; modules\_config.au3
