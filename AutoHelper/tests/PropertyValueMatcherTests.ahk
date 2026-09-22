#NoEnv
#SingleInstance Force
SetBatchLines, -1

#Include %A_ScriptDir%\..\lib\PropertyValueMatcher.ahk
#Include %A_ScriptDir%\..\lib\PropertyCatalog.ahk

global TestFailures := 0
global PropertyCatalog := {}
global PropertyDisplayToId := {}
InitializePropertyCatalog()

AssertTrue("stable ID resolves old vs Skaven alias", ResolvePropertyId("vs Skaven") = "power_vs_skaven")
AssertTrue("stable ID resolves Chinese display", ResolvePropertyId("对鼠人强度") = "power_vs_skaven")
AssertTrue("English recognition uses full Power vs name"
    , GetPropertyRecognitionName("power_vs_skaven", "English") = "Power vs Skaven")
AssertTrue("Chinese UI display does not change English OCR name"
    , GetPropertyDisplayName("power_vs_skaven", "Chinese-Simplified") = "对鼠人强度"
        && GetPropertyRecognitionName("power_vs_skaven", "English") = "Power vs Skaven")
legacyEnglishMapped := ResolveLegacyPropertyPair("Attack Speed - vs Skaven", legacyEnglish1, legacyEnglish2)
AssertTrue("legacy English menu pair maps to standard IDs"
    , legacyEnglishMapped && legacyEnglish1 = "attack_speed" && legacyEnglish2 = "power_vs_skaven")
legacyChineseMapped := ResolveLegacyPropertyPair("攻击速度 - 对鼠人攻击力", legacyChinese1, legacyChinese2)
AssertTrue("legacy Chinese menu pair maps to standard IDs"
    , legacyChineseMapped && legacyChinese1 = "attack_speed" && legacyChinese2 = "power_vs_skaven")

AssertEquivalent("5 == 5.0", "5", "5.0")
AssertEquivalent("5 == 5.00", "5", "5.00")
AssertEquivalent("5.0 == 5.00", "5.0", "5.00")
AssertEquivalent("5 == 05.0", "5", "05.0")
AssertEquivalent("5 == 5,0", "5", "5,0")
AssertComparison("4.9 < 5", "4.9", "5", false)
AssertComparison("5.1 >= 5", "5.1", "5", true)

AssertPropertyValue("plus and percent", "+5.0% Attack Speed", "Attack Speed", 5.0, true)
AssertPropertyValue("decimal comma", "5,0% Attack Speed", "Attack Speed", 5.0, true)
AssertPropertyValue("no percent", "5.0 Attack Speed", "Attack Speed", 5.0, true)
AssertPropertyValue("safe O correction", "+5.O% Attack Speed", "Attack Speed", 5.0, true)
AssertPropertyValue("unsafe O token rejected", "+O.O% Attack Speed", "Attack Speed", "", false)
AssertPropertyValue("ambiguous 5O token rejected", "+5O% Attack Speed", "Attack Speed", "", false)
AssertPropertyValue("value after property", "Attack Speed: 5.0%", "Attack Speed", 5.0, true)
AssertPropertyValue("current value before Chinese property ignores range"
    , "30% 格挡消耗减免 (10% - 30%)", "格挡消耗减免", 30, true)
AssertPropertyValue("attack speed current value ignores range"
    , "5% 攻击速度 (3% - 5%)", "攻击速度", 5, true)
AssertPropertyValue("current value after property ignores range"
    , "格挡消耗减免: 30% (10% - 30%)", "格挡消耗减免", 30, true)
AssertPropertyValue("full-width parentheses are range only"
    , "5% 攻击速度（3% - 5%）", "攻击速度", 5, true)
AssertPropertyValue("abbreviated vs Skaven matches full game property"
    , "+10.0% Power vs Skaven (5.0% - 10.0%)", "vs Skaven", 10, true)
AssertPropertyValue("abbreviated vs Infantry matches full game property"
    , "+10.0% Power vs Infantry (5.0% - 10.0%)", "vs Infantry", 10, true)
AssertPropertyValue("ambiguous contained property lines are rejected"
    , "+10.0% Power vs Skaven (5.0% - 10.0%)`n+8.0% Other vs Skaven (5.0% - 10.0%)"
    , "vs Skaven", "", false)
AssertPropertyValue("range without outside current value is rejected"
    , "格挡消耗减免 (10% - 30%)", "格挡消耗减免", "", false)
AssertPropertyValue("range before property is rejected"
    , "(10% - 30%) 格挡消耗减免", "格挡消耗减免", "", false)
AssertPropertyValue("unclosed range is rejected"
    , "30% 格挡消耗减免 (10% - 30%", "格挡消耗减免", "", false)
AssertPropertyValue("values on both sides are ambiguous"
    , "20% 格挡消耗减免 30%", "格挡消耗减免", "", false)
AssertPropertyValue("nearest outside value is associated with property"
    , "99% 30% 格挡消耗减免 (10% - 30%)", "格挡消耗减免", 30, true)
AssertPropertyValue("number touching closing parenthesis is rejected"
    , "(10% - 30%)30% 格挡消耗减免", "格挡消耗减免", "", false)
AssertPropertyValue("number touching opening parenthesis is rejected"
    , "格挡消耗减免: 30%(10% - 30%)", "格挡消耗减免", "", false)

AssertParsedProperty("debug parser full block cost reduction"
    , "30% 格挡消耗减免 (10% - 30%)", "格挡消耗减免", 30, 10, 30, true)
AssertParsedProperty("debug parser non-full block cost reduction"
    , "28% 格挡消耗减免 (10% - 30%)", "格挡消耗减免", 28, 10, 30, false)
AssertParsedProperty("debug parser decimal current value"
    , "4.5% 暴击几率 (3% - 5%)", "暴击几率", 4.5, 3, 5, false)
AssertParsedProperty("debug parser full-width range"
    , "5% 攻击速度（3% - 5%）", "攻击速度", 5, 3, 5, true)
AssertParsedProperty("real OCR revive speed line"
    , "+30.0% Revive Speed (10.0% - 30.0%)", "Revive Speed", 30, 10, 30, true)
AssertParsedProperty("real OCR curse resistance line"
    , "+33.0% Curse Resistance (11.0% - 33.0%)", "Curse Resistance", 33, 11, 33, true)
AssertParsedPropertyNoRange("debug parser property without displayed range"
    , "+5.0% Attack Speed", "Attack Speed", 5)
AssertParsedProperty("debug parser value after property"
    , "格挡消耗减免: 30% (10% - 30%)", "格挡消耗减免", 30, 10, 30, true)
AssertPropertyParseFailure("debug parser rejects range-only value"
    , "格挡消耗减免 (10% - 30%)", "current_value_missing")
AssertPropertyParseFailure("debug parser rejects multiple outside values"
    , "20% 格挡消耗减免 30% (10% - 30%)", "multiple_outside_values")
AssertPropertyParseFailure("debug parser rejects unbalanced parentheses"
    , "30% 格挡消耗减免 (10% - 30%", "unbalanced_parentheses")
AssertPropertyParseFailure("debug parser rejects current above maximum"
    , "35% 格挡消耗减免 (10% - 30%)", "current_outside_range")
AssertPropertyParseFailure("debug parser rejects number touching range"
    , "格挡消耗减免: 30%(10% - 30%)", "number_touches_parenthesis")

normalOrder := "+5.0% Attack Speed`n+5.0% Crit Chance"
swappedOrder := "+5.0% Crit Chance`n+5.0% Attack Speed"
oneBelow := "+5.0% Attack Speed`n+4.8% Crit Chance"
otherBelow := "+4.9% Attack Speed`n+5.0% Crit Chance"
twoDecimals := "+5.00% Attack Speed`n+5.00% Crit Chance"
decimalCommas := "+5,0% Attack Speed`n+5,0% Crit Chance"
nameOnlyValues := "+3.8% Attack Speed`n+4.2% Crit Chance"
missingValue := "Attack Speed`n+5.0% Crit Chance"
missingProperty := "+5.0% Attack Speed"
onlyOneTargetProperty := "+5.0% Attack Speed`n+10.0% Power vs Chaos"
unparseableValue := "+?.?% Attack Speed`n+5.0% Crit Chance"
rangeValuesReachTargets := "+5% Attack Speed (3% - 5%)`n+5% Crit Chance (3% - 5%)"
rangeMaximumMustNotPass := "+4% Attack Speed (3% - 5%)`n+5% Crit Chance (3% - 5%)"
rangeOnlyMustNotPass := "Attack Speed (3% - 5%)`n+5% Crit Chance (3% - 5%)"
abbreviatedPowerTargets := "+10.0% Power vs Infantry (5.0% - 10.0%)`n+10.0% Power vs Skaven (5.0% - 10.0%)"
abbreviatedPowerOneBelow := "+10.0% Power vs Infantry (5.0% - 10.0%)`n+9.5% Power vs Skaven (5.0% - 10.0%)"

AssertRerollInputs("normal order reaches both targets", normalOrder, "5", "5", true)
AssertRerollInputs("swapped order reaches both targets", swappedOrder, "5", "5", true)
AssertRerollInputs("first full second below continues", oneBelow, "5", "5", false)
AssertRerollInputs("first below second full continues", otherBelow, "5", "5", false)
AssertRerollInputs("two-decimal OCR equals target 5", twoDecimals, "5", "5", true)
AssertRerollInputs("decimal-comma OCR equals target 5", decimalCommas, "5", "5", true)
AssertRerollInputs("missing numeric value continues", missingValue, "5", "5", false)
AssertRerollInputs("missing property continues", missingProperty, "5", "5", false)
AssertRerollInputs("other property cannot replace Crit Chance", onlyOneTargetProperty, "5", "5", false)
AssertRerollInputs("unparseable question marks never succeed", unparseableValue, "5", "5", false)
AssertRerollInputs("value mode rejects names with low values", nameOnlyValues, "5", "5", false)
AssertRerollInputs("outside current values pass despite ranges", rangeValuesReachTargets, "5", "5", true)
AssertRerollInputs("range maximum cannot replace low current value", rangeMaximumMustNotPass, "5", "5", false)
AssertRerollInputs("range maximum cannot replace missing current value", rangeOnlyMustNotPass, "5", "5", false)
AssertRerollNamedInputs("abbreviated Power vs names reach both targets"
    , abbreviatedPowerTargets, "vs Infantry", "vs Skaven", "10", "10", true)
AssertRerollNamedInputs("abbreviated Power vs one below continues"
    , abbreviatedPowerOneBelow, "vs Infantry", "vs Skaven", "10", "10", false)
AssertReroll("name-only mode preserves original behavior", nameOnlyValues, false, "", "", true)
AssertMaximumReroll("automatic maximum accepts two maximum rolls", rangeValuesReachTargets, true)
AssertMaximumReroll("automatic maximum rejects one value below maximum", rangeMaximumMustNotPass, false)
AssertMaximumReroll("automatic maximum rejects missing ranges", normalOrder, false)
AssertMaximumReroll("automatic maximum ignores property line order"
    , "+5% Crit Chance (3% - 5%)`n+5% Attack Speed (3% - 5%)", true)

if (TestFailures) {
    FileAppend, % "FAILED: " TestFailures " test(s).`n", *
    ExitApp, 1
}

FileAppend, All PropertyValueMatcher tests passed.`n, *
ExitApp, 0

AssertEquivalent(label, left, right) {
    leftNumber := ToNumber(left, leftValid)
    rightNumber := ToNumber(right, rightValid)
    AssertTrue(label, leftValid && rightValid && leftNumber = rightNumber)
}

AssertComparison(label, current, target, expected) {
    currentNumber := ToNumber(current, currentValid)
    targetNumber := ToNumber(target, targetValid)
    actual := currentValid && targetValid && IsValueAtLeast(currentNumber, targetNumber)
    AssertTrue(label, actual = expected)
}

AssertPropertyValue(label, ocrText, propertyName, expectedValue, expectedFound) {
    actualValue := FindPropertyValue(ocrText, propertyName, actualFound)
    matches := (actualFound = expectedFound)
    if (expectedFound)
        matches := matches && (actualValue = expectedValue)
    AssertTrue(label, matches)
}

AssertParsedProperty(label, line, expectedName, expectedCurrent, expectedMin, expectedMax, expectedIsMax) {
    parsed := ParseOCRPropertyLine(line)
    matches := parsed.success
        && parsed.name = expectedName
        && parsed.currentValue = expectedCurrent
        && parsed.rangeFound
        && parsed.minValue = expectedMin
        && parsed.maxValue = expectedMax
        && parsed.isMaxKnown
        && parsed.isMax = expectedIsMax
    AssertTrue(label, matches)
}

AssertParsedPropertyNoRange(label, line, expectedName, expectedCurrent) {
    parsed := ParseOCRPropertyLine(line)
    matches := parsed.success
        && parsed.name = expectedName
        && parsed.currentValue = expectedCurrent
        && !parsed.rangeFound
        && !parsed.isMaxKnown
    AssertTrue(label, matches)
}

AssertPropertyParseFailure(label, line, expectedErrorCode) {
    parsed := ParseOCRPropertyLine(line)
    AssertTrue(label, !parsed.success && parsed.errorCode = expectedErrorCode)
}

AssertReroll(label, ocrText, requireValues, target1, target2, expected) {
    actual := RerollResultMatches(ocrText, "Attack Speed", "Crit Chance", requireValues
        , target1, target2, current1, current1Found, current2, current2Found)
    AssertTrue(label, actual = expected)
}

AssertRerollInputs(label, ocrText, target1Input, target2Input, expected) {
    target1 := ToNumber(target1Input, target1Valid)
    target2 := ToNumber(target2Input, target2Valid)
    actual := target1Valid && target2Valid
        && RerollResultMatches(ocrText, "Attack Speed", "Crit Chance", true
            , target1, target2, current1, current1Found, current2, current2Found)
    AssertTrue(label, actual = expected)
}

AssertRerollNamedInputs(label, ocrText, property1, property2, target1Input, target2Input, expected) {
    target1 := ToNumber(target1Input, target1Valid)
    target2 := ToNumber(target2Input, target2Valid)
    actual := target1Valid && target2Valid
        && RerollResultMatches(ocrText, property1, property2, true
            , target1, target2, current1, current1Found, current2, current2Found)
    AssertTrue(label, actual = expected)
}

AssertMaximumReroll(label, ocrText, expected) {
    actual := RerollResultMatchesMaximum(ocrText, "Attack Speed", "Crit Chance"
        , current1, current1Found, maximum1, current2, current2Found, maximum2)
    AssertTrue(label, actual = expected)
}

AssertTrue(label, condition) {
    global TestFailures
    if (condition) {
        FileAppend, % "PASS: " label "`n", *
    } else {
        TestFailures++
        FileAppend, % "FAIL: " label "`n", *
    }
}
