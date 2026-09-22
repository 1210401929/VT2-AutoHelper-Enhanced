#NoEnv
#SingleInstance Force
SetBatchLines, -1

#Include <Vis2>
#Include <OCRDebug>

runtimeConfigured := ConfigureOCRRuntime()

outputDir := A_Temp "\AutoHelperOCRDebugTest-" A_TickCount
resultFile := A_Temp "\AutoHelperOCRDebugCaptureTests-" A_PtrSize ".txt"
rawImage := outputDir "\ocr_raw.png"
processedImage := outputDir "\ocr_processed.png"
sourceImage := A_ScriptDir "\icon.png"
testLanguage := "eng"

if (A_Args.Length() >= 1)
    sourceImage := A_Args[1]
if (A_Args.Length() >= 2)
    testLanguage := A_Args[2]
keepOutput := false
if (A_Args.Length() >= 3) {
    outputDir := A_Args[3]
    rawImage := outputDir "\ocr_raw.png"
    processedImage := outputDir "\ocr_processed.png"
    keepOutput := true
}

if (FileExist(resultFile))
    FileDelete, %resultFile%

text := RunOCRDebugCapture(sourceImage, testLanguage, rawImage, processedImage, errorDetails)

passed := runtimeConfigured && (errorDetails = "") && FileExist(rawImage) && FileExist(processedImage)
if (passed) {
    FileGetSize, rawSize, %rawImage%
    FileGetSize, processedSize, %processedImage%
    passed := (rawSize > 0 && processedSize > 0)
}

; Exercise the real debug-window function because AHK v1 GUI control
; variables inside functions must be explicitly global or static.
TXT_OCRDebugTitle := "AutoHelper OCR Debug Window Test"
Gui, 1:New
ShowOCRDebugWindow("GUI runtime test")
GuiControlGet, displayedReport, OCRDebugWindow:, OCRDebugOutput
passed := passed && (displayedReport = "GUI runtime test")
Gui, OCRDebugWindow:Destroy
Gui, 1:Destroy

if (passed)
    resultText := "PASS: OCR debug capture and result window runtime tests passed.`nOCR text:`n" text "`n"
else
    resultText := "FAIL: OCR debug capture or result window runtime test failed.`n" errorDetails "`n"

FileAppend, %resultText%, *
FileAppend, %resultText%, %resultFile%, UTF-8

if (!keepOutput)
    FileRemoveDir, %outputDir%, 1
ExitApp, % passed ? 0 : 1
