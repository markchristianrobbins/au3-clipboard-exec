#include-once
#include <Array.au3>
#include <File.au3>
#include <StringConstants.au3>
#include "_ui.au3"
#include "_config.au3"

; Global tracking states for background periodic index sweeps
Global $g_aIndexQueue[0]
Global $g_oIndexMap = Null
Global $g_bIndexDirty = False
Global $g_iLastBatchTime = 0

; ==============================================================================
; Diagnostic Logger Helper: Appends timestamped trace logs directly under the tool workspace
; ==============================================================================
Func _Index_LogDiagnostic($sMsg)
    Local $sLogPath = StringReplace(_Index_GetIndexPath(), "clipboard-exec-index.txt", "clipboard-exec-diagnostics.txt")
    Local $hFile = FileOpen($sLogPath, 1) ; Append mode (creates file if not present)
    If $hFile <> -1 Then
        FileWriteLine($hFile, "[" & @YEAR & "-" & @MON & "-" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC & "] " & $sMsg)
        FileClose($hFile)
    EndIf
EndFunc

; ==============================================================================
; Public API: Pre-loads the directory maps and existing indexed files/folders
; ==============================================================================
Func _Index_Initialize()
    If IsObj($g_oIndexMap) Then Return
    
    $g_oIndexMap = ObjCreate("Scripting.Dictionary")
    $g_oIndexMap.CompareMode = 1
    
    Local $sIndexFilePath = _Index_GetIndexPath()
    _Index_LogDiagnostic("Initializing Index Map. Index DB Path: " & $sIndexFilePath)
    
    ; Auto-create index file if it does not exist so it is always present
    If Not FileExists($sIndexFilePath) Then
        _Index_LogDiagnostic("Index database not found. Creating empty database file.")
        Local $hFileNew = FileOpen($sIndexFilePath, 2) ; Overwrite/Create mode
        If $hFileNew <> -1 Then
            FileWrite($hFileNew, "")
            FileClose($hFileNew)
            _Index_LogDiagnostic("Successfully created empty database file.")
        Else
            _Index_LogDiagnostic("FAILED to create empty database file: FileOpen returned -1. @error=" & @error)
        EndIf
    EndIf
    
    If FileExists($sIndexFilePath) Then
        Local $hFile = FileOpen($sIndexFilePath, 0) ; Read mode
        If $hFile <> -1 Then
            Local $iLinesRead = 0
            While 1
                Local $sLine = StringStripWS(FileReadLine($hFile), 3)
                If @error Then ExitLoop
                If $sLine <> "" Then
                    If Not $g_oIndexMap.Exists($sLine) Then
                        $g_oIndexMap.Add($sLine, 1)
                        $iLinesRead += 1
                    EndIf
                EndIf
            WEnd
            FileClose($hFile)
            _Index_LogDiagnostic("Loaded " & $iLinesRead & " existing entries from db file.")
        Else
            _Index_LogDiagnostic("FAILED to open index database in read mode: FileOpen returned -1. @error=" & @error)
        EndIf
    Else
        _Index_LogDiagnostic("Index database file STILL does not exist after creation check.")
    EndIf
EndFunc

; ==============================================================================
; Public API: Performs a single light, non-blocking chunk crawl sweep over directories
; ==============================================================================
Func _Index_ProcessQueueBatch()
    _Index_Initialize()
    
    Local $sConfigIni = _Config_GetIniPath()
    
    Local $sEnabled = IniRead($sConfigIni, "indexing", "enabled", "true")
    If StringLower($sEnabled) <> "true" Then Return
    
    Local $iInterval = Int(IniRead($sConfigIni, "indexing", "interval_ms", "15000"))
    If TimerDiff($g_iLastBatchTime) < $iInterval And $g_iLastBatchTime <> 0 Then Return
    $g_iLastBatchTime = TimerInit()
    
    _Index_LogDiagnostic("------------------ BATCH PROCESS START ------------------")
    _Index_LogDiagnostic("Resolved CONFIG INI: " & $sConfigIni)
    
    Local $iBatchSize = Int(IniRead($sConfigIni, "indexing", "batch_size", "10"))
    Local $sIgnoreDirsStr = IniRead($sConfigIni, "indexing", "ignore_dirs", "node_modules;.git;.svn;dist;.next;build")
    Local $bIgnoreGuids = (StringLower(IniRead($sConfigIni, "indexing", "ignore_guids", "true")) == "true")
    Local $bIgnoreFiles = (StringLower(IniRead($sConfigIni, "indexing", "ignore_files", "true")) == "true")
    
    Local $aIgnoreDirs = StringSplit($sIgnoreDirsStr, ";")
    
    $g_bIndexDirty = False
    
    ; 2. If the scanner queue is currently empty, query sections and initialize root crawl states
    If UBound($g_aIndexQueue) == 0 Then
        _Index_LogDiagnostic("Queue is empty. Loading roots for new crawl...")
        Local $aRootSections = IniReadSection($sConfigIni, "index-paths")
        If Not @error Then
            For $i = 1 To $aRootSections[0][0]
                Local $sRoot = StringStripWS($aRootSections[$i][1], 3)
                $sRoot = StringRegExpReplace($sRoot, '^"|"$', '') ; Strip surrounding double quotes if any
                $sRoot = StringRegExpReplace($sRoot, "^'|'$", '') ; Strip single quotes
                _Index_LogDiagnostic("Configured root -> key=" & $aRootSections[$i][0] & ", val=" & $sRoot & ", exists=" & FileExists($sRoot))
                If FileExists($sRoot) Then
                    _ArrayAdd($g_aIndexQueue, $sRoot)
                    ; Add root directory itself to the database index
                    If Not $g_oIndexMap.Exists($sRoot) Then
                        $g_oIndexMap.Add($sRoot, 1)
                        $g_bIndexDirty = True
                        _Index_LogDiagnostic("  Added root to index map: " & $sRoot)
                    EndIf
                EndIf
            Next
        Else
            _Index_LogDiagnostic("  ERROR reading 'index-paths' INI section.")
        EndIf
    EndIf
    
    Local $iQueueSize = UBound($g_aIndexQueue)
    _Index_LogDiagnostic("Queue contains " & $iQueueSize & " directories pending crawl.")
    If $iQueueSize == 0 Then
        _Index_LogDiagnostic("------------------ BATCH PROCESS END (No Queue) ------------------")
        Return
    EndIf
    
    Local $iProcessed = 0
    Local $iPathsAdded = 0
    
    While $iProcessed < $iBatchSize And UBound($g_aIndexQueue) > 0
        Local $sCurrentDir = $g_aIndexQueue[0]
        _ArrayDelete($g_aIndexQueue, 0)
        $iProcessed += 1
        
        _Index_LogDiagnostic("  Processing batch step [" & $iProcessed & "]: " & $sCurrentDir)
        If Not FileExists($sCurrentDir) Then
            _Index_LogDiagnostic("    Directory no longer exists: " & $sCurrentDir)
            ContinueLoop
        EndIf
        
        Local $hSearch = FileFindFirstFile($sCurrentDir & "\*.*")
        If $hSearch == -1 Then
            _Index_LogDiagnostic("    FileFindFirstFile returned -1. @error=" & @error)
            ContinueLoop
        EndIf
        
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
            Endif
            
            ; If directory, append to queue loops for structural recursion sweeps
            If $bIsDir Then
                _ArrayAdd($g_aIndexQueue, $sFullPath)
            EndIf
            
            ; Store coordinates in system database register map if completely unique
            If Not $g_oIndexMap.Exists($sFullPath) Then
                $g_oIndexMap.Add($sFullPath, 1)
                $g_bIndexDirty = True
                $iPathsAdded += 1
            EndIf
        WEnd
        FileClose($hSearch)
    WEnd
    
    _Index_LogDiagnostic("Batch step complete. Processed=" & $iProcessed & ", Queue remaining=" & UBound($g_aIndexQueue) & ", Unique paths added=" & $iPathsAdded & ", Dirty=" & $g_bIndexDirty)
    
    ; 3. Write modified profiles back to standard index document
    If $g_bIndexDirty Then
        _Index_SaveIndexToDisk()
    EndIf
    _Index_LogDiagnostic("------------------ BATCH PROCESS END ------------------")
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
    If Not IsObj($g_oIndexMap) Then
        _Index_LogDiagnostic("SaveIndexToDisk aborted: IndexMap is not an object.")
        Return
    EndIf
    
    Local $aKeys = $g_oIndexMap.Keys()
    _ArraySort($aKeys)
    
    Local $sIndexFilePath = _Index_GetIndexPath()
    _Index_LogDiagnostic("Saving index database to disk. Entries count: " & UBound($aKeys) & ", Path: " & $sIndexFilePath)
    
    Local $hFile = FileOpen($sIndexFilePath, 2) ; Overwrite mode
    If $hFile <> -1 Then
        Local $iWritten = 0
        For $i = 0 To UBound($aKeys) - 1
            FileWriteLine($hFile, $aKeys[$i])
            $iWritten += 1
        Next
        FileClose($hFile)
        _Index_LogDiagnostic("Saved " & $iWritten & " lines to index database successfully.")
    Else
        _Index_LogDiagnostic("FAILED to save index database: FileOpen returned -1. @error=" & @error)
    EndIf
EndFunc

; ==============================================================================
; Public API: Forces an on-demand complete recursive sweep across configured roots
; ==============================================================================
Func _Index_ForceReload()
    _Index_Initialize()
    _Index_LogDiagnostic("================== FORCE RELOAD START ==================")
    
    Local $sConfigIni = _Config_GetIniPath()
    
    _Index_LogDiagnostic("Resolved CONFIG INI Path: " & $sConfigIni)
    If Not FileExists($sConfigIni) Then
        _Index_LogDiagnostic("CRITICAL CONFIG ERROR: Configuration INI file does not exist anywhere!")
        _UI_ShowToast("Index Reload", "Configuration INI file not found.")
        Return
    EndIf
    
    Local $aRootSections = IniReadSection($sConfigIni, "index-paths")
    If @error Or Not IsArray($aRootSections) Then
        _Index_LogDiagnostic("CRITICAL CONFIG ERROR: 'index-paths' section is missing or empty in Config INI. @error=" & @error)
        _UI_ShowToast("Index Reload", "No root index-paths configured in INI.")
        Return
    EndIf
    
    _Index_LogDiagnostic("Found " & $aRootSections[0][0] & " entries in 'index-paths' section of INI.")
    
    $g_oIndexMap = ObjCreate("Scripting.Dictionary")
    $g_oIndexMap.CompareMode = 1
    
    Local $sIgnoreDirsStr = IniRead($sConfigIni, "indexing", "ignore_dirs", "node_modules;.git;.svn;dist;.next;build")
    Local $aIgnoreDirs = StringSplit($sIgnoreDirsStr, ";")
    Local $bIgnoreGuids = (StringLower(IniRead($sConfigIni, "indexing", "ignore_guids", "true")) == "true")
    Local $bIgnoreFiles = (StringLower(IniRead($sConfigIni, "indexing", "ignore_files", "true")) == "true")
    
    _Index_LogDiagnostic("Crawl Settings -> ignore_dirs: " & $sIgnoreDirsStr & ", ignore_guids: " & $bIgnoreGuids & ", ignore_files: " & $bIgnoreFiles)
    
    Local $aQueue[10000]
    Local $iReadPtr = 0
    Local $iWritePtr = 0
    Local $iCount = 0
    
    For $i = 1 To $aRootSections[0][0]
        Local $sKeyName = $aRootSections[$i][0]
        Local $sRoot = StringStripWS($aRootSections[$i][1], 3)
        $sRoot = StringRegExpReplace($sRoot, '^"|"$', '') ; Strip surrounding quotes if any
        $sRoot = StringRegExpReplace($sRoot, "^'|'$", '') ; Strip single quotes
        _Index_LogDiagnostic("Checking configured root path: key=" & $sKeyName & ", value=" & $sRoot)
        
        Local $bExists = FileExists($sRoot)
        Local $sAttrs = FileGetAttrib($sRoot)
        _Index_LogDiagnostic("Root stats -> FileExists=" & $bExists & ", FileGetAttrib=" & $sAttrs)
        
        If $bExists Then
            $aQueue[$iWritePtr] = $sRoot
            $iWritePtr += 1
            If Not $g_oIndexMap.Exists($sRoot) Then
                $g_oIndexMap.Add($sRoot, 1)
                $iCount += 1
                _Index_LogDiagnostic("Added root to queue: " & $sRoot)
            EndIf
        Else
            _Index_LogDiagnostic("SKIPPED root (does not exist on disk): " & $sRoot)
        EndIf
    Next
    
    If $iCount == 0 Then
        _Index_LogDiagnostic("CRITICAL: No active root index-paths exist on disk. Crawl aborted.")
        _UI_ShowToast("Index Reload", "No active root index-paths exist on disk.")
        Return
    EndIf
    
    _Index_LogDiagnostic("Crawler Queue initialized with " & $iWritePtr & " roots. Starting BFS sweep...")
    
    Local $iMaxItems = 10000 ; Guard safety limit
    While $iReadPtr < $iWritePtr And $iCount < $iMaxItems
        Local $sCurrentDir = $aQueue[$iReadPtr]
        $iReadPtr += 1
        
        Local $sSearchPath = $sCurrentDir
        If StringRight($sSearchPath, 1) <> "\" Then $sSearchPath &= "\"
        
        _Index_LogDiagnostic("Crawling directory [" & $iReadPtr & " / " & $iWritePtr & "]: " & $sCurrentDir)
        
        Local $hSearch = FileFindFirstFile($sSearchPath & "*.*")
        If $hSearch == -1 Then
            _Index_LogDiagnostic("  FileFindFirstFile returned -1 for path: " & $sSearchPath & "*.*. @error=" & @error)
            ; Try fallback search design
            $hSearch = FileFindFirstFile($sSearchPath & "*")
            If $hSearch == -1 Then
                _Index_LogDiagnostic("  Fallback * search also failed for: " & $sSearchPath & "*. @error=" & @error)
                ContinueLoop
            Else
                _Index_LogDiagnostic("  Fallback * search succeeded for: " & $sSearchPath & "*")
            EndIf
        EndIf
        
        Local $iCountInDir = 0
        While 1
            Local $sFileName = FileFindNextFile($hSearch)
            If @error Then ExitLoop
            If $sFileName == "." Or $sFileName == ".." Then ContinueLoop
            
            $iCountInDir += 1
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
                If $bSkip Then
                    _Index_LogDiagnostic("    Skipped directory (match ignore_dir): " & $sFileName)
                ElseIf _Index_IsGuidPattern($sFileName) Then
                    _Index_LogDiagnostic("    Skipped directory (match guid): " & $sFileName)
                    $bSkip = True
                EndIf
                
                If Not $bSkip Then
                    If Not $g_oIndexMap.Exists($sFullPath) Then
                        $g_oIndexMap.Add($sFullPath, 1)
                        $iCount += 1
                        If $iWritePtr < 9990 Then ; Guard queue overflow
                            $aQueue[$iWritePtr] = $sFullPath
                            $iWritePtr += 1
                        Else
                            _Index_LogDiagnostic("    WARNING: Queue overflow threshold reached (9990 items). Cannot append " & $sFullPath)
                        EndIf
                    EndIf
                EndIf
            Else
                ; If not a directory, handle file index request
                If Not $bIgnoreFiles Then
                    If $bIgnoreGuids And _Index_IsGuidPattern($sFileName) Then 
                        $bSkip = True
                    Endif
                    
                    If Not $bSkip Then
                        If Not $g_oIndexMap.Exists($sFullPath) Then
                            $g_oIndexMap.Add($sFullPath, 1)
                            $iCount += 1
                        Endif
                    Endif
                EndIf
            EndIf
        WEnd
        FileClose($hSearch)
        _Index_LogDiagnostic("  Crawled " & $iCountInDir & " items under " & $sCurrentDir)
    WEnd
    
    _Index_LogDiagnostic("BFS Crawl Complete. Found total unique entries: " & $iCount)
    _Index_SaveIndexToDisk()
    _Index_LogDiagnostic("================== FORCE RELOAD END ==================")
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
    Return _PathFull($sDir & "\clipboard-exec-index.txt")
EndFunc
