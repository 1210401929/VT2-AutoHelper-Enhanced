; ============================================================================
; OCR DEBUG CAPTURE
; Runs the same Vis2 preprocessing and Tesseract conversion used by OCR().
; ============================================================================

ConfigureOCRRuntime() {
    global OCRBinDir

    candidates := []
    candidates.Push(A_ScriptDir "\bin")
    ; Development/source layout: AutoHelper.ahk is one directory below the
    ; packaged runtime resources in release\VT2-AutoHelper\bin.
    candidates.Push(A_ScriptDir "\..\release\VT2-AutoHelper\bin")
    candidates.Push(A_ScriptDir "\release\VT2-AutoHelper\bin")

    for index, candidate in candidates {
        leptonica := candidate "\leptonica_util\leptonica_util.exe"
        tesseract := candidate "\tesseract\tesseract.exe"
        if (!FileExist(leptonica) || !FileExist(tesseract))
            continue

        OCRBinDir := candidate
        Vis2.provider.Tesseract.leptonica := leptonica
        Vis2.provider.Tesseract.tesseract := tesseract
        Vis2.provider.Tesseract.tessdata_best := candidate "\tesseract\tessdata_best"
        Vis2.provider.Tesseract.tessdata_fast := candidate "\tesseract\tessdata_fast"
        return true
    }

    ; Keep the original expected path in the report if no runtime is present.
    OCRBinDir := A_ScriptDir "\bin"
    return false
}

RunOCRDebugCapture(imageSource, language, rawImagePath, processedImagePath, ByRef errorDetails) {
    errorDetails := ""
    text := ""
    provider := new Vis2.provider.Tesseract(language)

    try {
        SplitPath, rawImagePath,, debugDir
        FileCreateDir, %debugDir%
        if (FileExist(rawImagePath))
            FileDelete, %rawImagePath%
        if (FileExist(processedImagePath))
            FileDelete, %processedImagePath%

        if (FileExist(rawImagePath) || FileExist(processedImagePath))
            throw Exception("Could not replace existing debug image files.")

        ; Capture once to the same BMP used by the normal Vis2 pipeline.
        screenshot := Vis2.stdlib.toFile(imageSource, provider.file)
        if (!SaveDebugImageAsPng(screenshot, rawImagePath))
            throw Exception("Could not save the raw OCR image.",, rawImagePath)

        ; Use exactly the same preprocessing and best-data conversion as OCR().
        provider.preprocess(screenshot, provider.fileProcessedImage)
        if (!SaveDebugImageAsPng(provider.fileProcessedImage, processedImagePath))
            throw Exception("Could not save the processed OCR image.",, processedImagePath)

        provider.convert_optimized(provider.fileProcessedImage, provider.fileConvertedText)
        text := provider.getText(provider.fileConvertedText)
    } catch e {
        errorDetails := e.what
        if (e.message != "")
            errorDetails .= " - " e.message
        if (e.extra != "")
            errorDetails .= "`n" e.extra
    } finally {
        try provider.cleanup()
    }

    return text
}

SaveDebugImageAsPng(inputPath, outputPath) {
    pToken := Gdip_Startup()
    if (!pToken)
        return false

    pBitmap := 0
    success := false
    try {
        pBitmap := Gdip_CreateBitmapFromFile(inputPath)
        if (pBitmap && Gdip_SaveBitmapToFile(pBitmap, outputPath) = 0)
            success := FileExist(outputPath)
    } finally {
        if (pBitmap)
            Gdip_DisposeImage(pBitmap)
        Gdip_Shutdown(pToken)
    }

    return success
}

ShowOCRDebugWindow(report) {
    global TXT_OCRDebugTitle, OCRDebugOutput

    Gui, OCRDebugWindow:Destroy
    Gui, OCRDebugWindow:New, +AlwaysOnTop +Resize +MinSize620x420 +Owner1, %TXT_OCRDebugTitle%
    Gui, OCRDebugWindow:Font, s10, Microsoft YaHei UI
    Gui, OCRDebugWindow:Add, Edit, x10 y10 w760 h580 vOCRDebugOutput ReadOnly Multi HScroll, %report%
    Gui, OCRDebugWindow:Show, w780 h600
}
