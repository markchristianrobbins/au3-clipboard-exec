#include-once
#include <Array.au3>
#include <File.au3>
#include <StringConstants.au3>
#include "_ui.au3"

; Global tracking states for background periodic index sweeps
Global $g_aIndexQueue[0]
Global $g_oIndexMap = Null
Global $g_bIndexDirty = False
Global $g_iLastBatchTime = 0

; ==============================================================================
; Public API: Pre-loads the directory maps and existing indexed files/folders
; ==============================================================================
Func _Index_Initialize()
    If IsObj($g_oIndexMap) Then Return
    
    $g_oIndexMap = ObjCreate("Scripting.Dictionary")
    $g_oIndexMap.CompareMode = 1
    
    Local $sIndexFilePath = _Index_GetIndexPath()
    
    ; Auto-create index file if it does not exist so it is always present
    If Not FileExists($sIndexFilePath) Then
        Local $hFileNew = FileOpen($sIndexFilePath, 2) ; Overwrite/Create mode
        If $hFileNew <> -1 Then
            FileWrite($hFileNew, "")
            FileClose($hFileNew)
        EndIf
    EndIf
    
    If FileExists($sIndexFilePath) Then
        Local $hFile = FileOpen($sIndexFilePath, 0) ; Read mode
        If $hFile <> -1 Then
            While 1
                Local $sLine = StringStripWS(FileReadLine($hFile), 3)
                If @error Then ExitLoop
                If $sLine <> "" Then
                    If Not $g_oIndexMap.Exists($sLine) Then
                        $g_oIndexMap.Add($sLine, 1)
                    EndIf
                EndIf
            WEnd
            FileClose($hFile)
        EndIf
    EndIf
EndFunc

; ==============================================================================
; Public API: Performs a single light, non-blocking chunk crawl sweep over directories
; ==============================================================================
Func _Index_ProcessQueueBatch()
    _Index_Initialize()
    
    ; 1. Load config file coordinates
    Local $sConfigIni = "C:\$data\clipboard-exec.ini"
    If Not FileExists($sConfigIni) Then $sConfigIni = @ScriptDir & "\..\clipboard-exec.ini"
    If Not FileExists($sConfigIni) Then $sConfigIni = @ScriptDir & "\clipboard-exec.ini"
    If Not FileExists($sConfigIni) Then $sConfigIni = "clipboard-exec.ini"
    
    Local $sEnabled = IniRead($sConfigIni, "indexing", "enabled", "true")
    If StringLower($sEnabled) <> "true" Then Return
    
    Local $iInterval = Int(IniRead($sConfigIni, "indexing", "interval_ms", "15000"))
    If TimerDiff($g_iLastBatchTime) < $iInterval And $g_iLastBatchTime <> 0 Then Return
    $g_iLastBatchTime = TimerInit()
    
    Local $iBatchSize = Int(IniRead($sConfigIni, "indexing", "batch_size", "10"))
    Local $sIgnoreDirsStr = IniRead($sConfigIni, "indexing", "ignore_dirs", "node_modules;.git;.svn;dist;.next;build")
    Local $bIgnoreGuids = (StringLower(IniRead($sConfigIni, "indexing", "ignore_guids", "true")) == "true")
    Local $bIgnoreFiles = (StringLower(IniRead($sConfigIni, "indexing", "ignore_files", "true")) == "true")
    
    Local $aIgnoreDirs = StringSplit($sIgnoreDirsStr, ";")
    
    $g_bIndexDirty = False
    
    ; 2. If the scanner queue is currently empty, query sections and initialize root crawl states
    If UBound($g_aIndexQueue) == 0 Then
        Local $aRootSections = IniReadSection($sConfigIni, "index-paths")
        If Not @error Then
            For $i = 1 To $aRootSections[0][0]
                Local $sRoot = StringStripWS($aRootSections[$i][1], 3)
                $sRoot = StringRegExpReplace($sRoot, '^"|"$', '') ; Strip surrounding double quotes if any
                $sRoot = StringRegExpReplace($sRoot, "^'|'$", '') ; Strip single quotes
                If FileExists($sRoot) Then
                    _ArrayAdd($g_aIndexQueue, $sRoot)
                    ; Add root directory itself to the database index
                    If Not $g_oIndexMap.Exists($sRoot) Then
                        $g_oIndexMap.Add($sRoot, 1)
                        $g_bIndexDirty = True
                    EndIf
                EndIf
            Next
        EndIf
    EndIf
    
    If UBound($g_aIndexQueue) == 0 Then Return
    
    Local $iProcessed = 0
    
    While $iProcessed < $iBatchSize And UBound($g_aIndexQueue) > 0
        Local $sCurrentDir = $g_aIndexQueue[0]
        _ArrayDelete($g_aIndexQueue, 0)
        $iProcessed += 1
        
        If Not FileExists($sCurrentDir) Then ContinueLoop
        
        Local $hSearch = FileFindFirstFile($sCurrentDir & "\*.*")
        If $hSearch <> -1 Then
            While 1
                Local $sFileName = FileFindNextFile($hSearch)
                If @error Then ExitLoop
                
                ; Filter out system namespaces
                If $sFileName == "." Or $sFileName == ".." Then ContinueLoop
                
                Local $sFullPath = $sCurrentDir
                If StringRight($sFullPath, 1) <> "\" Then $sFullPath &= "\"
                $sFullPath &= $sFileName
                
                ; Detect file directory structures
                Local $bIsDir = StringInStr(FileGetAttrib($sFullPath), "D") > 0
                
                ; Validate ignores and bypass node_modules
                Local $bSkip = False
                If $bIsDir Then
                    For $j = 1 To $aIgnoreDirs[0]
                        If StringLower($sFileName) == StringLower($aIgnoreDirs[$j]) Then
                            $bSkip = True
                            ExitLoop
                        EndIf
                    Next
                Else
                    ; Ignore file entries if configure key demands folder tracking exclusively
                    If $bIgnoreFiles Then $bSkip = True
                Endif
                
                If $bSkip Then ContinueLoop
                
                ; GUID and Partial GUID file filters
                If $bIgnoreGuids Then
                    If _Index_IsGuidPattern($sFileName) Then ContinueLoop
                EndIf
                
                ; If directory, append to queue loops for structural recursion sweeps
                If $bIsDir Then
                    _ArrayAdd($g_aIndexQueue, $sFullPath)
                EndIf
                
                ; Store coordinates in system database register map if completely unique
                If Not $g_oIndexMap.Exists($sFullPath) Then
                    $g_oIndexMap.Add($sFullPath, 1)
                    $g_bIndexDirty = True
                EndIf
            WEnd
            FileClose($hSearch)
        EndIf
    WEnd
    
    ; 3. Write modified profiles back to standard index document
    If $g_bIndexDirty Then
        _Index_SaveIndexToDisk()
    EndIf
EndFunc

; ==============================================================================
; Public API: Returns the sorted physical array of all active indexed directories
; ==============================================================================
Func _Index_LoadIndexedPaths()
    _Index_Initialize()
    If Not IsObj($g_oIndexMap) Then
        Local $aEmpty[1] = [""]
        Return $aEmpty
    Endif
    If $g_oIndexMap.Count == 0 Then
        Local $aEmpty[1] = [""]
        Return $aEmpty
    Endif
    
    Local $aKeys = $g_oIndexMap.Keys()
    _ArraySort($aKeys)
    Return $aKeys
EndFunc

; ==============================================================================
; Private Helper: Checks for standard or partial GUID pattern matches
; ==============================================================================
Func _Index_IsGuidPattern($sFileName)
    ; Common GUID format, for example: 3f2504e0-4f89-11d3-9a0c-0305e82c3301 or 3f2504e0-4f89
    If StringRegExp($sFileName, "(?i)[0-9a-f]{4,12}-[0-9a-f]{4,8}-[0-9a-f]{4,8}") Then Return True
    If StringRegExp($sFileName, "(?i)[0-9a-f]{4,8}-[0-9a-f]{4,8}-[0-9a-f]{4,8}-[0-9a-f]{4,8}") Then Return True
    If StringRegExp($sFileName, "(?i)\{[0-9a-f\-]{8,36}\}") Then Return True
    Return False
EndFunc

; ==============================================================================
; Private Helper: Commits matching registers to local static index map on disk
; ==============================================================================
Func _Index_SaveIndexToDisk()
    If Not IsObj($g_oIndexMap) Then Return
    
    Local $aKeys = $g_oIndexMap.Keys()
    _ArraySort($aKeys)
    
    Local $sIndexFilePath = _Index_GetIndexPath()
    
    Local $hFile = FileOpen($sIndexFilePath, 2) ; Overwrite mode
    If $hFile <> -1 Then
        For $i = 0 To UBound($aKeys) - 1
            FileWriteLine($hFile, $aKeys[$i])
        Next
        FileClose($hFile)
    EndIf
EndFunc

; ==============================================================================
; Public API: Forces an on-demand complete recursive sweep across configured roots
; ==============================================================================
Func _Index_ForceReload()
    Local $sConfigIni = "C:\$data\clipboard-exec.ini"
    If Not FileExists($sConfigIni) Then $sConfigIni = @ScriptDir & "\..\clipboard-exec.ini"
    If Not FileExists($sConfigIni) Then $sConfigIni = @ScriptDir & "\clipboard-exec.ini"
    If Not FileExists($sConfigIni) Then $sConfigIni = "clipboard-exec.ini"
    
    Local $aRootSections = IniReadSection($sConfigIni, "index-paths")
    If @error Or Not IsArray($aRootSections) Then
        _UI_ShowToast("Index Reload", "No root index-paths configured in INI.")
        Return
    EndIf
    
    $g_oIndexMap = ObjCreate("Scripting.Dictionary")
    $g_oIndexMap.CompareMode = 1
    
    Local $sIgnoreDirsStr = IniRead($sConfigIni, "indexing", "ignore_dirs", "node_modules;.git;.svn;dist;.next;build")
    Local $aIgnoreDirs = StringSplit($sIgnoreDirsStr, ";")
    Local $bIgnoreGuids = (StringLower(IniRead($sConfigIni, "indexing", "ignore_guids", "true")) == "true")
    Local $bIgnoreFiles = (StringLower(IniRead($sConfigIni, "indexing", "ignore_files", "true")) == "true")
    
    Local $aQueue[10000]
    Local $iReadPtr = 0
    Local $iWritePtr = 0
    Local $iCount = 0
    
    For $i = 1 To $aRootSections[0][0]
        Local $sRoot = StringStripWS($aRootSections[$i][1], 3)
        $sRoot = StringRegExpReplace($sRoot, '^"|"$', '') ; Strip surrounding quotes if any
        $sRoot = StringRegExpReplace($sRoot, "^'|'$", '') ; Strip single quotes
        If $sRoot <> "" and FileExists($sRoot) Then
            $aQueue[$iWritePtr] = $sRoot
            $iWritePtr += 1
            If Not $g_oIndexMap.Exists($sRoot) Then
                $g_oIndexMap.Add($sRoot, 1)
                $iCount += 1
            EndIf
        EndIf
    Next
    
    If $iCount == 0 Then
        _UI_ShowToast("Index Reload", "No active root index-paths exist on disk.")
        Return
    EndIf
    
    Local $iMaxItems = 10000 ; Guard safety limit
    While $iReadPtr < $iWritePtr And $iCount < $iMaxItems
        Local $sCurrentDir = $aQueue[$iReadPtr]
        $iReadPtr += 1
        
        Local $sSearchPath = $sCurrentDir
        If StringRight($sSearchPath, 1) <> "\" Then $sSearchPath &= "\"
        
        Local $hSearch = FileFindFirstFile($sSearchPath & "*")
        If $hSearch <> -1 Then
            While 1
                Local $sFileName = FileFindNextFile($hSearch)
                If @error Then ExitLoop
                If $sFileName == "." Or $sFileName == ".." Then ContinueLoop
                
                Local $sFullPath = $sCurrentDir
                If StringRight($sFullPath, 1) <> "\" Then $sFullPath &= "\"
                $sFullPath &= $sFileName
                
                Local $sAttribs = FileGetAttrib($sFullPath)
                Local $bIsDir = StringInStr($sAttribs, "D") > 0
                
                Local $bSkip = False
                If $bIsDir Then
                    For $j = 1 To $aIgnoreDirs[0]
                        If StringLower($sFileName) == StringLower($aIgnoreDirs[$j]) Then
                            $bSkip = True
                            ExitLoop
                        EndIf
                    Next
                    If Not $bSkip And Not _Index_IsGuidPattern($sFileName) Then
                        If Not $g_oIndexMap.Exists($sFullPath) Then
                            $g_oIndexMap.Add($sFullPath, 1)
                            $iCount += 1
                            If $iWritePtr < 9990 Then ; Guard queue overflow
                                $aQueue[$iWritePtr] = $sFullPath
                                $iWritePtr += 1
                            EndIf
                        EndIf
                    EndIf
                Else
                    ; If not a directory, handle file index request
                    If Not $bIgnoreFiles Then
                        If $bIgnoreGuids And _Index_IsGuidPattern($sFileName) Then ContinueLoop
                        
                        If Not $g_oIndexMap.Exists($sFullPath) Then
                            $g_oIndexMap.Add($sFullPath, 1)
                            $iCount += 1
                        EndIf
                    EndIf
                EndIf
            WEnd
            FileClose($hSearch)
        EndIf
    WEnd
    
    _Index_SaveIndexToDisk()
    _UI_ShowToast("Index Reloaded", "Successfully crawled & saved " & $iCount & " directories to disk.")
EndFunc

; ==============================================================================
; Public API Helper: Locates clipboard-exec-index.txt directly next to clipboard-exec.au3
; ==============================================================================
Func _Index_GetIndexPath()
    Local $sDir = @ScriptDir
    If StringRight($sDir, 1) == "\" Then $sDir = StringTrimRight($sDir, 1)
    If Not FileExists($sDir & "\clipboard-exec.au3") Then
        If FileExists($sDir & "\..\clipboard-exec.au3") Then
            $sDir &= "\.."
        ElseIf FileExists($sDir & "\..\..\clipboard-exec.au3") Then
            $sDir &= "\..\.."
        EndIf
    EndIf
    Return $sDir & "\clipboard-exec-index.txt"
EndFunc


