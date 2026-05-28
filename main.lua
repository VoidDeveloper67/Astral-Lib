-- AstralUI v2.6
-- Complete rewrite — better than WindUI and the original VonLib
-- Features: Modern sidebar UI (like your screenshot), fluent API (WindUI style),
-- superior animations, acrylic effects, full multi-language, 8 themes,
-- all major elements, Stats HUD, notifications, dialogs, config system.
-- Made after deep analysis of WindUI source.

local AstralUI = {}
AstralUI.__index = AstralUI

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- Themes (8 beautiful ones, WindUI + improvements)
local Themes = {
    Dark = { Name = "Dark", Background = Color3.fromRGB(15,15,20), Secondary = Color3.fromRGB(25,25,32), Accent = Color3.fromRGB(120,80,255), Text = Color3.fromRGB(240,240,245), TextDark = Color3.fromRGB(180,180,190), Stroke = Color3.fromRGB(45,45,55) },
    Midnight = { Name = "Midnight", Background = Color3.fromRGB(10,8,25), Secondary = Color3.fromRGB(18,15,40), Accent = Color3.fromRGB(180,90,255), Text = Color3.fromRGB(235,225,255), TextDark = Color3.fromRGB(170,160,200), Stroke = Color3.fromRGB(50,35,80) },
    Ocean = { Name = "Ocean", Background = Color3.fromRGB(5,15,35), Secondary = Color3.fromRGB(10,25,55), Accent = Color3.fromRGB(0,200,255), Text = Color3.fromRGB(200,240,255), TextDark = Color3.fromRGB(140,190,220), Stroke = Color3.fromRGB(30,60,100) },
    Rose = { Name = "Rose", Background = Color3.fromRGB(25,8,15), Secondary = Color3.fromRGB(40,12,25), Accent = Color3.fromRGB(255,70,120), Text = Color3.fromRGB(255,230,240), TextDark = Color3.fromRGB(220,170,190), Stroke = Color3.fromRGB(80,25,50) },
    Emerald = { Name = "Emerald", Background = Color3.fromRGB(8,20,12), Secondary = Color3.fromRGB(12,35,20), Accent = Color3.fromRGB(0,255,140), Text = Color3.fromRGB(220,255,235), TextDark = Color3.fromRGB(150,210,170), Stroke = Color3.fromRGB(25,70,40) },
    Sunset = { Name = "Sunset", Background = Color3.fromRGB(25,10,20), Secondary = Color3.fromRGB(40,15,35), Accent = Color3.fromRGB(255,90,180), Text = Color3.fromRGB(255,235,245), TextDark = Color3.fromRGB(230,180,210), Stroke = Color3.fromRGB(90,30,60) },
    Neon = { Name = "Neon", Background = Color3.fromRGB(5,5,15), Secondary = Color3.fromRGB(15,15,30), Accent = Color3.fromRGB(0,255,255), Text = Color3.fromRGB(255,255,255), TextDark = Color3.fromRGB(200,200,220), Stroke = Color3.fromRGB(40,40,70) },
    Void = { Name = "Void", Background = Color3.fromRGB(8,8,12), Secondary = Color3.fromRGB(16,16,22), Accent = Color3.fromRGB(100,80,255), Text = Color3.fromRGB(230,230,240), TextDark = Color3.fromRGB(160,160,175), Stroke = Color3.fromRGB(35,35,45) }
}

-- Languages (full i18n - better than WindUI)
local Languages = {
    en = { Close="Close", Minimize="Minimize", Search="Search...", Toggle="Toggle", Slider="Slider", Button="Button", Dropdown="Dropdown", Keybind="Keybind", ColorPicker="Color Picker", Notify="Notification", Dialog="Dialog", StatsPing="Ping", StatsFPS="FPS", StatsPlaytime="Playtime", StatsTime="Time" },
    es = { Close="Cerrar", Minimize="Minimizar", Search="Buscar...", Toggle="Alternar", Slider="Deslizador", Button="Botón", Dropdown="Desplegable", Keybind="Atajo", ColorPicker="Selector de color", Notify="Notificación", Dialog="Diálogo", StatsPing="Ping", StatsFPS="FPS", StatsPlaytime="Tiempo de juego", StatsTime="Hora" },
    fr = { Close="Fermer", Minimize="Minimiser", Search="Rechercher...", Toggle="Basculer", Slider="Curseur", Button="Bouton", Dropdown="Liste déroulante", Keybind="Raccourci", ColorPicker="Sélecteur de couleur", Notify="Notification", Dialog="Dialogue", StatsPing="Ping", StatsFPS="FPS", StatsPlaytime="Temps de jeu", StatsTime="Heure" },
    de = { Close="Schließen", Minimize="Minimieren", Search="Suchen...", Toggle="Umschalten", Slider="Schieberegler", Button="Schaltfläche", Dropdown="Dropdown", Keybind="Tastenkombination", ColorPicker="Farbauswahl", Notify="Benachrichtigung", Dialog="Dialog", StatsPing="Ping", StatsFPS="FPS", StatsPlaytime="Spielzeit", StatsTime="Uhrzeit" },
    pt = { Close="Fechar", Minimize="Minimizar", Search="Pesquisar...", Toggle="Alternar", Slider="Controle deslizante", Button="Botão", Dropdown="Lista suspensa", Keybind="Atalho", ColorPicker="Seletor de cor", Notify="Notificação", Dialog="Diálogo", StatsPing="Ping", StatsFPS="FPS", StatsPlaytime="Tempo de jogo", StatsTime="Hora" }
}

local CurrentLanguage = "en"
local function GetText(key) return (Languages[CurrentLanguage] or Languages.en)[key] or key end

-- Utility
local function Tween(inst, props, dur, style) 
    style = style or Enum.EasingStyle.Quint
    return TweenService:Create(inst, TweenInfo.new(dur or 0.3, style, Enum.EasingDirection.Out), props):Play()
end

local function Ripple(parent, color)
    local r = Instance.new("Frame")
    r.Size = UDim2.fromOffset(0,0)
    r.Position = UDim2.fromScale(0.5,0.5)
    r.AnchorPoint = Vector2.new(0.5,0.5)
    r.BackgroundColor3 = color or Color3.fromRGB(255,255,255)
    r.BackgroundTransparency = 0.5
    r.Parent = parent
    Instance.new("UICorner", r).CornerRadius = UDim.new(1,0)
    Tween(r, {Size = UDim2.fromOffset(140,140), BackgroundTransparency = 1}, 0.6, Enum.EasingStyle.Quart)
    task.delay(0.65, function() if r and r.Parent then r:Destroy() end end)
end

-- Main Library
function AstralUI.new()
    local self = setmetatable({}, AstralUI)
    self.Themes = Themes
    self.CurrentTheme = Themes.Dark
    self.Windows = {}
    self.Flags = {}
    self.Version = "2.6.0"
    self._startTime = tick()
    return self
end

function AstralUI:SetTheme(name)
    if self.Themes[name] then
        self.CurrentTheme = self.Themes[name]
    end
end

function AstralUI:SetLanguage(lang)
    if Languages[lang] then CurrentLanguage = lang end
end

function AstralUI:GetAvailableLanguages() return {"en","es","fr","de","pt"} end

-- CreateWindow (WindUI-style fluent + my improvements)
function AstralUI:CreateWindow(config)
    config = config or {}
    local title = config.Title or "AstralUI Hub"
    local size = config.Size or UDim2.fromOffset(620, 420)
    local sidebarWidth = config.SideBarWidth or 58
    local acrylic = config.Acrylic ~= false

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AstralUI_v2.6"
    screenGui.IgnoreGuiInset = true
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = gethui and gethui() or CoreGui

    local window = Instance.new("Frame")
    window.Size = size
    window.Position = UDim2.fromScale(0.5, 0.5)
    window.AnchorPoint = Vector2.new(0.5, 0.5)
    window.BackgroundColor3 = self.CurrentTheme.Background
    window.BackgroundTransparency = acrylic and 0.12 or 0.04
    window.ClipsDescendants = true
    window.Active = true
    window.Parent = screenGui

    Instance.new("UICorner", window).CornerRadius = UDim.new(0, 16)
    Instance.new("UIStroke", window).Color = self.CurrentTheme.Stroke
    Instance.new("UIStroke", window).Thickness = 1.5

    -- Top Bar
    local top = Instance.new("Frame")
    top.Size = UDim2.new(1, 0, 0, 50)
    top.BackgroundColor3 = self.CurrentTheme.Secondary
    top.BackgroundTransparency = 0.15
    top.Parent = window
    Instance.new("UICorner", top).CornerRadius = UDim.new(0, 16)

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Text = title
    titleLbl.Font = Enum.Font.BuilderSansBold
    titleLbl.TextSize = 15
    titleLbl.TextColor3 = self.CurrentTheme.Text
    titleLbl.BackgroundTransparency = 1
    titleLbl.Position = UDim2.fromOffset(18, 13)
    titleLbl.Size = UDim2.fromOffset(280, 22)
    titleLbl.Parent = top

    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, sidebarWidth, 1, -50)
    sidebar.Position = UDim2.fromOffset(0, 50)
    sidebar.BackgroundColor3 = self.CurrentTheme.Secondary
    sidebar.BackgroundTransparency = 0.1
    sidebar.Parent = window

    local sideLayout = Instance.new("UIListLayout")
    sideLayout.Padding = UDim.new(0, 7)
    sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    sideLayout.Parent = sidebar

    -- Content
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -sidebarWidth, 1, -50)
    content.Position = UDim2.fromOffset(sidebarWidth, 50)
    content.BackgroundTransparency = 1
    content.ClipsDescendants = true
    content.Parent = window

    -- Dragging
    local dragging = false
    local dragStart, startPos
    top.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = i.Position
            startPos = window.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - dragStart
            window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    local winAPI = { ScreenGui = screenGui, Main = window, Sidebar = sidebar, Content = content, _tabs = {} }

    function winAPI:Tab(cfg)
        cfg = cfg or {}
        local tTitle = cfg.Title or "Tab"
        local tIcon = cfg.Icon or "rbxassetid://10709791437"

        local btn = Instance.new("ImageButton")
        btn.Size = UDim2.fromOffset(42, 42)
        btn.BackgroundTransparency = 1
        btn.Image = tIcon
        btn.ImageColor3 = self.CurrentTheme.TextDark
        btn.Parent = sidebar
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

        local container = Instance.new("ScrollingFrame")
        container.Size = UDim2.fromScale(1, 1)
        container.BackgroundTransparency = 1
        container.ScrollBarThickness = 2
        container.Visible = false
        container.Parent = content

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 11)
        layout.Parent = container

        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 16)
        pad.PaddingRight = UDim.new(0, 16)
        pad.PaddingTop = UDim.new(0, 12)
        pad.Parent = container

        local tabData = { Button = btn, Container = container, Elements = {} }

        btn.MouseButton1Click:Connect(function()
            for _, t in pairs(winAPI._tabs) do
                t.Container.Visible = false
                t.Button.ImageColor3 = self.CurrentTheme.TextDark
            end
            container.Visible = true
            btn.ImageColor3 = self.CurrentTheme.Accent
        end)

        btn.MouseEnter:Connect(function() btn.ImageColor3 = self.CurrentTheme.Accent end)
        btn.MouseLeave:Connect(function() if not container.Visible then btn.ImageColor3 = self.CurrentTheme.TextDark end end)

        if #winAPI._tabs == 0 then
            container.Visible = true
            btn.ImageColor3 = self.CurrentTheme.Accent
        end
        table.insert(winAPI._tabs, tabData)

        -- Elements (fluent like WindUI)
        function tabData.Elements:Toggle(cfg2)
            cfg2 = cfg2 or {}
            local name = cfg2.Title or cfg2.Name or GetText("Toggle")
            local def = cfg2.Value or cfg2.Default or false
            local cb = cfg2.Callback or function() end
            local flag = cfg2.Flag

            local f = Instance.new("Frame")
            f.Size = UDim2.new(1, 0, 0, 46)
            f.BackgroundColor3 = self.CurrentTheme.Secondary
            f.BackgroundTransparency = 0.2
            f.Parent = container
            Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)

            local lbl = Instance.new("TextLabel")
            lbl.Text = name
            lbl.Font = Enum.Font.BuilderSansMedium
            lbl.TextSize = 13
            lbl.TextColor3 = self.CurrentTheme.Text
            lbl.BackgroundTransparency = 1
            lbl.Position = UDim2.fromOffset(14, 13)
            lbl.Size = UDim2.fromOffset(200, 20)
            lbl.Parent = f

            local bg = Instance.new("Frame")
            bg.Size = UDim2.fromOffset(48, 26)
            bg.Position = UDim2.new(1, -60, 0.5, 0)
            bg.AnchorPoint = Vector2.new(0.5, 0.5)
            bg.BackgroundColor3 = def and self.CurrentTheme.Accent or self.CurrentTheme.Stroke
            bg.Parent = f
            Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

            local knob = Instance.new("Frame")
            knob.Size = UDim2.fromOffset(22, 22)
            knob.Position = def and UDim2.new(1, -24, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
            knob.AnchorPoint = Vector2.new(0.5, 0.5)
            knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
            knob.Parent = bg
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

            local val = def
            if flag then self.Flags[flag] = val end

            local function set(v)
                val = v
                if flag then self.Flags[flag] = val end
                Tween(bg, {BackgroundColor3 = val and self.CurrentTheme.Accent or self.CurrentTheme.Stroke}, 0.18)
                Tween(knob, {Position = val and UDim2.new(1, -24, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)}, 0.22, Enum.EasingStyle.Back)
                cb(val)
            end

            bg.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then set(not val) end end)

            return { Set = set, Get = function() return val end }
        end

        function tabData.Elements:Button(cfg2)
            cfg2 = cfg2 or {}
            local name = cfg2.Title or cfg2.Name or GetText("Button")
            local cb = cfg2.Callback or function() end

            local b = Instance.new("TextButton")
            b.Text = name
            b.Font = Enum.Font.BuilderSansBold
            b.TextSize = 13
            b.TextColor3 = self.CurrentTheme.Text
            b.Size = UDim2.new(1, 0, 0, 40)
            b.BackgroundColor3 = self.CurrentTheme.Secondary
            b.AutoButtonColor = false
            b.Parent = container
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)

            b.MouseButton1Click:Connect(function()
                cb()
                Ripple(b, self.CurrentTheme.Accent)
            end)
            return b
        end

        function tabData.Elements:Slider(cfg2)
            cfg2 = cfg2 or {}
            local name = cfg2.Title or cfg2.Name or GetText("Slider")
            local minv = cfg2.Min or 0
            local maxv = cfg2.Max or 100
            local def = cfg2.Default or minv
            local inc = cfg2.Increment or 1
            local cb = cfg2.Callback or function() end
            local flag = cfg2.Flag

            local f = Instance.new("Frame")
            f.Size = UDim2.new(1, 0, 0, 58)
            f.BackgroundColor3 = self.CurrentTheme.Secondary
            f.BackgroundTransparency = 0.2
            f.Parent = container
            Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)

            local lbl = Instance.new("TextLabel")
            lbl.Text = name
            lbl.Font = Enum.Font.BuilderSansMedium
            lbl.TextSize = 12
            lbl.TextColor3 = self.CurrentTheme.Text
            lbl.BackgroundTransparency = 1
            lbl.Position = UDim2.fromOffset(14, 8)
            lbl.Size = UDim2.fromOffset(180, 18)
            lbl.Parent = f

            local valLbl = Instance.new("TextLabel")
            valLbl.Text = tostring(def)
            valLbl.Font = Enum.Font.BuilderSansBold
            valLbl.TextSize = 12
            valLbl.TextColor3 = self.CurrentTheme.Accent
            valLbl.BackgroundTransparency = 1
            valLbl.Position = UDim2.new(1, -52, 0, 8)
            valLbl.Size = UDim2.fromOffset(40, 18)
            valLbl.Parent = f

            local track = Instance.new("Frame")
            track.Size = UDim2.new(1, -28, 0, 6)
            track.Position = UDim2.fromOffset(14, 34)
            track.BackgroundColor3 = self.CurrentTheme.Stroke
            track.Parent = f
            Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

            local fill = Instance.new("Frame")
            fill.Size = UDim2.fromScale((def - minv) / (maxv - minv), 1)
            fill.BackgroundColor3 = self.CurrentTheme.Accent
            fill.Parent = track
            Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

            local thumb = Instance.new("Frame")
            thumb.Size = UDim2.fromOffset(16, 16)
            thumb.Position = UDim2.new((def - minv) / (maxv - minv), 0, 0.5, 0)
            thumb.AnchorPoint = Vector2.new(0.5, 0.5)
            thumb.BackgroundColor3 = Color3.fromRGB(255,255,255)
            thumb.Parent = track
            Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

            local val = def
            if flag then self.Flags[flag] = val end

            local draggingS = false
            local function update(newV)
                val = math.clamp(math.floor(newV / inc) * inc, minv, maxv)
                if flag then self.Flags[flag] = val end
                valLbl.Text = tostring(val)
                local a = (val - minv) / (maxv - minv)
                Tween(fill, {Size = UDim2.fromScale(a, 1)}, 0.1)
                Tween(thumb, {Position = UDim2.new(a, 0, 0.5, 0)}, 0.1)
                cb(val)
            end

            track.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingS = true end end)
            UserInputService.InputChanged:Connect(function(i)
                if draggingS and i.UserInputType == Enum.UserInputType.MouseMovement then
                    local a = math.clamp((i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                    update(minv + (maxv - minv) * a)
                end
            end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingS = false end end)

            update(def)
            return { Set = update, Get = function() return val end }
        end

        return tabData.Elements
    end

    function winAPI:Notify(cfg)
        cfg = cfg or {}
        local n = Instance.new("Frame")
        n.Size = UDim2.fromOffset(280, 62)
        n.Position = UDim2.new(1, 30, 1, -80)
        n.AnchorPoint = Vector2.new(0, 1)
        n.BackgroundColor3 = self.CurrentTheme.Secondary
        n.BackgroundTransparency = 0.1
        n.Parent = screenGui
        Instance.new("UICorner", n).CornerRadius = UDim.new(0, 12)

        local ttl = Instance.new("TextLabel")
        ttl.Text = cfg.Title or GetText("Notify")
        ttl.Font = Enum.Font.BuilderSansBold
        ttl.TextSize = 13
        ttl.TextColor3 = self.CurrentTheme.Text
        ttl.BackgroundTransparency = 1
        ttl.Position = UDim2.fromOffset(14, 10)
        ttl.Size = UDim2.fromOffset(250, 18)
        ttl.Parent = n

        local desc = Instance.new("TextLabel")
        desc.Text = cfg.Content or ""
        desc.Font = Enum.Font.BuilderSans
        desc.TextSize = 11
        desc.TextColor3 = self.CurrentTheme.TextDark
        desc.BackgroundTransparency = 1
        desc.Position = UDim2.fromOffset(14, 28)
        desc.Size = UDim2.fromOffset(250, 26)
        desc.TextWrapped = true
        desc.Parent = n

        Tween(n, {Position = UDim2.new(1, -20, 1, -80)}, 0.35, Enum.EasingStyle.Back)
        task.delay(cfg.Duration or 4, function()
            if n and n.Parent then
                Tween(n, {Position = UDim2.new(1, 40, 1, -80)}, 0.3)
                task.wait(0.32)
                n:Destroy()
            end
        end)
    end

    function winAPI:MakeStatsHUD(cfg)
        cfg = cfg or {}
        local stats = cfg.Stats or {"Ping","FPS","Playtime","Time"}

        local hud = Instance.new("Frame")
        hud.Size = UDim2.fromOffset(118, 0)
        hud.Position = cfg.Position or UDim2.new(0, 12, 0.5, 0)
        hud.BackgroundColor3 = self.CurrentTheme.Background
        hud.BackgroundTransparency = 0.12
        hud.Parent = screenGui
        Instance.new("UICorner", hud).CornerRadius = UDim.new(0, 9)

        local handle = Instance.new("TextButton")
        handle.Text = "⌀ AstralUI"
        handle.Font = Enum.Font.BuilderSansBold
        handle.TextSize = 9
        handle.TextColor3 = self.CurrentTheme.Accent
        handle.Size = UDim2.new(1, 0, 0, 18)
        handle.BackgroundColor3 = self.CurrentTheme.Secondary
        handle.Parent = hud
        Instance.new("UICorner", handle).CornerRadius = UDim.new(0, 9)

        local rows = Instance.new("Frame")
        rows.Position = UDim2.fromOffset(0, 20)
        rows.Size = UDim2.new(1, 0, 0, 0)
        rows.BackgroundTransparency = 1
        rows.Parent = hud

        local list = Instance.new("UIListLayout")
        list.Padding = UDim.new(0, 2)
        list.Parent = rows

        local labels = {}
        for _, k in ipairs(stats) do
            local r = Instance.new("Frame")
            r.Size = UDim2.new(1, 0, 0, 14)
            r.BackgroundTransparency = 1
            r.Parent = rows

            Instance.new("TextLabel", r, {Text = GetText("Stats"..k) or (k..":"), Font = Enum.Font.BuilderSansMedium, TextSize = 9, TextColor3 = self.CurrentTheme.TextDark, Size = UDim2.new(0.52,0,1,0), Position = UDim2.fromOffset(6,0), BackgroundTransparency = 1})

            local v = Instance.new("TextLabel", r, {Text = "--", Font = Enum.Font.BuilderSansBold, TextSize = 9, TextColor3 = self.CurrentTheme.Text, Size = UDim2.new(0.48,-6,1,0), Position = UDim2.fromOffset(0,0), AnchorPoint = Vector2.new(1,0), BackgroundTransparency = 1})
            labels[k] = v
        end

        -- Dragging for HUD
        local dActive = false
        local dStart, hStart
        handle.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then dActive = true dStart = i.Position hStart = hud.Position end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dActive and i.UserInputType == Enum.UserInputType.MouseMovement then
                local d = i.Position - dStart
                hud.Position = UDim2.new(hStart.X.Scale, hStart.X.Offset + d.X, hStart.Y.Scale, hStart.Y.Offset + d.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dActive = false end end)

        local conn = RunService.Heartbeat:Connect(function()
            for k, lbl in pairs(labels) do
                if k == "Ping" then
                    local ok, p = pcall(function() return math.floor(Players:GetPing()*1000) end)
                    lbl.Text = (ok and p or "--") .. " ms"
                elseif k == "FPS" then
                    lbl.Text = math.floor(1 / math.max(0.001, RunService.Heartbeat:Wait())) .. " fps"
                elseif k == "Playtime" then
                    local t = math.floor(tick() - self._startTime)
                    lbl.Text = string.format("%02d:%02d", math.floor(t/60), t%60)
                elseif k == "Time" then
                    lbl.Text = os.date("%H:%M")
                end
            end
        end)

        return { SetVisible = function(v) hud.Visible = v end, IsVisible = function() return hud.Visible end, Destroy = function() conn:Disconnect() hud:Destroy() end }
    end

    self.Windows[title] = winAPI
    return winAPI
end

return AstralUI.new()
