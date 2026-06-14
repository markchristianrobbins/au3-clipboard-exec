#include-once
; ==============================================================================
; File: _picker_demo.au3
; Description: Demonstration file showing how to construct a list of mock paths and launch the Search Picker GUI with basic options.
; Functions:
;   - None (Demonstration script)
; ==============================================================================

#include <MsgBoxConstants.au3>
#include "_picker.au3"

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

; Show the GUI, passing in the list of paths, a custom window title, and an optional initial search query.
Local $sResult = _Picker_ShowGUI($aSampleDirs, "DIRECTORY OPUS - QUICK PICKER DEMO", "Music")

If $sResult <> "" Then
    MsgBox($MB_ICONINFORMATION, "Selection Complete", "You selected:" & @CRLF & $sResult)
Else
    MsgBox($MB_ICONWARNING, "Selection Cancelled", "No directory was selected (GUI closed or cancelled).")
EndIf

; End of file: _picker_demo.au3
