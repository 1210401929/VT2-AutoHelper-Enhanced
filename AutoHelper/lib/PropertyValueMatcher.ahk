; ============================================================================
; PROPERTY VALUE MATCHING
; Strict helpers for associating OCR values with property names.
; ============================================================================

ToNumber(value, ByRef isValid) {
    isValid := false
    value := Trim(value)
    value := RegExReplace(value, "\s")

    if (SubStr(value, 0) = "%" || SubStr(value, 0) = "％")
        value := SubStr(value, 1, -1)

    ; Only correct O/o when the token already contains a real digit.
    ; This avoids treating an arbitrary OCR word as a number.
    if (!RegExMatch(value, "\d"))
        return ""

    ; A bare token such as "5O" is ambiguous (5.0 vs 50), so do not repair it.
    if (RegExMatch(value, "i)O") && !RegExMatch(value, "[.,]"))
        return ""

    value := StrReplace(value, ",", ".")
    value := StrReplace(value, "O", "0")
    value := StrReplace(value, "o", "0")

    if (!RegExMatch(value, "^[+-]?(?:\d+(?:\.\d+)?|\.\d+)$"))
        return ""

    isValid := true
    return value + 0
}

FindPropertyValue(ocrText, propertyName, ByRef valueFound) {
    valueFound := false
    propertyName := Trim(propertyName)
    propertyName := RegExReplace(propertyName, "\s+", " ")
    containedMatchCount := 0
    containedMatchValue := ""

    if (ocrText = "" || propertyName = "")
        return ""

    ; A value is accepted only when it is on the same OCR line as the exact
    ; property name. This intentionally prefers a missed match over a false one.
    Loop, Parse, ocrText, `n, `r
    {
        line := Trim(A_LoopField)
        ; Parenthesized values describe the allowed range in Vermintide 2,
        ; for example: 30% Property Name (10% - 30%). Mask those sections
        ; before looking for the current value. A mask character is used
        ; instead of whitespace so a match cannot cross a range section.
        valueLine := MaskParenthesizedText(line, parenthesesReliable)
        if (!parenthesesReliable)
            continue

        propertyPos := InStr(valueLine, propertyName, false)
        if (!propertyPos)
            continue

        beforeProperty := RTrim(SubStr(valueLine, 1, propertyPos - 1))
        afterProperty := LTrim(SubStr(valueLine, propertyPos + StrLen(propertyName)))
        beforeCandidate := ""
        afterCandidate := ""

        ; Normal Vermintide layout: +5.0% Property Name
        if (RegExMatch(beforeProperty, "i)(?:^|[^[:alnum:]_\)）])([+-]?[0-9O]+(?:[.,][0-9O]+)?)\s*[%％]?\s*$", match))
            beforeCandidate := match1
        ; Conservative fallback for OCR/layout variants: Property Name 5.0%
        if (RegExMatch(afterProperty, "i)^\s*(?:[:=]\s*)?([+-]?[0-9O]+(?:[.,][0-9O]+)?)\s*[%％]?(?:\s|$)", match))
            afterCandidate := match1

        ; Values on both sides of the property are ambiguous. Do not choose
        ; one merely because it was found first.
        if (beforeCandidate != "" && afterCandidate != "")
            continue

        candidate := (beforeCandidate != "") ? beforeCandidate : afterCandidate
        if (candidate = "") {
            ; Menu entries may intentionally be shorter than the text shown by
            ; the game, for example "vs Skaven" versus "Power vs Skaven".
            ; Parse the whole line first, then allow the selected name to be a
            ; case-insensitive substring of that reliably parsed full name.
            ; Only one contained match is accepted; duplicates remain unsafe.
            parsedProperty := ParseOCRPropertyLine(line)
            if (parsedProperty.success) {
                parsedName := RegExReplace(Trim(parsedProperty.name), "\s+", " ")
                if (InStr(parsedName, propertyName, false)) {
                    containedMatchCount++
                    containedMatchValue := parsedProperty.currentValue
                }
            }
            continue
        }

        number := ToNumber(candidate, numberValid)
        if (numberValid) {
            valueFound := true
            return number
        }
    }

    if (containedMatchCount = 1) {
        valueFound := true
        return containedMatchValue
    }

    return ""
}

MaskParenthesizedText(line, ByRef isReliable) {
    isReliable := false
    maskedLine := ""
    depth := 0
    lineLength := StrLen(line)

    Loop, %lineLength%
    {
        character := SubStr(line, A_Index, 1)

        if (character = "(" || character = "（") {
            depth++
            maskedLine .= character
            continue
        }

        if (character = ")" || character = "）") {
            if (depth = 0)
                return ""
            depth--
            maskedLine .= character
            continue
        }

        maskedLine .= (depth > 0) ? "#" : character
    }

    ; An unclosed parenthesis makes the line structure unreliable.
    if (depth != 0)
        return ""

    isReliable := true
    return maskedLine
}

ParseOCRPropertyLine(line) {
    result := {success: false, line: line, errorCode: ""}
    line := Trim(line)

    if (line = "") {
        result.errorCode := "empty_line"
        return result
    }

    maskedLine := MaskParenthesizedText(line, parenthesesReliable)
    if (!parenthesesReliable) {
        result.errorCode := "unbalanced_parentheses"
        return result
    }

    ; Only numbers outside parentheses can be current-value candidates.
    ; Keep positions so a token touching a parenthesis can be rejected.
    tokenPattern := "i)(?<![[:alnum:]_])([+-]?[0-9O]+(?:[.,][0-9O]+)?)\s*[%％]?(?![[:alnum:]_])"
    tokens := []
    searchPos := 1
    while (tokenPos := RegExMatch(maskedLine, tokenPattern, tokenMatch, searchPos)) {
        tokenNumber := ToNumber(tokenMatch1, tokenValid)
        if (!tokenValid) {
            result.errorCode := "invalid_current_value"
            return result
        }

        tokenLength := StrLen(tokenMatch)
        tokens.Push({value: tokenNumber, pos: tokenPos, length: tokenLength})
        searchPos := tokenPos + tokenLength
    }

    if (tokens.Length() = 0) {
        result.errorCode := "current_value_missing"
        return result
    }

    ; Without a selected property name there is no safe way to associate more
    ; than one outside number. The debug parser reports ambiguity instead.
    if (tokens.Length() != 1) {
        result.errorCode := "multiple_outside_values"
        return result
    }

    token := tokens[1]
    characterBefore := (token.pos > 1) ? SubStr(line, token.pos - 1, 1) : ""
    characterAfter := SubStr(line, token.pos + token.length, 1)
    if (characterBefore = ")" || characterBefore = "）"
            || characterAfter = "(" || characterAfter = "（") {
        result.errorCode := "number_touches_parenthesis"
        return result
    }

    propertyName := SubStr(maskedLine, 1, token.pos - 1)
        . " " . SubStr(maskedLine, token.pos + token.length)
    propertyName := RegExReplace(propertyName, "[#()（）]+", " ")
    propertyName := RegExReplace(propertyName, "\s+", " ")
    propertyName := Trim(propertyName, " `t:：=+\-–—|")
    if (propertyName = "") {
        result.errorCode := "property_name_missing"
        return result
    }

    if (!ParsePropertyRange(line, minValue, maxValue, rangeFound)) {
        result.errorCode := "range_unreliable"
        return result
    }

    if (rangeFound) {
        tolerance := 0.000001
        if (token.value < minValue - tolerance || token.value > maxValue + tolerance) {
            result.errorCode := "current_outside_range"
            return result
        }
        result.isMaxKnown := true
        result.isMax := (Abs(token.value - maxValue) <= tolerance)
    } else {
        result.isMaxKnown := false
        result.isMax := false
    }

    result.success := true
    result.name := propertyName
    result.currentValue := token.value
    result.rangeFound := rangeFound
    result.minValue := rangeFound ? minValue : ""
    result.maxValue := rangeFound ? maxValue : ""
    result.unit := (InStr(line, "%") || InStr(line, "％")) ? "%" : ""
    return result
}

ParsePropertyRange(line, ByRef minValue, ByRef maxValue, ByRef rangeFound) {
    minValue := ""
    maxValue := ""
    rangeFound := false
    groupCount := 0

    Loop, Parse, line
    {
        if (A_LoopField = "(" || A_LoopField = "（")
            groupCount++
    }

    if (groupCount = 0)
        return true

    rangePattern := "i)[(（]\s*([+-]?[0-9O]+(?:[.,][0-9O]+)?)\s*[%％]?\s*[-–—~～]\s*([+-]?[0-9O]+(?:[.,][0-9O]+)?)\s*[%％]?\s*[)）]"
    searchPos := 1
    rangeCount := 0
    while (rangePos := RegExMatch(line, rangePattern, rangeMatch, searchPos)) {
        rangeMin := ToNumber(rangeMatch1, minValid)
        rangeMax := ToNumber(rangeMatch2, maxValid)
        if (!minValid || !maxValid || rangeMin > rangeMax)
            return false

        rangeCount++
        minValue := rangeMin
        maxValue := rangeMax
        searchPos := rangePos + StrLen(rangeMatch)
    }

    ; Every parenthesized group must be exactly one recognizable range.
    if (groupCount != 1 || rangeCount != 1)
        return false

    rangeFound := true
    return true
}

ParseOCRProperties(ocrText) {
    parsed := {properties: [], failures: []}

    Loop, Parse, ocrText, `n, `r
    {
        line := Trim(A_LoopField)
        if (line = "")
            continue

        property := ParseOCRPropertyLine(line)
        if (property.success)
            parsed.properties.Push(property)
        else
            parsed.failures.Push(property)
    }

    return parsed
}

IsValueAtLeast(currentValue, targetValue, tolerance := 0.000001) {
    return (currentValue + tolerance >= targetValue)
}

PropertyNamesMatch(ocrText, property1, property2) {
    return (InStr(ocrText, property1, false) && InStr(ocrText, property2, false))
}

RerollResultMatches(ocrText, property1, property2, requireValues, target1, target2
        , ByRef current1, ByRef current1Found, ByRef current2, ByRef current2Found) {
    current1 := ""
    current2 := ""
    current1Found := false
    current2Found := false

    namesMatch := PropertyNamesMatch(ocrText, property1, property2)
    if (!requireValues)
        return namesMatch

    current1 := FindPropertyValue(ocrText, property1, current1Found)
    current2 := FindPropertyValue(ocrText, property2, current2Found)

    if (!namesMatch || !current1Found || !current2Found)
        return false

    return (IsValueAtLeast(current1, target1) && IsValueAtLeast(current2, target2))
}

FindParsedProperty(ocrText, propertyName, ByRef propertyFound) {
    propertyFound := false
    propertyName := RegExReplace(Trim(propertyName), "\s+", " ")
    matchedProperty := ""
    matchCount := 0

    parsed := ParseOCRProperties(ocrText)
    for _, property in parsed.properties {
        parsedName := RegExReplace(Trim(property.name), "\s+", " ")
        if (parsedName = propertyName || InStr(parsedName, propertyName, false)) {
            matchCount++
            matchedProperty := property
        }
    }

    ; Refuse ambiguous duplicate/substring matches rather than guessing.
    if (matchCount = 1) {
        propertyFound := true
        return matchedProperty
    }
    return ""
}

RerollResultMatchesMaximum(ocrText, property1, property2
        , ByRef current1, ByRef current1Found, ByRef maximum1
        , ByRef current2, ByRef current2Found, ByRef maximum2) {
    current1 := ""
    current2 := ""
    maximum1 := ""
    maximum2 := ""
    record1 := FindParsedProperty(ocrText, property1, current1Found)
    record2 := FindParsedProperty(ocrText, property2, current2Found)

    ; Publish every reliably parsed current value immediately. Previously the
    ; values were assigned only after both properties and both ranges passed
    ; validation. If just one property/range was missing, its found flag could
    ; be true while its output value was still blank, which the UI formatted
    ; as a misleading zero.
    if (current1Found) {
        current1 := record1.currentValue
        if (record1.rangeFound)
            maximum1 := record1.maxValue
    }
    if (current2Found) {
        current2 := record2.currentValue
        if (record2.rangeFound)
            maximum2 := record2.maxValue
    }

    if (!current1Found || !current2Found)
        return false
    if (!record1.rangeFound || !record2.rangeFound)
        return false

    return (record1.isMaxKnown && record1.isMax && record2.isMaxKnown && record2.isMax)
}

FormatPropertyValue(value) {
    ; Never convert an absent OCR value into the numeric value zero.
    if (StrLen(value) = 0)
        return ""
    formatted := Format("{:.6f}", value + 0)
    formatted := RegExReplace(formatted, "0+$")
    formatted := RegExReplace(formatted, "\.$")
    return formatted
}
