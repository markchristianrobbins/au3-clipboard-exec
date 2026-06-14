#include-once
; ==============================================================================
; File: _picker_globals.au3
; Description: Defines all global state variables and GUI element handles.
; Functions:
;   - None (Global variables definition file)
; ==============================================================================


; Global handles used globally across modular helper files
Global $g_hPickerGUI = 0
Global $g_hInputField = 0
Global $g_hNoResults = 0
Global $g_hStatusText = 0
Global $g_hStatusBg = 0
Global $g_hBorderL = 0
Global $g_hBorderR = 0
Global $g_hBorderB = 0
Global $g_hRowFocusL = 0
Global $g_hRowFocusR = 0
Global $g_hRowFocusT = 0
Global $g_hRowFocusB = 0

Global $g_aRowIcon = 0
Global $g_aRowIdxCtrl = 0
Global $g_aRowBorder = 0
Global $g_aRowBg = 0
Global $g_aRowPre = 0
Global $g_aRowMatch = 0
Global $g_aRowPost = 0
Global $g_aRowPath = 0
Global $g_aRowDepthInfo = 0

; Dynamic state coordinates
Global $g_sSelectedPath = ""
Global $g_bHasBeenActive = False
Global $g_sLastQuery = "|||"
Global $g_iLastMouseX = -1
Global $g_iLastMouseY = -1
Global $g_aFilteredPaths[1] = [""]
Global $g_iDisplayCount = 0
Global $g_iSelectedIndex = 0
Global $g_iScrollOffset = 0
Global $g_iRecentCount = 0
Global $g_bExploreMode = False
Global $g_sExploreDir = ""
Global $g_aActiveBasePaths[1] = [""]
Global $g_bRestoringState = False
Global $g_sSavedQueryText = ""
Global $g_iSavedSelectedIndex = 0
Global $g_iSavedScrollOffset = 0

; Accelerator handles
Global $g_hDUp = 0
Global $g_hDDown = 0
Global $g_hDPgUp = 0
Global $g_hDPgDn = 0
Global $g_hDHome = 0
Global $g_hDEnd = 0
Global $g_hDEnter = 0
Global $g_hDCtrlEnter = 0
Global $g_hDEscape = 0
Global $g_hDBackspace = 0
Global $g_hDCtrlBS = 0
Global $g_hDCopy = 0

; End of file: _picker_globals.au3
