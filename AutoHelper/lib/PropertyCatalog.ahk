; ============================================================================
; PROPERTY CATALOG
; Stable property IDs are kept separate from UI labels and OCR match names.
; ============================================================================

InitializePropertyCatalog() {
    global PropertyCatalog, PropertyDisplayToId

    PropertyCatalog := {}
    PropertyDisplayToId := {}

    AddPropertyDefinition("attack_speed", "Attack Speed", "攻击速度")
    AddPropertyDefinition("crit_chance", "Crit Chance", "暴击几率", "Critical Chance", "致命一击几率")
    AddPropertyDefinition("block_cost_reduction", "Block Cost Reduction", "格挡消耗减免")
    AddPropertyDefinition("stamina_recovery", "Stamina Recovery", "体力恢复速率", "Stamina recovery")
    AddPropertyDefinition("power_vs_skaven", "Power vs Skaven", "对鼠人强度", "vs Skaven", "对鼠人攻击力")
    AddPropertyDefinition("power_vs_chaos", "Power vs Chaos", "对混沌单位强度", "vs Chaos", "对混沌单位攻击力")
    AddPropertyDefinition("power_vs_infantry", "Power vs Infantry", "对步兵强度", "vs Infantry", "对步兵攻击力")
    AddPropertyDefinition("power_vs_armoured", "Power vs Armoured", "对披甲单位强度", "vs Armoured", "对披甲单位攻击力")
    AddPropertyDefinition("power_vs_berserkers", "Power vs Berserkers", "对狂战士强度", "vs Berserkers", "对狂战士增加")
    AddPropertyDefinition("power_vs_monsters", "Power vs Monsters", "对怪物强度", "vs Monsters", "对怪物攻击力")
    AddPropertyDefinition("crit_power", "Crit Power", "暴击战力")
    AddPropertyDefinition("movement_speed", "Movement Speed", "移动速度")
    AddPropertyDefinition("revive_speed", "Revive Speed", "复活速度", "复活速率")
    AddPropertyDefinition("curse_resistance", "Curse Resistance", "诅咒抗性", "Curse Resist")
    AddPropertyDefinition("health", "Health", "生命值")
    AddPropertyDefinition("stamina", "Stamina", "体力")
    AddPropertyDefinition("cooldown_reduction", "Cooldown Reduction", "冷却时间减少", "Cooldown")
    AddPropertyDefinition("push_block_angle", "Push/Block Angle", "推击/格挡角度", "攻击/格挡范围")
}

AddPropertyDefinition(id, englishName, chineseName, aliases*) {
    global PropertyCatalog, PropertyDisplayToId

    definition := {id: id, english: englishName, chinese: chineseName, aliases: []}
    for _, alias in aliases
        definition.aliases.Push(alias)

    PropertyCatalog[id] := definition
    RegisterPropertyDisplay(id, id)
    RegisterPropertyDisplay(id, englishName)
    RegisterPropertyDisplay(id, chineseName)
    for _, alias in aliases
        RegisterPropertyDisplay(id, alias)
}

RegisterPropertyDisplay(id, displayName) {
    global PropertyDisplayToId
    key := NormalizePropertyDisplay(displayName)
    if (key != "")
        PropertyDisplayToId[key] := id
}

NormalizePropertyDisplay(displayName) {
    displayName := Trim(displayName)
    displayName := RegExReplace(displayName, "\s+", " ")
    StringLower, displayName, displayName
    return displayName
}

ResolvePropertyId(displayName) {
    global PropertyCatalog, PropertyDisplayToId

    if (PropertyCatalog.HasKey(displayName))
        return displayName

    key := NormalizePropertyDisplay(displayName)
    return PropertyDisplayToId.HasKey(key) ? PropertyDisplayToId[key] : ""
}

GetPropertyRecognitionName(propertyId, recognitionLanguage := "English") {
    global PropertyCatalog

    if (!PropertyCatalog.HasKey(propertyId))
        return ""

    definition := PropertyCatalog[propertyId]
    if (recognitionLanguage = "Chinese-Simplified")
        return definition.chinese
    return definition.english
}

GetPropertyDisplayName(propertyId, uiLanguage := "English") {
    global PropertyCatalog

    if (!PropertyCatalog.HasKey(propertyId))
        return ""

    definition := PropertyCatalog[propertyId]
    return (uiLanguage = "Chinese-Simplified") ? definition.chinese : definition.english
}

GetPropertyDropDownList(uiLanguage := "English") {
    global PropertyCatalog

    list := ""
    for id, definition in PropertyCatalog {
        displayName := GetPropertyDisplayName(id, uiLanguage)
        list .= (list = "" ? "" : "|") . displayName
    }
    return list
}

ResolveLegacyPropertyPair(itemName, ByRef propertyId1, ByRef propertyId2) {
    propertyId1 := ""
    propertyId2 := ""
    parts := StrSplit(itemName, " - ")
    if (parts.Length() != 2)
        return false

    propertyId1 := ResolvePropertyId(Trim(parts[1]))
    propertyId2 := ResolvePropertyId(Trim(parts[2]))
    return (propertyId1 != "" && propertyId2 != "")
}
