#include-once
; ==============================================================================
; File: _picker_demo.au3
; Description: Demonstration file showing how to construct a list of mock paths and launch the Search Picker GUI with basic options.
; Functions:
;   - None (Demonstration script)
; ==============================================================================

#include <MsgBoxConstants.au3>
#include "_picker.au3"
#include "_index.au3"
#include "_handler_dopus.au3"

; Define some directories to populate the picker with.
Local $aSampleDirs[22] = [ _
    "C:\Projects", _
    "C:\Projects\Active", _
    "C:\Projects\Active\DirectoryOpus", _
    "C:\Projects\Active\AutoItScripts", _
    "C:\Projects\Archive", _
    "C:\Projects\Archive\OldWebsite", _
    "C:\Projects\Archive\DatabaseBackup", _
    "C:\Users\Username\Documents", _
    "C:\Users\Username\Documents\Invoices", _
    "C:\Users\Username\Documents\Personal", _
    "C:\Users\Username\Downloads", _
    "D:\Media", _
    "D:\Media\Movies", _
    "D:\Media\TV Shows", _
    "D:\Media\Music", _
    "D:\Media\Music\Rock", _
    "D:\Media\Music\Alternative", _
    "D:\Media\Music\Electronic", _
    "D:\Media\Photos", _
    "D:\Media\Photos\2026_Summer", _
    "C:\Windows\System32", _
    "C:\Program Files\Directory Opus" _
]

; Load real scanned indices from disk if they exist, fallback to preset mocks
_Index_Initialize()
Local $aAllMatches = _Index_LoadIndexedPaths()
If UBound($aAllMatches) == 0 Or (UBound($aAllMatches) == 1 And $aAllMatches[0] == "") Then
    $aAllMatches = $aSampleDirs
EndIf

; Show the GUI, passing in the list of paths, a custom window title, and empty default query.
Local $sResult = _Picker_ShowGUI($aAllMatches, "DIRECTORY OPUS - INTELLIGENT SEARCH PICKER", "")

If $sResult <> "" Then
    ; Open the selected path cleanly in Directory Opus
    _Handler_OpenInDOpus($sResult, "DIRECTORY_FULL")
Else
    _UI_ShowToast("Search Picker", "Selection cancelled or window closed.")
EndIf

; End of file: _picker_demo.au3
