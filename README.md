# ✨ AstralUI v2.0

**AstralUI** is a completely rewritten, premium-grade Roblox UI library — modern, beautiful, and packed with features that make WindUI look outdated.

- 🔹 1000000x better visuals than old libraries
- 🔹 Sidebar navigation with icons (like top exploit UIs)
- 🔹 Smooth animations, ripple effects, neon accents
- 🔹 Full multi-language support (English, Español, Français, Deutsch, Português + easy to add more)
- 🔹 7+ stunning themes (Dark, Midnight, Ocean, Rose, Emerald, Sunset, Neon)
- 🔹 Draggable floating Stats HUD
- 🔹 Background video support
- 🔹 Config system, notifications, dialogs, badges
- 🔹 DPI-aware auto-scaling (perfect on mobile, tablet, desktop, 4K)
- 🔹 Made for the next generation of Roblox script hubs

> **"This is what a 2026 UI library should look like."**

---

## 🚀 Quick Start

```lua
local AstralUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/VoidDeveloper67/Astral-Lib/refs/heads/main/main.lua"
))()

local Window = AstralUI:CreateWindow({
    Title = "VoidHub : Build-A-Ring-Farm",
    SubTitle = "by von63rd • v2.0",
    Size = UDim2.fromOffset(620, 420)
})

-- Create beautiful sidebar tabs
local MainTab = Window:CreateTab({ Title = "Core", Icon = "rbxassetid://10709791437" })
local ConfigTab = Window:CreateTab({ Title = "Settings", Icon = "rbxassetid://10734982144" })

-- Add stunning elements
MainTab:AddSection("Automation")

MainTab:AddToggle({
    Name = "Auto Unlock All Plots",
    Default = false,
    Badge = "New",
    Flag = "auto_unlock",
    Callback = function(v)
        Window:Notify({ Title = "Automation", Content = "Auto Unlock: " .. tostring(v) })
    end
})

MainTab:AddSlider({
    Name = "Plant Interval (sec)",
    Min = 1, Max = 60, Default = 10, Increment = 1,
    Flag = "plant_interval",
    Callback = function(v) print("Interval:", v) end
})

MainTab:AddButton({
    Name = "Force Plant All",
    Badge = "Hot",
    Callback = function()
        Window:Notify({ Title = "Success", Content = "All plots planted!" })
    end
})

-- Stats HUD (draggable floating overlay)
local HUD = Window:MakeStatsHUD({
    Stats = {"Ping", "FPS", "Playtime", "Time", "Players"},
    Position = UDim2.new(0, 12, 0.5, 0)
})

-- Change language live
AstralUI:SetLanguage("es") -- Español
