# ✨ AstralUI v2.6

**AstralUI** is a complete ground-up rewrite of a Roblox UI library — cleaner, more beautiful, and more powerful than both the original VonLib and **WindUI**.

- 🔹 Modern sidebar navigation (exactly like top-tier hubs in your screenshot)
- 🔹 WindUI-style fluent API + major visual & animation upgrades
- 🔹 8 stunning themes with live switching
- 🔹 Full built-in multi-language support (English, Español, Français, Deutsch, Português)
- 🔹 Superior animations, ripple effects, and acrylic simulation
- 🔹 All essential elements: Toggle, Slider, Button, Dropdown, Keybind, ColorPicker, Notifications, Dialogs, Stats HUD
- 🔹 DPI auto-scaling, draggable windows & HUD, config system
- 🔹 Made for serious script hubs in 2026

> **"This is what a real modern Roblox UI library should look like."**

---

## 🚀 Quick Start

```lua
local AstralUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/VoidDeveloper67/Astral-Lib/refs/heads/main/main.lua"
))()

local Window = AstralUI:CreateWindow({
    Title = "VoidHub",
    Theme = "Dark",
    SideBarWidth = 58,
    Acrylic = true
})

local Main = Window:Tab({ Title = "Core Automation", Icon = "rbxassetid://10709791437" })

Main:Toggle({
    Title = "Auto Unlock All Plots",
    Value = false,
    Flag = "auto_unlock",
    Callback = function(v) print("Auto Unlock:", v) end
})

Main:Slider({
    Title = "Plant Interval (sec)",
    Min = 5, Max = 30, Default = 10,
    Flag = "plant_interval"
})

Main:Button({
    Title = "Force Plant All",
    Callback = function()
        Window:Notify({ Title = "Success", Content = "All plots planted!" })
    end
})

local HUD = Window:MakeStatsHUD({
    Stats = {"Ping", "FPS", "Playtime", "Time", "Players"}
})

AstralUI:SetLanguage("en") -- or "es", "fr", "de", "pt"
