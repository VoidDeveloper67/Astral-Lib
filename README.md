# ✨ AstralUI v3.0

**AstralUI v3.0** is a high-quality, modern Roblox UI library extracted and cleaned from a premium source. It features a beautiful sidebar, smooth animations, visual effects (blur, snow, rain, stars, text gradients), mobile support, and a clean fluent API.

- Modern sidebar navigation (matches top-tier hubs)
- Excellent animations and ripple effects
- 8+ visual effects (Blur, Snow, Rain, Stars, Text Gradient, etc.)
- Full element support: Toggle, Slider, Button, Dropdown (with search), Keybind, ColorPicker
- Notifications, Stats HUD, Draggable window
- Mobile-optimized scaling
- Config system + font presets
- Much better than previous versions and WindUI

---

## Quick Start

```lua
local AstralUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/VoidDeveloper67/Astral-Lib/refs/heads/main/main.lua"
))()

local Window = AstralUI:CreateWindow({
    Title = "VoidHub",
    AccentColor = Color3.fromRGB(130, 75, 255)
})

local Main = Window:Tab({ Title = "Core Automation", Icon = "rbxassetid://10709791437" })

Main:Toggle({ Title = "Auto Unlock All Plots", Value = false, Flag = "unlock" })
Main:Slider({ Title = "Plant Interval", Min = 5, Max = 30, Default = 10, Flag = "interval" })
Main:Button({ Title = "Force Plant All", Callback = function() Window:Notify({Title="Done"}) end })

Window:MakeStatsHUD({ Stats = {"Ping","FPS","Playtime","Time"} })
