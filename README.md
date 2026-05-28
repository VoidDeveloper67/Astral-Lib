<div align="center">

# 🦊 Foxy Library

**A clean, themeable, mobile-friendly Roblox UI library.**

[![Lua](https://img.shields.io/badge/Language-Lua-blue?style=flat-square)](https://www.lua.org/)
[![Roblox](https://img.shields.io/badge/Platform-Roblox-red?style=flat-square)](https://www.roblox.com/)
[![License](https://img.shields.io/badge/License-Free-green?style=flat-square)]()

</div>

-----

## 📦 Load

```lua
local FoxyLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/VoidDeveloper67/Foxy-Library/main/Main.lua"
))()
```

-----

## ⚡ Quick Start

```lua
local FoxyLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/VoidDeveloper67/Foxy-Library/main/Main.lua"
))()

local lib = FoxyLib.new({
    Name        = "My Script",
    AccentColor = Color3.fromRGB(130, 75, 255),
})

local section = lib:CreateSection({ Name = "Main" })
local tab     = section:AddTab({ Name = "Combat", Description = "Combat features" })
local group   = tab:AddGroup({ Name = "Settings" })

group:AddToggle({
    Name     = "Silent Aim",
    Default  = false,
    Callback = function(value)
        print("Silent Aim:", value)
    end,
})
```

-----

## 🏗️ UI Structure

```
FoxyLib.new()                  -- creates the window
  └─ lib:CreateSection()       -- left-side nav section
       └─ section:AddTab()     -- tab inside a section
            └─ tab:AddGroup()  -- group/box inside a tab
                 └─ Widgets    -- toggle, slider, button …
```

-----

## 🎨 `FoxyLib.new(config)`

|Field            |Type  |Default         |Description                        |
|-----------------|------|----------------|-----------------------------------|
|`Name`           |string|`"Foxy Library"`|Window title                       |
|`AccentColor`    |Color3|Blue            |Highlight color for active elements|
|`BackgroundColor`|Color3|Dark grey       |Main window background             |
|`SecondaryColor` |Color3|Slightly lighter|Secondary panels                   |
|`TextColor`      |Color3|White           |Primary text                       |
|`SubTextColor`   |Color3|Grey            |Labels and hints                   |

-----

## 📚 Library Methods

### `lib:CreateSection(config)`

Creates a left-side navigation section. Returns a **sectionObj**.

|Field |Type             |Default     |
|------|-----------------|------------|
|`Name`|string           |`"Section"` |
|`Icon`|string (asset id)|default icon|

```lua
local section = lib:CreateSection({ Name = "Visuals" })
```

-----

### `lib:SetToggleKey(keyCode)`

Sets the key that shows/hides the menu.

```lua
lib:SetToggleKey(Enum.KeyCode.Insert)
```

-----

### `lib:ToggleUI()`

Programmatically show or hide the window.

-----

### `lib:SetAccentColor(color)`

Updates the accent color live across all elements.

```lua
lib:SetAccentColor(Color3.fromRGB(255, 100, 50))
```

-----

### `lib:Notify(config)`

Shows a toast notification.

|Field        |Type             |Default         |
|-------------|-----------------|----------------|
|`Title`      |string           |`"Notification"`|
|`Description`|string           |*(none)*        |
|`Duration`   |number           |`3` (min `0.8`) |
|`Icon`       |string (asset id)|default icon    |

```lua
lib:Notify({
    Title       = "Loaded!",
    Description = "Foxy Library v1.0",
    Duration    = 3,
})
```

-----

### `lib:SaveConfig(fileName)`

Saves all control values to `FoxyConfigs/<fileName>.json`.
Returns `true, path` on success or `false, errorMessage`.

```lua
local ok, result = lib:SaveConfig("default")
```

-----

### `lib:LoadConfig(fileName)`

Loads and applies a saved config file.
Returns `true, path` on success or `false, errorMessage`.

```lua
lib:LoadConfig("default")
```

-----

### `lib:Destroy()`

Destroys the entire UI and disconnects all connections.

-----

## 🗂️ Section → Tab → Group

### `section:AddTab(config)`

|Field        |Type             |Default            |
|-------------|-----------------|-------------------|
|`Name`       |string           |`"Tab"`            |
|`Description`|string           |`"Tab description"`|
|`Icon`       |string (asset id)|default icon       |

```lua
local tab = section:AddTab({
    Name        = "Aimbot",
    Description = "Aim assistance features",
})
```

-----

### `tab:AddGroup(config)`

|Field |Type             |Default     |
|------|-----------------|------------|
|`Name`|string           |`"Group"`   |
|`Side`|string           |`"Left"`    |
|`Icon`|string (asset id)|default icon|

`Side` can be `"Left"` or `"Right"` to place groups in two columns.

```lua
local group = tab:AddGroup({ Name = "Settings", Side = "Left" })
```

-----

## 🧩 Widgets

Every value-holding widget supports:

- **`:Set(value)`** — update the value programmatically
- **`:Get()`** — read the current value
- **`Flag`** — unique string key used by `SaveConfig` / `LoadConfig` (auto-generated if omitted)

-----

### ✅ Toggle

```lua
local toggle = group:AddToggle({
    Name     = "Aimbot",
    Default  = false,
    Flag     = "aimbot",
    Callback = function(value) end,
})
toggle:Set(true)
toggle:Get()  -- true
```

-----

### 🎚️ Slider

```lua
local slider = group:AddSlider({
    Name      = "FOV",
    Min       = 10,
    Max       = 360,
    Default   = 90,
    Increment = 1,
    Flag      = "fov",
    Callback  = function(value) end,
})
slider:Set(120)
```

-----

### 🔘 Button

```lua
group:AddButton({
    Name     = "Teleport Home",
    Icon     = "rbxassetid://...",  -- optional
    Locked   = false,               -- greys out if true
    Callback = function() end,
})
```

-----

### 📋 Dropdown

```lua
local dd = group:AddDropdown({
    Name     = "Target Part",
    Options  = { "Head", "Torso", "HumanoidRootPart" },
    Default  = "Head",
    Flag     = "aimTarget",
    Callback = function(value) end,
})
dd:Set("Torso")
```

**Dynamic options** — use `OptionsProvider` to auto-refresh the list:

```lua
group:AddDropdown({
    Name            = "Players",
    OptionsProvider = function()
        local t = {}
        for _, p in ipairs(game.Players:GetPlayers()) do
            table.insert(t, p.Name)
        end
        return t
    end,
    AutoRefresh     = true,
    RefreshInterval = 1,
    Callback = function(value) end,
})
```

-----

### 📋 Multi-Select Dropdown

```lua
local mdd = group:AddMultiDropdown({
    Name     = "Features",
    Options  = { "ESP", "Aimbot", "Fly", "NoClip" },
    Default  = { "ESP" },       -- table of pre-selected options
    Flag     = "features",
    Callback = function(selected) end,  -- selected is a table
})
```

-----

### ⌨️ Keybind

```lua
group:AddKeybind({
    Name                = "Fly Key",
    Default             = Enum.KeyCode.F,
    Mode                = "Toggle",         -- "Toggle" or "Hold"
    Flag                = "flyKey",
    Callback            = function(active) end,
    ChangedCallback     = function(newKey) end,
    ModeChangedCallback = function(mode) end,
})
```

-----

### ⌨️ Keybind Toggle

A keybind and a toggle combined in one row.

```lua
group:AddKeybindToggle({
    Name        = "Aimbot",
    Default     = false,
    KeyDefault  = Enum.KeyCode.Q,
    KeyMode     = "Hold",
    Flag        = "aimbotEnabled",
    KeyFlag     = "aimbotKey",
    Callback    = function(value) end,
    KeyCallback = function(active) end,
})
```

-----

### 🎨 Color Picker

```lua
local cp = group:AddColorPicker({
    Name     = "ESP Color",
    Default  = Color3.fromRGB(255, 50, 50),
    Flag     = "espColor",
    Callback = function(color) end,
})
cp:Set(Color3.fromRGB(0, 255, 128))
```

-----

### ✏️ Text Input

```lua
group:AddTextInput({
    Name        = "Player Name",
    Placeholder = "Enter name...",
    Default     = "",
    Flag        = "playerName",
    Callback    = function(text) end,
})
```

-----

### 🏷️ Label

```lua
group:AddLabel({
    Text = "This is an info label.",
    Wrap = true,    -- wrap to multiple lines if needed
})
```

-----

### ─ Divider

```lua
group:AddDivider()
```

-----

## 💾 Config System

Set explicit `Flag` strings on controls so saved configs stay stable across updates:

```lua
group:AddToggle({ Name = "ESP", Flag = "esp_enabled", Callback = ... })
```

Then save and load anywhere:

```lua
lib:SaveConfig("slot1")   -- writes to FoxyConfigs/slot1.json
lib:LoadConfig("slot1")   -- restores all control values
```

-----

## 💡 Tips

- **Mobile** — auto-detected; UI scales down automatically on touch devices.
- **Accent color** — update live with `lib:SetAccentColor(color)`.
- **Overlay effects** — Snow, Rain, Stars. Use `lib:_SetOverlayMode("Snow")`.
- **Text gradient** — `lib:_SetTextGradientEnabled(true)` animates label colors.
- **Background FX** — `lib:_SetBackgroundEffectsEnabled(true)`.
- **Executor support** — works with `syn.protect_gui`, `gethui`, or falls back to `PlayerGui`.

-----

<div align="center">
Made by <b>VoidDeveloper67</b>
</div>
