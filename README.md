# VT2 AutoHelper Enhanced

[简体中文](#简体中文) | [English](#english)

## 简体中文

基于 AutoHotkey v1.1 的《Warhammer: Vermintide 2》屏幕自动化辅助工具。

本增强版本基于 **ChadMasodin** 的开源项目 [AutoHelper](https://github.com/ChadMasodin/AutoHelper) 开发。OCR、词条数值匹配、满属性判断、简体中文界面及易用性优化由 **余南松** 维护。

### 主要功能

- 自动开箱和回收物品。
- 回收红色物品。
- 在 Athanor 中升级武器或项链。
- 自动重洗两个指定词条。
- 可选：两个词条的数值都达到用户设置的目标值后才停止。
- 可选：两个词条都达到界面所示的最大值后才停止。
- 提供独立 OCR 测试，不点击游戏内的重洗按钮即可检查当前物品识别结果。
- 软件界面语言与游戏/OCR 识别语言相互独立。
- 支持内置坐标预设和用户自定义预设。

### 推荐设置

- 游戏语言：**English**
- 显示模式：**无边框窗口**
- 软件界面语言：`Chinese-Simplified` 或其他已有语言
- 游戏/OCR 识别语言：**English**

软件界面语言不会强制改变 OCR 语言，因此可以同时使用简体中文软件界面和英文游戏客户端。

### 快速开始

1. 启动 Vermintide 2，打开 **Reroll Properties（重洗属性）**界面。
2. 使用 AutoHotkey v1.1 运行 `AutoHelper.ahk`，或者使用已打包的发布版本。
3. 选择与当前游戏界面及分辨率相符的内置预设。
4. 设置目标游戏窗口、重洗按钮坐标和完整的物品属性区域。
5. 点击**测试当前物品识别**，检查解析出的词条名称、当前值和数值范围。
6. 选择两个目标词条，并设置手动目标值或自动满属性模式。
7. 开始自动重洗，并确保随时可以使用停止热键。

### 离线测试

使用 AutoHotkey v1.1 执行：

```text
AutoHotkeyU64.exe AutoHelper\tests\PropertyValueMatcherTests.ahk
```

测试覆盖数值标准化、小数逗号、OCR 安全失败、词条顺序交换、完整 `Power vs ...` 名称、词条 ID 映射以及自动满属性判断。

### 安全说明

AutoHelper 仅使用屏幕 OCR 和模拟鼠标输入，不会读取或写入游戏内存，不会注入 DLL、Hook 游戏、修改游戏文件或绕过 Easy Anti-Cheat。

### 署名

- 原项目：[AutoHelper](https://github.com/ChadMasodin/AutoHelper)
- 原作者：[ChadMasodin](https://github.com/ChadMasodin)
- 增强版本作者：余南松
- 基础版本：AutoHelper v2.3
- 增强版本：1.0.0

原版 Steam 指南：[How to automate routine processes in Vermintide 2](https://steamcommunity.com/sharedfiles/filedetails/?id=3434786311)

---

## English

An AutoHotkey v1.1 screen-automation helper for *Warhammer: Vermintide 2*.

This enhanced version is based on the open-source [AutoHelper](https://github.com/ChadMasodin/AutoHelper) project by **ChadMasodin**. The OCR, property-value matching, maximum-roll detection, Simplified Chinese interface, and usability improvements are maintained by **余南松**.

### Features

- Open chests and salvage items automatically.
- Salvage red items.
- Upgrade weapons or amulets in Athanor.
- Reroll two selected properties automatically.
- Optionally stop only after both property values reach user-defined targets.
- Optionally stop only after both properties reach the maximum values shown in their ranges.
- Test the selected property area without clicking the in-game Reroll button.
- Use the application interface language independently from the game/OCR recognition language.
- Use built-in coordinate presets or user-defined presets.

### Recommended setup

- Game language: **English**
- Display mode: **Borderless Window**
- Application language: `Chinese-Simplified` or any other included language
- Game/OCR recognition language: **English**

The application language does not control the OCR language. You can use the Simplified Chinese interface together with the English game client.

### Quick start

1. Start Vermintide 2 and open the **Reroll Properties** screen.
2. Launch `AutoHelper.ahk` with AutoHotkey v1.1, or use a packaged release.
3. Select a built-in preset matching the game UI and resolution.
4. Set the target game window, Reroll button coordinate, and complete item Properties area.
5. Click **Test current item recognition** and verify the parsed property names, current values, and ranges.
6. Select two target properties and configure manual target values or automatic maximum-value mode.
7. Start rerolling and keep the Stop hotkey available.

### Offline tests

Run with AutoHotkey v1.1:

```text
AutoHotkeyU64.exe AutoHelper\tests\PropertyValueMatcherTests.ahk
```

The tests cover numeric normalization, decimal commas, OCR-safe failures, property-order changes, complete `Power vs ...` names, property ID mapping, and automatic maximum-value matching.

### Safety

AutoHelper uses screen OCR and simulated mouse input only. It does not read or write game memory, inject DLLs, hook the game, modify game files, or bypass Easy Anti-Cheat.

### Credits

- Original project: [AutoHelper](https://github.com/ChadMasodin/AutoHelper)
- Original author: [ChadMasodin](https://github.com/ChadMasodin)
- Enhanced version author: 余南松
- Base version: AutoHelper v2.3
- Enhanced version: 1.0.0

Original Steam guide: [How to automate routine processes in Vermintide 2](https://steamcommunity.com/sharedfiles/filedetails/?id=3434786311)
