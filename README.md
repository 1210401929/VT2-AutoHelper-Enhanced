# VT2 AutoHelper Enhanced

AutoHotkey v1.1 automation helper for *Warhammer: Vermintide 2*.

This enhanced version is based on the open-source [AutoHelper](https://github.com/ChadMasodin/AutoHelper) project by **ChadMasodin**. The OCR, property-value matching, maximum-roll detection, Chinese UI, and usability improvements are maintained by **余南松**.

## Features

- Open chests and salvage items.
- Salvage red items.
- Upgrade weapons or amulets in Athanor.
- Reroll two selected properties automatically.
- Optionally require both property values to reach user-defined targets.
- Optionally require both properties to reach the maximum values shown in their ranges.
- Test the selected property area without clicking the in-game Reroll button.
- Chinese user interface with independent English game/OCR recognition.
- Built-in coordinate presets plus user presets.

## Recommended setup

- Game language: **English**
- Display mode: **Borderless Window**
- Application language: Chinese-Simplified or any included UI language
- OCR/game recognition language: **English**

The application language does not control the OCR language. A Chinese application interface can be used together with the English game client.

## Quick start

1. Start Vermintide 2 and open the **Reroll Properties** screen.
2. Launch `AutoHelper.ahk` with AutoHotkey v1.1, or use a packaged release.
3. Select a built-in preset matching the game UI and resolution.
4. Set the target game window, Reroll button coordinate, and complete Properties text area.
5. Click **Test current item recognition** and verify the parsed names, current values, and ranges.
6. Select two target properties and configure manual target values or automatic maximum-value mode.
7. Start the reroll and keep the Stop hotkey available.

## Offline tests

Run with AutoHotkey v1.1:

```text
AutoHotkeyU64.exe AutoHelper\tests\PropertyValueMatcherTests.ahk
```

The tests cover numeric normalization, decimal commas, OCR-safe failures, property order changes, complete `Power vs ...` names, property ID mapping, and automatic maximum-value matching.

## Safety

AutoHelper uses screen OCR and simulated mouse input. It does not read or write game memory, inject DLLs, hook the game, modify game files, or bypass Easy Anti-Cheat.

## Credits

- Original project: [AutoHelper](https://github.com/ChadMasodin/AutoHelper)
- Original author: [ChadMasodin](https://github.com/ChadMasodin)
- Enhanced version author: 余南松
- Base version: AutoHelper v2.3
- Enhanced version: 1.0.0

The original Steam guide is available here: [How to automate routine processes in Vermintide 2](https://steamcommunity.com/sharedfiles/filedetails/?id=3434786311).
