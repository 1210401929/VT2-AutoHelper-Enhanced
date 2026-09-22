/*
===============================================================================
AutoHelper - Vermintide 2 Automation Script
===============================================================================
Original author: ChadMasodin
Base version: 2.3
Enhanced version: 1.0.0
Language: Multilingual (Default: Chinese-Simplified)
Date: 29/12/2025
Description: Automated script for routine processes in Vermintide 2
===============================================================================
*/

; ============================================================================
; INITIALIZATION AND SETTINGS
; ============================================================================

#NoEnv
#SingleInstance Force
SetBatchLines -1
ListLines Off
SetMouseDelay, -1
CoordMode, Mouse, Screen
SetTitleMatchMode, 2
SetControlDelay, -1
DetectHiddenWindows, On
SetStoreCapsLockMode, Off

; ============================================================================
; CONSTANTS
; ============================================================================

global BASE_VERSION := "2.3"
global ENHANCED_VERSION := "1.0.0"
global VERSION := "2.3 / Enhanced 1.0.0"
global DELAY_SHORT := 100
global DELAY_MEDIUM := 300
global DELAY_LONG := 500
global DELAY_ANIMATION := 1500

; ============================================================================
; GLOBAL VARIABLES - COORDINATES
; ============================================================================

global X1 := "", Y1 := ""  ; White button
global X2 := "", Y2 := ""  ; Green button
global X3 := "", Y3 := ""  ; Blue button
global X4 := "", Y4 := ""  ; Yellow button
global X5 := "", Y5 := ""  ; Atanor button
global X6 := "", Y6 := ""  ; Button
global X7 := "", Y7 := ""  ; AfterReroll

global OCR_X := "", OCR_Y := "", OCR_W := "", OCR_H := ""

; ============================================================================
; GLOBAL VARIABLES - SCRIPT STATE
; ============================================================================

global Stop := 0
global Target_Window := ""
global LoopCount := ""
global SelectedProperties := ""
global savedPreset := ""
global RequireTargetValues := 0
global TargetValue1 := ""
global TargetValue2 := ""
global RerollInProgress := false
global TargetProperty1Id := ""
global TargetProperty2Id := ""
global TargetProperty1Display := ""
global TargetProperty2Display := ""
global AutoMaxTargetValues := 0
global OCRTestSucceeded := 0
global ConfirmBeforeReroll := 1
global OnboardingCompleted := 0
global RunStatusText := ""

; ============================================================================
; GLOBAL VARIABLES - LOCALIZATION
; ============================================================================

global CurrentLanguage := "Chinese-Simplified"
global RecognitionLanguage := "English"
global OCR_Language := "eng"
global SupportedLanguages := "English|French|Italian|German|Spanish|Polish|Portuguese-Brazil|Russian|Chinese-Simplified"
global SupportedRecognitionLanguages := "English|Chinese-Simplified"
global PropertyCatalog := {}
global PropertyDisplayToId := {}

; Language Codes Map for Tesseract
global LangCodes := {}
LangCodes["English"] := "eng"
LangCodes["French"] := "fra"
LangCodes["Italian"] := "ita"
LangCodes["German"] := "deu_latf"
LangCodes["Spanish"] := "spa"
LangCodes["Polish"] := "pol"
LangCodes["Portuguese-Brazil"] := "por"
LangCodes["Russian"] := "rus"
LangCodes["Chinese-Simplified"] := "chi_sim"

; UI Strings Variables (Global declaration)
global TXT_LangLabel, TXT_PresetList, TXT_PresetBuiltInNewUI, TXT_PresetBuiltInOldUI
global TXT_Save, TXT_Delete, TXT_SettingsTitle
global TXT_PosAtanor, TXT_Set, TXT_PosSalvage, TXT_SalvageBtn
global TXT_White, TXT_Blue, TXT_Green, TXT_Yellow
global TXT_AreaProps, TXT_SelectArea, TXT_BtnTestOCR, TXT_PosRerollOld, TXT_LoopLimit
global TXT_MatchPropertyValues, TXT_TargetValue1, TXT_TargetValue2
global TXT_SetTargetWin, TXT_BtnGroup
global TXT_BtnOpenChests, TXT_BtnSalvage, TXT_BtnAtanor, TXT_BtnSalvageRed
global TXT_BtnReroll, TXT_BtnInfo, TXT_BtnStop, TXT_BtnRestart
global TXT_RecognitionLanguage
global TXT_RecommendedTitle, TXT_RecommendedText, TXT_WorkflowTitle
global TXT_TargetProperty1, TXT_TargetProperty2, TXT_AutoMaxTarget, TXT_StartSelectedReroll, TXT_SelectFixedPair
global TXT_ConfigStatusTitle, TXT_RunStatusTitle, TXT_StatusReady, TXT_StatusIncomplete
global TXT_StatusWindow, TXT_StatusArea, TXT_StatusButton, TXT_StatusRecognition, TXT_StatusOCR, TXT_StatusTargets
global TXT_StatusSet, TXT_StatusNotSet, TXT_StatusTested, TXT_StatusNotTested, TXT_StatusSelected
global TXT_ConfirmBeforeReroll, TXT_OCRSafetyWarning, TXT_StartConfirmation
global TXT_OnboardingWelcome, TXT_OnboardingWindow, TXT_OnboardingArea, TXT_OnboardingOCR, TXT_OnboardingDone
global TXT_Info_Source, TXT_Info_OriginalAuthor, TXT_Info_EnhancedAuthor, TXT_Info_Versions

; OCR Debug Window Variables
global TXT_OCRDebugTitle, TXT_OCRRawHeader, TXT_OCRParsedHeader, TXT_OCRLanguage, TXT_OCRRuntime
global TXT_OCRTargetWindow, TXT_OCRArea, TXT_OCRScreen, TXT_OCRDpi, TXT_OCRDebugFiles
global TXT_OCRRecognizedCount, TXT_OCRProperty, TXT_OCRName, TXT_OCRCurrent
global TXT_OCRMin, TXT_OCRMax, TXT_OCRIsMax, TXT_Yes, TXT_No, TXT_Unknown
global TXT_OCRParseFailures, TXT_OCRReason, TXT_OCRNoText, TXT_OCRTestFailed
global TXT_OCRTestRunning, TXT_OCRTestBusy
global TXT_OCRTargetUnavailable, TXT_OCRTargetActivationFailed

; Messages & Tooltips Variables
global TXT_Msg_TargetWinNotSet, TXT_Msg_CoordNotSet, TXT_Msg_AreaNotSet
global TXT_Msg_BtnNotSet, TXT_Msg_InvalidTargetValues, TXT_Msg_DeleteConfirm, TXT_Msg_PresetDeleted
global TXT_Msg_SelectTwoProperties
global TXT_SB_EnterName, TXT_SB_Saved, TXT_SB_Deleted, TXT_SB_SelectDelete, TXT_SB_HotkeysSaved
global TXT_SB_BuiltinReadOnly
global TXT_Tip_Paused, TXT_Tip_Opening, TXT_Tip_Salvaging, TXT_Tip_SalvagingRed
global TXT_Tip_Upgrading, TXT_Tip_ClickSelect, TXT_Tip_DoubleClick, TXT_Tip_HoldLMB
global TXT_Tip_Selection, TXT_Tip_Selection2, TXT_Tip_AreaSmall, TXT_Tip_AreaSet, TXT_Tip_RerollStart
global TXT_Tip_Recognized, TXT_Tip_Found, TXT_Tip_Rerolling, TXT_Tip_Current, TXT_Tip_Cycle

; Info Window Variables
global TXT_Info_Author, TXT_Info_Release, TXT_Info_Update, TXT_Info_Desc, TXT_Info_RerollCredit
global TXT_Info_Link, TXT_Info_Hotkeys
global TXT_HK_Stop, TXT_HK_Pause, TXT_HK_Restart, TXT_HK_OpenChests
global TXT_HK_Salvage, TXT_HK_SalvageRed, TXT_HK_Reroll, TXT_HK_Atanor, TXT_HK_Close

; ============================================================================
; GLOBAL VARIABLES - HOTKEYS
; ============================================================================

global Stop_key := "Numpad1"
global Pause_key := "Numpad2"
global Reset_key := "Numpad3"
global OpenChests_key := "Numpad4"
global Salvage_items_key := "Numpad5"
global Salvage_red_items_key := "Numpad6"
global Reroll_Properties_key := "Numpad7"
global Atanor_key := "Numpad8"
global Close_script_key := "Numpad9"

; ============================================================================
; APPLICATION PATHS
; ============================================================================

RegExMatch(A_ScriptName, "^(.*?)\.", match)
global basename1 := match
global WINTITLE := "AutoHelper Enhanced " . ENHANCED_VERSION . " (Base " . BASE_VERSION . ")"

global presetsDir := A_ScriptDir
global presetFile := presetsDir "\presets.ini"
global builtInNewPresetFile := presetsDir "\Presets\FOR NEW UI\presets.ini"
global builtInOldPresetFile := presetsDir "\Presets\FOR OLD UI\presets.ini"
global PresetCatalog := {}
global LangDir := A_ScriptDir "\Languages"
global OCRBinDir := ""

; ============================================================================
; LIBRARY INCLUDES
; ============================================================================

#include <Vis2>
#include <PropertyValueMatcher>
#include <PropertyCatalog>
#include <OCRDebug>

; ============================================================================
; INITIALIZATION FLOW
; ============================================================================

ConfigureOCRRuntime()
InitializePropertyCatalog()
LoadSettings()
LoadStrings()
BuildMenu()
GoSub, CreateGUI
return

; ============================================================================
; LOCALIZATION FUNCTIONS
; ============================================================================

LoadSettings() {
    global presetFile, CurrentLanguage, RecognitionLanguage, OCR_Language, LangCodes
    global AutoMaxTargetValues, OCRTestSucceeded, ConfirmBeforeReroll
    global OnboardingCompleted, TargetProperty1Id, TargetProperty2Id

    ; New installations use a Chinese UI with English game/OCR recognition.
    ; A legacy Language key migrates only to the UI language and never changes
    ; the recognition language.
    IniRead, uiLanguage, %presetFile%, Settings, UILanguage, __MISSING__
    if (uiLanguage = "__MISSING__") {
        IniRead, uiLanguage, %presetFile%, Settings, Language, Chinese-Simplified
        IniWrite, %uiLanguage%, %presetFile%, Settings, UILanguage
    }
    CurrentLanguage := uiLanguage

    IniRead, gameLanguage, %presetFile%, Settings, GameLanguage, __MISSING__
    if (gameLanguage = "__MISSING__") {
        IniRead, gameLanguage, %presetFile%, Settings, OCRLanguage, English
        if (gameLanguage = "eng" || gameLanguage = "chi_sim")
            gameLanguage := (gameLanguage = "chi_sim") ? "Chinese-Simplified" : "English"
    }
    if (gameLanguage != "English" && gameLanguage != "Chinese-Simplified")
        gameLanguage := "English"
    RecognitionLanguage := gameLanguage
    IniWrite, %RecognitionLanguage%, %presetFile%, Settings, GameLanguage
    IniWrite, %RecognitionLanguage%, %presetFile%, Settings, OCRLanguage

    IniRead, ConfirmBeforeReroll, %presetFile%, Settings, ConfirmBeforeReroll, 1
    IniRead, OnboardingCompleted, %presetFile%, Settings, OnboardingCompleted, 0
    IniRead, OCRTestSucceeded, %presetFile%, Settings, OCRTestSucceeded, 0
    IniRead, AutoMaxTargetValues, %presetFile%, Settings, AutoMaxTargetValues, 0
    IniRead, TargetProperty1Id, %presetFile%, Settings, TargetProperty1, __MISSING__
    IniRead, TargetProperty2Id, %presetFile%, Settings, TargetProperty2, __MISSING__
    if (TargetProperty1Id = "__MISSING__")
        TargetProperty1Id := ""
    if (TargetProperty2Id = "__MISSING__")
        TargetProperty2Id := ""

    ; Validate Language Folder
    if (CurrentLanguage != "English") {
        targetDir := LangDir "\" CurrentLanguage
        if (!FileExist(targetDir)) {
            Gui, +OwnDialogs
            MsgBox, 262192, Error, Language folder for '%CurrentLanguage%' not found!`nPath: %targetDir%`n`nReverting to English.
            CurrentLanguage := "English"
            IniWrite, English, %presetFile%, Settings, Language
            IniWrite, English, %presetFile%, Settings, UILanguage
        }
    }

    if (LangCodes.HasKey(RecognitionLanguage))
        OCR_Language := LangCodes[RecognitionLanguage]
    else
        OCR_Language := "eng"
}

GetLanguageIndex(language, languageList := "") {
    global SupportedLanguages

    if (languageList = "")
        languageList := SupportedLanguages

    Loop, Parse, languageList, |
    {
        if (A_LoopField = language)
            return A_Index
    }

    return 1
}

LoadStrings() {
    global

    ; --- ENGLISH DEFAULTS (Fallback) ---
    TXT_LangLabel := "Language:"
    TXT_PresetList := "Preset:"
    TXT_PresetBuiltInNewUI := "Built-in NEW UI"
    TXT_PresetBuiltInOldUI := "Built-in OLD UI"
    TXT_Save := "Save"
    TXT_Delete := "Delete"
    TXT_SettingsTitle := "Settings"
    TXT_PosAtanor := "#1 Athanor upgrade button position:"
    TXT_Set := "Set"
    TXT_PosSalvage := "#2 Item salvage button positions:"
    TXT_SalvageBtn := "Salvage Button"
    TXT_White := "White"
    TXT_Blue := "Blue"
    TXT_Green := "Green"
    TXT_Yellow := "Yellow"
    TXT_AreaProps := "#3 Item properties area:"
    TXT_SelectArea := "Select area"
    TXT_BtnTestOCR := "Test current item recognition"
    TXT_PosRerollOld := "#4 Item slot position after reroll (FOR OLD UI):"
    TXT_LoopLimit := "Loop Limiter:"
    TXT_MatchPropertyValues := "Match Property Values"
    TXT_TargetValue1 := "Target 1:"
    TXT_TargetValue2 := "Target 2:"
    TXT_SetTargetWin := "Set Window:"
    TXT_BtnGroup := "Buttons"
    TXT_BtnOpenChests := "OPEN CHESTS"
    TXT_BtnSalvage := "SALVAGE ITEMS"
    TXT_BtnAtanor := "UPGRADE ATHANOR"
    TXT_BtnSalvageRed := "SALVAGE RED ITEMS"
    TXT_BtnReroll := "REROLL PROPERTIES"
    TXT_BtnInfo := "<><><> HOTKEYS AND INFO <><><>"
    TXT_BtnStop := "STOP"
    TXT_BtnRestart := "RESTART"

    ; Beginner / language-independent workflow
    TXT_RecognitionLanguage := "Game recognition language:"
    TXT_RecommendedTitle := "Recommended settings"
    TXT_RecommendedText := "Game language: English    Display mode: Borderless Window`nThe application UI may stay in Chinese; English game recognition is independent."
    TXT_WorkflowTitle := "Property reroll settings"
    TXT_TargetProperty1 := "Target property 1:"
    TXT_TargetProperty2 := "Target property 2:"
    TXT_AutoMaxTarget := "Automatically require the maximum value shown in the property range"
    TXT_StartSelectedReroll := "START PROPERTY REROLL"
    TXT_SelectFixedPair := "Choose the item type, then choose one of its valid property pairs. Target value 1 / 2 follow the pair order."
    TXT_ConfigStatusTitle := "Configuration status"
    TXT_RunStatusTitle := "Current run"
    TXT_StatusReady := "Status: Ready to start"
    TXT_StatusIncomplete := "Status: Complete the missing setup first"
    TXT_StatusWindow := "Game window:"
    TXT_StatusArea := "Property area:"
    TXT_StatusButton := "Reroll button:"
    TXT_StatusRecognition := "Recognition language:"
    TXT_StatusOCR := "OCR status:"
    TXT_StatusTargets := "Target properties:"
    TXT_StatusSet := "Set [OK]"
    TXT_StatusNotSet := "Not set [!]"
    TXT_StatusTested := "Tested [OK]"
    TXT_StatusNotTested := "Not tested [!]"
    TXT_StatusSelected := "Selected [OK]"
    TXT_ConfirmBeforeReroll := "Confirm before starting reroll"
    TXT_OCRSafetyWarning := "OCR has not been tested successfully.`n`nIt is recommended to click 'Test current item recognition' first.`nContinue anyway?"
    TXT_StartConfirmation := "The automatic property reroll is about to start."
    TXT_OnboardingWelcome := "Welcome to VT2 AutoHelper Enhanced.`n`nBefore starting:`n1. Set Vermintide 2 language to English.`n2. Use Borderless Window mode if possible.`n3. Keep a stable game resolution.`n4. Open the Reroll Properties screen."
    TXT_OnboardingWindow := "Step 1/4`n`nClick 'Set game window', then select the Vermintide 2 window."
    TXT_OnboardingArea := "Step 2/4`n`nClick 'Select property area' and drag over the complete Properties text area."
    TXT_OnboardingOCR := "Step 3/4`n`nClick 'Test current item recognition' and confirm that names and values are correct."
    TXT_OnboardingDone := "Step 4/4`n`nChoose two target properties and values, then start the reroll.`n`nDo not show this guide again?"

    ; OCR Debug Window
    TXT_OCRDebugTitle := "OCR Test"
    TXT_OCRRawHeader := "===== RAW OCR RESULT ====="
    TXT_OCRParsedHeader := "===== PARSED RESULT ====="
    TXT_OCRLanguage := "OCR language:"
    TXT_OCRRuntime := "OCR runtime:"
    TXT_OCRTargetWindow := "Target window:"
    TXT_OCRArea := "OCR area:"
    TXT_OCRScreen := "Screen resolution:"
    TXT_OCRDpi := "Windows DPI / scale:"
    TXT_OCRDebugFiles := "Debug images:"
    TXT_OCRRecognizedCount := "Parsed properties:"
    TXT_OCRProperty := "Property"
    TXT_OCRName := "Name:"
    TXT_OCRCurrent := "Current value:"
    TXT_OCRMin := "Minimum value:"
    TXT_OCRMax := "Maximum value:"
    TXT_OCRIsMax := "Maximum roll:"
    TXT_Yes := "Yes"
    TXT_No := "No"
    TXT_Unknown := "Unknown"
    TXT_OCRParseFailures := "Unparsed lines:"
    TXT_OCRReason := "Reason:"
    TXT_OCRNoText := "OCR returned no text."
    TXT_OCRTestFailed := "OCR test failed:"
    TXT_OCRTestRunning := "Testing OCR..."
    TXT_OCRTestBusy := "Property reroll is running. Stop it before testing OCR."
    TXT_OCRTargetUnavailable := "The target window does not exist. Open it or set the target window again."
    TXT_OCRTargetActivationFailed := "The target window could not be activated. OCR was not performed."

    ; Messages & Tooltips
    TXT_Msg_TargetWinNotSet := "Target window not set. Set the window before running the script."
    TXT_Msg_CoordNotSet := "Coordinate %coord% not set. Set required coordinates before running."
    TXT_Msg_AreaNotSet := "Item properties area not set!`nSelect area before running."
    TXT_Msg_BtnNotSet := "Re-roll/Salvage button position not set!`nSet coordinates before running."
    TXT_Msg_InvalidTargetValues := "Enter two valid target numbers (for example, 5 or 5.0)."
    TXT_Msg_SelectTwoProperties := "Select two different target properties."
    TXT_Msg_DeleteConfirm := "Are you sure you want to delete preset"
    TXT_Msg_PresetDeleted := "Preset deleted:"

    TXT_SB_EnterName := "Enter preset name!"
    TXT_SB_Saved := "saved!"
    TXT_SB_Deleted := "deleted"
    TXT_SB_SelectDelete := "Select preset to delete"
    TXT_SB_HotkeysSaved := "Hotkeys saved to preset"
    TXT_SB_BuiltinReadOnly := "Built-in presets are read-only. Enter a new name to save a user preset."

    TXT_Tip_Paused := "PAUSE"
    TXT_Tip_Opening := "Opening chests"
    TXT_Tip_Salvaging := "Salvaging items"
    TXT_Tip_SalvagingRed := "Salvaging red items"
    TXT_Tip_Upgrading := "Upgrading athanor"

    TXT_Tip_ClickSelect := "Click LMB to select`nPress ESC to cancel`n`nCurrent coordinates:"
    TXT_Tip_DoubleClick := "Double-click LMB on window`nPress ESC to cancel`n`nCurrent Window:"
    TXT_Tip_HoldLMB := "Hold LMB and select item properties area`nPress ESC to cancel`n`nCurrent coordinates:"
    TXT_Tip_Selection := "Selection:"
    TXT_Tip_Selection2 := "Release LMB to finish`nPress ESC to cancel"
    TXT_Tip_AreaSmall := "The area is too small! Please set a larger area"
    TXT_Tip_AreaSet := "Item properties area set!"

    TXT_Tip_RerollStart := "Starting property reroll...`nLooking for:"
    TXT_Tip_Recognized := "Recognized text:"
    TXT_Tip_Found := "Target properties found!"
    TXT_Tip_Rerolling := "Rerolling properties"
    TXT_Tip_Current := "Current:"
    TXT_Tip_Cycle := "Cycle:"

    ; Info Window
    TXT_Info_Author := "Author:"
    TXT_Info_Release := "Release date:"
    TXT_Info_Update := "Update date:"
    TXT_Info_Desc := "AutoHelper - is a script that automates a number`nof routine processes in Vermintide 2."
    TXT_Info_RerollCredit := "Property reroll and OCR enhancements by 余南松."
    TXT_Info_Source := "Based on the open-source AutoHelper project."
    TXT_Info_OriginalAuthor := "Original author: ChadMasodin"
    TXT_Info_EnhancedAuthor := "Enhanced version author: 余南松"
    TXT_Info_Versions := "Base: AutoHelper v2.3    Enhanced: 1.0.0"
    TXT_Info_Link := "More information about it can be found in this"
    TXT_Info_Hotkeys := "HOTKEYS"

    TXT_HK_Stop := "Stop:"
    TXT_HK_Pause := "Pause:"
    TXT_HK_Restart := "Restart:"
    TXT_HK_OpenChests := "Open Chests:"
    TXT_HK_Salvage := "Salvage Items:"
    TXT_HK_SalvageRed := "Salvage Red Items:"
    TXT_HK_Reroll := "Reroll Properties:"
    TXT_HK_Atanor := "Upgrade Athanor:"
    TXT_HK_Close := "Close Script:"

    ; --- LOAD EXTERNAL LANGUAGE ---
    if (CurrentLanguage != "English") {
        ahkPath := LangDir "\" CurrentLanguage "\text.ahk"
        if (FileExist(ahkPath)) {
            Loop, Read, %ahkPath%
            {
                line := Trim(A_LoopReadLine)
                ; Simple parser: Variable := "Value"
                if (RegExMatch(line, "^(\w+)\s*:=\s*""(.*)""", match)) {
                    ; Need to handle `n in the string (escaped in file as `n or real newline? usually AHK file has real `n logic if included, but we are parsing)
                    ; We will manually replace literal `n string with newline char for parsing simple text
                    val := StrReplace(match2, "``n", "`n")
                    %match1% := val
                }
            }
        } else {
            ; ERROR: File missing
            Gui, +OwnDialogs
            MsgBox, 262192, Error, Localization file 'text.ahk' not found for language '%CurrentLanguage%'!`nPath: %ahkPath%`n`nReverting to English defaults.
            CurrentLanguage := "English"
            ; Update INI to reflect fallback
            IniWrite, English, %presetFile%, Settings, Language
            IniWrite, English, %presetFile%, Settings, UILanguage
        }
    }
}

BuildMenu() {
    global CurrentLanguage, LangDir

    try {
        Menu, RerollScript, DeleteAll
        Menu, Submenu1, DeleteAll
        Menu, Submenu2, DeleteAll
        Menu, Submenu3, DeleteAll
        Menu, Submenu4, DeleteAll
        Menu, Submenu5, DeleteAll
    }

    if (CurrentLanguage == "English") {
        ; Submenu 1: Melee
        Menu, Submenu1, Add, Attack Speed - Crit Chance, menuHandler
        Menu, Submenu1, Add, Attack Speed - Block Cost Reduction, menuHandler
        Menu, Submenu1, Add, Attack Speed - Crit Power, menuHandler
        Menu, Submenu1, Add, Attack Speed - Stamina , menuHandler
        Menu, Submenu1, Add, Attack Speed - vs Chaos, menuHandler
        Menu, Submenu1, Add, Attack Speed - vs Skaven, menuHandler
        Menu, Submenu1, Add, Block Cost Reduction - Crit Chance, menuHandler
        Menu, Submenu1, Add, Block Cost Reduction - Crit Power, menuHandler
        Menu, Submenu1, Add, Block Cost Reduction - Push/Block Angle, menuHandler
        Menu, Submenu1, Add, Block Cost Reduction - vs Chaos, menuHandler
        Menu, Submenu1, Add, Block Cost Reduction - vs Skaven, menuHandler
        Menu, Submenu1, Add, Block Cost Reduction - vs Attack Speed, menuHandler
        Menu, Submenu1, Add, Crit Chance - Crit Power, menuHandler
        Menu, Submenu1, Add, Crit Chance - vs Chaos, menuHandler
        Menu, Submenu1, Add, Crit Chance - vs Skaven, menuHandler
        Menu, Submenu1, Add, Crit Power - vs Chaos, menuHandler
        Menu, Submenu1, Add, Crit Power - vs Skaven, menuHandler
        Menu, Submenu1, Add, Stamina - Block Cost Reduction, menuHandler
        Menu, Submenu1, Add, Stamina - Crit Chance, menuHandler
        Menu, Submenu1, Add, Stamina - Crit Power, menuHandler
        Menu, Submenu1, Add, Stamina - Push/Block Angle, menuHandler
        Menu, Submenu1, Add, Stamina - vs Chaos, menuHandler
        Menu, Submenu1, Add, Stamina - vs Skaven, menuHandler

        ; Submenu 2: Ranged
        Menu, Submenu2, Add, Crit chance - Crit Power, menuHandler
        Menu, Submenu2, Add, Crit chance - vs Armoured, menuHandler
        Menu, Submenu2, Add, Crit chance - vs Berserkers, menuHandler
        Menu, Submenu2, Add, Crit chance - vs Chaos, menuHandler
        Menu, Submenu2, Add, Crit chance - vs Infantry, menuHandler
        Menu, Submenu2, Add, Crit chance - vs Monsters, menuHandler
        Menu, Submenu2, Add, Crit chance - vs Skaven, menuHandler
        Menu, Submenu2, Add, Crit Power - vs Armoured, menuHandler
        Menu, Submenu2, Add, Crit Power - vs Berserkers, menuHandler
        Menu, Submenu2, Add, Crit Power - vs Chaos, menuHandler
        Menu, Submenu2, Add, Crit Power - vs Infantry, menuHandler
        Menu, Submenu2, Add, Crit Power - vs Monsters, menuHandler
        Menu, Submenu2, Add, Crit Power - vs Skaven, menuHandler
        Menu, Submenu2, Add, vs Armoured - vs Berserkers, menuHandler
        Menu, Submenu2, Add, vs Armoured - vs Infantry, menuHandler
        Menu, Submenu2, Add, vs Armoured - vs Monsters, menuHandler
        Menu, Submenu2, Add, vs Chaos - vs Armoured, menuHandler
        Menu, Submenu2, Add, vs Chaos - vs Berserkers, menuHandler
        Menu, Submenu2, Add, vs Chaos - vs Infantry, menuHandler
        Menu, Submenu2, Add, vs Chaos - vs Monsters, menuHandler
        Menu, Submenu2, Add, vs Infantry - vs Berserkers, menuHandler
        Menu, Submenu2, Add, vs Monsters - vs Infantry, menuHandler
        Menu, Submenu2, Add, vs Monsters - vs Infantry, menuHandler
        Menu, Submenu2, Add, vs Skaven - vs Armoured, menuHandler
        Menu, Submenu2, Add, vs Skaven - vs Berserkers, menuHandler
        Menu, Submenu2, Add, vs Skaven - vs Infantry, menuHandler
        Menu, Submenu2, Add, vs Skaven - vs Monsters, menuHandler

        ; Submenu 3: Necklace
        Menu, Submenu3, Add, Block Cost Reduction - Health, menuHandler
        Menu, Submenu3, Add, Block Cost Reduction - Push/Block Angle, menuHandler
        Menu, Submenu3, Add, Stamina - Block Cost Reduction, menuHandler
        Menu, Submenu3, Add, Stamina - Health, menuHandler
        Menu, Submenu3, Add, Stamina - Push/Block Angle Angle, menuHandler

        ; Submenu 4: Charm
        Menu, Submenu4, Add, Attack Speed - Crit Power, menuHandler
        Menu, Submenu4, Add, Attack Speed - vs Armoured, menuHandler
        Menu, Submenu4, Add, Attack Speed - vs Berserkers, menuHandler
        Menu, Submenu4, Add, Attack Speed - vs Chaos, menuHandler
        Menu, Submenu4, Add, Attack Speed - vs Infantry, menuHandler
        Menu, Submenu4, Add, Attack Speed - vs Monsters, menuHandler
        Menu, Submenu4, Add, Attack Speed - vs Skaven, menuHandler
        Menu, Submenu4, Add, Crit Power - vs Armoured, menuHandler
        Menu, Submenu4, Add, Crit Power - vs Berserkers, menuHandler
        Menu, Submenu4, Add, Crit Power - vs Chaos, menuHandler
        Menu, Submenu4, Add, Crit Power - vs Infantry, menuHandler
        Menu, Submenu4, Add, Crit Power - vs Monsters, menuHandler
        Menu, Submenu4, Add, Crit Power - vs Skaven, menuHandler
        Menu, Submenu4, Add, vs Armoured - vs Berserkers, menuHandler
        Menu, Submenu4, Add, vs Armoured - vs Infantry, menuHandler
        Menu, Submenu4, Add, vs Armoured - vs Monsters, menuHandler
        Menu, Submenu4, Add, vs Chaos - vs Armoured, menuHandler
        Menu, Submenu4, Add, vs Chaos - vs Berserkers, menuHandler
        Menu, Submenu4, Add, vs Chaos - vs Infantry, menuHandler
        Menu, Submenu4, Add, vs Chaos - vs Monsters, menuHandler
        Menu, Submenu4, Add, vs Chaos - vs Skaven, menuHandler
        Menu, Submenu4, Add, vs Infantry - vs Berserkers, menuHandler
        Menu, Submenu4, Add, vs Monsters - vs Infantry, menuHandler
        Menu, Submenu4, Add, vs Skaven - vs Armoured, menuHandler
        Menu, Submenu4, Add, vs Skaven - vs Berserkers, menuHandler
        Menu, Submenu4, Add, vs Skaven - vs Infantry, menuHandler
        Menu, Submenu4, Add, vs Skaven - vs Monsters, menuHandler

        ; Submenu 5: Trinket
        Menu, Submenu5, Add, Cooldown - Crit Chance, menuHandler
        Menu, Submenu5, Add, Cooldown - Curse Resist, menuHandler
        Menu, Submenu5, Add, Cooldown - Movement speed, menuHandler
        Menu, Submenu5, Add, Cooldown - Revive Speed, menuHandler
        Menu, Submenu5, Add, Cooldown - Stamina recovery, menuHandler
        Menu, Submenu5, Add, Crit Chance - Curse Resist, menuHandler
        Menu, Submenu5, Add, Crit Chance - Movement Speed, menuHandler
        Menu, Submenu5, Add, Crit Chance - Revive Speed, menuHandler
        Menu, Submenu5, Add, Crit Chance - Stamina recovery, menuHandler
        Menu, Submenu5, Add, Curse Resist - Movement Speed, menuHandler
        Menu, Submenu5, Add, Curse Resist - Stamina recovery, menuHandler
        Menu, Submenu5, Add, Movement Speed - Revive Speed, menuHandler
        Menu, Submenu5, Add, Movement Speed - Stamina recovery, menuHandler
        Menu, Submenu5, Add, Revive Speed - Stamina recovery, menuHandler

        Menu, RerollScript, Add, Melee, :Submenu1
        Menu, RerollScript, Add, Ranged, :Submenu2
        Menu, RerollScript, Add ; Separator
        Menu, RerollScript, Add, Necklace, :Submenu3
        Menu, RerollScript, Add, Charm, :Submenu4
        Menu, RerollScript, Add, Trinkets, :Submenu5

    } else {
        menuPath := LangDir "\" CurrentLanguage "\menu.ahk"
        if (FileExist(menuPath)) {
            Loop, Read, %menuPath%
            {
                tline := Trim(A_LoopReadLine)
                if (RegExMatch(tline, "^Menu,\s*([^,]+),\s*Add\s*$", match)) {
                    Menu, %match1%, Add
                }
                else if (RegExMatch(tline, "^Menu,\s*([^,]+),\s*Add,\s*([^,]+),\s*([^,]+)", match)) {
                    Menu, %match1%, Add, %match2%, %match3%
                }
            }
        } else {
            Menu, RerollScript, Add, Error: menu.ahk missing, menuHandler
        }
    }
}

ChangeLanguage:
    Gui, Submit, NoHide
    if (NewLanguage != CurrentLanguage) {
        IniWrite, %NewLanguage%, %presetFile%, Settings, Language
        IniWrite, %NewLanguage%, %presetFile%, Settings, UILanguage
        Reload
    }
return

ChangeRecognitionLanguage:
    Gui, Submit, NoHide
    if (NewRecognitionLanguage != RecognitionLanguage) {
        IniWrite, %NewRecognitionLanguage%, %presetFile%, Settings, GameLanguage
        IniWrite, %NewRecognitionLanguage%, %presetFile%, Settings, OCRLanguage
        IniWrite, 0, %presetFile%, Settings, OCRTestSucceeded
        Reload
    }
return

; ============================================================================
; HOTKEY MANAGEMENT
; ============================================================================

UpdateAllKeys()
{
    global
    Gui, Submit, NoHide
    Hotkey, %Stop_key%, Stope, On
    Hotkey, %Pause_key%, Pauza, On
    Hotkey, %Reset_key%, Reset, On
    Hotkey, %OpenChests_key%, OpenChests, On
    Hotkey, %Salvage_items_key%, SalvageItems, On
    Hotkey, %Salvage_red_items_key%, SalvageRedItems, On
    Hotkey, %Reroll_Properties_key%, RerollProperties, On
    Hotkey, %Atanor_key%, UpgradeAtanor, On
    Hotkey, %Close_script_key%, CloseScript, On
}

UpdateKey(KeyVariable, Label) {
    Global
    GuiControlGet, New_Key, , %KeyVariable%
    Current_Key := %KeyVariable%

    if (New_Key != Current_Key) {
        try Hotkey, %Current_Key%, %Label%, Off
        %KeyVariable% := New_Key
        Hotkey, %New_Key%, %Label%, On

        if (savedPreset != "" && !IsBuiltInPreset(savedPreset))
            IniWrite, %New_Key%, %presetFile%, %savedPreset%, %KeyVariable%
    }
}

; ============================================================================
; GUI CREATION
; ============================================================================

CreateGUI:
    Gui, +AlwaysOnTop -DPIScale +OwnDialogs

    ; Language and preset selectors
    Gui, Font, s9
    Gui, Add, Text, x10 y10, %TXT_LangLabel%
    languageIndex := GetLanguageIndex(CurrentLanguage)
    Gui, Add, DropDownList, x+5 yp-3 w125 vNewLanguage gChangeLanguage Choose%languageIndex%, %SupportedLanguages%
    Gui, Add, Text, x215 y10, %TXT_RecognitionLanguage%
    recognitionIndex := GetLanguageIndex(RecognitionLanguage, SupportedRecognitionLanguages)
    Gui, Add, DropDownList, x+5 yp-3 w135 vNewRecognitionLanguage gChangeRecognitionLanguage Choose%recognitionIndex%, %SupportedRecognitionLanguages%

    Gui, Font, s9, Segoe UI
    Gui, Add, Text, x825 y10, %TXT_LoopLimit%
    Gui, Add, Edit, x+10 w65 h20 vLoopCount Number

    Gui, Font, s9
    Gui, Add, Text, x10 y42 w70 section, %TXT_PresetList%
    Gui, Add, ComboBox, x85 y39 w300 vsavedPreset gPresetChange
    Gui, Add, Button, x395 y39 h22 w70 gSavePreset, %TXT_Save%
    Gui, Add, Button, x475 y39 h22 w70 gDeletePreset vDELETEBUTTON, %TXT_Delete%

    ; Always-visible recommendation. UI language and OCR language are independent.
    Gui, Font, c535353 s11 Bold, Segoe UI
    Gui, Add, GroupBox, x10 y70 w960 h65, %TXT_RecommendedTitle%
    Gui, Font, cA00000 s9 Bold, Segoe UI
    Gui, Add, Text, x30 y94 w920 h32 Center, %TXT_RecommendedText%

    ; Window, coordinate, and OCR configuration
    Gui, Font, c535353 s12 Bold, Segoe UI
    Gui, Add, GroupBox, x10 y145 w420 h430, %TXT_SettingsTitle%
    Gui, Font, s9 Norm, Segoe UI
    Gui, Add, Text, x30 y177 w100 h20, %TXT_SetTargetWin%
    Gui, Add, Button, x135 y170 w110 h28 gSetLocation, %TXT_Set%
    Gui, Add, Edit, x255 y174 w155 h22 vTarget_Window ReadOnly, %Target_Window%

    Gui, Add, Text, x30 y215 w370 h20, %TXT_PosAtanor%
    Gui, Add, Button, x30 y238 w90 h25 gSetPosAtanor, %TXT_Set%
    Gui, Add, Edit, x135 y241 w100 h20 vPos_5 ReadOnly,

    Gui, Add, Text, x30 y275 w370 h20, %TXT_PosSalvage%
    Gui, Add, Button, x30 y298 w120 h25 gSet_Pos_Button, %TXT_SalvageBtn%
    Gui, Add, Edit, x160 y301 w240 h20 vPos_6 ReadOnly,
    Gui, Add, Button, x30 y333 w65 h22 gSetPosWhite, %TXT_White%
    Gui, Add, Edit, x100 y334 w65 h20 vPos_1 ReadOnly,
    Gui, Add, Button, x180 y333 w65 h22 gSetPosBlue, %TXT_Blue%
    Gui, Add, Edit, x250 y334 w65 h20 vPos_3 ReadOnly,
    Gui, Add, Button, x30 y361 w65 h22 gSetPosGreen, %TXT_Green%
    Gui, Add, Edit, x100 y362 w65 h20 vPos_2 ReadOnly,
    Gui, Add, Button, x180 y361 w65 h22 gSetPosYellow, %TXT_Yellow%
    Gui, Add, Edit, x250 y362 w65 h20 vPos_4 ReadOnly,

    Gui, Add, Text, x30 y397 w370 h20, %TXT_AreaProps%
    Gui, Add, Button, x30 y420 w100 h28 gSetOCRArea, %TXT_SelectArea%
    Gui, Add, Button, x140 y420 w180 h28 gTestOCR, %TXT_BtnTestOCR%
    Gui, Add, Edit, x30 y455 w370 h22 vOCR_Pos ReadOnly,

    Gui, Add, Text, x30 y492 w370 h20, %TXT_PosRerollOld%
    Gui, Add, Button, x30 y515 w90 h25 gSet_Pos_AfterReroll, %TXT_Set%
    Gui, Add, Edit, x135 y518 w100 h20 vPos_7 ReadOnly,

    ; Property selection and reroll options
    Gui, Font, c535353 s12 Bold, Segoe UI
    Gui, Add, GroupBox, x440 y145 w530 h290, %TXT_WorkflowTitle%
    Gui, Font, s9 Norm, Segoe UI
    Gui, Add, Text, x460 y177 w480 h35, %TXT_SelectFixedPair%
    Gui, Font, s10 Bold, Segoe UI
    Gui, Add, Button, x460 y217 w295 h40 gRerollProperties, %TXT_StartSelectedReroll%
    Gui, Add, Button, x765 y217 w85 h40 gStope, %TXT_BtnStop%
    Gui, Add, Button, x860 y217 w80 h40 gReset, %TXT_BtnRestart%
    Gui, Font, s9 Norm, Segoe UI
    Gui, Add, Checkbox, x460 y276 w20 h20 vRequireTargetValues gToggleTargetValueControls Checked%RequireTargetValues%
    Gui, Add, Text, x485 y278 w420 h20, %TXT_MatchPropertyValues%
    Gui, Add, Checkbox, x485 y305 w440 h22 vAutoMaxTargetValues gToggleTargetValueControls Checked%AutoMaxTargetValues%, %TXT_AutoMaxTarget%
    Gui, Add, Text, x485 y340 w90 h20, %TXT_TargetValue1%
    Gui, Add, Edit, x575 y336 w80 h22 vTargetValue1, %TargetValue1%
    Gui, Add, Text, x685 y340 w90 h20, %TXT_TargetValue2%
    Gui, Add, Edit, x775 y336 w80 h22 vTargetValue2, %TargetValue2%
    Gui, Add, Checkbox, x485 y378 w420 h22 vConfirmBeforeReroll gSaveUXSettings Checked%ConfirmBeforeReroll%, %TXT_ConfirmBeforeReroll%

    ; All automation functions are available in the same view.
    Gui, Font, c535353 s12 Bold, Segoe UI
    Gui, Add, GroupBox, x440 y445 w530 h130, %TXT_BtnGroup%
    Gui, Font, s9 Bold, Segoe UI
    Gui, Add, Button, x460 y475 w150 h35 gOpenChests, %TXT_BtnOpenChests%
    Gui, Add, Button, x620 y475 w150 h35 gSalvageItems, %TXT_BtnSalvage%
    Gui, Add, Button, x780 y475 w160 h35 gUpgradeAtanor, %TXT_BtnAtanor%
    Gui, Add, Button, x460 y520 w150 h35 gSalvageRedItems, %TXT_BtnSalvageRed%
    Gui, Add, Button, x620 y520 w150 h35 gRerollProperties, %TXT_BtnReroll%
    Gui, Add, Button, x780 y520 w160 h35 gShowInfo, %TXT_BtnInfo%

    ; Configuration and current-run feedback
    Gui, Font, c535353 s11 Bold, Segoe UI
    Gui, Add, GroupBox, x10 y585 w475 h160, %TXT_ConfigStatusTitle%
    Gui, Font, s9 Norm, Segoe UI
    Gui, Add, Edit, x25 y612 w445 h120 vConfigStatus ReadOnly -Wrap,
    Gui, Font, c535353 s11 Bold, Segoe UI
    Gui, Add, GroupBox, x495 y585 w475 h160, %TXT_RunStatusTitle%
    Gui, Font, s9 Norm, Segoe UI
    Gui, Add, Edit, x510 y612 w445 h120 vRunStatus ReadOnly -Wrap,

    Gui, Add, StatusBar
    Gui, Show, w980 h780, %WINTITLE%

    GoSub, UpdatePresetList
    GoSub, ToggleTargetValueControls
    SetTimer, RefreshConfigurationStatus, 500
    if (!OnboardingCompleted)
        SetTimer, ShowFirstRunGuide, -500
return

ToggleTargetValueControls:
    Gui, Submit, NoHide
    if (AutoMaxTargetValues) {
        RequireTargetValues := 1
        GuiControl,, RequireTargetValues, 1
        GuiControl, Disable, TargetValue1
        GuiControl, Disable, TargetValue2
    } else if (RequireTargetValues) {
        GuiControl, Enable, TargetValue1
        GuiControl, Enable, TargetValue2
    } else {
        GuiControl, Disable, TargetValue1
        GuiControl, Disable, TargetValue2
    }
    IniWrite, %AutoMaxTargetValues%, %presetFile%, Settings, AutoMaxTargetValues
    UpdateConfigurationStatus()
return

TargetPropertiesChanged:
    Gui, Submit, NoHide
    TargetProperty1Id := ResolvePropertyId(TargetProperty1Display)
    TargetProperty2Id := ResolvePropertyId(TargetProperty2Display)
    if (TargetProperty1Id != "")
        IniWrite, %TargetProperty1Id%, %presetFile%, Settings, TargetProperty1
    if (TargetProperty2Id != "")
        IniWrite, %TargetProperty2Id%, %presetFile%, Settings, TargetProperty2
    UpdateConfigurationStatus()
return

SaveUXSettings:
    Gui, Submit, NoHide
    IniWrite, %ConfirmBeforeReroll%, %presetFile%, Settings, ConfirmBeforeReroll
return

RefreshConfigurationStatus:
    UpdateConfigurationStatus()
return

ShowFirstRunGuide:
    Gui, 1:+OwnDialogs
    MsgBox, 262145, AutoHelper Enhanced, %TXT_OnboardingWelcome%
    IfMsgBox, Cancel
        return
    MsgBox, 262144, AutoHelper Enhanced, %TXT_OnboardingWindow%
    MsgBox, 262144, AutoHelper Enhanced, %TXT_OnboardingArea%
    MsgBox, 262144, AutoHelper Enhanced, %TXT_OnboardingOCR%
    MsgBox, 262148, AutoHelper Enhanced, %TXT_OnboardingDone%
    IfMsgBox, Yes
    {
        OnboardingCompleted := 1
        IniWrite, 1, %presetFile%, Settings, OnboardingCompleted
    }
return

; ============================================================================
; INFO WINDOW
; ============================================================================

ShowInfo:
    Gui, InfoWindow:New, , Help
    Gui, +AlwaysOnTop -DPIScale +Owner1
    Gui, Add, Picture, x10 y33, icon.png

    Gui, Font, c666666 s11 Bold Q3, Segoe UI Black
    Gui, Add, GroupBox, x10 y10 w280 h220 Center Section, AutoHelper Enhanced
    Gui, Font,

    Gui, Add, Text, xs+145 yp+25 w125, %TXT_Info_OriginalAuthor%
    Gui, Add, Link, xs+145 yp+22, <a href="https://steamcommunity.com/id/ChadMasodin">ChadMasodin</a>
    Gui, Add, Text, xs+145 yp+24 w125, %TXT_Info_EnhancedAuthor%
    Gui, Add, Text, xs+10 yp+35 w260, %TXT_Info_Source%
    Gui, Add, Text, xs+10 yp+25 w260, %TXT_Info_Versions%
    Gui, Add, Text, xs+10 yp+25 w260, %TXT_Info_RerollCredit%
    Gui, Add, Link, xs+10 yp+22, %TXT_Info_Link% <a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3385048068\">guide.</a>

    ; Hotkeys Section
    Gui, Font, c666666 s11 Bold Q3, Segoe UI Black
    Gui, Add, GroupBox, x10 y240 w280 h300 Center Section, %TXT_Info_Hotkeys%
    Gui, Font, s9

    labelX := "xs+10"
    hotkeyX := "x+1"
    hotkeyWidth := "w90"
    labelWidth := "w155"

    Gui, Add, Text, cBlue %labelX% yp+30 %labelWidth% Left, %TXT_HK_Stop%
    Gui, Add, Hotkey, %hotkeyX% yp %hotkeyWidth% h20 vStop_key, %Stop_key%

    Gui, Add, Text, cBlue %labelX% yp+30 %labelWidth% Left, %TXT_HK_Pause%
    Gui, Add, Hotkey, %hotkeyX% yp %hotkeyWidth% h22 vPause_key, %Pause_key%

    Gui, Add, Text, cBlue %labelX% yp+30 %labelWidth% Left, %TXT_HK_Restart%
    Gui, Add, Hotkey, %hotkeyX% yp %hotkeyWidth% h22 vReset_key, %Reset_key%

    Gui, Add, Text, cRed %labelX% yp+30 %labelWidth% Left, %TXT_HK_OpenChests%
    Gui, Add, Hotkey, %hotkeyX% yp %hotkeyWidth% h20 vOpenChests_key, %OpenChests_key%

    Gui, Add, Text, cRed %labelX% yp+30 %labelWidth% Left, %TXT_HK_Salvage%
    Gui, Add, Hotkey, %hotkeyX% yp %hotkeyWidth% h20 vSalvage_items_key, %Salvage_items_key%

    Gui, Add, Text, cRed %labelX% yp+30 %labelWidth% Left, %TXT_HK_SalvageRed%
    Gui, Add, Hotkey, %hotkeyX% yp %hotkeyWidth% h20 vSalvage_red_items_key, %Salvage_red_items_key%

    Gui, Add, Text, cRed %labelX% yp+30 %labelWidth% Left, %TXT_HK_Reroll%
    Gui, Add, Hotkey, %hotkeyX% yp %hotkeyWidth% h20 vReroll_Properties_key, %Reroll_Properties_key%

    Gui, Add, Text, cRed %labelX% yp+30 %labelWidth% Left, %TXT_HK_Atanor%
    Gui, Add, Hotkey, %hotkeyX% yp %hotkeyWidth% h20 vAtanor_key, %Atanor_key%

    Gui, Add, Text, cMaroon %labelX% yp+30 %labelWidth% Left, %TXT_HK_Close%
    Gui, Add, Hotkey, %hotkeyX% yp %hotkeyWidth% h20 vClose_script_key, %Close_script_key%

    Gui, Font, s11 Bold Q3, Segoe UI
    Gui, Add, Button, x10 y550 w280 h45 gSaveHotkeySettings, OK
    Gui, Font

    Gui, Show, w300 h610
return

SaveHotkeySettings:
    Gui, Submit
    UpdateAllKeys()

    if (savedPreset != "" && !IsBuiltInPreset(savedPreset)) {
        try {
            Loop, Parse, % "Stop_key|Pause_key|Reset_key|OpenChests_key|Salvage_items_key|Salvage_red_items_key|Reroll_Properties_key|Atanor_key|Close_script_key", |
                IniWrite, % %A_LoopField%, %presetFile%, %savedPreset%, %A_LoopField%

            SB_SetText(TXT_SB_HotkeysSaved . " '" . savedPreset . "'")
        }
    }

    Gui, Destroy
return

; ============================================================================
; VALIDATION FUNCTIONS
; ============================================================================

ValidateScript(requireCoords := false, coordsList := "") {
    global LoopCount, Target_Window, TXT_Msg_TargetWinNotSet, TXT_Msg_CoordNotSet
    Gui, +OwnDialogs

    if (Target_Window == "") {
        MsgBox, 262192, Error, %TXT_Msg_TargetWinNotSet%
        return false
    }

    if (requireCoords) {
        Loop, Parse, coordsList, `,
        {
            coord := Trim(A_LoopField)
            if (%coord% == "") {
                errText := StrReplace(TXT_Msg_CoordNotSet, "%coord%", coord)
                MsgBox, 262160, Error, %errText%
                return false
            }
        }
    }

    return true
}

CheckActiveWindow() {
    global Target_Window
    WinGetActiveTitle, Current_Window

    if (Current_Window != Target_Window) {
        ToolTip, Script paused. Activate window: %Target_Window%
        Sleep, DELAY_LONG
        return false
    }
    return true
}

; ============================================================================
; UTILITY FUNCTIONS
; ============================================================================

UpdateTooltip(action, count) {
    global LoopCount
    if (LoopCount != "" && LoopCount > 0)
        ToolTip, %action%... Cycle: %count%/%LoopCount%
    else
        ToolTip, %action%... Cycle: %count% (infinite)
}

SendKey(key, delay := 300) {
    Send, {%key% down}
    Send, {%key% up}
    Sleep, delay
}

Min(a, b) {
    return a < b ? a : b
}

UpdateConfigurationStatus() {
    global Target_Window, OCR_X, OCR_Y, OCR_W, OCR_H, X6, Y6
    global RecognitionLanguage, OCRTestSucceeded, TargetProperty1Id, TargetProperty2Id
    global RequireTargetValues, AutoMaxTargetValues, TargetValue1, TargetValue2
    global TXT_StatusWindow, TXT_StatusArea, TXT_StatusButton, TXT_StatusRecognition
    global TXT_StatusOCR, TXT_StatusTargets, TXT_StatusSet, TXT_StatusNotSet
    global TXT_StatusTested, TXT_StatusNotTested, TXT_StatusSelected
    global TXT_StatusReady, TXT_StatusIncomplete

    windowReady := (Target_Window != "")
    areaReady := (OCR_X != "" && OCR_Y != "" && OCR_W != "" && OCR_H != "")
    buttonReady := (X6 != "" && Y6 != "")
    targetsReady := (TargetProperty1Id != "" && TargetProperty2Id != "" && TargetProperty1Id != TargetProperty2Id)
    valuesReady := true
    if (RequireTargetValues && !AutoMaxTargetValues) {
        ToNumber(TargetValue1, target1Valid)
        ToNumber(TargetValue2, target2Valid)
        valuesReady := (target1Valid && target2Valid)
    }

    statusText := TXT_StatusWindow " " (windowReady ? TXT_StatusSet : TXT_StatusNotSet) "`r`n"
    statusText .= TXT_StatusArea " " (areaReady ? TXT_StatusSet : TXT_StatusNotSet) "`r`n"
    statusText .= TXT_StatusButton " " (buttonReady ? TXT_StatusSet : TXT_StatusNotSet) "`r`n"
    statusText .= TXT_StatusRecognition " " RecognitionLanguage " [OK]`r`n"
    statusText .= TXT_StatusOCR " " (OCRTestSucceeded ? TXT_StatusTested : TXT_StatusNotTested) "`r`n"
    statusText .= TXT_StatusTargets " " (targetsReady ? TXT_StatusSelected : TXT_StatusNotSet) "`r`n`r`n"
    ready := (windowReady && areaReady && buttonReady && targetsReady && valuesReady)
    statusText .= ready ? TXT_StatusReady : TXT_StatusIncomplete
    GuiControl, 1:, ConfigStatus, %statusText%
}

UpdateMainRunStatus(statusText) {
    global RunStatusText
    RunStatusText := statusText
    GuiControl, 1:, RunStatus, %RunStatusText%
}

GetSystemDpiInfo(ByRef scalePercent) {
    dpi := 0
    try dpi := DllCall("User32.dll\GetDpiForSystem", "UInt")

    if (!dpi) {
        hdc := DllCall("GetDC", "Ptr", 0, "Ptr")
        if (hdc) {
            dpi := DllCall("GetDeviceCaps", "Ptr", hdc, "Int", 88)
            DllCall("ReleaseDC", "Ptr", 0, "Ptr", hdc)
        }
    }

    if (!dpi)
        dpi := 96
    scalePercent := Round(dpi / 96 * 100)
    return dpi
}

GetOCRParseErrorText(errorCode) {
    global CurrentLanguage

    if (CurrentLanguage = "Chinese-Simplified") {
        errors := {empty_line: "空行"
            , unbalanced_parentheses: "括号不完整"
            , invalid_current_value: "当前值无法转换为数字"
            , current_value_missing: "没有找到可靠的括号外当前值"
            , multiple_outside_values: "存在多个括号外数字，无法可靠关联"
            , number_touches_parenthesis: "候选数字紧挨括号，已拒绝猜测"
            , property_name_missing: "无法提取词条名称"
            , range_unreliable: "括号内范围无法可靠解析"
            , current_outside_range: "当前值超出识别到的最小值/最大值范围"}
    } else {
        errors := {empty_line: "Empty line"
            , unbalanced_parentheses: "Unbalanced parentheses"
            , invalid_current_value: "Current value is not a reliable number"
            , current_value_missing: "No reliable current value outside parentheses"
            , multiple_outside_values: "Multiple outside numbers cannot be associated reliably"
            , number_touches_parenthesis: "Candidate number touches a parenthesis"
            , property_name_missing: "Property name could not be extracted"
            , range_unreliable: "Parenthesized range could not be parsed reliably"
            , current_outside_range: "Current value is outside the recognized range"}
    }

    return errors.HasKey(errorCode) ? errors[errorCode] : errorCode
}

BuildOCRDebugReport(ocrText, ocrError, rawImagePath, processedImagePath) {
    global CurrentLanguage, RecognitionLanguage, OCR_Language, OCRBinDir, Target_Window, OCR_X, OCR_Y, OCR_W, OCR_H
    global TXT_OCRRawHeader, TXT_OCRParsedHeader, TXT_OCRLanguage, TXT_OCRArea
    global TXT_OCRRuntime, TXT_OCRTargetWindow, TXT_OCRScreen, TXT_OCRDpi, TXT_OCRDebugFiles, TXT_OCRRecognizedCount
    global TXT_OCRProperty, TXT_OCRName, TXT_OCRCurrent, TXT_OCRMin, TXT_OCRMax
    global TXT_OCRIsMax, TXT_Yes, TXT_No, TXT_Unknown, TXT_OCRParseFailures
    global TXT_OCRReason, TXT_OCRNoText, TXT_OCRTestFailed

    dpi := GetSystemDpiInfo(scalePercent)
    parsedPreview := ParseOCRProperties(ocrText)
    recognitionSucceeded := (ocrError = "" && parsedPreview.properties.Length() > 0)
    if (CurrentLanguage = "Chinese-Simplified") {
        if (recognitionSucceeded)
            friendlySummary := "识别成功：已解析 " parsedPreview.properties.Length() " 个词条。"
        else
            friendlySummary := "未能正确识别装备属性。`r`n请检查：游戏是否为 English、是否完整框选 Properties 区域、是否使用无边框窗口、Windows/UI 缩放是否异常。"
    } else {
        if (recognitionSucceeded)
            friendlySummary := "Recognition succeeded: " parsedPreview.properties.Length() " properties parsed."
        else
            friendlySummary := "Item properties could not be recognized.`r`nCheck the English game language, complete Properties area, Borderless Window mode, and Windows/game UI scaling."
    }

    report := friendlySummary "`r`n`r`n"
    report .= TXT_OCRLanguage " " RecognitionLanguage " (" OCR_Language ")`r`n"
    report .= TXT_OCRRuntime " " OCRBinDir "`r`n"
    report .= TXT_OCRTargetWindow " " Target_Window "`r`n"
    report .= TXT_OCRArea " X=" OCR_X " / Y=" OCR_Y " / W=" OCR_W " / H=" OCR_H "`r`n"
    report .= TXT_OCRScreen " " A_ScreenWidth " x " A_ScreenHeight "`r`n"
    report .= TXT_OCRDpi " " dpi " DPI (" scalePercent "%)`r`n"
    report .= TXT_OCRDebugFiles "`r`n  " rawImagePath "`r`n  " processedImagePath "`r`n`r`n"
    report .= TXT_OCRRawHeader "`r`n`r`n"

    if (ocrText != "")
        report .= ocrText "`r`n`r`n"
    else
        report .= TXT_OCRNoText "`r`n`r`n"

    report .= TXT_OCRParsedHeader "`r`n`r`n"
    if (ocrError != "") {
        report .= TXT_OCRTestFailed " " ocrError
        return report
    }

    parsed := ParseOCRProperties(ocrText)
    report .= TXT_OCRRecognizedCount " " parsed.properties.Length() "`r`n`r`n"

    for index, property in parsed.properties {
        unit := property.unit
        report .= TXT_OCRProperty " " index ":`r`n"
        report .= TXT_OCRName " " property.name "`r`n"
        report .= TXT_OCRCurrent " " FormatPropertyValue(property.currentValue) unit "`r`n"

        if (property.rangeFound) {
            report .= TXT_OCRMin " " FormatPropertyValue(property.minValue) unit "`r`n"
            report .= TXT_OCRMax " " FormatPropertyValue(property.maxValue) unit "`r`n"
        } else {
            report .= TXT_OCRMin " " TXT_Unknown "`r`n"
            report .= TXT_OCRMax " " TXT_Unknown "`r`n"
        }

        maxStatus := property.isMaxKnown ? (property.isMax ? TXT_Yes : TXT_No) : TXT_Unknown
        report .= TXT_OCRIsMax " " maxStatus "`r`n`r`n"
    }

    if (parsed.failures.Length() > 0) {
        report .= TXT_OCRParseFailures " " parsed.failures.Length() "`r`n`r`n"
        for index, failure in parsed.failures {
            report .= index ". " failure.line "`r`n"
            report .= TXT_OCRReason " " GetOCRParseErrorText(failure.errorCode) "`r`n`r`n"
        }
    }

    return report
}

; ============================================================================
; COORDINATE SETTING FUNCTIONS
; ============================================================================

SetPosWhite:
    Stop := 1
    GetClickPos(X1, Y1)
    GuiControl,, Pos_1, %X1% %Y1%
return

SetPosGreen:
    Stop := 1
    GetClickPos(X2, Y2)
    GuiControl,, Pos_2, %X2% %Y2%
return

SetPosBlue:
    Stop := 1
    GetClickPos(X3, Y3)
    GuiControl,, Pos_3, %X3% %Y3%
return

SetPosYellow:
    Stop := 1
    GetClickPos(X4, Y4)
    GuiControl,, Pos_4, %X4% %Y4%
return

SetPosAtanor:
    Stop := 1
    GetClickPos(X5, Y5)
    GuiControl,, Pos_5, %X5% %Y5%
return

Set_Pos_Button:
    Stop := 1
    GetClickPos(X6, Y6)
    GuiControl,, Pos_6, %X6% %Y6%
return

Set_Pos_AfterReroll:
    Stop := 1
    GetClickPos(X7, Y7)
    GuiControl,, Pos_7, %X7% %Y7%
return

SetOCRArea:
    Stop := 1
    GetOCRArea(OCR_X, OCR_Y, OCR_W, OCR_H)
    GuiControl,, OCR_Pos, %OCR_X% %OCR_Y% %OCR_W% %OCR_H%
    if (OCR_X != "" && OCR_Y != "" && OCR_W != "" && OCR_H != "") {
        OCRTestSucceeded := 0
        IniWrite, 0, %presetFile%, Settings, OCRTestSucceeded
    }
    UpdateConfigurationStatus()
return

TestOCR:
    Gui, 1:Submit, NoHide
    Gui, 1:+OwnDialogs

    if (RerollInProgress) {
        MsgBox, 262192, %TXT_OCRDebugTitle%, %TXT_OCRTestBusy%
        return
    }

    if (OCR_X = "" || OCR_Y = "" || OCR_W = "" || OCR_H = "") {
        MsgBox, 262160, Error, %TXT_Msg_AreaNotSet%
        return
    }

    if (Target_Window = "") {
        MsgBox, 262192, Error, %TXT_Msg_TargetWinNotSet%
        return
    }

    if (!WinExist(Target_Window)) {
        MsgBox, 262160, Error, %TXT_OCRTargetUnavailable%
        return
    }

    ocrArea := [OCR_X, OCR_Y, OCR_W, OCR_H]
    debugDir := A_ScriptDir "\debug"
    rawImagePath := debugDir "\ocr_raw.png"
    processedImagePath := debugDir "\ocr_processed.png"
    ocrText := ""
    ocrError := ""

    ; Never leave old screenshots in place when this attempt cannot capture.
    if (FileExist(rawImagePath))
        FileDelete, %rawImagePath%
    if (FileExist(processedImagePath))
        FileDelete, %processedImagePath%

    ; Hide AutoHelper so its always-on-top window cannot cover the OCR area.
    Gui, 1:Hide
    try {
        WinActivate, %Target_Window%
        WinWaitActive, %Target_Window%,, 2
        if (ErrorLevel || !WinActive(Target_Window))
            throw Exception(TXT_OCRTargetActivationFailed)

        ; Allow the game to redraw after AutoHelper is hidden and activated.
        Sleep, 500
        ocrText := RunOCRDebugCapture(ocrArea, OCR_Language
            , rawImagePath, processedImagePath, ocrError)
    } catch e {
        ocrError := e.what
        if (e.message != "")
            ocrError .= " - " e.message
    } finally {
        Gui, 1:Show, NoActivate
    }

    parsedTest := ParseOCRProperties(ocrText)
    OCRTestSucceeded := (ocrError = "" && parsedTest.properties.Length() > 0) ? 1 : 0
    IniWrite, %OCRTestSucceeded%, %presetFile%, Settings, OCRTestSucceeded
    UpdateConfigurationStatus()
    report := BuildOCRDebugReport(ocrText, ocrError, rawImagePath, processedImagePath)
    ShowOCRDebugWindow(report)
return

SetLocation:
    Target_Window := SetWindow(Target_Window)
    GuiControl,, Target_Window, %Target_Window%
    if (Target_Window != "") {
        OCRTestSucceeded := 0
        IniWrite, 0, %presetFile%, Settings, OCRTestSucceeded
    }
    UpdateConfigurationStatus()
return

GetClickPos(ByRef X, ByRef Y) {
    global TXT_Tip_ClickSelect
    isPressed := 0
    X := "", Y := ""

    Loop {
        if (GetKeyState("Esc", "P")) {
            ToolTip
            X := "", Y := ""
            return
        }

        Left_Mouse := GetKeyState("LButton")
        MouseGetPos, currentX, currentY
        ToolTip, %TXT_Tip_ClickSelect%`nX=%currentX% Y=%currentY%

        if (Left_Mouse == False && isPressed == 0) {
            isPressed := 1
        } else if (Left_Mouse == True && isPressed == 1) {
            X := currentX
            Y := currentY
            ToolTip
            break
        }
    }
}

SetWindow(Target_Window) {
    global TXT_Tip_DoubleClick
    isPressed := 0
    i := 0
    Target_Window := ""

    Loop {
        if (GetKeyState("Esc", "P")) {
            ToolTip
            return ""
        }

        Left_Mouse := GetKeyState("LButton")
        WinGetTitle, Temp_Window, A
        ToolTip, %TXT_Tip_DoubleClick% %Temp_Window%

        if (Left_Mouse == False && isPressed == 0) {
            isPressed := 1
        } else if (Left_Mouse == True && isPressed == 1) {
            i++, isPressed := 0
            if (i >= 2) {
                Target_Window := Temp_Window
                ToolTip
                break
            }
        }
    }

    return Target_Window
}

GetOCRArea(ByRef X, ByRef Y, ByRef W, ByRef H) {
    global TXT_Tip_HoldLMB, TXT_Tip_Selection, TXT_Tip_AreaSmall, TXT_Tip_AreaSet, TXT_Tip_Selection2

    ; First loop - wait for LMB press
    Loop {
        ; Check ESC press
        if (GetKeyState("Esc", "P")) {
            ToolTip
            DestroySelectionGui()
            X := Y := W := H := ""
            return
        }

        ; Check LMB press to exit first loop
        if (GetKeyState("LButton", "P")) {
            break
        }
        MouseGetPos, currentX, currentY
        ToolTip, %TXT_Tip_HoldLMB%`nX1=%currentX% Y1=%currentY%
    }

    ; Get start coordinates after LMB press
    MouseGetPos, startX, startY

    ; Second loop - track area selection
    Loop {
        ; Check ESC press
        if (GetKeyState("Esc", "P")) {
            DestroySelectionGui()
            ToolTip
            X := Y := W := H := ""
            return
        }

        ; Check if LMB is still held
        if (!GetKeyState("LButton", "P")) {
            break
        }

        ; Get current coordinates
        MouseGetPos, currentX, currentY

        ; Calculate area dimensions
        width := Abs(currentX - startX)
        height := Abs(currentY - startY)
        minX := Min(startX, currentX)
        minY := Min(startY, currentY)

        ; Update selection rectangle visualization
        DrawSelectionRect(minX, minY, width, height)

        ; Show selection info with moving ToolTip
        ToolTip, %TXT_Tip_Selection% %minX% %minY% [%width% x %height%]`n`n%TXT_Tip_Selection2%

        Sleep, 10
    }

    ; Get end coordinates
    MouseGetPos, endX, endY

    ; Calculate final area
    X := Min(startX, endX)
    Y := Min(startY, endY)
    W := Abs(startX - endX)
    H := Abs(startY - endY)

        ; Destroy visualization
    DestroySelectionGui()

    if (W < 15 || H < 15) {
        ToolTip, %TXT_Tip_AreaSmall%
        Sleep, 3000
        ToolTip
        X := Y := W := H := ""
        return
    }

    ToolTip, %TXT_Tip_AreaSet%`nX: %X% Y: %Y%`nW: %W% H: %H%
    Sleep, DELAY_ANIMATION
    ToolTip
}

DrawSelectionRect(X, Y, W, H) {
    global hSelectionGui

    ; Create or update selection window
    if (hSelectionGui = "") {
        Gui, SelectionOverlay: -Caption +AlwaysOnTop +ToolWindow +E0x20
        Gui, SelectionOverlay: Color, 0066FF
        Gui, SelectionOverlay: +LastFound
        SelectionOverlayGui := WinExist()
        WinSet, Transparent, 135, ahk_id %SelectionOverlayGui%
        hSelectionGui := 1
    }

    ; Show the rectangle with transparency
    Gui, SelectionOverlay: Show, x%X% y%Y% w%W% h%H% NoActivate, SelectionOverlay
}

DestroySelectionGui() {
    global hSelectionGui
    Gui, SelectionOverlay: Destroy
    hSelectionGui := ""
}

; ============================================================================
; CONTROL FUNCTIONS
; ============================================================================

Stope:
    Stop := 1
    ToolTip
    UpdateMainRunStatus(TXT_BtnStop)
return

Pauza:
    global TXT_Tip_Paused
    if (A_IsPaused) {
        Pause, , 1
        ToolTip
    } else {
        Pause, , 1
        ToolTip, %TXT_Tip_Paused%
        Sleep, DELAY_SHORT
    }
return

Reset:
    Reload
return

CloseScript:
    ExitApp
return

; ============================================================================
; MAIN AUTOMATION FUNCTIONS
; ============================================================================

OpenChests:
    global TXT_Tip_Opening
    Stop := 0
    CycleCount := 0
    Gui, Submit, NoHide

    if (!ValidateScript()) {
        return
    }

    loop {
        if (!CheckActiveWindow())
            continue

        if (Stop == 1 || (LoopCount != "" && CycleCount >= LoopCount))
            break

        SendInput, {Space}
        Sleep, DELAY_LONG
        SendInput, {Space}

        CycleCount++
        UpdateTooltip(TXT_Tip_Opening, CycleCount)
        Sleep, DELAY_LONG
    }

    if (LoopCount != "" && CycleCount >= LoopCount) {
        SoundPlay, *64
    }

    ToolTip
return

SalvageItems:
    global TXT_Tip_Salvaging
    Stop := 0
    CycleCount := 0
    Gui, Submit, NoHide

    if (!ValidateScript(true, "X1,Y1,X2,Y2,X3,Y3,X4,Y4,X6,Y6")) {
        return
    }

    loop {
        if (!CheckActiveWindow())
            continue

        if (Stop == 1 || (LoopCount != "" && CycleCount >= LoopCount))
            break

        Sleep, DELAY_LONG

        MouseMove, %X1%, %Y1%
        Click
        Sleep, DELAY_MEDIUM

        MouseMove, %X2%, %Y2%
        Click
        Sleep, DELAY_MEDIUM

        MouseMove, %X3%, %Y3%
        Click
        Sleep, DELAY_MEDIUM

        MouseMove, %X4%, %Y4%
        Click
        Sleep, DELAY_MEDIUM

        MouseMove, %X6%, %Y6%
        Click, down
        Sleep, DELAY_LONG
        Click, up
        Sleep, DELAY_ANIMATION

        CycleCount++
        UpdateTooltip(TXT_Tip_Salvaging, CycleCount)
        Sleep, DELAY_MEDIUM
    }

    if (LoopCount != "" && CycleCount >= LoopCount) {
        SoundPlay, *64
    }

    ToolTip
return

SalvageRedItems:
    global TXT_Tip_SalvagingRed
    Stop := 0
    CycleCount := 0
    Gui, Submit, NoHide

    if (!ValidateScript(true, "X1,Y1,X2,Y2,X3,Y3,X4,Y4,X6,Y6")) {
        return
    }

    loop {
        if (!CheckActiveWindow())
            continue

        if (Stop == 1 || (LoopCount != "" && CycleCount >= LoopCount))
            break

        Sleep, DELAY_LONG

        MouseMove, %X1%, %Y1%
        Click right
        Sleep, DELAY_MEDIUM

        MouseMove, %X2%, %Y2%
        Click right
        Sleep, DELAY_MEDIUM

        MouseMove, %X3%, %Y3%
        Click right
        Sleep, DELAY_MEDIUM

        MouseMove, %X4%, %Y4%
        Click right
        Sleep, DELAY_MEDIUM

        MouseMove, %X6%, %Y6%
        Click, down
        Sleep, DELAY_LONG
        Click, up
        Sleep, DELAY_ANIMATION

        CycleCount++
        UpdateTooltip(TXT_Tip_SalvagingRed, CycleCount)
        Sleep, DELAY_SHORT
    }

    if (LoopCount != "" && CycleCount >= LoopCount) {
        SoundPlay, *64
    }

    ToolTip
return

UpgradeAtanor:
    global TXT_Tip_Upgrading
    Stop := 0
    CycleCount := 0
    Gui, Submit, NoHide

    if (!ValidateScript(true, "X5,Y5")) {
        return
    }

    loop {
        if (!CheckActiveWindow())
            continue

        if (Stop == 1 || (LoopCount != "" && CycleCount >= LoopCount))
            break

        Sleep, 150
        MouseMove, %X5%, %Y5%
        Click

        CycleCount++
        UpdateTooltip(TXT_Tip_Upgrading, CycleCount)
        Sleep, DELAY_ANIMATION
    }

    if (LoopCount != "" && CycleCount >= LoopCount) {
        SoundPlay, *64
    }

    ToolTip
return

; ============================================================================
; REROLL PROPERTIES FUNCTION
; ============================================================================

StartSelectedReroll:
    Gui, Submit, NoHide
    Gui, +OwnDialogs
    TargetProperty1Id := ResolvePropertyId(TargetProperty1Display)
    TargetProperty2Id := ResolvePropertyId(TargetProperty2Display)

    if (TargetProperty1Id = "" || TargetProperty2Id = "" || TargetProperty1Id = TargetProperty2Id) {
        MsgBox, 262160, Error, %TXT_Msg_SelectTwoProperties%
        return
    }
    if (Target_Window = "") {
        MsgBox, 262192, Error, %TXT_Msg_TargetWinNotSet%
        return
    }
    if (OCR_X = "" || OCR_Y = "" || OCR_W = "" || OCR_H = "") {
        MsgBox, 262160, Error, %TXT_Msg_AreaNotSet%
        return
    }
    if (X6 = "" || Y6 = "") {
        MsgBox, 262160, Error, %TXT_Msg_BtnNotSet%
        return
    }

    menuHandler("__ID__" TargetProperty1Id "|" TargetProperty2Id)
return

RerollProperties:
    Gui, Submit, NoHide
    Gui, +OwnDialogs
    global TXT_Msg_TargetWinNotSet, TXT_Msg_AreaNotSet, TXT_Msg_BtnNotSet

    if (Target_Window == "") {
        MsgBox, 262192, Error, %TXT_Msg_TargetWinNotSet%
        return
    }

    if (OCR_X = "" || OCR_Y = "" || OCR_W = "" || OCR_H = "") {
        MsgBox, 262160, Error, %TXT_Msg_AreaNotSet%
        return
    }

    if ((!X6 || !Y6)) {
        MsgBox, 262160, Error, %TXT_Msg_BtnNotSet%
        return
    }
    Menu, RerollScript, Show
return

menuHandler(itemName) {
    global Stop, Target_Window, LoopCount, OCR_X, OCR_Y, OCR_W, OCR_H, OCR_Language
    global RerollInProgress
    global SelectedProperties := itemName
    global RequireTargetValues, TargetValue1, TargetValue2, AutoMaxTargetValues
    global RecognitionLanguage, OCRTestSucceeded, ConfirmBeforeReroll, CurrentLanguage
    global TargetProperty1Id, TargetProperty2Id, presetFile
    global X7, Y7
    global TXT_Msg_InvalidTargetValues
    global TXT_OCRSafetyWarning, TXT_StartConfirmation
    global TXT_Tip_RerollStart, TXT_Tip_Recognized, TXT_Tip_Found, TXT_Tip_Rerolling
    global TXT_Tip_Current, TXT_Tip_Cycle, TXT_BtnStop

    ; The beginner UI passes stable IDs. Legacy menu entries are resolved to
    ; the same IDs where possible, so OCR always receives complete names such
    ; as "Power vs Skaven" rather than the old "vs Skaven" abbreviation.
    if (SubStr(itemName, 1, 6) = "__ID__") {
        propertyIds := StrSplit(SubStr(itemName, 7), "|")
        propertyId1 := propertyIds[1]
        propertyId2 := propertyIds[2]
        Property1 := GetPropertyRecognitionName(propertyId1, RecognitionLanguage)
        Property2 := GetPropertyRecognitionName(propertyId2, RecognitionLanguage)
    } else if (ResolveLegacyPropertyPair(itemName, propertyId1, propertyId2)) {
        Property1 := GetPropertyRecognitionName(propertyId1, RecognitionLanguage)
        Property2 := GetPropertyRecognitionName(propertyId2, RecognitionLanguage)
    } else {
        ; Preserve non-English legacy menus that are not yet represented in
        ; the standard catalog rather than disabling an existing workflow.
        Properties := StrSplit(itemName, " - ")
        Property1 := Trim(Properties[1])
        Property2 := Trim(Properties[2])
    }

    ; Keep the selected fixed pair as stable IDs. Target value 1 and 2 always
    ; follow the first and second properties in the chosen menu entry.
    if (propertyId1 != "" && propertyId2 != "") {
        TargetProperty1Id := propertyId1
        TargetProperty2Id := propertyId2
        IniWrite, %TargetProperty1Id%, %presetFile%, Settings, TargetProperty1
        IniWrite, %TargetProperty2Id%, %presetFile%, Settings, TargetProperty2
    }

    Gui, Submit, NoHide

    if (RequireTargetValues && !AutoMaxTargetValues) {
        target1 := ToNumber(TargetValue1, target1Valid)
        target2 := ToNumber(TargetValue2, target2Valid)
        if (!target1Valid || !target2Valid) {
            Gui, +OwnDialogs
            MsgBox, 262160, Error, %TXT_Msg_InvalidTargetValues%
            return
        }
    }

    if (!OCRTestSucceeded) {
        Gui, +OwnDialogs
        MsgBox, 262148, OCR, %TXT_OCRSafetyWarning%
        IfMsgBox, No
            return
    }

    if (ConfirmBeforeReroll) {
        loopText := (LoopCount != "" && LoopCount > 0) ? LoopCount : "Infinite"
        if (AutoMaxTargetValues)
            targetText := Property1 ": MAX`n" Property2 ": MAX"
        else if (RequireTargetValues)
            targetText := Property1 ": " FormatPropertyValue(target1) "`n" Property2 ": " FormatPropertyValue(target2)
        else
            targetText := Property1 "`n" Property2
        confirmText := TXT_StartConfirmation "`n`n" targetText "`n`n" TXT_Tip_Cycle " " loopText
        MsgBox, 262148, AutoHelper Enhanced, %confirmText%
        IfMsgBox, No
            return
    }

    RerollInProgress := true
    WinActivate, %Target_Window%

    CycleCount := 0
    Stop := 0

    ; Setup coordinates for OCR
    ocrArea := [OCR_X, OCR_Y, OCR_W, OCR_H]

    ToolTip, %TXT_Tip_RerollStart% %Property1% - %Property2%
    UpdateMainRunStatus(TXT_Tip_Rerolling "`r`n`r`n" Property1 "`r`n" Property2 "`r`n`r`n" TXT_Tip_Cycle " 0")
    Sleep, 1000

    loop {
        ; Check stop conditions
        if (Stop == 1 || (LoopCount != "" && CycleCount >= LoopCount)) {
            ToolTip
            break
        }

        ; Check if correct window is active
        if (!CheckActiveWindow())
            continue

        ; Never reuse text from an earlier cycle when OCR fails.
        text := ""
        try {
            ; OCR with specified Language Code
            text := OCR(ocrArea, OCR_Language)
        }

        ; Evaluate each property independently, so OCR line order does not matter.
        if (AutoMaxTargetValues) {
            isMatch := RerollResultMatchesMaximum(text, Property1, Property2
                , current1, current1Found, maximum1, current2, current2Found, maximum2)
        } else {
            isMatch := RerollResultMatches(text, Property1, Property2, RequireTargetValues
                , target1, target2, current1, current1Found, current2, current2Found)
        }

        ; Display OCR results and parsed values when value matching is enabled.
        if (RequireTargetValues) {
            current1Text := current1Found ? FormatPropertyValue(current1) : "?"
            current2Text := current2Found ? FormatPropertyValue(current2) : "?"
            target1Text := AutoMaxTargetValues ? (maximum1 != "" ? FormatPropertyValue(maximum1) : "MAX") : FormatPropertyValue(target1)
            target2Text := AutoMaxTargetValues ? (maximum2 != "" ? FormatPropertyValue(maximum2) : "MAX") : FormatPropertyValue(target2)
            cycleText := (LoopCount != "" && LoopCount > 0) ? CycleCount "/" LoopCount : CycleCount " (infinite)"
            tooltipText := TXT_Tip_Recognized "`n" text "`n---`n"
                . Property1 " >= " target1Text "`n" TXT_Tip_Current " " current1Text "`n`n"
                . Property2 " >= " target2Text "`n" TXT_Tip_Current " " current2Text "`n`n"
                . TXT_Tip_Cycle " " cycleText
            ToolTip, %tooltipText%
            UpdateMainRunStatus(TXT_Tip_Rerolling "`r`n`r`n"
                . Property1 ": " current1Text " / " target1Text "`r`n"
                . Property2 ": " current2Text " / " target2Text "`r`n`r`n"
                . TXT_Tip_Cycle " " cycleText)
        } else {
            ToolTip, %TXT_Tip_Recognized%`n%text%`n---`nLooking for: %Property1% - %Property2%`nCycle: %CycleCount%/%LoopCount%
            UpdateMainRunStatus(TXT_Tip_Rerolling "`r`n`r`n" Property1 "`r`n" Property2 "`r`n`r`n" TXT_Tip_Cycle " " CycleCount)
        }
        Sleep, 1000

        ; Check if target properties (and optional target values) were found.
        If (isMatch) {
            SoundPlay, *64
            if (RequireTargetValues) {
                successText := TXT_Tip_Found "`n" Property1 ": " FormatPropertyValue(current1)
                    . " >= " target1Text "`n" Property2 ": " FormatPropertyValue(current2)
                    . " >= " target2Text
                ToolTip, %successText%
            } else {
                ToolTip, %TXT_Tip_Found%`n%Property1% - %Property2%
            }
            UpdateMainRunStatus(TXT_Tip_Found "`r`n`r`n" Property1 ": " (current1Found ? FormatPropertyValue(current1) : "OK")
                . "`r`n" Property2 ": " (current2Found ? FormatPropertyValue(current2) : "OK")
                . "`r`n`r`n" TXT_Tip_Cycle " " CycleCount)
            Sleep, 5000
            ToolTip
            RerollInProgress := false
            return
        }

        MouseMove, %X6%, %Y6%
        Click, down
        Sleep, DELAY_LONG
        Click, up
        Sleep, 2500

        ; MOVE MOUSE TO SPECIFIED COORDINATE AFTER REROLL
        if (X7 != "" && Y7 != "") {
            MouseMove, %X7%, %Y7%
            Sleep, 1000
        }

        CycleCount++
        UpdateTooltip(TXT_Tip_Rerolling, CycleCount)
        Sleep, DELAY_SHORT
    }

    ToolTip
    RerollInProgress := false
    UpdateMainRunStatus(TXT_BtnStop "`r`n`r`n" TXT_Tip_Cycle " " CycleCount)
}

; ============================================================================
; PRESET MANAGEMENT FUNCTIONS
; ============================================================================

PresetChange:
    Gui, Submit, NoHide
    if (savedPreset = "")
        return

    ; Typing a new custom name must keep the currently loaded coordinates so
    ; the built-in preset can be saved as a user copy.
    if (!PresetCatalog.HasKey(savedPreset)) {
        UpdatePresetButtons(savedPreset)
        return
    }

    presetInfo := PresetCatalog[savedPreset]
    selectedPresetFile := presetInfo.file
    selectedPresetSection := presetInfo.section

    ; Clear values first so fields missing from a NEW UI preset cannot retain
    ; stale OLD UI coordinates (especially optional Pos_7).
    ClearPresetFields()

    Loop, 7 {
        IniRead, xVal, %selectedPresetFile%, %selectedPresetSection%, Pos_%A_Index%_X
        IniRead, yVal, %selectedPresetFile%, %selectedPresetSection%, Pos_%A_Index%_Y
        if (xVal != "ERROR" && yVal != "ERROR") {
            GuiControl,, Pos_%A_Index%, %xVal% %yVal%
            X%A_Index% := xVal
            Y%A_Index% := yVal
        }
    }

    IniRead, ocrX, %selectedPresetFile%, %selectedPresetSection%, OCR_X
    IniRead, ocrY, %selectedPresetFile%, %selectedPresetSection%, OCR_Y
    IniRead, ocrW, %selectedPresetFile%, %selectedPresetSection%, OCR_W
    IniRead, ocrH, %selectedPresetFile%, %selectedPresetSection%, OCR_H
    if (ocrX != "ERROR" && ocrY != "ERROR" && ocrW != "ERROR" && ocrH != "ERROR") {
        OCR_X := ocrX
        OCR_Y := ocrY
        OCR_W := ocrW
        OCR_H := ocrH
        GuiControl,, OCR_Pos, %ocrX% %ocrY% %ocrW% %ocrH%
    }

    IniRead, twVal, %selectedPresetFile%, %selectedPresetSection%, Target_Window
    if (twVal != "ERROR") {
        GuiControl,, Target_Window, %twVal%
        Target_Window := twVal
    }

    IniRead, lcVal, %selectedPresetFile%, %selectedPresetSection%, LoopCount
    if (lcVal != "ERROR") {
        GuiControl,, LoopCount, %lcVal%
        LoopCount := lcVal
    }

    IniRead, requireValuesVal, %selectedPresetFile%, %selectedPresetSection%, RequireTargetValues, 0
    RequireTargetValues := (requireValuesVal = 1) ? 1 : 0
    GuiControl,, RequireTargetValues, %RequireTargetValues%

    IniRead, target1Val, %selectedPresetFile%, %selectedPresetSection%, TargetValue1, __MISSING__
    if (target1Val = "__MISSING__")
        target1Val := ""
    TargetValue1 := target1Val
    GuiControl,, TargetValue1, %TargetValue1%

    IniRead, target2Val, %selectedPresetFile%, %selectedPresetSection%, TargetValue2, __MISSING__
    if (target2Val = "__MISSING__")
        target2Val := ""
    TargetValue2 := target2Val
    GuiControl,, TargetValue2, %TargetValue2%

    IniRead, autoMaxVal, %selectedPresetFile%, %selectedPresetSection%, AutoMaxTargetValues, 0
    AutoMaxTargetValues := (autoMaxVal = 1) ? 1 : 0
    GuiControl,, AutoMaxTargetValues, %AutoMaxTargetValues%

    IniRead, property1IdVal, %selectedPresetFile%, %selectedPresetSection%, TargetProperty1, __MISSING__
    IniRead, property2IdVal, %selectedPresetFile%, %selectedPresetSection%, TargetProperty2, __MISSING__
    if (property1IdVal != "__MISSING__" && PropertyCatalog.HasKey(property1IdVal)) {
        TargetProperty1Id := property1IdVal
    }
    if (property2IdVal != "__MISSING__" && PropertyCatalog.HasKey(property2IdVal)) {
        TargetProperty2Id := property2IdVal
    }
    OCRTestSucceeded := 0
    IniWrite, 0, %presetFile%, Settings, OCRTestSucceeded
    GoSub, ToggleTargetValueControls

    Gui, Submit, NoHide
    Loop, Parse, % "Stop_key|Pause_key|Reset_key|OpenChests_key|Salvage_items_key|Salvage_red_items_key|Reroll_Properties_key|Atanor_key|Close_script_key", |
    {
        IniRead, val, %selectedPresetFile%, %selectedPresetSection%, %A_LoopField%
        if (val != "ERROR") {
            %A_LoopField% := val
            GuiControl,, %A_LoopField%, %val%
        }
    }

    UpdateAllKeys()
    UpdatePresetButtons(savedPreset)

    if (IsBuiltInPreset(savedPreset))
        SB_SetText(TXT_SB_BuiltinReadOnly)

return

SavePreset:
    Gui, Submit, NoHide
    Gui, +OwnDialogs

    if (savedPreset = "") {
        SB_SetText(TXT_SB_EnterName)
        return
    }

    if (IsBuiltInPreset(savedPreset)) {
        SB_SetText(TXT_SB_BuiltinReadOnly)
        return
    }

    Loop, 7 {
        GuiControlGet, pos,, Pos_%A_Index%
        if (pos != "") {
            StringSplit, coord, pos, %A_Space%
            IniWrite, %coord1%, %presetFile%, %savedPreset%, Pos_%A_Index%_X
            IniWrite, %coord2%, %presetFile%, %savedPreset%, Pos_%A_Index%_Y
        }
    }

    if (OCR_X != "" && OCR_Y != "" && OCR_W != "" && OCR_H != "") {
        IniWrite, %OCR_X%, %presetFile%, %savedPreset%, OCR_X
        IniWrite, %OCR_Y%, %presetFile%, %savedPreset%, OCR_Y
        IniWrite, %OCR_W%, %presetFile%, %savedPreset%, OCR_W
        IniWrite, %OCR_H%, %presetFile%, %savedPreset%, OCR_H
    }

    if (Target_Window != "")
        IniWrite, %Target_Window%, %presetFile%, %savedPreset%, Target_Window

    if (LoopCount != "")
        IniWrite, %LoopCount%, %presetFile%, %savedPreset%, LoopCount

    ; Save optional property value matching settings.
    IniWrite, %RequireTargetValues%, %presetFile%, %savedPreset%, RequireTargetValues
    IniWrite, %AutoMaxTargetValues%, %presetFile%, %savedPreset%, AutoMaxTargetValues
    if (TargetProperty1Id != "")
        IniWrite, %TargetProperty1Id%, %presetFile%, %savedPreset%, TargetProperty1
    if (TargetProperty2Id != "")
        IniWrite, %TargetProperty2Id%, %presetFile%, %savedPreset%, TargetProperty2
    if (TargetValue1 != "")
        IniWrite, %TargetValue1%, %presetFile%, %savedPreset%, TargetValue1
    else
        IniDelete, %presetFile%, %savedPreset%, TargetValue1
    if (TargetValue2 != "")
        IniWrite, %TargetValue2%, %presetFile%, %savedPreset%, TargetValue2
    else
        IniDelete, %presetFile%, %savedPreset%, TargetValue2

    ; Save hotkeys
    IniWrite, %Stop_key%, %presetFile%, %savedPreset%, Stop_key
    IniWrite, %Pause_key%, %presetFile%, %savedPreset%, Pause_key
    IniWrite, %Reset_key%, %presetFile%, %savedPreset%, Reset_key
    IniWrite, %OpenChests_key%, %presetFile%, %savedPreset%, OpenChests_key
    IniWrite, %Salvage_items_key%, %presetFile%, %savedPreset%, Salvage_items_key
    IniWrite, %Salvage_red_items_key%, %presetFile%, %savedPreset%, Salvage_red_items_key
    IniWrite, %Reroll_Properties_key%, %presetFile%, %savedPreset%, Reroll_Properties_key
    IniWrite, %Atanor_key%, %presetFile%, %savedPreset%, Atanor_key
    IniWrite, %Close_script_key%, %presetFile%, %savedPreset%, Close_script_key

    SB_SetText(TXT_SB_HotkeysSaved . " '" . savedPreset . "'")
    GoSub, UpdatePresetList

return

DeletePreset:
    Gui, Submit, NoHide
    Gui, +OwnDialogs

    if (savedPreset = "") {
        SB_SetText(TXT_SB_SelectDelete)
        return
    }

    if (IsBuiltInPreset(savedPreset)) {
        SB_SetText(TXT_SB_BuiltinReadOnly)
        return
    }

    MsgBox, 262148, Confirmation, %TXT_Msg_DeleteConfirm% "%savedPreset%"?
    IfMsgBox, Yes
    {
        IniDelete, %presetFile%, %savedPreset%
        SB_SetText(TXT_Msg_PresetDeleted . " '" . savedPreset . "'")
        GoSub, UpdatePresetList
    }
return

UpdatePresetList:
    currentSelection := savedPreset
    PresetCatalog := {}
    presetList := ""

    AddPresetSections(presetList, presetFile, "", false)
    AddPresetSections(presetList, builtInNewPresetFile, TXT_PresetBuiltInNewUI, true)
    AddPresetSections(presetList, builtInOldPresetFile, TXT_PresetBuiltInOldUI, true)

    GuiControl,, savedPreset, |%presetList%
    if (currentSelection != "")
        GuiControl, ChooseString, savedPreset, %currentSelection%
    UpdatePresetButtons(currentSelection)
return

AddPresetSections(ByRef presetList, sourceFile, prefix, isBuiltIn) {
    global PresetCatalog

    if (!FileExist(sourceFile))
        return

    IniRead, sectionNames, %sourceFile%
    if (sectionNames = "" || sectionNames = "ERROR")
        return

    Loop, Parse, sectionNames, `n, `r
    {
        sectionName := Trim(A_LoopField)
        if (sectionName = "" || sectionName = "Settings")
            continue

        displayName := (prefix != "") ? prefix " - " sectionName : sectionName
        PresetCatalog[displayName] := {file: sourceFile, section: sectionName, isBuiltIn: isBuiltIn}
        presetList .= (presetList = "" ? "" : "|") . displayName
    }
}

IsBuiltInPreset(presetName) {
    global PresetCatalog
    return (PresetCatalog.HasKey(presetName) && PresetCatalog[presetName].isBuiltIn)
}

UpdatePresetButtons(presetName) {
    global PresetCatalog
    if (presetName = "" || !PresetCatalog.HasKey(presetName) || IsBuiltInPreset(presetName))
        GuiControl, Disable, DELETEBUTTON
    else
        GuiControl, Enable, DELETEBUTTON
}

ClearPresetFields() {
    global

    Loop, 7 {
        X%A_Index% := ""
        Y%A_Index% := ""
        GuiControl,, Pos_%A_Index%,
    }

    OCR_X := ""
    OCR_Y := ""
    OCR_W := ""
    OCR_H := ""
    Target_Window := ""
    LoopCount := ""
    GuiControl,, OCR_Pos,
    GuiControl,, Target_Window,
    GuiControl,, LoopCount,
    OCRTestSucceeded := 0
    IniWrite, 0, %presetFile%, Settings, OCRTestSucceeded
    UpdateConfigurationStatus()
}

; ============================================================================
; GUI EVENT HANDLERS
; ============================================================================

GuiClose:
    Gui, Submit, NoHide
    ExitApp
return

InfoWindowGuiClose:
    Gui, Destroy
return

OCRDebugWindowGuiSize:
    if (A_EventInfo = 1)
        return
    GuiControl, OCRDebugWindow:Move, OCRDebugOutput, % "w" (A_GuiWidth - 20) " h" (A_GuiHeight - 20)
return

OCRDebugWindowGuiClose:
OCRDebugWindowGuiEscape:
    Gui, OCRDebugWindow:Destroy
return
