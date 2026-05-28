# 🦊 Foxy Library

A clean, themeable, mobile-friendly Roblox UI library.  
Drop `Main.lua` into your script and you’re ready to go.

-----

## Quick Start

```lua
local FoxyLib = loadstring(game:HttpGet("YOUR_RAW_URL"))()

local lib = FoxyLib.new({
    Name         = "My Script",
    AccentColor  = Color3.fromRGB(130, 75, 255),
})

local section = lib:AddSection("Main")
local tab     = section:AddTab({ Name = "Combat" })
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

## Creating the Library

```lua
local lib = FoxyLib.new(config)
```

|Field            |Type  |Default         |Description                               |
|-----------------|------|----------------|------------------------------------------|
|`Name`           |string|`"Foxy Library"`|Window title shown in the UI              |
|`AccentColor`    |Color3|Blue            |Highlight color for toggles, sliders, etc.|
|`BackgroundColor`|Color3|Dark grey       |Main window background                    |
|`SecondaryColor` |Color3|Slightly lighter|Secondary panels / groups                 |
|`TextColor`      |Color3|White           |Primary text                              |
|`SubTextColor`   |Color3|Grey            |Labels, hints                             |

-----

## Structure

The UI follows a 4-level hierarchy:

```
lib  (library)
 └─ Section  :AddSection(name)
      └─ Tab      :AddTab({ Name })
           └─ Group   :AddGroup({ Name })
                └─ Widgets  (toggle, slider, button …)
```

-----

## `lib` Methods

### `lib:AddSection(name)`

Creates a new section (a top-level page/nav entry).  
Returns a **sectionObj**.

```lua
local section = lib:AddSection("Visuals")
```

-----

### `lib:SetToggleKey(keyCode)`

Sets the keyboard key that shows/hides the menu.

```lua
lib:SetToggleKey(Enum.KeyCode.Insert)
```

-----

### `lib:ToggleUI()`

Programmatically show or hide the menu.

-----

### `lib:Notify(config)`

Shows a toast notification in the corner.

```lua
lib:Notify({
    Title       = "Loaded",
    Description = "Script v1.0 ready.",
    Duration    = 3,                          -- seconds (min 0.8)
    Icon        = "rbxassetid://10747361219", -- optional image id
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

Loads and applies a saved config.  
Returns `true, path` on success or `false, errorMessage`.

```lua
lib:LoadConfig("default")
```

-----

### `lib:Destroy()`

Destroys the entire UI and disconnects all connections.

-----

## Section → Tab

### `section:AddTab(config)`

```lua
local tab = section:AddTab({ Name = "Tab Name" })
```

Returns a **tabObj**. Methods: `:Activate()`, `:Deactivate()`.

-----

## Tab → Group

### `tab:AddGroup(config)`

```lua
local group = tab:AddGroup({ Name = "Group Name" })
```

Returns a **groupObj** to which you add all widgets.

-----

## Widgets

All widgets are added to a **group**. Every widget that holds a value has:

- **`:Set(value)`** — programmatically update the value
- **`:Get()`** — read the current value
- **`Flag`** field — unique string key used by `SaveConfig`/`LoadConfig`

-----

### Toggle

```lua
local toggle = group:AddToggle({
    Name     = "Aimbot",
    Default  = false,         -- initial state
    Flag     = "aimbot",      -- save key (auto-generated if omitted)
    Callback = function(value)
        -- value is true/false
    end,
})

toggle:Set(true)
print(toggle:Get())  -- true
```

-----

### Slider

```lua
local slider = group:AddSlider({
    Name      = "FOV",
    Min       = 10,
    Max       = 360,
    Default   = 90,
    Increment = 1,            -- step size
    Flag      = "fov",
    Callback  = function(value)
        print("FOV:", value)
    end,
})

slider:Set(120)
```

-----

### Button

```lua
group:AddButton({
    Name     = "Teleport Home",
    Icon     = "rbxassetid://...",  -- optional
    Locked   = false,               -- greys out the button if true
    Callback = function()
        -- fired on click
    end,
})
```

-----

### Dropdown

```lua
local dd = group:AddDropdown({
    Name    = "Target Part",
    Options = { "Head", "Torso", "HumanoidRootPart" },
    Default = "Head",
    Flag    = "aimTarget",
    Callback = function(value)
        print("Selected:", value)
    end,
})

dd:Set("Torso")
print(dd:Get())  -- "Torso"
```

**Dynamic options** — use `OptionsProvider` to refresh the list automatically:

```lua
group:AddDropdown({
    Name            = "Players",
    OptionsProvider = function()
        local names = {}
        for _, p in ipairs(game.Players:GetPlayers()) do
            table.insert(names, p.Name)
        end
        return names
    end,
    AutoRefresh     = true,   -- re-calls OptionsProvider periodically
    RefreshInterval = 1,      -- seconds between refreshes
    Callback = function(value) end,
})
```

-----

### Multi-Select Dropdown

```lua
local mdd = group:AddMultiDropdown({
    Name     = "Features",
    Options  = { "ESP", "Aimbot", "Fly", "NoClip" },
    Default  = { "ESP" },     -- table of initially selected options
    Flag     = "features",
    Callback = function(selected)
        -- selected is a table: { "ESP", "Fly" }
    end,
})
```

-----

### Keybind

```lua
local kb = group:AddKeybind({
    Name              = "Fly Key",
    Default           = Enum.KeyCode.F,
    Mode              = "Toggle",    -- "Toggle" or "Hold"
    Flag              = "flyKey",
    Callback          = function(active) end,   -- fired when key activates
    ChangedCallback   = function(newKey) end,   -- fired when key is rebound
    ModeChangedCallback = function(mode) end,
})
```

-----

### Keybind Toggle

A combined keybind + toggle in one row — the keybind activates the feature and the toggle switches it on/off.

```lua
group:AddKeybindToggle({
    Name          = "Aimbot",
    Default       = false,
    KeyDefault    = Enum.KeyCode.Q,
    KeyMode       = "Hold",
    Flag          = "aimbotEnabled",
    KeyFlag       = "aimbotKey",
    Callback      = function(value) end,
    KeyCallback   = function(active) end,
})
```

-----

### Color Picker

```lua
local cp = group:AddColorPicker({
    Name     = "ESP Color",
    Default  = Color3.fromRGB(255, 50, 50),
    Flag     = "espColor",
    Callback = function(color)
        -- color is a Color3
    end,
})

cp:Set(Color3.fromRGB(0, 255, 128))
print(cp:Get())
```

-----

### Text Input

```lua
local input = group:AddTextInput({
    Name        = "Custom Name",
    Placeholder = "Enter name...",
    Default     = "",
    Flag        = "customName",
    Callback    = function(text)
        print("Entered:", text)
    end,
})
```

-----

### Label

```lua
group:AddLabel({
    Text = "This is an info label.",
    Wrap = true,   -- wrap to multiple lines if needed
})
```

-----

### Divider

```lua
group:AddDivider()
```

Inserts a thin horizontal rule between elements.

-----

## Flags & Config System

Every control that holds a value accepts a `Flag` key. Flags are used to save and restore configs:

```lua
-- Save current state of all controls
lib:SaveConfig("slot1")   -- writes FoxyConfigs/slot1.json

-- Restore it later
lib:LoadConfig("slot1")
```

Auto-generated flags are derived from the widget name, but **explicit flags are recommended** for stability across script updates.

-----

## Tips

- **Mobile support** — the library auto-detects touch devices and scales everything down via `mobileScaleFactor`.
- **Theme at runtime** — change `lib.config.AccentColor` then call `lib:CreateUIBecauseWeNeedIt()` to rebuild, or tween the color on individual elements.
- **Overlay effects** — Snow, Rain, Stars and None modes are built in. Call `lib:_SetOverlayMode("Snow")` to activate.
- **Text gradient** — call `lib:_SetTextGradientEnabled(true)` for animated gradient labels.
