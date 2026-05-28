-- ============================================================
--  Foxy Library  v1.0
--  A clean, themeable Roblox UI library.
--
--  Usage:
--      local FoxyLib = loadstring(...)()          -- or require
--      local lib = FoxyLib.new({ Name = "My Script", ... })
--      local sec = lib:AddSection("Section Name")
--      local tab = sec:AddTab({ Name = "Tab" })
--      local grp = tab:AddGroup({ Name = "Group" })
--      grp:AddToggle({ Name = "Feature", Default = false, Callback = function(v) end })
--
--  See README.md for the full API reference.
-- ============================================================

local FoxyLib = (function()
local v0rtexdIsTheBestDev = cloneref or function(service) return service end

local oMgThisTweenServiceIsSoCool = v0rtexdIsTheBestDev(game:GetService("TweenService"))
local thisInputServiceGoesHard = v0rtexdIsTheBestDev(game:GetService("UserInputService"))
local runServiceMoreLikeWalkService = v0rtexdIsTheBestDev(game:GetService("RunService"))
local playersAreNoobs = v0rtexdIsTheBestDev(game:GetService("Players"))
local textServiceBeLikeText = v0rtexdIsTheBestDev(game:GetService("TextService"))
local coreGuiMoreLikeBoreGui = v0rtexdIsTheBestDev(game:GetService("CoreGui"))
local guiServiceIsCool = v0rtexdIsTheBestDev(game:GetService("GuiService"))
local httpServiceNoCap = v0rtexdIsTheBestDev(game:GetService("HttpService"))
local lightingServiceLooksClean = v0rtexdIsTheBestDev(game:GetService("Lighting"))

local FoxyLibrary = {}
FoxyLibrary.__index = FoxyLibrary

local theOneAndOnlyPlayer = playersAreNoobs.LocalPlayer
local mouseGoClickClick = theOneAndOnlyPlayer:GetMouse()

local isMobileUserSadly = thisInputServiceGoesHard.TouchEnabled and not thisInputServiceGoesHard.KeyboardEnabled
local mobileScaleFactor = isMobileUserSadly and 0.7 or 1
local defaultFlowUIFontEnum = Enum.Font.GothamSemibold
local defaultFlowUIFontFamily = "rbxasset://fonts/families/GothamSSm.json"

local function resolveFlowUIFontEnum(weight)
    if weight == Enum.FontWeight.Bold then
        return Enum.Font.GothamBold
    end
    if weight == Enum.FontWeight.Medium then
        return Enum.Font.GothamMedium
    end
    return defaultFlowUIFontEnum
end

-- BUG FIX: flowUIFontFaceSupported was declared but never set or used; dead variable removed

local function makeFlowUIFontDescriptor(family, weight, style, enumFont)
    return {
        __flowUIFontDescriptor = true,
        Family = family or defaultFlowUIFontFamily,
        Weight = weight or Enum.FontWeight.SemiBold,
        Style = style or Enum.FontStyle.Normal,
        EnumFont = enumFont or resolveFlowUIFontEnum(weight)
    }
end

local function isFlowUIFontDescriptor(value)
    return type(value) == "table" and value.__flowUIFontDescriptor == true
end

local function getFallbackFlowUIFont(value, fallbackEnum)
    if isFlowUIFontDescriptor(value) then
        return value.EnumFont or fallbackEnum or defaultFlowUIFontEnum
    end
    return fallbackEnum or defaultFlowUIFontEnum
end

local function applyFlowUIFont(instance, value, fallbackEnum)
    if not instance or not (instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox")) then
        return false
    end

    local ok = pcall(function()
        instance.Font = getFallbackFlowUIFont(value, fallbackEnum)
    end)
    return ok  -- BUG FIX: was always returning false
end

local Font = {
    new = function(family, weight, style)
        family = family or defaultFlowUIFontFamily
        weight = weight or Enum.FontWeight.SemiBold
        style = style or Enum.FontStyle.Normal
        return makeFlowUIFontDescriptor(family, weight, style)
    end,
    fromEnum = function(enumFont)
        enumFont = enumFont or defaultFlowUIFontEnum
        return makeFlowUIFontDescriptor(defaultFlowUIFontFamily, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal, enumFont)
    end
}

local function makeThingExist(className, properties)
    local whatWeJustMade = Instance.new(className)
    for property, value in pairs(properties) do
        if property ~= "Parent" then
            if property == "FontFace" then
                applyFlowUIFont(whatWeJustMade, value)
            else
                pcall(function()
                    whatWeJustMade[property] = value
                end)
            end
        end
    end
    if properties.Parent then
        whatWeJustMade.Parent = properties.Parent
    end
    return whatWeJustMade
end

local function smoothMoveGoWoosh(instance, properties, duration, easingStyle, easingDirection)
    local tweenInfoYay = TweenInfo.new(duration or 0.22, easingStyle or Enum.EasingStyle.Quint, easingDirection or Enum.EasingDirection.Out)
    local tweenGoVroom = oMgThisTweenServiceIsSoCool:Create(instance, tweenInfoYay, properties)
    tweenGoVroom:Play()
    return tweenGoVroom
end

local function disconnectFlowConnection(conn)
    if conn and typeof(conn) == "RBXScriptConnection" then
        pcall(function()
            if conn.Connected then
                conn:Disconnect()
            end
        end)
    elseif type(conn) == "function" then
        pcall(conn)
    end
end

local function makeDraggableCuzWeCan(frame, handle, libraryRef)
    local amIDragging = false
    local activeDragInput
    local whereDidIStart
    local whereWasIBefore
    local targetDragPosition = frame.Position
    local dragLerpSpeed = isMobileUserSadly and 18 or 22
    local renderDragConn

    handle = handle or frame

    local function stopDragLoop()
        disconnectFlowConnection(renderDragConn)
        renderDragConn = nil
    end

    local function ensureDragLoop()
        if renderDragConn and renderDragConn.Connected then
            return
        end
        renderDragConn = runServiceMoreLikeWalkService.RenderStepped:Connect(function(dt)
            if not frame or not frame.Parent then
                stopDragLoop()
                return
            end
            local currentPos = frame.Position
            local goalPos = targetDragPosition
            local offsetDelta = math.abs(goalPos.X.Offset - currentPos.X.Offset) + math.abs(goalPos.Y.Offset - currentPos.Y.Offset)
            if offsetDelta <= 0.1 then
                if currentPos ~= goalPos then
                    frame.Position = goalPos
                end
                if not amIDragging then
                    stopDragLoop()
                end
                return
            end
            local alpha = math.clamp(1 - math.exp(-dragLerpSpeed * dt), 0, 1)  -- BUG FIX: was capped at 0.45, preventing full convergence
            frame.Position = currentPos:Lerp(goalPos, alpha)
        end)
        if libraryRef and type(libraryRef._TrackConnection) == "function" then
            libraryRef:_TrackConnection(renderDragConn)
        end
    end

    local function updateTargetPositionYay(input)
        local howMuchDidIMove = input.Position - whereDidIStart
        targetDragPosition = UDim2.new(
            whereWasIBefore.X.Scale,
            whereWasIBefore.X.Offset + howMuchDidIMove.X,
            whereWasIBefore.Y.Scale,
            whereWasIBefore.Y.Offset + howMuchDidIMove.Y
        )
    end

    local inputBeganConn = handle.InputBegan:Connect(function(input)
        local isMouse = input.UserInputType == Enum.UserInputType.MouseButton1
        local isTouch = input.UserInputType == Enum.UserInputType.Touch
        if not isMouse and not isTouch then
            return
        end

        amIDragging = true
        activeDragInput = isTouch and input or nil
        whereDidIStart = input.Position
        whereWasIBefore = frame.Position
        targetDragPosition = frame.Position
        ensureDragLoop()

        local inputEndConn
        inputEndConn = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                if frame and frame.Parent then
                    frame.Position = targetDragPosition
                end
                amIDragging = false
                activeDragInput = nil
                stopDragLoop()
                if inputEndConn then
                    inputEndConn:Disconnect()
                    inputEndConn = nil
                end
            end
        end)
        if libraryRef and type(libraryRef._TrackConnection) == "function" then
            libraryRef:_TrackConnection(inputEndConn)
        end
    end)

    local userInputChangedConn = thisInputServiceGoesHard.InputChanged:Connect(function(input)
        if not amIDragging then
            return
        end
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            updateTargetPositionYay(input)
        elseif input.UserInputType == Enum.UserInputType.Touch and (activeDragInput == nil or input == activeDragInput) then
            updateTargetPositionYay(input)
        end
    end)

    if libraryRef and type(libraryRef._TrackConnection) == "function" then
        libraryRef:_TrackConnection(inputBeganConn)
        libraryRef:_TrackConnection(userInputChangedConn)
    end
end

local function startFloatingPositionTracker(libraryRef, anchorInstance, updateFn)
    if type(updateFn) ~= "function" or not anchorInstance then
        return nil
    end

    local active = true
    local connections = {}

    local function bindSignal(instance, propertyName)
        if not instance then
            return
        end
        table.insert(connections, libraryRef:_TrackConnection(instance:GetPropertyChangedSignal(propertyName):Connect(updateFn)))
    end

    bindSignal(anchorInstance, "AbsolutePosition")
    bindSignal(anchorInstance, "AbsoluteSize")
    table.insert(connections, libraryRef:_TrackConnection(anchorInstance.AncestryChanged:Connect(updateFn)))

    if libraryRef and libraryRef.screenGuiYay then
        bindSignal(libraryRef.screenGuiYay, "AbsoluteSize")
    end

    updateFn()

    return function()
        if not active then
            return
        end
        active = false
        for i = #connections, 1, -1 do
            disconnectFlowConnection(connections[i])
            connections[i] = nil
        end
    end
end

local function getPlayerAvatarCuzTheyreBeautiful(userId)
    local didItWork, whatWeGot = pcall(function()
        return playersAreNoobs:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    end)
    if didItWork then
        return whatWeGot
    end
    return "rbxassetid://135756197673563"
end

local function resolveAvatar3DUserIdFromRobloxEndpoint(defaultUserId)
    local fallbackUserId = tonumber(defaultUserId) or 1
    local endpoint = "https://thumbnails.roblox.com/v1/users/avatar-3d?userId=" .. tostring(fallbackUserId)

    local okBody, rawBody = pcall(function()
        return game:HttpGet(endpoint)
    end)
    if not okBody or type(rawBody) ~= "string" or rawBody == "" then
        return fallbackUserId, nil
    end

    local okDecode, payload = pcall(function()
        return httpServiceNoCap:JSONDecode(rawBody)
    end)
    if not okDecode or type(payload) ~= "table" then
        return fallbackUserId, nil
    end

    local resolvedUserId = tonumber(payload.targetId) or tonumber(payload.userId) or fallbackUserId
    local imageUrl = type(payload.imageUrl) == "string" and payload.imageUrl or nil
    return resolvedUserId, imageUrl
end

local function howWideIsThisText(text, textSize, font)
    local textBoundsYay = textServiceBeLikeText:GetTextSize(text, textSize, font or Enum.Font.GothamSemibold, Vector2.new(math.huge, math.huge))
    return textBoundsYay.X
end

local function truncateTextLikeABoss(text, maxWidth, textSize, font)
    local fullWidth = howWideIsThisText(text, textSize, font)
    if fullWidth <= maxWidth then
        return text
    end

    local truncated = text
    while howWideIsThisText(truncated .. "...", textSize, font) > maxWidth and #truncated > 0 do
        truncated = truncated:sub(1, -2)
    end
    return truncated .. "..."
end

local function normalizeSearchText(text)
    return string.lower(tostring(text or "")):gsub("^%s+", ""):gsub("%s+$", "")
end

local function normalizeDropdownOptions(options)
    local normalized = {}
    if type(options) == "table" then
        for _, option in ipairs(options) do
            if option ~= nil then
                table.insert(normalized, option)
            end
        end
    end
    if #normalized == 0 then
        normalized[1] = "None"
    end
    return normalized
end

local function getDropdownOptionsSignature(options)
    if type(options) ~= "table" then
        return "0"
    end
    local count = #options
    if count <= 0 then
        return "0"
    end
    local signaturePieces = table.create and table.create(count + 1, "") or {}
    signaturePieces[1] = tostring(count)
    for index, option in ipairs(options) do
        signaturePieces[index + 1] = tostring(option)
    end
    return table.concat(signaturePieces, "\31")
end

local function getNumberDecimalPlaces(value)
    if type(value) ~= "number" then
        return 0
    end
    local valueString = tostring(value)
    local decimalPart = valueString:match("%.(%d+)")
    if decimalPart then
        return #decimalPart
    end
    local exponentPart = valueString:match("[eE]([%+%-]?%d+)")
    if exponentPart then
        local exponent = tonumber(exponentPart) or 0
        if exponent < 0 then
            return -exponent
        end
    end
    return 0
end

local function roundToDecimalPlaces(value, decimals)
    if decimals <= 0 then
        if value >= 0 then
            return math.floor(value + 0.5)
        end
        return math.ceil(value - 0.5)
    end
    local factor = 10 ^ decimals
    if value >= 0 then
        return math.floor(value * factor + 0.5) / factor
    end
    return math.ceil(value * factor - 0.5) / factor
end

local function resolveSliderPrecision(minValue, maxValue, increment, defaultValue)
    local precision = 0
    precision = math.max(precision, getNumberDecimalPlaces(minValue))
    precision = math.max(precision, getNumberDecimalPlaces(maxValue))
    precision = math.max(precision, getNumberDecimalPlaces(increment))
    precision = math.max(precision, getNumberDecimalPlaces(defaultValue))
    return math.clamp(precision, 0, 6)
end

local function normalizeSliderValue(value, minValue, maxValue, increment, precision)
    local numericValue = tonumber(value) or minValue
    numericValue = math.clamp(numericValue, minValue, maxValue)
    local normalizedIncrement = math.max(math.abs(tonumber(increment) or 1), 1e-6)
    local steps = math.floor(((numericValue - minValue) / normalizedIncrement) + 0.5)
    local snappedValue = minValue + (steps * normalizedIncrement)
    snappedValue = roundToDecimalPlaces(snappedValue, precision)
    return math.clamp(snappedValue, minValue, maxValue)
end

local function formatSliderValue(value, precision)
    if precision <= 0 then
        return tostring(roundToDecimalPlaces(value, 0))
    end
    local formatted = string.format("%." .. tostring(precision) .. "f", value)
    formatted = formatted:gsub("(%..-)0+$", "%1"):gsub("%.$", "")
    return formatted
end

local function serializeConfigValue(value)
    local valueType = typeof(value)
    if valueType == "Color3" then
        return {
            __type = "Color3",
            r = value.R,
            g = value.G,
            b = value.B
        }
    end
    if valueType == "EnumItem" and value.EnumType == Enum.KeyCode then
        return {
            __type = "KeyCode",
            value = value.Name
        }
    end
    return value
end

local function deserializeConfigValue(value)
    if type(value) ~= "table" or not value.__type then
        return value
    end
    if value.__type == "Color3" and value.r and value.g and value.b then
        return Color3.new(value.r, value.g, value.b)
    end
    if value.__type == "KeyCode" and value.value then
        return Enum.KeyCode[value.value] or Enum.KeyCode.Unknown
    end
    return value
end

local function sanitizeConfigName(name)
    local cleanName = tostring(name or "default")
    cleanName = cleanName:gsub("[\\/:*?\"<>|]", "_")
    cleanName = cleanName:gsub("^%s+", ""):gsub("%s+$", "")
    if cleanName == "" then
        cleanName = "default"
    end
    return cleanName
end

local function getFlowUIConfigFolderPath()
    return "FoxyConfigs"
end

local function ensureFlowUIConfigFolder()
    local folder = getFlowUIConfigFolderPath()

    if isfolder and isfolder(folder) then
        return true, folder
    end

    return false, folder
end

local function getFlowUIConfigFileName(configName)
    return sanitizeConfigName(configName) .. ".json"
end

local function getWritableFlowUIConfigPath(configName)
    local fileName = getFlowUIConfigFileName(configName)
    local okFolder, folder = ensureFlowUIConfigFolder()
    if okFolder then
        return folder .. "/" .. fileName, true
    end
    return fileName, false
end

local function getReadableFlowUIConfigPaths(configName)
    local fileName = getFlowUIConfigFileName(configName)
    local folder = getFlowUIConfigFolderPath()
    return {
        folder .. "/" .. fileName,
        fileName
    }
end

function FoxyLibrary.new(config)
    local self = setmetatable({}, FoxyLibrary)

    self.config = config or {}
    self.config.Name = self.config.Name or "Foxy Library"
    self.config.AccentColor = self.config.AccentColor or Color3.fromRGB(2, 133, 255)
    self.config.BackgroundColor = self.config.BackgroundColor or Color3.fromRGB(16, 16, 16)
    self.config.SecondaryColor = self.config.SecondaryColor or Color3.fromRGB(18, 18, 18)
    self.config.TextColor = self.config.TextColor or Color3.fromRGB(255, 255, 255)
    self.config.SubTextColor = self.config.SubTextColor or Color3.fromRGB(124, 124, 124)

    self.sectionsAreAwesome = {}
    self.tabsGoWoosh = {}
    self.currentTabYay = nil
    self.notificationsAreCool = {}
    self.isToggledOn = true
    self.dropdownHolderRef = nil
    self.toggleKeyCode = Enum.KeyCode.RightControl
    self.toggleButtonVisible = true
    self._destroyed = false
    self._connections = {}
    self._trackedControls = {}
    self._smoothScrollFrames = {}
    self._searchQuery = ""
    self._fpsRollingSize = 60
    self._fpsRollingWindow = table.create and table.create(self._fpsRollingSize, 0) or {}
    self._fpsRollingTotal = 0
    self._fpsRollingIndex = 1
    self._fpsRollingCount = 0
    self._latestFPSValue = 0
    self._cachedViewportSize = Vector2.new(1280, 720)
    self._cachedViewportWidth = 1280
    self._cachedViewportHeight = 720
    self._cachedViewportAreaScale = 1
    self._blurEffectRef = nil
    self._snowflakes = {}
    self._snowSpawnAccumulator = 0
    self._snowMaxFlakes = isMobileUserSadly and 45 or 90
    self._overlayMode = "None"
    self._overlayModes = {"Snow", "Rain", "Stars", "None"}
    self._backgroundFxTime = 0
    self._backgroundFxAccumulator = 0
    self._textGradientAnimationTime = 0
    self._gradientAnimationAccumulator = 0
    self._overlayUpdateAccumulator = 0
    self._uiVisualSettings = {
        Blur = false,
        Snow = false,
        BackgroundEffects = false,
        TextGradient = false,
        ESPSelfPreview = false,
        HideName = false
    }
    self._fontPresets = {
        {Name = "Gotham", EnumFont = Enum.Font.Gotham, Family = "rbxasset://fonts/families/GothamSSm.json", Weight = Enum.FontWeight.SemiBold},
        {Name = "Gotham Medium", EnumFont = Enum.Font.GothamMedium, Family = "rbxasset://fonts/families/GothamSSm.json", Weight = Enum.FontWeight.Medium},
        {Name = "Montserrat", EnumFont = Enum.Font.Gotham, Family = "rbxasset://fonts/families/Montserrat.json", Weight = Enum.FontWeight.SemiBold},
        {Name = "Nunito", EnumFont = Enum.Font.Gotham, Family = "rbxasset://fonts/families/Nunito.json", Weight = Enum.FontWeight.SemiBold},
        {Name = "Bodoni", EnumFont = Enum.Font.Bodoni},
        {Name = "Garamond", EnumFont = Enum.Font.Garamond},
        {Name = "Source Sans", EnumFont = Enum.Font.SourceSans, Family = "rbxasset://fonts/families/SourceSansPro.json", Weight = Enum.FontWeight.SemiBold},
        {Name = "Highway", EnumFont = Enum.Font.Highway},
        {Name = "Antique", EnumFont = Enum.Font.Antique},
        {Name = "Code", EnumFont = Enum.Font.Code}
    }
    self._fontPresetIndex = 1
    self._gradientLabels = {}
    self._gradientObjects = {}
    self._espPreviewProvider = nil
    self._espPreviewData = nil
    self._espPreviewState = nil
    self._espPreviewResolveAccumulator = 0
    self._espPreviewUpdateAccumulator = 0
    self._espPreviewWasShowing = false
    self._espPreviewPanel = nil
    self._espPreviewViewport = nil
    self._espPreviewWorldModel = nil
    self._espPreviewCamera = nil
    self._espPreviewCharacter = nil
    self._espPreviewLastCharacter = nil
    self._espPreviewPartDefaults = {}
    self._espPreviewHeadPart = nil
    self._espPreviewRootPart = nil
    self._espPreviewVisualState = nil
    self._espPreviewVisualDirty = false
    self._espPreviewProjectionCache = nil
    self._espPreviewProjectionDirty = true
    self._espPreviewHighlight = nil
    self._espPreviewHeaderTag = nil
    self._espPreviewBox = nil
    self._espPreviewBoxStroke = nil
    self._espPreviewHealthTrack = nil
    self._espPreviewHealthFill = nil
    self._espPreviewDot = nil
    self._espPreviewTracer = nil
    self._espPreviewName = nil
    self._espPreviewItem = nil
    self._espPreviewDistance = nil
    self._espPreviewWalkTrack = nil
    self._espPreviewAnimationId = nil
    self._espPreviewAvatar3DUserId = tonumber(theOneAndOnlyPlayer.UserId) or 0
    self._espPreviewAvatar3DImageUrl = nil
    self._espPreviewRotationYaw = math.rad(180)
    self._espPreviewRotationTargetYaw = math.rad(180)
    self._espPreviewStaticMode = true
    self._espPreviewAllowManualRotation = true
    self._espPreviewPivotYOffset = -2
    self._espPreviewRotateCapture = nil
    self._espPreviewIsRotating = false
    self._espPreviewRotateInput = nil
    self._espPreviewRotateLastX = 0

    self:CreateUIBecauseWeNeedIt()

    return self
end

function FoxyLibrary:_TrackConnection(conn)
    if conn then
        table.insert(self._connections, conn)
        if #self._connections % 100 == 0 then
            local activeConnections = {}
            for _, item in ipairs(self._connections) do
                if item and typeof(item) == "RBXScriptConnection" and item.Connected then
                    table.insert(activeConnections, item)
                end
            end
            self._connections = activeConnections
        end
    end
    return conn
end

function FoxyLibrary:RegisterControl(flag, getter, setter)
    if type(flag) ~= "string" or flag == "" then return end
    if type(getter) ~= "function" or type(setter) ~= "function" then return end
    self._trackedControls[flag] = {
        get = getter,
        set = setter
    }
end

function FoxyLibrary:_RefreshViewportMetrics()
    local viewportSize = (self.screenGuiYay and self.screenGuiYay.AbsoluteSize) or Vector2.new(0, 0)
    local width = math.max(200, math.floor(viewportSize.X > 0 and viewportSize.X or 1280))
    local height = math.max(320, math.floor(viewportSize.Y > 0 and viewportSize.Y or 720))
    self._cachedViewportSize = Vector2.new(width, height)
    self._cachedViewportWidth = width
    self._cachedViewportHeight = height
    self._cachedViewportAreaScale = math.clamp(math.sqrt((width * height) / (1280 * 720)), isMobileUserSadly and 0.52 or 0.68, 1.12)
end

function FoxyLibrary:_InvalidateESPPreviewProjection(clearCache)
    self._espPreviewProjectionDirty = true
    if clearCache then
        self._espPreviewProjectionCache = nil
    end
end

function FoxyLibrary:_EnsureBlurEffect()
    if self._blurEffectRef and self._blurEffectRef.Parent then
        return self._blurEffectRef
    end
    local existingBlur = lightingServiceLooksClean:FindFirstChild("FlowUIBlurEffect")
    if existingBlur and existingBlur:IsA("BlurEffect") then
        self._blurEffectRef = existingBlur
        return existingBlur
    end
    self._blurEffectRef = makeThingExist("BlurEffect", {
        Name = "FlowUIBlurEffect",
        Size = 0,
        Enabled = true,
        Parent = lightingServiceLooksClean
    })
    return self._blurEffectRef
end

function FoxyLibrary:_SetBlurActive(active, instant)
    local blur = self:_EnsureBlurEffect()
    local shouldEnable = self._uiVisualSettings.Blur and active
    local targetSize = shouldEnable and (isMobileUserSadly and 14 or 18) or 0
    if instant then
        blur.Size = targetSize
        return
    end
    smoothMoveGoWoosh(blur, {Size = targetSize}, 0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
end

function FoxyLibrary:_ClearSnowflakes()
    for i = #self._snowflakes, 1, -1 do
        local snowObj = self._snowflakes[i]
        if snowObj and snowObj.instance and snowObj.instance.Parent then
            snowObj.instance:Destroy()
        end
        self._snowflakes[i] = nil
    end
end

function FoxyLibrary:_SpawnSnowflake()
    if not self.snowLayerFrame or not self.snowLayerFrame.Parent then
        return
    end
    local width = self._cachedViewportWidth or 200
    local size = math.random(2, 7) * mobileScaleFactor
    local startX = math.random(-18, width + 18)
    local flake = makeThingExist("ImageLabel", {
        BackgroundTransparency = 1,
        Image = "rbxassetid://3570695787",
        ImageColor3 = Color3.fromRGB(236 + math.random(0, 19), 243 + math.random(0, 12), 255),
        ImageTransparency = math.random(22, 56) / 100,
        Size = UDim2.new(0, size, 0, size),
        Position = UDim2.new(0, startX, 0, -math.random(6, 80)),
        Rotation = math.random(0, 359),
        ZIndex = 2,
        Parent = self.snowLayerFrame
    })
    table.insert(self._snowflakes, {
        overlayType = "Snow",
        instance = flake,
        baseX = startX,
        fallSpeed = math.random(16, 42) * mobileScaleFactor,
        driftAmount = math.random(12, 42) * mobileScaleFactor,
        swirlAmount = math.random(2, 10) * mobileScaleFactor,
        driftSpeed = math.random(5, 15) / 10,
        twinkleSpeed = math.random(6, 15) / 10,
        baseTransparency = flake.ImageTransparency,
        phase = math.random() * math.pi * 2,
        spin = math.random(-14, 14),
        size = size,
        yOffset = flake.Position.Y.Offset
    })
end

function FoxyLibrary:_SpawnRainDrop()
    if not self.snowLayerFrame or not self.snowLayerFrame.Parent then
        return
    end
    local width = self._cachedViewportWidth or 200
    local depthScale = math.random(62, 150) / 100
    local length = (math.random(12, 30) * depthScale + 3) * mobileScaleFactor
    local thickness = math.max(1, math.floor((0.8 + depthScale * 0.9) * mobileScaleFactor + 0.5))
    local startX = math.random(-58, width + 58)
    local startY = -math.random(30, 180)
    local windSpeed = (math.random(26, 88) * depthScale) * mobileScaleFactor
    local fallSpeed = (math.random(270, 560) * depthScale) * mobileScaleFactor
    local angle = math.deg(math.atan(fallSpeed / windSpeed)) - 90
    local drop = makeThingExist("Frame", {
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(176 + math.random(0, 26), 208 + math.random(0, 26), 255),
        BackgroundTransparency = math.random(15, 45) / 100,
        Position = UDim2.new(0, startX, 0, startY),
        Size = UDim2.new(0, thickness, 0, length),
        Rotation = angle,
        ZIndex = depthScale > 1 and 3 or 2,
        Parent = self.snowLayerFrame
    })
    makeThingExist("UICorner", {CornerRadius = UDim.new(1, 0), Parent = drop})
    table.insert(self._snowflakes, {
        overlayType = "RainDrop",
        instance = drop,
        xOffset = startX,
        yOffset = startY,
        velocityX = windSpeed,
        velocityY = fallSpeed,
        angle = angle,
        width = thickness,
        length = length,
        baseTransparency = drop.BackgroundTransparency,
        driftSpeed = math.random(11, 24) / 10,
        windJitter = math.random(6, 18) * mobileScaleFactor,
        stretchPulse = math.random(16, 30) / 10,
        splashChance = 0.55 + math.random() * 0.25,
        phase = math.random() * math.pi * 2
    })
end

function FoxyLibrary:_SpawnRainSplash(xPosition, yPosition)
    if not self.snowLayerFrame or not self.snowLayerFrame.Parent then
        return
    end
    local startSize = math.random(2, 5) * mobileScaleFactor
    local splash = makeThingExist("Frame", {
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(194 + math.random(0, 20), 224 + math.random(0, 22), 255),
        BackgroundTransparency = math.random(24, 42) / 100,
        Position = UDim2.new(0, xPosition, 0, yPosition),
        Size = UDim2.new(0, startSize, 0, math.max(1 * mobileScaleFactor, startSize * 0.5)),
        ZIndex = 3,
        Parent = self.snowLayerFrame
    })
    makeThingExist("UICorner", {CornerRadius = UDim.new(1, 0), Parent = splash})
    local life = math.random(8, 14) / 100
    table.insert(self._snowflakes, {
        overlayType = "RainSplash",
        instance = splash,
        baseX = xPosition,
        yOffset = yPosition,
        life = life,
        totalLife = life,
        startSize = startSize,
        startThickness = math.max(1 * mobileScaleFactor, startSize * 0.5),
        endSize = math.random(10, 20) * mobileScaleFactor,
        driftX = math.random(-14, 14) * mobileScaleFactor,
        baseTransparency = splash.BackgroundTransparency
    })
end

function FoxyLibrary:_SpawnStarParticle()
    if not self.snowLayerFrame or not self.snowLayerFrame.Parent then
        return
    end
    local width = self._cachedViewportWidth or 200
    local height = self._cachedViewportHeight or 320
    local size = (math.random(10, 28) / 10) * mobileScaleFactor
    local startX = math.random(0, width)
    local startY = math.random(0, height)
    local star = makeThingExist("ImageLabel", {
        BackgroundTransparency = 1,
        Image = "rbxassetid://3570695787",
        ImageColor3 = Color3.fromRGB(224 + math.random(0, 28), 233 + math.random(0, 20), 255),
        ImageTransparency = math.random(22, 56) / 100,
        Position = UDim2.new(0, startX, 0, startY),
        Size = UDim2.new(0, size, 0, size),
        ZIndex = 3,
        Parent = self.snowLayerFrame
    })
    table.insert(self._snowflakes, {
        overlayType = "Stars",
        instance = star,
        xOffset = startX,
        yOffset = startY,
        velocityX = (math.random(-16, 16) / 10) * mobileScaleFactor,
        velocityY = (math.random(-9, 9) / 10) * mobileScaleFactor,
        baseSize = size,
        driftAmount = math.random(5, 18) * mobileScaleFactor,
        driftLift = math.random(4, 14) * mobileScaleFactor,
        driftSpeed = math.random(3, 10) / 10,
        twinkleSpeed = math.random(7, 18) / 10,
        pulseAmount = (math.random(8, 24) / 100),
        baseTransparency = star.ImageTransparency,
        phase = math.random() * math.pi * 2
    })
end

function FoxyLibrary:_SetSnowEnabled(enabled)
    self._uiVisualSettings.Snow = enabled == true
    if self.snowLayerFrame then
        self.snowLayerFrame.Visible = self._uiVisualSettings.Snow and self.isToggledOn and self._overlayMode ~= "None"
    end
    if not self._uiVisualSettings.Snow or not self.isToggledOn or self._overlayMode == "None" then
        self._overlayUpdateAccumulator = 0
        self._snowSpawnAccumulator = 0
        self:_ClearSnowflakes()
    end
end

function FoxyLibrary:_SetOverlayMode(mode)
    local normalized = string.lower(tostring(mode or "snow"))
    local resolved = "Snow"
    if normalized == "rain" then
        resolved = "Rain"
    elseif normalized == "stars" or normalized == "star" then
        resolved = "Stars"
    elseif normalized == "none" or normalized == "off" then
        resolved = "None"
    end
    local changed = self._overlayMode ~= resolved
    self._overlayMode = resolved
    if self.uiOverlayModeValueLabel then
        self.uiOverlayModeValueLabel.Text = resolved
    end
    if self.snowLayerFrame then
        self.snowLayerFrame.Visible = self.isToggledOn and self._uiVisualSettings.Snow and resolved ~= "None"
    end
    if changed or resolved == "None" then
        self._overlayUpdateAccumulator = 0
        self._snowSpawnAccumulator = 0
        self:_ClearSnowflakes()
    end
end

function FoxyLibrary:_SetBackgroundEffectsEnabled(enabled)
    self._uiVisualSettings.BackgroundEffects = enabled == true
    if not self._uiVisualSettings.BackgroundEffects then
        self._backgroundFxAccumulator = 0
    end
    if self.mainBackgroundEffectsFrame then
        self.mainBackgroundEffectsFrame.Visible = self._uiVisualSettings.BackgroundEffects
    end
end

function FoxyLibrary:_SetNameHidden(enabled)
    self._uiVisualSettings.HideName = enabled == true
    local hideName = self._uiVisualSettings.HideName == true

    if self.userNameLabel then
        self.userNameLabel.Visible = not hideName
        if not hideName then
            self.userNameLabel.Text = "@" .. tostring(theOneAndOnlyPlayer.Name)
        end
    end

    if self._espPreviewHeaderTag then
        self._espPreviewHeaderTag.Visible = not hideName
        if not hideName then
            self._espPreviewHeaderTag.Text = "@" .. tostring(theOneAndOnlyPlayer.Name)
        end
    end

    if self._espPreviewPanel then
        self:_UpdateESPPreview(0)
    end
end

function FoxyLibrary:_SetTextGradientEnabled(enabled)
    self._uiVisualSettings.TextGradient = enabled == true
    if not self._uiVisualSettings.TextGradient then
        self._gradientAnimationAccumulator = 0
    end
    local accent = self.config.AccentColor
    local gradientSweepSpeed = 0.9
    local animationTime = tonumber(self._textGradientAnimationTime) or 0
    local sweepX = ((animationTime * gradientSweepSpeed) % 2) - 1
    for i = #self._gradientObjects, 1, -1 do
        self._gradientObjects[i] = nil
    end
    for _, label in ipairs(self._gradientLabels) do
        if label and label.Parent then
            local gradientObj = label:FindFirstChild("FlowUITextGradient")
            if self._uiVisualSettings.TextGradient then
                if not gradientObj then
                    gradientObj = makeThingExist("UIGradient", {
                        Name = "FlowUITextGradient",
                        Rotation = 0,
                        Parent = label
                    })
                end
                gradientObj.Rotation = 0
                gradientObj.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, accent:Lerp(Color3.new(1, 1, 1), 0.2)),
                    ColorSequenceKeypoint.new(0.55, Color3.new(1, 1, 1)),
                    ColorSequenceKeypoint.new(1, accent:Lerp(Color3.new(1, 1, 1), 0.35))
                })
                gradientObj.Offset = Vector2.new(sweepX, 0)
                table.insert(self._gradientObjects, gradientObj)
            elseif gradientObj then
                gradientObj:Destroy()
            end
        end
    end
end

function FoxyLibrary:_AnimateTextGradients(dt)
    if not self._uiVisualSettings.TextGradient then
        return
    end

    self._gradientAnimationAccumulator = (tonumber(self._gradientAnimationAccumulator) or 0) + (dt or 0)
    if self._gradientAnimationAccumulator < (1 / 30) then
        return
    end
    local resolvedDt = self._gradientAnimationAccumulator
    self._gradientAnimationAccumulator = 0

    local gradientSweepSpeed = 0.9
    self._textGradientAnimationTime = (tonumber(self._textGradientAnimationTime) or 0) + resolvedDt
    local sweepX = ((self._textGradientAnimationTime * gradientSweepSpeed) % 2) - 1
    local animatedOffset = Vector2.new(sweepX, 0)

    for i = #self._gradientObjects, 1, -1 do
        local gradientObj = self._gradientObjects[i]
        if gradientObj and gradientObj.Parent then
            gradientObj.Rotation = 0
            gradientObj.Offset = animatedOffset
        else
            table.remove(self._gradientObjects, i)
        end
    end
end

function FoxyLibrary:ApplyFontPreset(index)
    if #self._fontPresets == 0 then
        return
    end
    local normalizedIndex = tonumber(index) or (self._fontPresetIndex + 1)
    if normalizedIndex > #self._fontPresets then
        normalizedIndex = 1
    elseif normalizedIndex < 1 then
        normalizedIndex = #self._fontPresets
    end
    self._fontPresetIndex = normalizedIndex
    local preset = self._fontPresets[self._fontPresetIndex]
    local targetFontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    if preset.Family then
        local okFont, generatedFont = pcall(function()
            return Font.new(preset.Family, preset.Weight or Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        end)
        if okFont then
            targetFontFace = generatedFont
        end
    elseif preset.EnumFont then
        pcall(function()
            targetFontFace = Font.fromEnum(preset.EnumFont)
        end)
    end
    if self.screenGuiYay and self.screenGuiYay.Parent then
        for _, obj in ipairs(self.screenGuiYay:GetDescendants()) do
            if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                if preset.EnumFont then
                    pcall(function()
                        obj.Font = preset.EnumFont
                    end)
                end
                applyFlowUIFont(obj, targetFontFace, preset.EnumFont or defaultFlowUIFontEnum)
            end
        end
    end
    if self.uiSettingsFontValueLabel then
        self.uiSettingsFontValueLabel.Text = preset.Name
    end
end

function FoxyLibrary:_RefreshAccentCore()
    local accent = self.config.AccentColor
    if self.mobileToggleIcon then
        self.mobileToggleIcon.ImageColor3 = accent
    end
    if self.mainBackgroundAccentGlow then
        self.mainBackgroundAccentGlow.ImageColor3 = accent
    end
    if self.uiAccentPreviewFrame then
        self.uiAccentPreviewFrame.BackgroundColor3 = accent
    end
    if self.uiSettingsButtonStroke then
        self.uiSettingsButtonStroke.Color = self.uiSettingsOpen and accent:Lerp(Color3.fromRGB(20, 20, 20), 0.45) or Color3.fromRGB(45, 45, 45)
    end
    if self.currentTabYay and self.currentTabYay.buttonFrame then
        self.currentTabYay.buttonFrame.BackgroundColor3 = accent
    end
    self:_SetTextGradientEnabled(self._uiVisualSettings.TextGradient)
end

function FoxyLibrary:_ApplyOpenCloseVisuals(instant)
    self:_SetBlurActive(self.isToggledOn, instant)
    if self.backdropDimFrame then
        local targetTransparency = (self.isToggledOn and self._uiVisualSettings.Blur) and 0.55 or 1
        if instant then
            self.backdropDimFrame.BackgroundTransparency = targetTransparency
        else
            smoothMoveGoWoosh(self.backdropDimFrame, {
                BackgroundTransparency = targetTransparency
            }, 0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        end
    end
    if self.snowLayerFrame then
        self.snowLayerFrame.Visible = self.isToggledOn and self._uiVisualSettings.Snow and self._overlayMode ~= "None"
    end
    if not self.isToggledOn or not self._uiVisualSettings.Snow or self._overlayMode == "None" then
        self._overlayUpdateAccumulator = 0
        self._snowSpawnAccumulator = 0
        self:_ClearSnowflakes()
    end
    self:_UpdateESPPreview(0)
end

local function flowPreviewPullValue(sourceTable, keys)
    if type(sourceTable) ~= "table" then
        return nil
    end
    for _, key in ipairs(keys) do
        local value = sourceTable[key]
        if value ~= nil then
            return value
        end
    end
    return nil
end

local function flowPreviewToBool(value)
    if type(value) == "boolean" then
        return value
    end
    if type(value) == "number" then
        return value ~= 0
    end
    if type(value) == "string" then
        local normalized = string.lower(value)
        if normalized == "true" or normalized == "on" or normalized == "enabled" or normalized == "yes" or normalized == "1" then
            return true
        end
        if normalized == "false" or normalized == "off" or normalized == "disabled" or normalized == "no" or normalized == "0" then
            return false
        end
    end
    return nil
end

local function flowPreviewToColor3(value)
    if typeof(value) == "Color3" then
        return value
    end
    if type(value) ~= "table" then
        return nil
    end
    local r = value.r or value.R or value[1]
    local g = value.g or value.G or value[2]
    local b = value.b or value.B or value[3]
    if type(r) ~= "number" or type(g) ~= "number" or type(b) ~= "number" then
        return nil
    end
    if r > 1 or g > 1 or b > 1 then
        r, g, b = r / 255, g / 255, b / 255
    end
    return Color3.new(math.clamp(r, 0, 1), math.clamp(g, 0, 1), math.clamp(b, 0, 1))
end

local flowPreviewCoreBodyParts = {
    Head = true,
    UpperTorso = true,
    LowerTorso = true,
    Torso = true,
    LeftUpperArm = true,
    LeftLowerArm = true,
    LeftHand = true,
    RightUpperArm = true,
    RightLowerArm = true,
    RightHand = true,
    LeftUpperLeg = true,
    LeftLowerLeg = true,
    LeftFoot = true,
    RightUpperLeg = true,
    RightLowerLeg = true,
    RightFoot = true,
    ["Left Arm"] = true,
    ["Right Arm"] = true,
    ["Left Leg"] = true,
    ["Right Leg"] = true
}

local flowPreviewBoundingCornerSigns = {
    Vector3.new(-1, -1, -1),
    Vector3.new(-1, -1, 1),
    Vector3.new(-1, 1, -1),
    Vector3.new(-1, 1, 1),
    Vector3.new(1, -1, -1),
    Vector3.new(1, -1, 1),
    Vector3.new(1, 1, -1),
    Vector3.new(1, 1, 1)
}

local function getModelBoundingBoxSafe(model)
    if not model or not model.Parent then
        return nil, nil
    end
    local okBounds, boundsCF, boundsSize = pcall(function()
        return model:GetBoundingBox()
    end)
    if okBounds and typeof(boundsCF) == "CFrame" and typeof(boundsSize) == "Vector3" and boundsSize.Magnitude > 0 then
        return boundsCF, boundsSize
    end
    return nil, nil
end

function FoxyLibrary:SetESPPreviewProvider(providerFn)
    if providerFn ~= nil and type(providerFn) ~= "function" then
        return false, "ESP preview provider must be a function or nil."
    end
    self._espPreviewProvider = providerFn
    self._espPreviewResolveAccumulator = 0.2
    return true
end

function FoxyLibrary:SetESPPreviewData(previewData)
    if previewData ~= nil and type(previewData) ~= "table" then
        return false, "ESP preview data must be a table or nil."
    end
    self._espPreviewData = previewData
    self._espPreviewResolveAccumulator = 0.2
    return true
end

function FoxyLibrary:SetESPPreviewEnabled(enabled)
    self._uiVisualSettings.ESPSelfPreview = enabled == true
    if not self._uiVisualSettings.ESPSelfPreview then
        self._espPreviewWasShowing = false
        self._espPreviewUpdateAccumulator = 0
        self:_DestroyESPPreviewCharacter()
    else
        self:_InvalidateESPPreviewProjection(true)
    end
    self:_UpdateESPPreview(0)
end

function FoxyLibrary:_ResolveESPPreviewWalkAnimationId(sourceCharacter)
    if not sourceCharacter then
        return nil
    end
    local animateScript = sourceCharacter:FindFirstChild("Animate")
    if animateScript then
        local preferredFolders = {"walk", "run"}
        for _, folderName in ipairs(preferredFolders) do
            local folder = animateScript:FindFirstChild(folderName)
            if folder then
                local directAnimation = folder:FindFirstChildWhichIsA("Animation")
                if directAnimation and type(directAnimation.AnimationId) == "string" and directAnimation.AnimationId ~= "" then
                    return directAnimation.AnimationId
                end
                for _, child in ipairs(folder:GetDescendants()) do
                    if child:IsA("Animation") and type(child.AnimationId) == "string" and child.AnimationId ~= "" then
                        return child.AnimationId
                    end
                end
            end
        end
        for _, child in ipairs(animateScript:GetDescendants()) do
            if child:IsA("Animation") then
                local childName = string.lower(child.Name or "")
                if (string.find(childName, "walk", 1, true) or string.find(childName, "run", 1, true))
                    and type(child.AnimationId) == "string"
                    and child.AnimationId ~= "" then
                    return child.AnimationId
                end
            end
        end
    end
    return nil
end

function FoxyLibrary:_StartESPPreviewWalkAnimation(sourceCharacter)
    if self._espPreviewStaticMode then
        if self._espPreviewWalkTrack then
            pcall(function()
                self._espPreviewWalkTrack:Stop(0.1)
            end)
            pcall(function()
                self._espPreviewWalkTrack:Destroy()
            end)
            self._espPreviewWalkTrack = nil
        end
        self._espPreviewAnimationId = nil
        return
    end
    if not self._espPreviewCharacter or not self._espPreviewCharacter.Parent then
        return
    end
    if self._espPreviewWalkTrack and self._espPreviewWalkTrack.IsPlaying and self._espPreviewAnimationId then
        pcall(function()
            self._espPreviewWalkTrack:AdjustSpeed(0.95)
        end)
        return
    end
    local previewHumanoid = self._espPreviewCharacter:FindFirstChildOfClass("Humanoid")
    if not previewHumanoid then
        return
    end
    local resolvedId = self:_ResolveESPPreviewWalkAnimationId(sourceCharacter)
    if not resolvedId then
        return
    end
    if self._espPreviewWalkTrack and self._espPreviewAnimationId ~= resolvedId then
        pcall(function()
            self._espPreviewWalkTrack:Stop(0.1)
        end)
        pcall(function()
            self._espPreviewWalkTrack:Destroy()
        end)
        self._espPreviewWalkTrack = nil
    end

    local animator = previewHumanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = previewHumanoid
    end
    if not self._espPreviewWalkTrack then
        local walkAnimation = Instance.new("Animation")
        walkAnimation.AnimationId = resolvedId
        local okTrack, track = pcall(function()
            return animator:LoadAnimation(walkAnimation)
        end)
        walkAnimation:Destroy()
        if not okTrack or not track then
            return
        end
        track.Looped = true
        self._espPreviewWalkTrack = track
        self._espPreviewAnimationId = resolvedId
    end
    if self._espPreviewWalkTrack and not self._espPreviewWalkTrack.IsPlaying then
        pcall(function()
            self._espPreviewWalkTrack:Play(0.15, 1, 1)
        end)
    end
    if self._espPreviewWalkTrack then
        pcall(function()
            self._espPreviewWalkTrack:AdjustSpeed(0.95)
        end)
    end
end

function FoxyLibrary:_CreateESPPreviewFallbackCharacter()
    local fallbackModel = nil
    local created = false
    local previewUserId, previewImageUrl = resolveAvatar3DUserIdFromRobloxEndpoint(theOneAndOnlyPlayer.UserId)
    self._espPreviewAvatar3DUserId = previewUserId
    self._espPreviewAvatar3DImageUrl = previewImageUrl

    local okCreate = pcall(function()
        fallbackModel = playersAreNoobs:CreateHumanoidModelFromUserId(previewUserId)
    end)
    if not okCreate or not fallbackModel then
        local okDescription, humanoidDescription = pcall(function()
            return playersAreNoobs:GetHumanoidDescriptionFromUserId(previewUserId)
        end)
        if okDescription and humanoidDescription then
            pcall(function()
                fallbackModel = playersAreNoobs:CreateHumanoidModelFromDescription(humanoidDescription, Enum.HumanoidRigType.R15)
                created = true
            end)
        end
    end
    if fallbackModel then
        fallbackModel.Name = "FlowESPSelfPreviewAvatar"
        if created and not fallbackModel:FindFirstChildOfClass("Humanoid") then
            fallbackModel:Destroy()
            return nil
        end
    end
    return fallbackModel
end

function FoxyLibrary:_DestroyESPPreviewCharacter()
    if self._espPreviewWalkTrack then
        pcall(function()
            self._espPreviewWalkTrack:Stop(0.1)
        end)
        pcall(function()
            self._espPreviewWalkTrack:Destroy()
        end)
    end
    self._espPreviewWalkTrack = nil
    self._espPreviewAnimationId = nil
    if self._espPreviewHighlight then
        self._espPreviewHighlight.Adornee = nil
        self._espPreviewHighlight.Enabled = false
    end
    self._espPreviewPartDefaults = {}
    self._espPreviewHeadPart = nil
    self._espPreviewRootPart = nil
    self._espPreviewVisualState = nil
    self._espPreviewVisualDirty = false
    self._espPreviewProjectionCache = nil
    self._espPreviewProjectionDirty = true
    if self._espPreviewCharacter and self._espPreviewCharacter.Parent then
        self._espPreviewCharacter:Destroy()
    end
    self._espPreviewCharacter = nil
    self._espPreviewLastCharacter = nil
    self._espPreviewPivotYOffset = -2
end

function FoxyLibrary:_EnsureESPPreviewCharacter()
    if not self._espPreviewWorldModel then
        return
    end
    local liveCharacter = theOneAndOnlyPlayer.Character
    if self._espPreviewCharacter and self._espPreviewCharacter.Parent then
        if liveCharacter and self._espPreviewLastCharacter == liveCharacter then
            return
        end
        if not liveCharacter and self._espPreviewLastCharacter == false then
            return
        end
    end
    self:_DestroyESPPreviewCharacter()

    local function cloneFromLiveCharacter()
        if not liveCharacter then
            return nil
        end
        local previousArchivable = liveCharacter.Archivable
        local cloneCharacter = nil
        local clonedOk = pcall(function()
            liveCharacter.Archivable = true
            cloneCharacter = liveCharacter:Clone()
        end)
        pcall(function()
            liveCharacter.Archivable = previousArchivable
        end)
        if not clonedOk then
            return nil
        end
        return cloneCharacter
    end

    local function preparePreviewCharacter(model)
        if not model then
            return false
        end
        self._espPreviewPartDefaults = {}
        local rootPart = model:FindFirstChild("HumanoidRootPart")
            or model:FindFirstChild("UpperTorso")
            or model:FindFirstChild("Torso")
        local corePartCount = 0
        local visibleCorePartCount = 0
        local visiblePartCount = 0
        for _, obj in ipairs(model:GetDescendants()) do
            if obj:IsA("Script") or obj:IsA("LocalScript") then
                obj:Destroy()
            elseif obj:IsA("BasePart") then
                local isRootPart = obj.Name == "HumanoidRootPart"
                local isCoreBodyPart = flowPreviewCoreBodyParts[obj.Name] == true
                local sanitizedTransparency = math.clamp(tonumber(obj.Transparency) or 0, 0, 1)
                if isRootPart then
                    sanitizedTransparency = 1
                elseif isCoreBodyPart and sanitizedTransparency >= 0.98 then
                    sanitizedTransparency = 0
                end
                self._espPreviewPartDefaults[obj] = {
                    Color = obj.Color,
                    Material = obj.Material,
                    Transparency = sanitizedTransparency
                }
                obj.Transparency = sanitizedTransparency
                pcall(function()
                    obj.LocalTransparencyModifier = 0
                end)
                if isRootPart then
                    pcall(function()
                        obj.LocalTransparencyModifier = 1
                    end)
                end
                obj.CanCollide = false
                pcall(function()
                    obj.CanQuery = false
                end)
                pcall(function()
                    obj.CanTouch = false
                end)
                obj.Massless = true
                obj.CastShadow = false
                if rootPart == nil then
                    rootPart = obj
                end
                obj.Anchored = obj == rootPart

                if sanitizedTransparency < 0.985 and obj.Size.Magnitude > 0.05 then
                    visiblePartCount = visiblePartCount + 1
                end
                if isCoreBodyPart then
                    corePartCount = corePartCount + 1
                    if sanitizedTransparency < 0.985 then
                        visibleCorePartCount = visibleCorePartCount + 1
                    end
                end
            end
        end

        local headPart = model:FindFirstChild("Head")
            or model:FindFirstChild("UpperTorso")
            or model:FindFirstChild("Torso")
            or rootPart

        if corePartCount > 0 and visibleCorePartCount < math.min(4, corePartCount) then
            for part, originalData in pairs(self._espPreviewPartDefaults) do
                if part and part.Parent and originalData and flowPreviewCoreBodyParts[part.Name] then
                    originalData.Transparency = 0
                    part.Transparency = 0
                end
            end
            visibleCorePartCount = math.max(visibleCorePartCount, math.min(4, corePartCount))
        end

        if visiblePartCount < 6 then
            for _, obj in ipairs(model:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Transparency >= 0.98 and obj.Name ~= "HumanoidRootPart" then
                    local originalData = self._espPreviewPartDefaults[obj]
                    if originalData then
                        originalData.Transparency = 0
                    end
                    obj.Transparency = 0
                end
            end
            visiblePartCount = 6
        end

        self._espPreviewHeadPart = headPart
        self._espPreviewRootPart = rootPart or headPart
        self._espPreviewVisualDirty = true
        self:_InvalidateESPPreviewProjection(true)
        if rootPart then
            pcall(function()
                model.PrimaryPart = rootPart
            end)
        end

        if corePartCount > 0 and corePartCount < 3 then
            return false
        end
        if corePartCount >= 3 and visibleCorePartCount < 3 then
            return false
        end
        return visiblePartCount >= 6
    end

    local previewCharacter = self:_CreateESPPreviewFallbackCharacter()
    local hasReliableAvatar = preparePreviewCharacter(previewCharacter)
    if not hasReliableAvatar and previewCharacter and previewCharacter.Parent == nil then
        previewCharacter:Destroy()
        previewCharacter = nil
    end

    if not previewCharacter then
        previewCharacter = cloneFromLiveCharacter()
        local hasReliableClone = preparePreviewCharacter(previewCharacter)
        if not hasReliableClone and previewCharacter and previewCharacter.Parent == nil then
            previewCharacter:Destroy()
            previewCharacter = nil
        end
    end
    if not previewCharacter then
        return
    end

    previewCharacter.Parent = self._espPreviewWorldModel
    local previewHumanoid = previewCharacter:FindFirstChildOfClass("Humanoid")
    if previewHumanoid then
        previewHumanoid.AutoRotate = false
        previewHumanoid.PlatformStand = false
        pcall(function()
            previewHumanoid.BreakJointsOnDeath = false
        end)
    end
    local previewExtents = Vector3.new(4, 6, 3)
    local okPreviewExtents, calculatedPreviewExtents = pcall(function()
        return previewCharacter:GetExtentsSize()
    end)
    if okPreviewExtents and calculatedPreviewExtents then
        previewExtents = calculatedPreviewExtents
    end
    local pivotYOffset = self._espPreviewStaticMode and 0 or -math.clamp(previewExtents.Y * 0.43, 1.2, 3.2)
    self._espPreviewPivotYOffset = pivotYOffset
    local allowPreviewRotate = self._espPreviewAllowManualRotation == true
    local initialYaw = (self._espPreviewStaticMode and not allowPreviewRotate) and math.rad(180) or (tonumber(self._espPreviewRotationYaw) or tonumber(self._espPreviewRotationTargetYaw) or math.rad(180))
    self._espPreviewRotationYaw = initialYaw
    self._espPreviewRotationTargetYaw = initialYaw
    pcall(function()
        previewCharacter:PivotTo(CFrame.new(0, pivotYOffset, 0) * CFrame.Angles(0, initialYaw, 0))
    end)
    self._espPreviewCharacter = previewCharacter
    self._espPreviewLastCharacter = liveCharacter or false
    if self._espPreviewHighlight then
        self._espPreviewHighlight.Adornee = previewCharacter
    end

    if self._espPreviewCamera then
        if self._espPreviewStaticMode then
            self._espPreviewCamera.FieldOfView = 30
            local boundsCF, boundsSize = getModelBoundingBoxSafe(previewCharacter)
            if boundsCF and boundsSize then
                local boundsCenter = boundsCF.Position
                local viewportSize = self._espPreviewViewport and self._espPreviewViewport.AbsoluteSize or Vector2.new(1, 1)
                local aspectRatio = math.max(0.5, viewportSize.X / math.max(1, viewportSize.Y))
                local verticalHalfFov = math.rad(self._espPreviewCamera.FieldOfView) * 0.5
                local horizontalHalfFov = math.atan(math.tan(verticalHalfFov) * aspectRatio)
                local fitDepthY = (boundsSize.Y * 0.5) / math.max(0.001, math.tan(verticalHalfFov))
                local fitDepthX = (boundsSize.X * 0.5) / math.max(0.001, math.tan(horizontalHalfFov))
                local depth = math.max(fitDepthX, fitDepthY) + boundsSize.Z * 0.92 + 1.25
                depth = math.clamp(depth, 7.2, 16.2)
                local focus = boundsCenter + Vector3.new(0, math.clamp(boundsSize.Y * 0.03, -0.08, 0.25), 0)
                self._espPreviewCamera.CFrame = CFrame.new(focus + Vector3.new(0, math.clamp(boundsSize.Y * 0.03, -0.08, 0.35), depth), focus)
            else
                local fallbackFocus = Vector3.new(0, 0.45, 0)
                self._espPreviewCamera.CFrame = CFrame.new(Vector3.new(0, fallbackFocus.Y, 9.2), fallbackFocus)
            end
        else
            local focus = Vector3.new(0, math.clamp(previewExtents.Y * 0.36, 1.2, 2.45), 0)
            local depth = math.clamp(math.max(6.8, previewExtents.Y * 1.05 + previewExtents.X * 0.65), 6.8, 18)
            self._espPreviewCamera.FieldOfView = 32
            self._espPreviewCamera.CFrame = CFrame.new(Vector3.new(0, focus.Y, depth), focus)
        end
    end
    if not self._espPreviewStaticMode then
        self:_StartESPPreviewWalkAnimation(liveCharacter)
    end
end

function FoxyLibrary:_CreateESPPreviewPanel()
    if self._espPreviewPanel and self._espPreviewPanel.Parent then
        return
    end
    if not self.screenGuiYay or not self.screenGuiYay.Parent then
        return
    end

    local panelWidth = 226 * mobileScaleFactor
    local panelHeight = 296 * mobileScaleFactor
    local defaultPanelPosition = UDim2.new(0, 14 * mobileScaleFactor, 0, 66 * mobileScaleFactor)
    if self.mainFrameYay and self.mainFrameYay.Parent then
        local mainPos = self.mainFrameYay.Position
        defaultPanelPosition = UDim2.new(
            mainPos.X.Scale,
            mainPos.X.Offset - panelWidth - 12 * mobileScaleFactor,
            mainPos.Y.Scale,
            mainPos.Y.Offset + 42 * mobileScaleFactor
        )
    end
    local panel = makeThingExist("Frame", {
        Name = "FlowESPSelfPreviewPanel",
        BackgroundColor3 = Color3.fromRGB(14, 14, 16),
        BackgroundTransparency = 0.06,
        BorderSizePixel = 0,
        Position = defaultPanelPosition,
        Size = UDim2.new(0, panelWidth, 0, panelHeight),
        Visible = false,
        ZIndex = 30,
        Parent = self.screenGuiYay
    })
    makeThingExist("UICorner", {CornerRadius = UDim.new(0, 10), Parent = panel})
    makeThingExist("UIStroke", {Color = Color3.fromRGB(40, 40, 44), Thickness = 1.1, Parent = panel})
    makeThingExist("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 24)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 12, 14))
        }),
        Rotation = 90,
        Parent = panel
    })
    local panelDragHandle = makeThingExist("TextButton", {
        Name = "ESPPreviewDragHandle",
        Text = "",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 24 * mobileScaleFactor),
        Active = true,
        ZIndex = 36,
        Parent = panel
    })

    makeThingExist("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10 * mobileScaleFactor, 0, 8 * mobileScaleFactor),
        Size = UDim2.new(0, 110 * mobileScaleFactor, 0, 16 * mobileScaleFactor),
        Text = "ESP Preview",
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Color3.fromRGB(240, 240, 240),
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        TextSize = 13 * mobileScaleFactor,
        ZIndex = 31,
        Parent = panel
    })

    self._espPreviewHeaderTag = makeThingExist("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0.42, 0, 0, 8 * mobileScaleFactor),
        Size = UDim2.new(0.58, -8 * mobileScaleFactor, 0, 16 * mobileScaleFactor),
        Text = "@" .. tostring(theOneAndOnlyPlayer.Name),
        TextXAlignment = Enum.TextXAlignment.Right,
        TextColor3 = Color3.fromRGB(156, 156, 164),
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        TextSize = 12 * mobileScaleFactor,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 31,
        Parent = panel
    })

    local card = makeThingExist("Frame", {
        BackgroundColor3 = Color3.fromRGB(11, 11, 13),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 8 * mobileScaleFactor, 0, 28 * mobileScaleFactor),
        Size = UDim2.new(1, -16 * mobileScaleFactor, 1, -34 * mobileScaleFactor),
        ZIndex = 30,
        Parent = panel
    })
    makeThingExist("UICorner", {CornerRadius = UDim.new(0, 8), Parent = card})
    makeThingExist("UIStroke", {Color = Color3.fromRGB(33, 33, 37), Parent = card})

    local viewport = makeThingExist("ViewportFrame", {
        BackgroundColor3 = Color3.fromRGB(15, 15, 18),
        BackgroundTransparency = 0.08,
        Position = UDim2.new(0, 6 * mobileScaleFactor, 0, 6 * mobileScaleFactor),
        Size = UDim2.new(1, -12 * mobileScaleFactor, 1, -44 * mobileScaleFactor),
        Active = true,
        LightColor = Color3.new(1, 1, 1),
        LightDirection = Vector3.new(-0.34, -1, -0.22),
        Ambient = Color3.fromRGB(122, 122, 130),
        ZIndex = 31,
        Parent = card
    })
    makeThingExist("UICorner", {CornerRadius = UDim.new(0, 7), Parent = viewport})
    local worldModel = makeThingExist("WorldModel", {Parent = viewport})
    local camera = makeThingExist("Camera", {
        CFrame = CFrame.new(Vector3.new(0, 1.4, 7.2), Vector3.new(0, 1.2, 0)),
        Parent = viewport
    })
    viewport.CurrentCamera = camera

    local rotateCapture = makeThingExist("TextButton", {
        Name = "ESPPreviewRotateCapture",
        Text = "",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        Active = self._espPreviewAllowManualRotation == true,
        Selectable = false,
        ZIndex = 35,
        Parent = viewport
    })

    self._espPreviewBox = makeThingExist("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0.18, 0, 0.07, 0),
        Size = UDim2.new(0.64, 0, 0.84, 0),
        Visible = false,
        ZIndex = 33,
        Parent = viewport
    })
    self._espPreviewBoxStroke = makeThingExist("UIStroke", {
        Color = self.config.AccentColor,
        Thickness = 1.5,
        Parent = self._espPreviewBox
    })

    self._espPreviewHealthTrack = makeThingExist("Frame", {
        BackgroundColor3 = Color3.fromRGB(28, 28, 32),
        BorderSizePixel = 0,
        Position = UDim2.new(0.15, 0, 0.07, 0),
        Size = UDim2.new(0, 3 * mobileScaleFactor, 0.84, 0),
        Visible = false,
        ZIndex = 33,
        Parent = viewport
    })
    self._espPreviewHealthFill = makeThingExist("Frame", {
        BackgroundColor3 = Color3.fromRGB(100, 255, 100),
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 34,
        Parent = self._espPreviewHealthTrack
    })

    self._espPreviewDot = makeThingExist("Frame", {
        BackgroundColor3 = self.config.AccentColor,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -3 * mobileScaleFactor, 0.27, -3 * mobileScaleFactor),
        Size = UDim2.new(0, 6 * mobileScaleFactor, 0, 6 * mobileScaleFactor),
        Visible = false,
        ZIndex = 34,
        Parent = viewport
    })
    makeThingExist("UICorner", {CornerRadius = UDim.new(1, 0), Parent = self._espPreviewDot})

    self._espPreviewTracer = makeThingExist("Frame", {
        BackgroundColor3 = self.config.AccentColor,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, -1 * mobileScaleFactor, 0.58, 0),
        Size = UDim2.new(0, 2 * mobileScaleFactor, 0.34, 0),
        Visible = false,
        ZIndex = 33,
        Parent = viewport
    })

    self._espPreviewName = makeThingExist("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 1 * mobileScaleFactor),
        Size = UDim2.new(1, 0, 0, 15 * mobileScaleFactor),
        Text = tostring(theOneAndOnlyPlayer.Name),
        TextColor3 = self.config.AccentColor,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        TextSize = 11 * mobileScaleFactor,
        Visible = false,
        ZIndex = 34,
        Parent = viewport
    })

    self._espPreviewDistance = makeThingExist("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 1, -18 * mobileScaleFactor),
        Size = UDim2.new(1, 0, 0, 14 * mobileScaleFactor),
        Text = "0m",
        TextColor3 = Color3.fromRGB(186, 186, 192),
        TextXAlignment = Enum.TextXAlignment.Center,
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        TextSize = 11 * mobileScaleFactor,
        Visible = false,
        ZIndex = 34,
        Parent = card
    })

    self._espPreviewItem = makeThingExist("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 1, -32 * mobileScaleFactor),
        Size = UDim2.new(1, 0, 0, 14 * mobileScaleFactor),
        Text = "None",
        TextColor3 = Color3.fromRGB(206, 206, 212),
        TextXAlignment = Enum.TextXAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        TextSize = 11 * mobileScaleFactor,
        Visible = false,
        ZIndex = 34,
        Parent = card
    })

    self._espPreviewHighlight = makeThingExist("Highlight", {
        Enabled = false,
        DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
        Parent = worldModel
    })

    self._espPreviewPanel = panel
    self._espPreviewViewport = viewport
    self._espPreviewWorldModel = worldModel
    self._espPreviewCamera = camera
    self._espPreviewRotateCapture = rotateCapture
    self:_TrackConnection(viewport:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        self:_InvalidateESPPreviewProjection(false)
    end))

    if self._espPreviewAllowManualRotation == true then
        local function stopESPPreviewRotate()
            self._espPreviewIsRotating = false
            self._espPreviewRotateInput = nil
        end

        self:_TrackConnection(rotateCapture.InputBegan:Connect(function(input)
            local isMouse = input.UserInputType == Enum.UserInputType.MouseButton1
            local isTouch = input.UserInputType == Enum.UserInputType.Touch
            if not isMouse and not isTouch then
                return
            end
            self._espPreviewIsRotating = true
            self._espPreviewRotateInput = isTouch and input or nil
            self._espPreviewRotateLastX = input.Position.X
        end))

        self:_TrackConnection(rotateCapture.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                stopESPPreviewRotate()
                return
            end
            if input.UserInputType == Enum.UserInputType.Touch and (self._espPreviewRotateInput == nil or input == self._espPreviewRotateInput) then
                stopESPPreviewRotate()
            end
        end))

        self:_TrackConnection(thisInputServiceGoesHard.InputChanged:Connect(function(input)
            if not self._espPreviewIsRotating then
                return
            end
            local isMouseMove = input.UserInputType == Enum.UserInputType.MouseMovement and self._espPreviewRotateInput == nil
            local isTouchMove = input.UserInputType == Enum.UserInputType.Touch and (self._espPreviewRotateInput == nil or input == self._espPreviewRotateInput)
            if not isMouseMove and not isTouchMove then
                return
            end

            local previousX = tonumber(self._espPreviewRotateLastX) or input.Position.X
            local deltaX = input.Position.X - previousX
            self._espPreviewRotateLastX = input.Position.X

            local rotationSensitivity = isMobileUserSadly and 0.02 or 0.015
            self._espPreviewRotationTargetYaw = (tonumber(self._espPreviewRotationTargetYaw) or math.rad(180)) - deltaX * rotationSensitivity
        end))

        self:_TrackConnection(thisInputServiceGoesHard.InputEnded:Connect(function(input)
            if not self._espPreviewIsRotating then
                return
            end
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                stopESPPreviewRotate()
                return
            end
            if input.UserInputType == Enum.UserInputType.Touch and (self._espPreviewRotateInput == nil or input == self._espPreviewRotateInput) then
                stopESPPreviewRotate()
            end
        end))
    else
        self._espPreviewIsRotating = false
        self._espPreviewRotateInput = nil
        self._espPreviewRotateLastX = 0
    end

    makeDraggableCuzWeCan(panel, panelDragHandle, self)
    self:_EnsureESPPreviewCharacter()
    self:_UpdateESPPreview(0)
end

function FoxyLibrary:_ResolveESPPreviewState()
    local state = {
        Enabled = true,
        ShowBox = false,
        ShowHealth = false,
        ShowName = false,
        UseDisplayName = false,
        ShowItem = false,
        ShowDistance = false,
        ShowTracers = false,
        ShowDot = false,
        ShowChams = false,
        ShowHighlight = false,
        ChamsTransparency = 0.55,
        HighlightFillTransparency = 0.5,
        HighlightOutlineTransparency = 0,
        Color = self.config.AccentColor,
        Name = tostring(theOneAndOnlyPlayer.Name),
        Item = "None",
        DistanceText = "0m",
        HealthPercent = 1
    }

    local liveCharacter = theOneAndOnlyPlayer.Character
    local liveHumanoid = liveCharacter and liveCharacter:FindFirstChildOfClass("Humanoid")
    if liveHumanoid and liveHumanoid.MaxHealth > 0 then
        state.HealthPercent = math.clamp(liveHumanoid.Health / liveHumanoid.MaxHealth, 0, 1)
    end
    if liveCharacter then
        for _, tool in ipairs(liveCharacter:GetChildren()) do
            if tool:IsA("Tool") then
                state.Item = tool.Name
                break
            end
        end
        local localRoot = liveCharacter:FindFirstChild("HumanoidRootPart")
        local cameraRef = workspace.CurrentCamera
        if localRoot and cameraRef then
            state.DistanceText = string.format("%.0fm", (cameraRef.CFrame.Position - localRoot.Position).Magnitude)
        end
    end

    local function applyStateFromTrackedControls()
        local touched = false
        for flagName, control in pairs(self._trackedControls) do
            if type(control) == "table" and type(control.get) == "function" then
                local okValue, controlValue = pcall(control.get)
                if okValue then
                    local rawFlag = string.lower(tostring(flagName or ""))
                    local compactFlag = rawFlag:gsub("[^%w]", "")
                    local function hasFlagToken(...)
                        local tokens = {...}
                        for _, token in ipairs(tokens) do
                            local rawToken = string.lower(tostring(token))
                            local compactToken = rawToken:gsub("[^%w]", "")
                            if rawToken ~= "" and string.find(rawFlag, rawToken, 1, true) then
                                return true
                            end
                            if compactToken ~= "" and string.find(compactFlag, compactToken, 1, true) then
                                return true
                            end
                        end
                        return false
                    end
                    local boolValue = flowPreviewToBool(controlValue)
                    if boolValue ~= nil then
                        if hasFlagToken("esp enabled", "espenabled", "esp toggle", "toggle esp", "enable esp") then
                            state.Enabled = boolValue
                            touched = true
                        elseif hasFlagToken("show box", "showbox", "box esp", "boxes") then
                            state.ShowBox = boolValue
                            touched = true
                        elseif hasFlagToken("show health", "health bar", "healthesp", "showhealth") then
                            state.ShowHealth = boolValue
                            touched = true
                        elseif hasFlagToken("show name", "name esp", "nametag", "showname") then
                            state.ShowName = boolValue
                            touched = true
                        elseif hasFlagToken("display name", "usedisplayname") then
                            state.UseDisplayName = boolValue
                            touched = true
                        elseif hasFlagToken("show equipped item", "show item", "show weapon", "item esp", "tool esp") then
                            state.ShowItem = boolValue
                            touched = true
                        elseif hasFlagToken("show distance", "distance esp", "showdistance") then
                            state.ShowDistance = boolValue
                            touched = true
                        elseif hasFlagToken("show tracers", "tracers", "tracer esp") then
                            state.ShowTracers = boolValue
                            touched = true
                        elseif hasFlagToken("show dot", "dot esp", "head dot", "headdot") then
                            state.ShowDot = boolValue
                            touched = true
                        elseif hasFlagToken("chams enabled", "chams", "use chams") then
                            state.ShowChams = boolValue
                            touched = true
                        elseif hasFlagToken("highlight enabled", "use highlight", "highlight") then
                            state.ShowHighlight = boolValue
                            touched = true
                        end
                    elseif typeof(controlValue) == "Color3" then
                        if hasFlagToken("esp color", "visual color", "highlight color", "chams color", "espcolour", "visualcolour") then
                            state.Color = controlValue
                            touched = true
                        end
                    elseif type(controlValue) == "number" then
                        if hasFlagToken("chams transparency", "cham transparency") then
                            state.ChamsTransparency = math.clamp(controlValue, 0, 1)
                            touched = true
                        elseif hasFlagToken("fill transparency", "highlight fill transparency") then
                            state.HighlightFillTransparency = math.clamp(controlValue, 0, 1)
                            touched = true
                        elseif hasFlagToken("outline transparency", "highlight outline transparency") then
                            state.HighlightOutlineTransparency = math.clamp(controlValue, 0, 1)
                            touched = true
                        end
                    end
                end
            end
        end
        return touched
    end

    local function applyStateFrom(sourceTable)
        if type(sourceTable) ~= "table" then
            return false
        end
        local touched = false
        local function setBoolField(targetField, keys)
            local rawValue = flowPreviewPullValue(sourceTable, keys)
            local boolValue = flowPreviewToBool(rawValue)
            if boolValue ~= nil then
                state[targetField] = boolValue
                touched = true
            end
        end
        local function setNumberField(targetField, keys, minValue, maxValue)
            local rawValue = flowPreviewPullValue(sourceTable, keys)
            if type(rawValue) == "number" then
                state[targetField] = math.clamp(rawValue, minValue, maxValue)
                touched = true
            end
        end

        setBoolField("Enabled", {"ESPEnabled", "Enabled", "ESP", "MasterEnabled", "MasterSwitch"})
        setBoolField("ShowBox", {"ShowBox", "Boxes", "Box", "BoxESP"})
        setBoolField("ShowHealth", {"ShowHealth", "Health", "HealthBar", "HealthESP"})
        setBoolField("ShowName", {"ShowName", "Names", "NameESP", "Nametags"})
        setBoolField("UseDisplayName", {"UseDisplayName", "DisplayName", "DisplayNames"})
        setBoolField("ShowItem", {"ShowEquippedItem", "ShowItem", "ItemESP", "ShowWeapon", "ShowTool"})
        setBoolField("ShowDistance", {"ShowDistance", "Distance", "DistanceESP"})
        setBoolField("ShowTracers", {"ShowTracers", "Tracers", "TracerESP"})
        setBoolField("ShowDot", {"ShowDot", "Dot", "DotESP", "HeadDot"})
        setBoolField("ShowChams", {"ChamsEnabled", "Chams", "UseChams", "CharacterMaterial"})
        setBoolField("ShowHighlight", {"HighlightEnabled", "Highlight", "UseHighlight"})

        setNumberField("ChamsTransparency", {"ChamsTransparency", "ChamTransparency", "ChamsAlpha"}, 0, 1)
        setNumberField("HighlightFillTransparency", {"HighlightFillTransparency", "HighlightFillAlpha"}, 0, 1)
        setNumberField("HighlightOutlineTransparency", {"HighlightOutlineTransparency", "HighlightOutlineAlpha"}, 0, 1)

        local colorValue = flowPreviewToColor3(flowPreviewPullValue(sourceTable, {
            "VisualColor", "ESPColor", "Color", "Colour", "MainColor", "ChamsColor", "HighlightColor"
        }))
        if colorValue then
            state.Color = colorValue
            touched = true
        end

        local suppliedName = flowPreviewPullValue(sourceTable, {"Name", "PlayerName", "DisplayName", "NameText"})
        if type(suppliedName) == "string" and suppliedName ~= "" then
            state.Name = suppliedName
            touched = true
        end
        local suppliedItem = flowPreviewPullValue(sourceTable, {"Item", "ItemName", "Tool", "ToolName", "Weapon", "WeaponName"})
        if type(suppliedItem) == "string" and suppliedItem ~= "" then
            state.Item = suppliedItem
            touched = true
        end
        local suppliedDistanceText = flowPreviewPullValue(sourceTable, {"DistanceText", "DistanceString", "DistanceLabel"})
        if type(suppliedDistanceText) == "string" and suppliedDistanceText ~= "" then
            state.DistanceText = suppliedDistanceText
            touched = true
        else
            local suppliedDistance = flowPreviewPullValue(sourceTable, {"Distance", "DistanceValue"})
            if type(suppliedDistance) == "number" then
                state.DistanceText = string.format("%.0fm", suppliedDistance)
                touched = true
            end
        end

        local suppliedHealthPercent = flowPreviewPullValue(sourceTable, {"HealthPercent", "HPPercent", "HealthRatio"})
        if type(suppliedHealthPercent) == "number" then
            if suppliedHealthPercent > 1 then
                suppliedHealthPercent = suppliedHealthPercent / 100
            end
            state.HealthPercent = math.clamp(suppliedHealthPercent, 0, 1)
            touched = true
        else
            local suppliedHealth = flowPreviewPullValue(sourceTable, {"Health", "HP"})
            local suppliedMaxHealth = flowPreviewPullValue(sourceTable, {"MaxHealth", "MaxHP", "HealthMax"})
            if type(suppliedHealth) == "number" and type(suppliedMaxHealth) == "number" and suppliedMaxHealth > 0 then
                state.HealthPercent = math.clamp(suppliedHealth / suppliedMaxHealth, 0, 1)
                touched = true
            end
        end

        return touched
    end

    local appliedTracked = applyStateFromTrackedControls()
    local appliedExternal = false
    if type(self._espPreviewData) == "table" then
        appliedExternal = applyStateFrom(self._espPreviewData) or appliedExternal
    end
    if type(self._espPreviewProvider) == "function" then
        local ok, providerResult = pcall(self._espPreviewProvider, self, state)
        if ok and type(providerResult) == "table" then
            appliedExternal = applyStateFrom(providerResult) or appliedExternal
        end
    end

    if not appliedExternal and not appliedTracked then
        local candidates = {}
        local candidateSet = {}
        local function addCandidate(candidate)
            if type(candidate) ~= "table" then
                return
            end
            if candidateSet[candidate] then
                return
            end
            candidateSet[candidate] = true
            table.insert(candidates, candidate)
        end
        local function addFromEnvironment(env)
            if type(env) ~= "table" then
                return
            end
            addCandidate(env.Settings)
            addCandidate(env.settings)
            addCandidate(env.ESPSettings)
            addCandidate(env.VisualSettings)
            addCandidate(env.Visuals)
            addCandidate(env.ESP)
            addCandidate(env.esp)
            addCandidate(env.Flags)
            addCandidate(env.flags)
            if type(env.Config) == "table" then
                addCandidate(env.Config.Settings)
                addCandidate(env.Config.ESP)
                addCandidate(env.Config.Visuals)
            end
        end
        if type(getgenv) == "function" then
            local okEnv, env = pcall(getgenv)
            if okEnv then
                addFromEnvironment(env)
            end
        end
        addFromEnvironment(_G)

        local knownKeys = {
            "ESPEnabled", "ShowBox", "ShowHealth", "ShowName", "UseDisplayName", "ShowEquippedItem",
            "ShowDistance", "ShowTracers", "ShowDot", "ChamsEnabled", "HighlightEnabled", "VisualColor"
        }
        local bestCandidate = nil
        local bestScore = 0
        for _, candidate in ipairs(candidates) do
            local score = 0
            for _, keyName in ipairs(knownKeys) do
                if candidate[keyName] ~= nil then
                    score = score + 1
                end
            end
            if score > bestScore then
                bestScore = score
                bestCandidate = candidate
            end
        end
        if bestCandidate and bestScore > 0 then
            applyStateFrom(bestCandidate)
        end
    end

    if state.UseDisplayName then
        state.Name = tostring(theOneAndOnlyPlayer.DisplayName or theOneAndOnlyPlayer.Name)
    elseif state.Name == "" or state.Name == nil then
        state.Name = tostring(theOneAndOnlyPlayer.Name)
    end
    return state
end

function FoxyLibrary:_ApplyESPPreviewPartVisualState(showChams, previewColor, chamsTransparency)
    local targetShowChams = showChams == true
    local targetChamsTransparency = math.clamp(chamsTransparency or 0.55, 0, 0.92)
    local lastVisualState = self._espPreviewVisualState or {}
    local colorChanged = targetShowChams and lastVisualState.Color ~= previewColor
    local transparencyChanged = targetShowChams and math.abs((lastVisualState.ChamsTransparency or targetChamsTransparency) - targetChamsTransparency) > 0.001

    if not self._espPreviewVisualDirty
        and lastVisualState.ShowChams == targetShowChams
        and not colorChanged
        and not transparencyChanged then
        return
    end

    for part, originalData in pairs(self._espPreviewPartDefaults) do
        if part and part.Parent and originalData then
            local isRootPart = part.Name == "HumanoidRootPart"
            if targetShowChams and not isRootPart then
                if part.Material ~= Enum.Material.ForceField then
                    part.Material = Enum.Material.ForceField
                end
                if part.Color ~= previewColor then
                    part.Color = previewColor
                end
                if math.abs(part.Transparency - targetChamsTransparency) > 0.001 then
                    part.Transparency = targetChamsTransparency
                end
            else
                if part.Material ~= originalData.Material then
                    part.Material = originalData.Material
                end
                if part.Color ~= originalData.Color then
                    part.Color = originalData.Color
                end

                local targetTransparency
                if isRootPart then
                    targetTransparency = 1
                elseif flowPreviewCoreBodyParts[part.Name] and (originalData.Transparency or 0) >= 0.98 then
                    targetTransparency = 0
                else
                    targetTransparency = originalData.Transparency
                end

                if math.abs(part.Transparency - targetTransparency) > 0.001 then
                    part.Transparency = targetTransparency
                end
            end
        end
    end

    self._espPreviewVisualState = {
        ShowChams = targetShowChams,
        Color = previewColor,
        ChamsTransparency = targetChamsTransparency
    }
    self._espPreviewVisualDirty = false
end

function FoxyLibrary:_UpdateESPPreview(dt)
    local shouldShow = self.isToggledOn and self._uiVisualSettings.ESPSelfPreview
    if not shouldShow then
        if self._espPreviewPanel then
            self._espPreviewPanel.Visible = false
        end
        if self._espPreviewWasShowing then
            self._espPreviewWasShowing = false
            self._espPreviewUpdateAccumulator = 0
            self:_DestroyESPPreviewCharacter()
        end
        return
    end

    self._espPreviewWasShowing = true

    if not self._espPreviewPanel or not self._espPreviewPanel.Parent then
        self:_CreateESPPreviewPanel()
    end
    if not self._espPreviewPanel then
        return
    end
    self._espPreviewPanel.Visible = true

    local resolvedDt = tonumber(dt) or 0
    if resolvedDt > 0 then
        self._espPreviewUpdateAccumulator = (tonumber(self._espPreviewUpdateAccumulator) or 0) + resolvedDt
        local updateInterval = isMobileUserSadly and 0.075 or 0.06
        if self._latestFPSValue > 0 then
            if self._latestFPSValue < 40 then
                updateInterval = isMobileUserSadly and 0.11 or 0.09
            elseif self._latestFPSValue < 55 then
                updateInterval = isMobileUserSadly and 0.09 or 0.075
            elseif self._latestFPSValue > 95 then
                updateInterval = isMobileUserSadly and 0.065 or 0.05
            end
        end
        if self._espPreviewUpdateAccumulator < updateInterval then
            return
        end
        resolvedDt = self._espPreviewUpdateAccumulator
        self._espPreviewUpdateAccumulator = 0
    end

    self._espPreviewResolveAccumulator = self._espPreviewResolveAccumulator + resolvedDt
    if not self._espPreviewState or self._espPreviewResolveAccumulator >= 0.16 then
        self._espPreviewState = self:_ResolveESPPreviewState()
        self._espPreviewResolveAccumulator = 0
    end
    local state = self._espPreviewState or self:_ResolveESPPreviewState()
    local previewColor = state.Color or self.config.AccentColor
    local showMaster = state.Enabled ~= false
    local hidePlayerName = self._uiVisualSettings.HideName == true
    local needsProjection = showMaster and (
        state.ShowBox == true
        or state.ShowHealth == true
        or state.ShowName == true
        or state.ShowDot == true
        or state.ShowTracers == true
    )

    self:_EnsureESPPreviewCharacter()
    if self._espPreviewAllowManualRotation == true and self._espPreviewCharacter and self._espPreviewCharacter.Parent then
        local currentYaw = tonumber(self._espPreviewRotationYaw) or math.rad(180)
        local targetYaw = tonumber(self._espPreviewRotationTargetYaw) or currentYaw
        local yawDelta = math.atan2(math.sin(targetYaw - currentYaw), math.cos(targetYaw - currentYaw))
        local yawAlpha = math.clamp((resolvedDt > 0 and resolvedDt or (1 / 60)) * 14, 0.08, 0.58)
        if math.abs(yawDelta) > 0.0004 then
            currentYaw = currentYaw + yawDelta * yawAlpha
            self._espPreviewRotationYaw = currentYaw
            self:_InvalidateESPPreviewProjection(false)
            local pivotYOffset = tonumber(self._espPreviewPivotYOffset) or -2
            pcall(function()
                self._espPreviewCharacter:PivotTo(CFrame.new(0, pivotYOffset, 0) * CFrame.Angles(0, currentYaw, 0))
            end)
        end
    end
    if not self._espPreviewStaticMode and (not self._espPreviewWalkTrack or not self._espPreviewWalkTrack.IsPlaying) then
        self:_StartESPPreviewWalkAnimation(theOneAndOnlyPlayer.Character)
    end
    if self._espPreviewHeaderTag then
        self._espPreviewHeaderTag.Visible = not hidePlayerName
        if not hidePlayerName then
            self._espPreviewHeaderTag.Text = "@" .. tostring(theOneAndOnlyPlayer.Name)
        end
    end
    if not self._espPreviewCharacter then
        if self._espPreviewBox then self._espPreviewBox.Visible = false end
        if self._espPreviewHealthTrack then self._espPreviewHealthTrack.Visible = false end
        if self._espPreviewDot then self._espPreviewDot.Visible = false end
        if self._espPreviewTracer then self._espPreviewTracer.Visible = false end
        if self._espPreviewName then self._espPreviewName.Visible = false end
        if self._espPreviewItem then self._espPreviewItem.Visible = false end
        if self._espPreviewDistance then self._espPreviewDistance.Visible = false end
        if self._espPreviewHighlight then self._espPreviewHighlight.Enabled = false end
        return
    end

    if self._espPreviewBoxStroke then self._espPreviewBoxStroke.Color = previewColor end
    if self._espPreviewDot then self._espPreviewDot.BackgroundColor3 = previewColor end
    if self._espPreviewTracer then self._espPreviewTracer.BackgroundColor3 = previewColor end

    local viewportCamera = self._espPreviewCamera or (self._espPreviewViewport and self._espPreviewViewport.CurrentCamera)
    local viewportSize = self._espPreviewViewport and self._espPreviewViewport.AbsoluteSize or Vector2.new(0, 0)
    local hasProjectedBox = false
    local boxMinX, boxMinY = math.huge, math.huge
    local boxMaxX, boxMaxY = -math.huge, -math.huge
    local headScreenPos = nil
    local rootScreenPos = nil
    local boundsCF = nil
    local boundsSize = nil
    local projectionCache = nil
    local canReuseProjection = false

    if needsProjection and viewportCamera and viewportSize.X > 2 and viewportSize.Y > 2 then
        projectionCache = self._espPreviewProjectionCache
        canReuseProjection = self._espPreviewStaticMode
            and self._espPreviewProjectionDirty ~= true
            and projectionCache ~= nil
            and math.abs((projectionCache.ViewportWidth or 0) - viewportSize.X) < 0.5
            and math.abs((projectionCache.ViewportHeight or 0) - viewportSize.Y) < 0.5

        if canReuseProjection then
            hasProjectedBox = projectionCache.HasProjectedBox == true
            boxMinX = projectionCache.BoxMinX or boxMinX
            boxMinY = projectionCache.BoxMinY or boxMinY
            boxMaxX = projectionCache.BoxMaxX or boxMaxX
            boxMaxY = projectionCache.BoxMaxY or boxMaxY
            if projectionCache.HeadX ~= nil and projectionCache.HeadY ~= nil then
                headScreenPos = Vector2.new(projectionCache.HeadX, projectionCache.HeadY)
            end
            if projectionCache.RootX ~= nil and projectionCache.RootY ~= nil then
                rootScreenPos = Vector2.new(projectionCache.RootX, projectionCache.RootY)
            end
        else
            boundsCF, boundsSize = getModelBoundingBoxSafe(self._espPreviewCharacter)

            if not self._espPreviewStaticMode and boundsCF and boundsSize then
                viewportCamera.FieldOfView = 32
                local boundsCenter = boundsCF.Position
                local verticalFov = math.rad(math.clamp(viewportCamera.FieldOfView, 18, 80))
                local aspectRatio = math.max(0.35, viewportSize.X / viewportSize.Y)
                local horizontalHalfFov = math.atan(math.tan(verticalFov * 0.5) * aspectRatio)
                local fitDepthY = (boundsSize.Y * 0.5) / math.max(0.001, math.tan(verticalFov * 0.5))
                local fitDepthX = (boundsSize.X * 0.5) / math.max(0.001, math.tan(horizontalHalfFov))
                local targetDepth = math.max(fitDepthX, fitDepthY) + boundsSize.Z * 0.85 + 1.35
                targetDepth = math.clamp(targetDepth, 6.8, 19.5)
                local lookTarget = boundsCenter + Vector3.new(0, math.clamp(boundsSize.Y * 0.03, -0.1, 0.45), 0)
                local cameraPos = lookTarget + Vector3.new(0, math.clamp(boundsSize.Y * 0.08, -0.2, 0.6), targetDepth)
                local targetCFrame = CFrame.new(cameraPos, lookTarget)
                local lerpAlpha = math.clamp((resolvedDt > 0 and resolvedDt or (1 / 60)) * 10, 0.12, 0.52)
                viewportCamera.CFrame = viewportCamera.CFrame:Lerp(targetCFrame, lerpAlpha)
            end

            if boundsCF and boundsSize then
                local halfSize = boundsSize * 0.5
                for _, cornerSign in ipairs(flowPreviewBoundingCornerSigns) do
                    local worldPoint = boundsCF:PointToWorldSpace(Vector3.new(
                        halfSize.X * cornerSign.X,
                        halfSize.Y * cornerSign.Y,
                        halfSize.Z * cornerSign.Z
                    ))
                    local screenPoint = viewportCamera:WorldToViewportPoint(worldPoint)
                    if screenPoint.Z > 0 then
                        hasProjectedBox = true
                        boxMinX = math.min(boxMinX, screenPoint.X)
                        boxMinY = math.min(boxMinY, screenPoint.Y)
                        boxMaxX = math.max(boxMaxX, screenPoint.X)
                        boxMaxY = math.max(boxMaxY, screenPoint.Y)
                    end
                end
            end

            local headPart = self._espPreviewHeadPart
            if headPart and headPart.Parent then
                local headWorld = headPart.Position + Vector3.new(0, math.max(0.12, headPart.Size.Y * 0.3), 0)
                local headPoint = viewportCamera:WorldToViewportPoint(headWorld)
                if headPoint.Z > 0 then
                    headScreenPos = Vector2.new(headPoint.X, headPoint.Y)
                end
            end

            local rootPart = self._espPreviewRootPart
            if rootPart and rootPart.Parent then
                local rootPoint = viewportCamera:WorldToViewportPoint(rootPart.Position)
                if rootPoint.Z > 0 then
                    rootScreenPos = Vector2.new(rootPoint.X, rootPoint.Y)
                end
            end
        end
    end

    if needsProjection and hasProjectedBox then
        boxMinX = math.clamp(boxMinX, 0, viewportSize.X)
        boxMinY = math.clamp(boxMinY, 0, viewportSize.Y)
        boxMaxX = math.clamp(boxMaxX, 0, viewportSize.X)
        boxMaxY = math.clamp(boxMaxY, 0, viewportSize.Y)
        if boxMaxX - boxMinX < 2 or boxMaxY - boxMinY < 2 then
            hasProjectedBox = false
        end
    end

    if needsProjection and not hasProjectedBox and viewportSize.X > 2 and viewportSize.Y > 2 then
        local fallbackWidth = viewportSize.X * 0.44
        local fallbackHeight = viewportSize.Y * 0.78
        boxMinX = (viewportSize.X - fallbackWidth) * 0.5
        boxMaxX = boxMinX + fallbackWidth
        boxMinY = viewportSize.Y * 0.1
        boxMaxY = boxMinY + fallbackHeight
        hasProjectedBox = true
        if not headScreenPos then
            headScreenPos = Vector2.new((boxMinX + boxMaxX) * 0.5, boxMinY + 8 * mobileScaleFactor)
        end
        if not rootScreenPos then
            rootScreenPos = Vector2.new((boxMinX + boxMaxX) * 0.5, boxMaxY)
        end
    end

    if needsProjection and self._espPreviewStaticMode and viewportSize.X > 2 and viewportSize.Y > 2 and not canReuseProjection then
        self._espPreviewProjectionCache = {
            ViewportWidth = viewportSize.X,
            ViewportHeight = viewportSize.Y,
            HasProjectedBox = hasProjectedBox == true,
            BoxMinX = hasProjectedBox and boxMinX or nil,
            BoxMinY = hasProjectedBox and boxMinY or nil,
            BoxMaxX = hasProjectedBox and boxMaxX or nil,
            BoxMaxY = hasProjectedBox and boxMaxY or nil,
            HeadX = headScreenPos and headScreenPos.X or nil,
            HeadY = headScreenPos and headScreenPos.Y or nil,
            RootX = rootScreenPos and rootScreenPos.X or nil,
            RootY = rootScreenPos and rootScreenPos.Y or nil
        }
        self._espPreviewProjectionDirty = false
    end
    if self._espPreviewBox then
        local showBox = showMaster and state.ShowBox == true and hasProjectedBox
        self._espPreviewBox.Visible = showBox
        if showBox then
            self._espPreviewBox.Position = UDim2.new(0, boxMinX, 0, boxMinY)
            self._espPreviewBox.Size = UDim2.new(0, boxMaxX - boxMinX, 0, boxMaxY - boxMinY)
        end
    end
    if self._espPreviewDot then
        local showDot = showMaster and state.ShowDot == true and headScreenPos ~= nil
        self._espPreviewDot.Visible = showDot
        if showDot then
            local dotSize = math.max(5 * mobileScaleFactor, 1)
            self._espPreviewDot.Position = UDim2.new(0, headScreenPos.X - dotSize * 0.5, 0, headScreenPos.Y - dotSize * 0.5)
            self._espPreviewDot.Size = UDim2.new(0, dotSize, 0, dotSize)
        end
    end
    if self._espPreviewTracer then
        local showTracer = showMaster and state.ShowTracers == true and (hasProjectedBox or rootScreenPos ~= nil)
        self._espPreviewTracer.Visible = showTracer
        if showTracer then
            local fromX = viewportSize.X * 0.5
            local fromY = viewportSize.Y - 1
            local toX = rootScreenPos and rootScreenPos.X or (boxMinX + (boxMaxX - boxMinX) * 0.5)
            local toY = rootScreenPos and rootScreenPos.Y or boxMaxY
            local dx = toX - fromX
            local dy = toY - fromY
            local length = math.sqrt(dx * dx + dy * dy)
            if length >= 2 then
                self._espPreviewTracer.Position = UDim2.new(0, fromX, 0, fromY)
                self._espPreviewTracer.Size = UDim2.new(0, 2 * mobileScaleFactor, 0, length)
                self._espPreviewTracer.Rotation = math.deg(math.atan2(dy, dx)) + 90
            else
                self._espPreviewTracer.Visible = false
            end
        end
    end

    if self._espPreviewName then
        local showName = not hidePlayerName and showMaster and state.ShowName == true and (hasProjectedBox or headScreenPos ~= nil)
        self._espPreviewName.Visible = showName
        if not hidePlayerName then
            self._espPreviewName.Text = tostring(state.Name or theOneAndOnlyPlayer.Name)
        end
        self._espPreviewName.TextColor3 = previewColor
        if showName then
            local nameWidth = hasProjectedBox and (boxMaxX - boxMinX + 20 * mobileScaleFactor) or (120 * mobileScaleFactor)
            nameWidth = math.clamp(nameWidth, 70 * mobileScaleFactor, viewportSize.X)
            local centerX = hasProjectedBox and (boxMinX + (boxMaxX - boxMinX) * 0.5) or headScreenPos.X
            local nameX = math.clamp(centerX - nameWidth * 0.5, 0, math.max(0, viewportSize.X - nameWidth))
            local nameY = hasProjectedBox and math.max(0, boxMinY - 16 * mobileScaleFactor) or math.max(0, headScreenPos.Y - 16 * mobileScaleFactor)
            self._espPreviewName.Position = UDim2.new(0, nameX, 0, nameY)
            self._espPreviewName.Size = UDim2.new(0, nameWidth, 0, 14 * mobileScaleFactor)
        end
    end

    if self._espPreviewItem then
        self._espPreviewItem.Visible = state.ShowItem == true and showMaster
        self._espPreviewItem.Text = tostring(state.Item or "None")
        self._espPreviewItem.TextColor3 = previewColor
    end

    if self._espPreviewDistance then
        self._espPreviewDistance.Visible = state.ShowDistance == true and showMaster
        self._espPreviewDistance.Text = tostring(state.DistanceText or "0m")
        self._espPreviewDistance.TextColor3 = previewColor
    end

    if self._espPreviewHealthTrack then
        local showHealth = state.ShowHealth == true and showMaster and hasProjectedBox
        self._espPreviewHealthTrack.Visible = showHealth
        if showHealth and self._espPreviewHealthFill then
            self._espPreviewHealthTrack.Position = UDim2.new(0, math.max(0, boxMinX - 5 * mobileScaleFactor), 0, boxMinY)
            self._espPreviewHealthTrack.Size = UDim2.new(0, 3 * mobileScaleFactor, 0, boxMaxY - boxMinY)
            local hpPercent = math.clamp(tonumber(state.HealthPercent) or 1, 0, 1)
            self._espPreviewHealthFill.Size = UDim2.new(1, 0, hpPercent, 0)
            self._espPreviewHealthFill.BackgroundColor3 = Color3.new(1 - hpPercent, hpPercent, 0)
        end
    end

    self:_ApplyESPPreviewPartVisualState(state.ShowChams == true and showMaster, previewColor, state.ChamsTransparency)

    if self._espPreviewHighlight then
        self._espPreviewHighlight.FillColor = previewColor
        self._espPreviewHighlight.OutlineColor = previewColor
        self._espPreviewHighlight.FillTransparency = math.clamp(state.HighlightFillTransparency or 0.5, 0, 1)
        self._espPreviewHighlight.OutlineTransparency = math.clamp(state.HighlightOutlineTransparency or 0, 0, 1)
        self._espPreviewHighlight.Enabled = state.ShowHighlight == true and state.Enabled ~= false
    end
end

function FoxyLibrary:EnableSmoothScrolling(scrollFrame, smoothSpeed)
    if not scrollFrame or self._smoothScrollFrames[scrollFrame] then return end
    if scrollFrame:GetAttribute("FlowDisableSmoothScroll") == true then
        scrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
        scrollFrame.ElasticBehavior = Enum.ElasticBehavior.Never
        scrollFrame.ScrollBarImageTransparency = 0.1
        return
    end
    self._smoothScrollFrames[scrollFrame] = {
        targetY = scrollFrame.CanvasPosition.Y,
        internal = false,
        speed = smoothSpeed or 34
    }
    scrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    scrollFrame.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
    scrollFrame.ScrollBarImageTransparency = 0.25
    self:_TrackConnection(scrollFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
        local state = self._smoothScrollFrames[scrollFrame]
        if not state or state.internal then return end
        state.targetY = scrollFrame.CanvasPosition.Y
    end))
end

function FoxyLibrary:ApplySearchFilter(rawQuery)
    local query = normalizeSearchText(rawQuery)
    self._searchQuery = query
    local firstVisibleTab = nil
    local function matchesAny(queryText, termList)
        if queryText == "" then return true end
        if type(termList) ~= "table" then return false end
        for _, term in ipairs(termList) do
            local normalized = normalizeSearchText(term)
            if normalized ~= "" and string.find(normalized, queryText, 1, true) ~= nil then
                return true
            end
        end
        return false
    end

    for _, section in ipairs(self.sectionsAreAwesome) do
        local sectionHasVisibleContent = false
        for _, tab in ipairs(section.tabsInSection) do
            local tabMatch = matchesAny(query, tab.searchTerms)
            local groupMatch = false

            for _, group in ipairs(tab.groupsInTab) do
                local visible = query == "" or tabMatch or matchesAny(query, group.searchTerms)
                if group.mainFrame then
                    group.mainFrame.Visible = visible
                end
                if visible then
                    groupMatch = true
                end
            end

            local tabVisible = query == "" or tabMatch or groupMatch
            tab.isFilteredVisible = tabVisible
            if tab.buttonFrame then
                tab.buttonFrame.Visible = tabVisible
                if tab.defaultButtonSize then
                    tab.buttonFrame.Size = tabVisible and tab.defaultButtonSize or UDim2.new(tab.defaultButtonSize.X.Scale, tab.defaultButtonSize.X.Offset, tab.defaultButtonSize.Y.Scale, 0)
                end
            end
            if tabVisible and not firstVisibleTab then
                firstVisibleTab = tab
            end
            if tabVisible then
                sectionHasVisibleContent = true
            end
        end

        if section.containerFrame then
            section.containerFrame.Visible = sectionHasVisibleContent or query == ""
        end
    end

    if self.currentTabYay and not self.currentTabYay.isFilteredVisible then
        if firstVisibleTab then
            firstVisibleTab:Activate()
        else
            self.currentTabYay:Deactivate()
            self.currentTabYay = nil
        end
    elseif not self.currentTabYay and firstVisibleTab then
        firstVisibleTab:Activate()
    end
end

function FoxyLibrary:SaveConfig(fileName)
    if not writefile then
        return false, "writefile API is unavailable in this executor."
    end

    local configName = sanitizeConfigName(fileName)
    local payload = {
        version = 1,
        ui = self.config.Name,
        controls = {}
    }

    for flag, control in pairs(self._trackedControls) do
        local ok, value = pcall(control.get)
        if ok then
            payload.controls[flag] = serializeConfigValue(value)
        end
    end

    local path, usingFolder = getWritableFlowUIConfigPath(configName)
    local encoded = httpServiceNoCap:JSONEncode(payload)
    local okWrite, errWrite = pcall(function()
        writefile(path, encoded)
    end)

    if not okWrite and usingFolder then
        path = getFlowUIConfigFileName(configName)
        okWrite, errWrite = pcall(function()
            writefile(path, encoded)
        end)
    end

    if not okWrite then
        return false, "Failed to write config file: " .. tostring(errWrite)
    end
    return true, path
end

function FoxyLibrary:LoadConfig(fileName)
    if not readfile or not isfile then
        return false, "readfile/isfile APIs are unavailable in this executor."
    end

    local configName = sanitizeConfigName(fileName)
    local path = nil
    for _, candidatePath in ipairs(getReadableFlowUIConfigPaths(configName)) do
        if isfile(candidatePath) then
            path = candidatePath
            break
        end
    end
    if not path then
        return false, "Config file not found: " .. getFlowUIConfigFolderPath() .. "/" .. getFlowUIConfigFileName(configName)
    end

    local okDecode, data = pcall(function()
        return httpServiceNoCap:JSONDecode(readfile(path))
    end)
    if not okDecode or type(data) ~= "table" or type(data.controls) ~= "table" then
        return false, "Invalid config JSON format."
    end

    for flag, rawValue in pairs(data.controls) do
        local control = self._trackedControls[flag]
        if control then
            local decodedValue = deserializeConfigValue(rawValue)
            pcall(control.set, decodedValue)
        end
    end

    return true, path
end

function FoxyLibrary:CreateUIBecauseWeNeedIt()
    self.screenGuiYay = makeThingExist("ScreenGui", {
        Name = "FoxyLibrary_GUI",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        IgnoreGuiInset = true
    })

    if syn then
        syn.protect_gui(self.screenGuiYay)
        self.screenGuiYay.Parent = coreGuiMoreLikeBoreGui
    elseif gethui then
        self.screenGuiYay.Parent = gethui()
    else
        self.screenGuiYay.Parent = theOneAndOnlyPlayer:WaitForChild("PlayerGui")
    end

    self:_RefreshViewportMetrics()
    self:_TrackConnection(self.screenGuiYay:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        self:_RefreshViewportMetrics()
        self:_InvalidateESPPreviewProjection(false)
    end))

    self.backdropDimFrame = makeThingExist("Frame", {
        Name = "BackdropDimForBlur",
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 0,
        Parent = self.screenGuiYay
    })

    self.snowLayerFrame = makeThingExist("Frame", {
        Name = "SnowLayerWhenOpen",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 2,
        ClipsDescendants = true,
        Parent = self.screenGuiYay
    })

    self.dropdownHolderRef = makeThingExist("Frame", {
        Name = "DropdownHolderBecauseDropdownsNeedHomes",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 9999,
        Parent = self.screenGuiYay
    })

    self:CreateWatermarkBecauseWeCool()
    self:CreateMainFrameYay()
    if self._uiVisualSettings.ESPSelfPreview then
        self:_CreateESPPreviewPanel()
    end
    self:CreateNotificationHolderForCoolNotifs()
    self:CreateMobileToggleButton()
    self:ApplyFontPreset(self._fontPresetIndex)
    self:_SetTextGradientEnabled(self._uiVisualSettings.TextGradient)
    self:_SetBackgroundEffectsEnabled(self._uiVisualSettings.BackgroundEffects)
    self:_SetOverlayMode(self._overlayMode)
    self:_ApplyOpenCloseVisuals(true)

    self:_TrackConnection(thisInputServiceGoesHard.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == self.toggleKeyCode then
            self:ToggleUI()
        end
    end))

    self:_TrackConnection(runServiceMoreLikeWalkService.RenderStepped:Connect(function(dt)
        if self._destroyed then return end

        local rollingIndex = self._fpsRollingIndex or 1
        local previousDt = self._fpsRollingWindow[rollingIndex] or 0
        if (self._fpsRollingCount or 0) >= self._fpsRollingSize then
            self._fpsRollingTotal = self._fpsRollingTotal - previousDt
        else
            self._fpsRollingCount = (self._fpsRollingCount or 0) + 1
        end
        self._fpsRollingWindow[rollingIndex] = dt
        self._fpsRollingTotal = self._fpsRollingTotal + dt
        rollingIndex = rollingIndex + 1
        if rollingIndex > self._fpsRollingSize then
            rollingIndex = 1
        end
        self._fpsRollingIndex = rollingIndex
        if self._fpsRollingTotal > 0 and (self._fpsRollingCount or 0) > 0 then
            self._latestFPSValue = math.clamp(math.floor(((self._fpsRollingCount or 0) / self._fpsRollingTotal) + 0.5), 1, 360)
        end

        for scrollingFrame, state in pairs(self._smoothScrollFrames) do
            if not scrollingFrame or not scrollingFrame.Parent then
                self._smoothScrollFrames[scrollingFrame] = nil
            else
                local currentY = scrollingFrame.CanvasPosition.Y
                local goalY = state.targetY
                local diff = goalY - currentY
                if math.abs(diff) > 0.05 then
                    state.internal = true
                    local frameDt = math.clamp(tonumber(dt) or (1 / 60), 1 / 240, 1 / 20)
                    local alpha = math.clamp(1 - math.exp(-(state.speed or 34) * frameDt), 0.16, 1)
                    scrollingFrame.CanvasPosition = Vector2.new(scrollingFrame.CanvasPosition.X, currentY + diff * alpha)
                    state.internal = false
                elseif state.internal then
                    state.internal = false
                end
            end
        end

        if self._uiVisualSettings.ESPSelfPreview or self._espPreviewWasShowing then
            self:_UpdateESPPreview(dt)
        end
        if self._uiVisualSettings.TextGradient and #self._gradientObjects > 0 then
            self:_AnimateTextGradients(dt)
        end

        local currentFps = self._latestFPSValue

        if self.isToggledOn and self._uiVisualSettings.BackgroundEffects and self.mainBackgroundEffectsFrame and self.mainBackgroundEffectsFrame.Visible then
            self._backgroundFxAccumulator = (self._backgroundFxAccumulator or 0) + dt
            local backgroundStep
            if currentFps > 0 and currentFps < 36 then
                backgroundStep = isMobileUserSadly and (1 / 10) or (1 / 14)
            elseif currentFps > 0 and currentFps < 50 then
                backgroundStep = isMobileUserSadly and (1 / 13) or (1 / 18)
            else
                backgroundStep = isMobileUserSadly and (1 / 16) or (1 / 24)
            end
            if self._backgroundFxAccumulator >= backgroundStep then
                local backgroundDt = self._backgroundFxAccumulator
                self._backgroundFxAccumulator = 0
                self._backgroundFxTime = self._backgroundFxTime + backgroundDt
                if self.mainBackgroundGradient then
                    self.mainBackgroundGradient.Rotation = (self.mainBackgroundGradient.Rotation + backgroundDt * 8) % 360
                end
                if self.mainBackgroundAccentGlow then
                    local timeNow = self._backgroundFxTime
                    local xPos = 0.5 + math.sin(timeNow * 0.45) * 0.09
                    local yPos = 0.5 + math.cos(timeNow * 0.63) * 0.06
                    self.mainBackgroundAccentGlow.Position = UDim2.new(xPos, 0, yPos, 0)
                    self.mainBackgroundAccentGlow.ImageTransparency = 0.9 - (math.sin(timeNow * 1.6) + 1) * 0.03
                end
            end
        else
            self._backgroundFxAccumulator = 0
        end

        if self.isToggledOn and self._uiVisualSettings.Snow and self.snowLayerFrame and self.snowLayerFrame.Visible and self._overlayMode ~= "None" then
            self._overlayUpdateAccumulator = (self._overlayUpdateAccumulator or 0) + dt
            local overlayStep
            if currentFps > 0 and currentFps < 36 then
                overlayStep = isMobileUserSadly and (1 / 14) or (1 / 18)
            elseif currentFps > 0 and currentFps < 50 then
                overlayStep = isMobileUserSadly and (1 / 18) or (1 / 24)
            else
                overlayStep = isMobileUserSadly and (1 / 24) or (1 / 34)
            end

            if self._overlayUpdateAccumulator >= overlayStep then
                local overlayDt = math.min(self._overlayUpdateAccumulator, 0.12)
                self._overlayUpdateAccumulator = 0

                self._snowSpawnAccumulator = self._snowSpawnAccumulator + overlayDt
                local overlayMode = self._overlayMode
                local spawnInterval
                local maxParticles
                if overlayMode == "Rain" then
                    spawnInterval = isMobileUserSadly and 0.018 or 0.011
                    maxParticles = isMobileUserSadly and 72 or 150
                elseif overlayMode == "Stars" then
                    spawnInterval = isMobileUserSadly and 0.038 or 0.022
                    maxParticles = isMobileUserSadly and 72 or 150
                else
                    spawnInterval = isMobileUserSadly and 0.16 or 0.105
                    maxParticles = isMobileUserSadly and 30 or 62
                end

                local overlayQualityScale = self._cachedViewportAreaScale or 1
                if isMobileUserSadly then
                    overlayQualityScale = overlayQualityScale * 0.82
                end
                if currentFps > 0 then
                    if currentFps < 30 then
                        overlayQualityScale = overlayQualityScale * 0.28
                    elseif currentFps < 36 then
                        overlayQualityScale = overlayQualityScale * 0.4
                    elseif currentFps < 45 then
                        overlayQualityScale = overlayQualityScale * 0.55
                    elseif currentFps < 58 then
                        overlayQualityScale = overlayQualityScale * 0.72
                    elseif currentFps > 120 then
                        overlayQualityScale = overlayQualityScale * 1.04
                    end
                end
                overlayQualityScale = math.clamp(overlayQualityScale, isMobileUserSadly and 0.22 or 0.3, 1.08)
                spawnInterval = spawnInterval / math.max(overlayQualityScale, 0.35)
                maxParticles = math.max(overlayMode == "Snow" and 10 or 12, math.floor(maxParticles * overlayQualityScale))
                local maxSpawnBurst
                if overlayMode == "Rain" then
                    maxSpawnBurst = isMobileUserSadly and 3 or 6
                elseif overlayMode == "Stars" then
                    maxSpawnBurst = isMobileUserSadly and 2 or 4
                else
                    maxSpawnBurst = isMobileUserSadly and 1 or 2
                end
                self._snowSpawnAccumulator = math.min(self._snowSpawnAccumulator, spawnInterval * maxSpawnBurst)

                local spawnedThisStep = 0
                while self._snowSpawnAccumulator >= spawnInterval and #self._snowflakes < maxParticles and spawnedThisStep < maxSpawnBurst do
                    if overlayMode == "Rain" then
                        self:_SpawnRainDrop()
                    elseif overlayMode == "Stars" then
                        self:_SpawnStarParticle()
                    else
                        self:_SpawnSnowflake()
                    end
                    self._snowSpawnAccumulator = self._snowSpawnAccumulator - spawnInterval
                    spawnedThisStep = spawnedThisStep + 1
                end

                local nowTick = os.clock()
                local viewportHeight = self._cachedViewportHeight or 320
                local viewportWidth = self._cachedViewportWidth or 200
                local allowRainSplashes = overlayMode == "Rain" and overlayQualityScale > (isMobileUserSadly and 0.52 or 0.38)
                for i = #self._snowflakes, 1, -1 do
                    local flakeData = self._snowflakes[i]
                    local flakeObj = flakeData and flakeData.instance
                    if not flakeObj or not flakeObj.Parent then
                        table.remove(self._snowflakes, i)
                    else
                        local overlayType = flakeData.overlayType or "Snow"
                        if overlayType == "RainDrop" then
                            flakeData.yOffset = flakeData.yOffset + flakeData.velocityY * overlayDt
                            flakeData.xOffset = flakeData.xOffset + flakeData.velocityX * overlayDt
                            local windOffset = math.sin(nowTick * flakeData.driftSpeed + flakeData.phase) * flakeData.windJitter
                            local xPos = flakeData.xOffset + windOffset
                            flakeObj.Position = UDim2.new(0, xPos, 0, flakeData.yOffset)
                            local stretchPulse = 0.82 + math.sin(nowTick * flakeData.stretchPulse + flakeData.phase) * 0.18
                            flakeObj.Size = UDim2.new(0, flakeData.width, 0, flakeData.length * stretchPulse)
                            flakeObj.Rotation = flakeData.angle
                            flakeObj.BackgroundTransparency = math.clamp(flakeData.baseTransparency + (math.sin(nowTick * 3.6 + flakeData.phase) * 0.07), 0.08, 0.9)
                            if flakeData.yOffset > viewportHeight + 20 then
                                if allowRainSplashes and xPos > -40 and xPos < viewportWidth + 40 and math.random() < (flakeData.splashChance * overlayQualityScale) then
                                    self:_SpawnRainSplash(xPos, viewportHeight - math.random(1, 8))
                                end
                                flakeObj:Destroy()
                                table.remove(self._snowflakes, i)
                            end
                        elseif overlayType == "RainSplash" then
                            flakeData.life = flakeData.life - overlayDt
                            if flakeData.life <= 0 then
                                flakeObj:Destroy()
                                table.remove(self._snowflakes, i)
                            else
                                local progress = 1 - (flakeData.life / flakeData.totalLife)
                                local widthNow = flakeData.startSize + flakeData.endSize * progress
                                local heightNow = math.max(1 * mobileScaleFactor, flakeData.startThickness * (1 - progress * 0.8))
                                flakeObj.Size = UDim2.new(0, widthNow, 0, heightNow)
                                flakeObj.Position = UDim2.new(0, flakeData.baseX + flakeData.driftX * progress, 0, flakeData.yOffset - progress * 1.2)
                                flakeObj.BackgroundTransparency = math.clamp(flakeData.baseTransparency + progress * 0.55, 0.2, 0.97)
                            end
                        elseif overlayType == "Stars" then
                            flakeData.xOffset = flakeData.xOffset + flakeData.velocityX * overlayDt
                            flakeData.yOffset = flakeData.yOffset + flakeData.velocityY * overlayDt
                            local driftX = math.sin(nowTick * flakeData.driftSpeed + flakeData.phase) * flakeData.driftAmount
                            local driftY = math.cos(nowTick * (flakeData.driftSpeed * 0.72) + flakeData.phase) * flakeData.driftLift
                            local xPos = flakeData.xOffset + driftX
                            local yPos = flakeData.yOffset + driftY
                            if xPos < -16 then
                                flakeData.xOffset = viewportWidth + 16
                                xPos = flakeData.xOffset
                            elseif xPos > viewportWidth + 16 then
                                flakeData.xOffset = -16
                                xPos = flakeData.xOffset
                            end
                            if yPos < -16 then
                                flakeData.yOffset = viewportHeight + 16
                                yPos = flakeData.yOffset
                            elseif yPos > viewportHeight + 16 then
                                flakeData.yOffset = -16
                                yPos = flakeData.yOffset
                            end
                            flakeObj.Position = UDim2.new(0, xPos, 0, yPos)
                            local sparkle = (math.sin(nowTick * flakeData.twinkleSpeed + flakeData.phase) + 1) * 0.5
                            local pulse = 1 + (math.sin(nowTick * (flakeData.twinkleSpeed * 0.75) + flakeData.phase) * flakeData.pulseAmount)
                            local sizeNow = math.max(1 * mobileScaleFactor, flakeData.baseSize * (0.82 + pulse * 0.36))
                            flakeObj.Size = UDim2.new(0, sizeNow, 0, sizeNow)
                            flakeObj.ImageTransparency = math.clamp(flakeData.baseTransparency - sparkle * 0.5, 0.01, 0.92)
                        else
                            flakeData.yOffset = flakeData.yOffset + flakeData.fallSpeed * overlayDt
                            local driftX = math.sin(nowTick * flakeData.driftSpeed + flakeData.phase) * flakeData.driftAmount
                            local swirlX = math.cos(nowTick * (flakeData.driftSpeed * 0.58) + flakeData.phase) * flakeData.swirlAmount
                            flakeObj.Position = UDim2.new(0, flakeData.baseX + driftX + swirlX, 0, flakeData.yOffset)
                            flakeObj.Rotation = (flakeObj.Rotation + flakeData.spin * overlayDt) % 360
                            local twinkle = (math.sin(nowTick * flakeData.twinkleSpeed + flakeData.phase) + 1) * 0.5
                            flakeObj.ImageTransparency = math.clamp(flakeData.baseTransparency + twinkle * 0.22, 0.08, 0.84)
                            if flakeData.yOffset > viewportHeight + 28 then
                                flakeObj:Destroy()
                                table.remove(self._snowflakes, i)
                            end
                        end
                    end
                end
            end
        else
            self._overlayUpdateAccumulator = 0
        end
    end))
end

function FoxyLibrary:ToggleUI()
    self.isToggledOn = not self.isToggledOn
    smoothMoveGoWoosh(self.mainFrameYay, {
        Position = self.isToggledOn and UDim2.new(0.5, -376 * mobileScaleFactor, 0.5, -246 * mobileScaleFactor) or UDim2.new(0.5, -376 * mobileScaleFactor, 1.5, 0)
    }, 0.4, Enum.EasingStyle.Quint, self.isToggledOn and Enum.EasingDirection.Out or Enum.EasingDirection.In)
    self:_ApplyOpenCloseVisuals(false)
end

function FoxyLibrary:SetToggleButtonVisible(visible)
    self.toggleButtonVisible = visible
    if self.mobileToggleFrame then
        self.mobileToggleFrame.Visible = visible
    end
end

function FoxyLibrary:SetToggleKey(keyCode)
    self.toggleKeyCode = keyCode
end

function FoxyLibrary:CreateMobileToggleButton()
    local buttonSize = 48 * mobileScaleFactor

    self.mobileToggleFrame = makeThingExist("Frame", {
        Name = "MobileToggleButton",
        BackgroundColor3 = Color3.fromRGB(16, 16, 16),
        Position = UDim2.new(0.5, -buttonSize/2, 0, 10),
        BorderColor3 = Color3.new(),
        BorderSizePixel = 0,
        Size = UDim2.new(0, buttonSize, 0, buttonSize),
        Parent = self.screenGuiYay
    })

    makeThingExist("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = self.mobileToggleFrame
    })

    local mobileStroke = makeThingExist("UIStroke", {
        Color = Color3.fromRGB(40, 40, 40),
        Thickness = 1.5,
        Parent = self.mobileToggleFrame
    })

    makeThingExist("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 150, 150)),
            ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
        }),
        Rotation = 45,
        Parent = mobileStroke
    })

    self.mobileToggleIcon = makeThingExist("ImageLabel", {
        Name = "ToggleIcon",
        BackgroundTransparency = 1,
        Image = "rbxassetid://95109736896642",
        ImageColor3 = self.config.AccentColor,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 28 * mobileScaleFactor, 0, 28 * mobileScaleFactor),
        Parent = self.mobileToggleFrame
    })

    local glowEffect = makeThingExist("ImageLabel", {
        Name = "GlowEffect",
        BackgroundTransparency = 1,
        Image = "rbxassetid://5028857084",
        ImageColor3 = self.config.AccentColor,
        ImageTransparency = 0.7,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(1.8, 0, 1.8, 0),
        ZIndex = 0,
        Parent = self.mobileToggleFrame
    })

    local mobileToggleBtn = makeThingExist("TextButton", {
        Name = "ClickButton",
        Text = "",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = self.mobileToggleFrame
    })

    self:_TrackConnection(mobileToggleBtn.MouseButton1Click:Connect(function()
        self:ToggleUI()

        smoothMoveGoWoosh(self.mobileToggleIcon, {Size = UDim2.new(0, 24 * mobileScaleFactor, 0, 24 * mobileScaleFactor)}, 0.1)
        task.delay(0.1, function()
            smoothMoveGoWoosh(self.mobileToggleIcon, {Size = UDim2.new(0, 28 * mobileScaleFactor, 0, 28 * mobileScaleFactor)}, 0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end)
    end))

    self:_TrackConnection(mobileToggleBtn.MouseEnter:Connect(function()
        smoothMoveGoWoosh(self.mobileToggleFrame, {BackgroundColor3 = Color3.fromRGB(24, 24, 24)}, 0.2)
        smoothMoveGoWoosh(glowEffect, {ImageTransparency = 0.5}, 0.2)
    end))

    self:_TrackConnection(mobileToggleBtn.MouseLeave:Connect(function()
        smoothMoveGoWoosh(self.mobileToggleFrame, {BackgroundColor3 = Color3.fromRGB(16, 16, 16)}, 0.2)
        smoothMoveGoWoosh(glowEffect, {ImageTransparency = 0.7}, 0.2)
    end))

    makeDraggableCuzWeCan(self.mobileToggleFrame, nil, self)
end

function FoxyLibrary:CreateWatermarkBecauseWeCool()
    local initialText = self.config.Name .. " | 00:00:00 | 60 FPS"
    local initialWidth = howWideIsThisText(initialText, 14, Enum.Font.GothamSemibold) + 45

    self.watermarkFrame = makeThingExist("Frame", {
        Name = "WatermarkCuzWeNeedFlexing",
        BackgroundColor3 = Color3.fromRGB(16, 16, 16),
        Position = UDim2.new(0, 4 * mobileScaleFactor, 0.215, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(0, initialWidth * mobileScaleFactor, 0, 36 * mobileScaleFactor),
        Parent = self.screenGuiYay
    })

    makeThingExist("UICorner", {CornerRadius = UDim.new(0, 7), Parent = self.watermarkFrame})

    makeThingExist("ImageLabel", {
        Image = "rbxassetid://10723375250", BackgroundTransparency = 1,
        Position = UDim2.new(0, 11, 0.5, -7.5 * mobileScaleFactor),
        Size = UDim2.new(0, 15 * mobileScaleFactor, 0, 15 * mobileScaleFactor),
        Parent = self.watermarkFrame
    })

    self.watermarkTextLabel = makeThingExist("TextLabel", {
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
        TextColor3 = Color3.new(1, 1, 1), Text = initialText, BackgroundTransparency = 1,
        Position = UDim2.new(0, 32, 0, 0), TextSize = 14 * mobileScaleFactor,
        Size = UDim2.new(1, -40, 1, 0), TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.watermarkFrame
    })
    table.insert(self._gradientLabels, self.watermarkTextLabel)

    makeDraggableCuzWeCan(self.watermarkFrame, nil, self)

    local lastWatermarkWidth = 0
    task.spawn(function()
        while not self._destroyed do
            task.wait(0.25)
            if self.watermarkFrame and self.watermarkFrame.Parent and self.watermarkTextLabel and self.watermarkTextLabel.Parent then
                local timeNow = os.date("%H:%M:%S")
                local fpsCount = self._latestFPSValue > 0 and self._latestFPSValue or 0
                local newText = self.config.Name .. " | " .. timeNow .. " | " .. fpsCount .. " FPS"
                if self.watermarkTextLabel.Text ~= newText then
                    self.watermarkTextLabel.Text = newText
                end
                local newWidth = howWideIsThisText(newText, 14 * mobileScaleFactor, Enum.Font.GothamSemibold) + 45
                if math.abs(newWidth - lastWatermarkWidth) > 1 then
                    lastWatermarkWidth = newWidth
                    smoothMoveGoWoosh(self.watermarkFrame, {Size = UDim2.new(0, newWidth, 0, 36 * mobileScaleFactor)}, 0.18)
                end
            end
        end
    end)
end

function FoxyLibrary:CreateMainFrameYay()
    local frameWidth = 753 * mobileScaleFactor
    local frameHeight = 493 * mobileScaleFactor

    self.mainFrameYay = makeThingExist("Frame", {
        Name = "MainFrameIsAwesome",
        BackgroundColor3 = Color3.fromRGB(16, 16, 16),
        Position = UDim2.new(0.5, -frameWidth/2, 0.5, -frameHeight/2),
        BorderSizePixel = 0,
        Size = UDim2.new(0, frameWidth, 0, frameHeight),
        Parent = self.screenGuiYay
    })

    makeThingExist("UICorner", {CornerRadius = UDim.new(0, 10), Parent = self.mainFrameYay})

    self.mainBackgroundEffectsFrame = makeThingExist("Frame", {
        Name = "MainBackgroundEffects",
        BackgroundColor3 = Color3.fromRGB(18, 18, 18),
        BackgroundTransparency = 0.45,
        Size = UDim2.new(1, 0, 1, 0),
        ClipsDescendants = true,
        ZIndex = 0,
        Parent = self.mainFrameYay
    })
    self.mainBackgroundGradient = makeThingExist("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 10, 10)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(18, 18, 18)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 12, 12))
        }),
        Rotation = 210,
        Parent = self.mainBackgroundEffectsFrame
    })
    self.mainBackgroundAccentGlow = makeThingExist("ImageLabel", {
        Name = "AccentGlow",
        BackgroundTransparency = 1,
        Image = "rbxassetid://5028857084",
        ImageColor3 = self.config.AccentColor,
        ImageTransparency = 0.9,
        Size = UDim2.new(1.8, 0, 1.8, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 0,
        Parent = self.mainBackgroundEffectsFrame
    })

    self.dragBarThing = makeThingExist("Frame", {
        BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 65 * mobileScaleFactor), Parent = self.mainFrameYay
    })

    makeDraggableCuzWeCan(self.mainFrameYay, self.dragBarThing, self)

    local hubNameWidth = howWideIsThisText(self.config.Name, 17 * mobileScaleFactor, Enum.Font.GothamSemibold)

    self.hubNameLabel = makeThingExist("TextLabel", {
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
        TextColor3 = Color3.new(1, 1, 1), Text = self.config.Name, BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 14 * mobileScaleFactor), TextSize = 17 * mobileScaleFactor,
        Size = UDim2.new(0, hubNameWidth + 10, 0, 20 * mobileScaleFactor),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = self.mainFrameYay
    })
    table.insert(self._gradientLabels, self.hubNameLabel)

    local playerName = "@" .. theOneAndOnlyPlayer.Name
    self.userNameLabel = makeThingExist("TextLabel", {
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
        TextColor3 = Color3.fromRGB(46, 46, 46), Text = playerName, BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 34 * mobileScaleFactor), TextSize = 14 * mobileScaleFactor,
        Size = UDim2.new(0, 120 * mobileScaleFactor, 0, 18 * mobileScaleFactor),
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = self.mainFrameYay
    })
    self:_SetNameHidden(self._uiVisualSettings.HideName)

    self.playerAvatarImg = makeThingExist("ImageLabel", {
        Image = getPlayerAvatarCuzTheyreBeautiful(theOneAndOnlyPlayer.UserId), BackgroundTransparency = 1,
        Position = UDim2.new(0, 145 * mobileScaleFactor, 0, 17 * mobileScaleFactor),
        Size = UDim2.new(0, 30 * mobileScaleFactor, 0, 30 * mobileScaleFactor), Parent = self.mainFrameYay
    })
    makeThingExist("UICorner", {CornerRadius = UDim.new(1, 0), Parent = self.playerAvatarImg})

    self.lineSeperator = makeThingExist("Frame", {
        BackgroundColor3 = Color3.fromRGB(36, 36, 36),
        Position = UDim2.new(0, 19, 0, 64 * mobileScaleFactor),
        Size = UDim2.new(0, 156 * mobileScaleFactor, 0, 1), Parent = self.mainFrameYay
    })

    self.tabNameLabel = makeThingExist("TextLabel", {
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
        TextColor3 = Color3.new(1, 1, 1), Text = "tab name", BackgroundTransparency = 1,
        Position = UDim2.new(0, 201 * mobileScaleFactor, 0, 14 * mobileScaleFactor),
        TextSize = 17 * mobileScaleFactor, Size = UDim2.new(0, 78, 0, 20 * mobileScaleFactor),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = self.mainFrameYay
    })
    table.insert(self._gradientLabels, self.tabNameLabel)

    self.tabDescriptionLabel = makeThingExist("TextLabel", {
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
        TextColor3 = Color3.fromRGB(46, 46, 46), Text = "tab description", BackgroundTransparency = 1,
        Position = UDim2.new(0, 201 * mobileScaleFactor, 0, 34 * mobileScaleFactor),
        TextSize = 14 * mobileScaleFactor, Size = UDim2.new(0, 200, 0, 18 * mobileScaleFactor),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = self.mainFrameYay
    })

    self.searchFrame = makeThingExist("Frame", {
        BackgroundColor3 = Color3.fromRGB(22, 22, 22),
        Position = UDim2.new(0, 524 * mobileScaleFactor, 0, 16 * mobileScaleFactor),
        Size = UDim2.new(0, 214 * mobileScaleFactor, 0, 28 * mobileScaleFactor),
        Parent = self.mainFrameYay
    })
    makeThingExist("UICorner", {CornerRadius = UDim.new(1, 0), Parent = self.searchFrame})
    makeThingExist("UIStroke", {Color = Color3.fromRGB(38, 38, 38), Parent = self.searchFrame})
    makeThingExist("ImageLabel", {
        Image = "rbxassetid://10734943674",
        ImageColor3 = Color3.fromRGB(120, 120, 120),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0.5, -7 * mobileScaleFactor),
        Size = UDim2.new(0, 14 * mobileScaleFactor, 0, 14 * mobileScaleFactor),
        Parent = self.searchFrame
    })
    self.searchBox = makeThingExist("TextBox", {
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
        Text = "",
        PlaceholderText = "Search tabs/groups...",
        PlaceholderColor3 = Color3.fromRGB(80, 80, 80),
        TextColor3 = Color3.fromRGB(210, 210, 210),
        TextSize = 13 * mobileScaleFactor,
        BackgroundTransparency = 1,
        ClearTextOnFocus = false,
        Position = UDim2.new(0, 28 * mobileScaleFactor, 0, 0),
        Size = UDim2.new(1, -34 * mobileScaleFactor, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.searchFrame
    })
    self:_TrackConnection(self.searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        self:ApplySearchFilter(self.searchBox.Text)
    end))

    self.sectionHolderScroll = makeThingExist("ScrollingFrame", {
        BackgroundTransparency = 1, Position = UDim2.new(0, 17, 0, 75 * mobileScaleFactor),
        Size = UDim2.new(0, 162 * mobileScaleFactor, 0, 404 * mobileScaleFactor),
        ScrollBarThickness = 0, CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y, ClipsDescendants = true, Parent = self.mainFrameYay
    })

    makeThingExist("UIPadding", {PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 2), PaddingTop = UDim.new(0, 2), Parent = self.sectionHolderScroll})
    self.sectionLayoutThing = makeThingExist("UIListLayout", {Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder, Parent = self.sectionHolderScroll})

    self.contentHolderFrame = makeThingExist("Frame", {
        BackgroundTransparency = 1, Position = UDim2.new(0, 198 * mobileScaleFactor, 0, 62 * mobileScaleFactor),
        Size = UDim2.new(0, 548 * mobileScaleFactor, 0, 424 * mobileScaleFactor),
        ClipsDescendants = true, Parent = self.mainFrameYay
    })

    local settingsPanelWidth = 185 * mobileScaleFactor
    local settingsPanelHeight = 268 * mobileScaleFactor
    self.uiSettingsOpen = false

    self.uiSettingsButtonFrame = makeThingExist("Frame", {
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        Position = UDim2.new(0, 10, 1, -31 * mobileScaleFactor),
        Size = UDim2.new(0, 116 * mobileScaleFactor, 0, 22 * mobileScaleFactor),
        BorderSizePixel = 0,
        Parent = self.mainFrameYay
    })
    makeThingExist("UICorner", {CornerRadius = UDim.new(1, 0), Parent = self.uiSettingsButtonFrame})
    self.uiSettingsButtonStroke = makeThingExist("UIStroke", {Color = Color3.fromRGB(45, 45, 45), Parent = self.uiSettingsButtonFrame})

    makeThingExist("ImageLabel", {
        Image = "rbxassetid://6031280882",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 7, 0.5, -6 * mobileScaleFactor),
        Size = UDim2.new(0, 12 * mobileScaleFactor, 0, 12 * mobileScaleFactor),
        ImageColor3 = Color3.fromRGB(165, 165, 165),
        Parent = self.uiSettingsButtonFrame
    })
    makeThingExist("TextLabel", {
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
        Text = "UI Settings",
        TextColor3 = Color3.fromRGB(185, 185, 185),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 24 * mobileScaleFactor, 0, 0),
        Size = UDim2.new(1, -28 * mobileScaleFactor, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 12 * mobileScaleFactor,
        Parent = self.uiSettingsButtonFrame
    })
    local settingsToggleButton = makeThingExist("TextButton", {
        Text = "",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = self.uiSettingsButtonFrame
    })

    self.uiSettingsPanelFrame = makeThingExist("Frame", {
        BackgroundColor3 = Color3.fromRGB(15, 15, 15),
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 10, 1, -36 * mobileScaleFactor),
        Size = UDim2.new(0, settingsPanelWidth, 0, 0),
        ClipsDescendants = true,
        Visible = false,
        Parent = self.mainFrameYay
    })
    makeThingExist("UICorner", {CornerRadius = UDim.new(0, 8), Parent = self.uiSettingsPanelFrame})
    makeThingExist("UIStroke", {Color = Color3.fromRGB(44, 44, 44), Parent = self.uiSettingsPanelFrame})

    makeThingExist("TextLabel", {
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
        Text = "UI Tweaks",
        TextColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 8 * mobileScaleFactor),
        Size = UDim2.new(0.7, 0, 0, 16 * mobileScaleFactor),
        TextSize = 13 * mobileScaleFactor,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.uiSettingsPanelFrame
    })

    self.uiAccentPreviewFrame = makeThingExist("Frame", {
        BackgroundColor3 = self.config.AccentColor,
        Position = UDim2.new(1, -22 * mobileScaleFactor, 0, 11 * mobileScaleFactor),
        Size = UDim2.new(0, 10 * mobileScaleFactor, 0, 10 * mobileScaleFactor),
        Parent = self.uiSettingsPanelFrame
    })
    makeThingExist("UICorner", {CornerRadius = UDim.new(1, 0), Parent = self.uiAccentPreviewFrame})

    local rowY = 30 * mobileScaleFactor
    local rowStep = 24 * mobileScaleFactor
    local function createSettingsToggle(labelText, initial, callback)
        local rowFrame = makeThingExist("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, rowY),
            Size = UDim2.new(1, -20, 0, 20 * mobileScaleFactor),
            Parent = self.uiSettingsPanelFrame
        })
        makeThingExist("TextLabel", {
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
            Text = labelText,
            TextColor3 = Color3.fromRGB(150, 150, 150),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -46 * mobileScaleFactor, 1, 0),
            TextSize = 12 * mobileScaleFactor,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = rowFrame
        })
        local switchFrame = makeThingExist("Frame", {
            BackgroundColor3 = initial and self.config.AccentColor or Color3.fromRGB(33, 33, 33),
            Position = UDim2.new(1, -34 * mobileScaleFactor, 0.5, -8 * mobileScaleFactor),
            Size = UDim2.new(0, 34 * mobileScaleFactor, 0, 16 * mobileScaleFactor),
            Parent = rowFrame
        })
        makeThingExist("UICorner", {CornerRadius = UDim.new(1, 0), Parent = switchFrame})
        local knob = makeThingExist("Frame", {
            BackgroundColor3 = initial and Color3.new(1, 1, 1) or Color3.fromRGB(95, 95, 95),
            Position = initial and UDim2.new(0.5, 0, 0.5, -6 * mobileScaleFactor) or UDim2.new(0, 2 * mobileScaleFactor, 0.5, -6 * mobileScaleFactor),
            Size = UDim2.new(0, 12 * mobileScaleFactor, 0, 12 * mobileScaleFactor),
            Parent = switchFrame
        })
        makeThingExist("UICorner", {CornerRadius = UDim.new(1, 0), Parent = knob})

        local state = initial == true
        local function setState(nextState, skipCallback)
            state = nextState == true
            smoothMoveGoWoosh(switchFrame, {BackgroundColor3 = state and self.config.AccentColor or Color3.fromRGB(33, 33, 33)}, 0.16)
            smoothMoveGoWoosh(knob, {
                Position = state and UDim2.new(0.5, 0, 0.5, -6 * mobileScaleFactor) or UDim2.new(0, 2 * mobileScaleFactor, 0.5, -6 * mobileScaleFactor),
                BackgroundColor3 = state and Color3.new(1, 1, 1) or Color3.fromRGB(95, 95, 95)
            }, 0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            if not skipCallback then
                callback(state)
            end
        end

        local toggleButton = makeThingExist("TextButton", {
            Text = "",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Parent = rowFrame
        })
        toggleButton.MouseButton1Click:Connect(function()
            setState(not state, false)
        end)

        rowY = rowY + rowStep
        return {
            Set = setState,
            Get = function()
                return state
            end
        }
    end

    local blurToggleRef = createSettingsToggle("Blur Background", self._uiVisualSettings.Blur, function(enabled)
        self._uiVisualSettings.Blur = enabled
        self:_ApplyOpenCloseVisuals(false)
    end)
    local overlayToggleRef = createSettingsToggle("Overlay FX", self._uiVisualSettings.Snow, function(enabled)
        self:_SetSnowEnabled(enabled)
    end)
    local bgFxToggleRef = createSettingsToggle("Background FX", self._uiVisualSettings.BackgroundEffects, function(enabled)
        self:_SetBackgroundEffectsEnabled(enabled)
    end)
    local gradientToggleRef = createSettingsToggle("Text Gradient", self._uiVisualSettings.TextGradient, function(enabled)
        self:_SetTextGradientEnabled(enabled)
    end)
    local espPreviewToggleRef = createSettingsToggle("ESP Preview", self._uiVisualSettings.ESPSelfPreview, function(enabled)
        self:SetESPPreviewEnabled(enabled)
    end)
    local hideNameToggleRef = createSettingsToggle("Hide Name", self._uiVisualSettings.HideName, function(enabled)
        self:_SetNameHidden(enabled)
    end)
    self.uiSettingsToggleRefs = {blurToggleRef, overlayToggleRef, bgFxToggleRef, gradientToggleRef, espPreviewToggleRef, hideNameToggleRef}

    local overlayRow = makeThingExist("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, rowY + 2 * mobileScaleFactor),
        Size = UDim2.new(1, -20, 0, 20 * mobileScaleFactor),
        Parent = self.uiSettingsPanelFrame
    })
    makeThingExist("TextLabel", {
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
        Text = "Overlay",
        TextColor3 = Color3.fromRGB(150, 150, 150),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 52 * mobileScaleFactor, 1, 0),
        TextSize = 12 * mobileScaleFactor,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = overlayRow
    })

    local overlayPickerFrame = makeThingExist("Frame", {
        BackgroundColor3 = Color3.fromRGB(29, 29, 29),
        Position = UDim2.new(1, -84 * mobileScaleFactor, 0, 0),
        Size = UDim2.new(0, 84 * mobileScaleFactor, 1, 0),
        Parent = overlayRow
    })
    makeThingExist("UICorner", {CornerRadius = UDim.new(1, 0), Parent = overlayPickerFrame})
    makeThingExist("UIStroke", {Color = Color3.fromRGB(44, 44, 44), Parent = overlayPickerFrame})

    self.uiOverlayModeValueLabel = makeThingExist("TextLabel", {
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
        Text = self._overlayMode,
        TextColor3 = Color3.fromRGB(210, 210, 210),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8 * mobileScaleFactor, 0, 0),
        Size = UDim2.new(1, -24 * mobileScaleFactor, 1, 0),
        TextSize = 11.5 * mobileScaleFactor,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = overlayPickerFrame
    })

    local overlayArrowImage = makeThingExist("ImageLabel", {
        Image = "rbxassetid://111626678408582",
        ImageColor3 = Color3.fromRGB(132, 132, 132),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -18 * mobileScaleFactor, 0.5, -6 * mobileScaleFactor),
        Size = UDim2.new(0, 12 * mobileScaleFactor, 0, 12 * mobileScaleFactor),
        Parent = overlayPickerFrame
    })

    local overlayDropdownWidth = 102 * mobileScaleFactor
    local overlayDropdownRowHeight = 21 * mobileScaleFactor
    local overlayDropdownFrame = makeThingExist("Frame", {
        BackgroundColor3 = Color3.fromRGB(16, 16, 16),
        Size = UDim2.new(0, overlayDropdownWidth, 0, 0),
        ClipsDescendants = true,
        Visible = false,
        ZIndex = 9999,
        Parent = self.dropdownHolderRef
    })
    makeThingExist("UICorner", {CornerRadius = UDim.new(0, 7), Parent = overlayDropdownFrame})
    makeThingExist("UIStroke", {Color = Color3.fromRGB(42, 42, 42), Parent = overlayDropdownFrame})

    local overlayDropdownContainer = makeThingExist("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 4 * mobileScaleFactor, 0, 4 * mobileScaleFactor),
        Size = UDim2.new(1, -8 * mobileScaleFactor, 0, 0),
        ZIndex = 10000,
        Parent = overlayDropdownFrame
    })

    local overlayDropdownOpen = false
    local overlayDropdownPositionConn = nil
    local overlayDropdownOutsideConn = nil

    local function updateOverlayDropdownPosition()
        local pickerAbsPos = overlayPickerFrame.AbsolutePosition
        local pickerAbsSize = overlayPickerFrame.AbsoluteSize
        overlayDropdownFrame.Position = UDim2.new(0, pickerAbsPos.X + pickerAbsSize.X - overlayDropdownWidth, 0, pickerAbsPos.Y + pickerAbsSize.Y + 5)
    end

    local function closeOverlayDropdown(isInstant)
        overlayDropdownOpen = false
        if overlayDropdownPositionConn then
            overlayDropdownPositionConn()
            overlayDropdownPositionConn = nil
        end
        if overlayDropdownOutsideConn then
            overlayDropdownOutsideConn:Disconnect()
            overlayDropdownOutsideConn = nil
        end
        smoothMoveGoWoosh(overlayArrowImage, {Rotation = 0}, 0.16)
        smoothMoveGoWoosh(overlayPickerFrame, {BackgroundColor3 = Color3.fromRGB(29, 29, 29)}, 0.16)
        if isInstant then
            overlayDropdownFrame.Size = UDim2.new(0, overlayDropdownWidth, 0, 0)
            overlayDropdownFrame.Visible = false
            return
        end
        smoothMoveGoWoosh(overlayDropdownFrame, {Size = UDim2.new(0, overlayDropdownWidth, 0, 0)}, 0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        task.delay(0.18, function()
            if overlayDropdownFrame and overlayDropdownFrame.Parent and not overlayDropdownOpen then
                overlayDropdownFrame.Visible = false
            end
        end)
    end

    local rebuildOverlayDropdownOptions
    rebuildOverlayDropdownOptions = function()
        for _, child in ipairs(overlayDropdownContainer:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextButton") then
                child:Destroy()
            end
        end
        local optionY = 0
        for _, modeName in ipairs(self._overlayModes) do
            local isSelected = modeName == self._overlayMode
            local optionFrame = makeThingExist("Frame", {
                BackgroundColor3 = isSelected and Color3.fromRGB(33, 33, 33) or Color3.fromRGB(23, 23, 23),
                Position = UDim2.new(0, 0, 0, optionY),
                Size = UDim2.new(1, 0, 0, overlayDropdownRowHeight - 2 * mobileScaleFactor),
                ZIndex = 10001,
                Parent = overlayDropdownContainer
            })
            makeThingExist("UICorner", {CornerRadius = UDim.new(0, 5), Parent = optionFrame})
            local optionLabel = makeThingExist("TextLabel", {
                FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
                Text = modeName,
                TextColor3 = isSelected and Color3.new(1, 1, 1) or Color3.fromRGB(138, 138, 138),
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -8 * mobileScaleFactor, 1, 0),
                Position = UDim2.new(0, 8 * mobileScaleFactor, 0, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextSize = 11.5 * mobileScaleFactor,
                ZIndex = 10002,
                Parent = optionFrame
            })
            local optionButton = makeThingExist("TextButton", {
                Text = "",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = 10003,
                Parent = optionFrame
            })
            optionButton.MouseButton1Click:Connect(function()
                self:_SetOverlayMode(modeName)
                self.uiOverlayModeValueLabel.Text = self._overlayMode
                rebuildOverlayDropdownOptions()
                closeOverlayDropdown(false)
            end)
            optionButton.MouseEnter:Connect(function()
                if self._overlayMode ~= modeName then
                    smoothMoveGoWoosh(optionFrame, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}, 0.12)
                    smoothMoveGoWoosh(optionLabel, {TextColor3 = Color3.fromRGB(188, 188, 188)}, 0.12)
                end
            end)
            optionButton.MouseLeave:Connect(function()
                if self._overlayMode ~= modeName then
                    smoothMoveGoWoosh(optionFrame, {BackgroundColor3 = Color3.fromRGB(23, 23, 23)}, 0.12)
                    smoothMoveGoWoosh(optionLabel, {TextColor3 = Color3.fromRGB(138, 138, 138)}, 0.12)
                end
            end)
            optionY = optionY + overlayDropdownRowHeight
        end
        overlayDropdownContainer.Size = UDim2.new(1, -8 * mobileScaleFactor, 0, optionY)
    end

    local function openOverlayDropdown()
        overlayDropdownOpen = true
        rebuildOverlayDropdownOptions()
        updateOverlayDropdownPosition()
        overlayDropdownFrame.Visible = true
        smoothMoveGoWoosh(overlayDropdownFrame, {Size = UDim2.new(0, overlayDropdownWidth, 0, #self._overlayModes * overlayDropdownRowHeight + 8 * mobileScaleFactor)}, 0.2)
        smoothMoveGoWoosh(overlayArrowImage, {Rotation = 180}, 0.16)
        smoothMoveGoWoosh(overlayPickerFrame, {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}, 0.16)
        if overlayDropdownPositionConn then
            overlayDropdownPositionConn()
            overlayDropdownPositionConn = nil
        end
        overlayDropdownPositionConn = startFloatingPositionTracker(self, overlayPickerFrame, function()
            if overlayDropdownOpen then
                updateOverlayDropdownPosition()
            end
        end)
        if overlayDropdownOutsideConn then
            overlayDropdownOutsideConn:Disconnect()
            overlayDropdownOutsideConn = nil
        end
        overlayDropdownOutsideConn = self:_TrackConnection(thisInputServiceGoesHard.InputBegan:Connect(function(input)
            if not overlayDropdownOpen then
                return
            end
            local isClick = input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.MouseButton2
                or input.UserInputType == Enum.UserInputType.Touch
            if not isClick then
                return
            end
            local clickPos = input.Position
            local menuPos = overlayDropdownFrame.AbsolutePosition
            local menuSize = overlayDropdownFrame.AbsoluteSize
            local pickerPos = overlayPickerFrame.AbsolutePosition
            local pickerSize = overlayPickerFrame.AbsoluteSize
            local insideMenu = clickPos.X >= menuPos.X and clickPos.X <= menuPos.X + menuSize.X and clickPos.Y >= menuPos.Y and clickPos.Y <= menuPos.Y + menuSize.Y
            local insidePicker = clickPos.X >= pickerPos.X and clickPos.X <= pickerPos.X + pickerSize.X and clickPos.Y >= pickerPos.Y and clickPos.Y <= pickerPos.Y + pickerSize.Y
            if not insideMenu and not insidePicker then
                closeOverlayDropdown(false)
            end
        end))
    end

    local overlayPickerButton = makeThingExist("TextButton", {
        Text = "",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = overlayPickerFrame
    })
    overlayPickerButton.MouseButton1Click:Connect(function()
        if overlayDropdownOpen then
            closeOverlayDropdown(false)
        else
            openOverlayDropdown()
        end
    end)
    overlayPickerButton.MouseEnter:Connect(function()
        if not overlayDropdownOpen then
            smoothMoveGoWoosh(overlayPickerFrame, {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}, 0.12)
        end
    end)
    overlayPickerButton.MouseLeave:Connect(function()
        if not overlayDropdownOpen then
            smoothMoveGoWoosh(overlayPickerFrame, {BackgroundColor3 = Color3.fromRGB(29, 29, 29)}, 0.12)
        end
    end)

    rowY = rowY + rowStep

    local fontRow = makeThingExist("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, rowY + 2 * mobileScaleFactor),
        Size = UDim2.new(1, -20, 0, 20 * mobileScaleFactor),
        Parent = self.uiSettingsPanelFrame
    })
    makeThingExist("TextLabel", {
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
        Text = "Font",
        TextColor3 = Color3.fromRGB(150, 150, 150),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 34 * mobileScaleFactor, 1, 0),
        TextSize = 12 * mobileScaleFactor,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = fontRow
    })
    self.uiSettingsFontValueLabel = makeThingExist("TextLabel", {
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
        Text = self._fontPresets[self._fontPresetIndex].Name,
        TextColor3 = Color3.fromRGB(210, 210, 210),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 36 * mobileScaleFactor, 0, 0),
        Size = UDim2.new(0, 82 * mobileScaleFactor, 1, 0),
        TextSize = 12 * mobileScaleFactor,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = fontRow
    })
    local fontCycleFrame = makeThingExist("Frame", {
        BackgroundColor3 = Color3.fromRGB(29, 29, 29),
        Position = UDim2.new(1, -44 * mobileScaleFactor, 0, 0),
        Size = UDim2.new(0, 44 * mobileScaleFactor, 1, 0),
        Parent = fontRow
    })
    makeThingExist("UICorner", {CornerRadius = UDim.new(1, 0), Parent = fontCycleFrame})
    makeThingExist("TextLabel", {
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
        Text = "Next",
        TextColor3 = Color3.fromRGB(190, 190, 190),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        TextSize = 11 * mobileScaleFactor,
        Parent = fontCycleFrame
    })
    local fontCycleButton = makeThingExist("TextButton", {
        Text = "",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = fontCycleFrame
    })
    fontCycleButton.MouseButton1Click:Connect(function()
        self:ApplyFontPreset(self._fontPresetIndex + 1)
    end)

    local accentRowY = rowY + 28 * mobileScaleFactor
    makeThingExist("TextLabel", {
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
        Text = "Accent",
        TextColor3 = Color3.fromRGB(150, 150, 150),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, accentRowY),
        Size = UDim2.new(0, 46 * mobileScaleFactor, 0, 16 * mobileScaleFactor),
        TextSize = 12 * mobileScaleFactor,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.uiSettingsPanelFrame
    })
    local accentColors = {
        Color3.fromRGB(2, 133, 255),
        Color3.fromRGB(48, 196, 122),
        Color3.fromRGB(237, 88, 88),
        Color3.fromRGB(255, 169, 64),
        Color3.fromRGB(185, 108, 255)
    }
    for index, color in ipairs(accentColors) do
        local swatch = makeThingExist("Frame", {
            BackgroundColor3 = color,
            Position = UDim2.new(0, (58 + (index - 1) * 22) * mobileScaleFactor, 0, accentRowY - 1 * mobileScaleFactor),
            Size = UDim2.new(0, 16 * mobileScaleFactor, 0, 16 * mobileScaleFactor),
            Parent = self.uiSettingsPanelFrame
        })
        makeThingExist("UICorner", {CornerRadius = UDim.new(1, 0), Parent = swatch})
        local swatchClick = makeThingExist("TextButton", {
            Text = "",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Parent = swatch
        })
        swatchClick.MouseButton1Click:Connect(function()
            self:SetAccentColor(color)
            blurToggleRef:Set(self._uiVisualSettings.Blur, true)
            overlayToggleRef:Set(self._uiVisualSettings.Snow, true)
            bgFxToggleRef:Set(self._uiVisualSettings.BackgroundEffects, true)
            gradientToggleRef:Set(self._uiVisualSettings.TextGradient, true)
        end)
    end

    local function setSettingsPanelOpen(openState)
        self.uiSettingsOpen = openState == true
        if self.uiSettingsOpen then
            self.uiSettingsPanelFrame.Visible = true
            smoothMoveGoWoosh(self.uiSettingsPanelFrame, {Size = UDim2.new(0, settingsPanelWidth, 0, settingsPanelHeight)}, 0.22)
            smoothMoveGoWoosh(self.uiSettingsButtonFrame, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}, 0.2)
            smoothMoveGoWoosh(self.uiSettingsButtonStroke, {Color = self.config.AccentColor:Lerp(Color3.fromRGB(20, 20, 20), 0.45)}, 0.2)
        else
            closeOverlayDropdown(true)
            smoothMoveGoWoosh(self.uiSettingsPanelFrame, {Size = UDim2.new(0, settingsPanelWidth, 0, 0)}, 0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            smoothMoveGoWoosh(self.uiSettingsButtonFrame, {BackgroundColor3 = Color3.fromRGB(20, 20, 20)}, 0.2)
            smoothMoveGoWoosh(self.uiSettingsButtonStroke, {Color = Color3.fromRGB(45, 45, 45)}, 0.2)
            task.delay(0.18, function()
                if self.uiSettingsPanelFrame and self.uiSettingsPanelFrame.Parent and not self.uiSettingsOpen then
                    self.uiSettingsPanelFrame.Visible = false
                end
            end)
        end
    end

    settingsToggleButton.MouseButton1Click:Connect(function()
        setSettingsPanelOpen(not self.uiSettingsOpen)
    end)
    settingsToggleButton.MouseEnter:Connect(function()
        smoothMoveGoWoosh(self.uiSettingsButtonFrame, {BackgroundColor3 = Color3.fromRGB(28, 28, 28)}, 0.15)
    end)
    settingsToggleButton.MouseLeave:Connect(function()
        if not self.uiSettingsOpen then
            smoothMoveGoWoosh(self.uiSettingsButtonFrame, {BackgroundColor3 = Color3.fromRGB(20, 20, 20)}, 0.15)
        end
    end)
end

function FoxyLibrary:CreateNotificationHolderForCoolNotifs()
    self.notificationHolderFrame = makeThingExist("Frame", {
        BackgroundTransparency = 1, Position = UDim2.new(0, 20, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5), Size = UDim2.new(0, 300 * mobileScaleFactor, 0, 400),
        Parent = self.screenGuiYay
    })
    makeThingExist("UIListLayout", {Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center, Parent = self.notificationHolderFrame})
end

function FoxyLibrary:Notify(config)
    config = config or {}
    config.Title = tostring(config.Title or "Notification")
    config.Description = tostring(config.Description or "")
    config.Duration = tonumber(config.Duration) or 3
    config.Duration = math.max(0.8, config.Duration)
    config.Icon = config.Icon or "rbxassetid://10747361219"

    local hasDescription = normalizeSearchText(config.Description) ~= ""
    local titleBounds = textServiceBeLikeText:GetTextSize(
        config.Title,
        15 * mobileScaleFactor,
        Enum.Font.GothamSemibold,
        Vector2.new(210 * mobileScaleFactor, math.huge)
    )
    local descBounds = Vector2.new(0, 0)
    if hasDescription then
        descBounds = textServiceBeLikeText:GetTextSize(
            config.Description,
            13 * mobileScaleFactor,
            Enum.Font.GothamSemibold,
            Vector2.new(220 * mobileScaleFactor, math.huge)
        )
    end

    local notifWidth = math.max(190 * mobileScaleFactor, math.min(310 * mobileScaleFactor, math.max(titleBounds.X, descBounds.X) + 84 * mobileScaleFactor))
    local notifHeight = hasDescription and (66 * mobileScaleFactor) or (52 * mobileScaleFactor)

    local notificationFrame = makeThingExist("Frame", {
        BackgroundColor3 = Color3.fromRGB(14, 14, 14),
        Position = UDim2.new(-1.25, 0, 0, 0),
        Size = UDim2.new(0, notifWidth, 0, notifHeight),
        BackgroundTransparency = 0.18,
        ClipsDescendants = true,
        Parent = self.notificationHolderFrame
    })
    makeThingExist("UICorner", {CornerRadius = UDim.new(0, 12), Parent = notificationFrame})
    local notificationStroke = makeThingExist("UIStroke", {
        Color = Color3.fromRGB(38, 38, 38),
        Thickness = 1.1,
        Parent = notificationFrame
    })
    makeThingExist("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 24, 24)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 16, 16))
        }),
        Rotation = 22,
        Parent = notificationFrame
    })
    local uiScaleRef = makeThingExist("UIScale", {Scale = 0.88, Parent = notificationFrame})

    local glowEffect = makeThingExist("ImageLabel", {
        Name = "NotifGlow",
        BackgroundTransparency = 1,
        Image = "rbxassetid://5028857084",
        ImageColor3 = self.config.AccentColor,
        ImageTransparency = 0.92,
        Position = UDim2.new(0.25, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(1.8, 0, 2, 0),
        ZIndex = 0,
        Parent = notificationFrame
    })

    local accentBar = makeThingExist("Frame", {
        BackgroundColor3 = self.config.AccentColor,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 4 * mobileScaleFactor, 1, 0),
        Parent = notificationFrame
    })
    makeThingExist("UICorner", {CornerRadius = UDim.new(1, 0), Parent = accentBar})

    local iconHolder = makeThingExist("Frame", {
        BackgroundColor3 = Color3.fromRGB(24, 24, 24),
        Position = UDim2.new(0, 12 * mobileScaleFactor, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(0, 28 * mobileScaleFactor, 0, 28 * mobileScaleFactor),
        Parent = notificationFrame
    })
    makeThingExist("UICorner", {CornerRadius = UDim.new(1, 0), Parent = iconHolder})
    makeThingExist("UIStroke", {
        Color = self.config.AccentColor:Lerp(Color3.fromRGB(16, 16, 16), 0.55),
        Thickness = 1.1,
        Parent = iconHolder
    })

    local notifImageLabel = makeThingExist("ImageLabel", {
        Image = config.Icon,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 17 * mobileScaleFactor, 0, 17 * mobileScaleFactor),
        ImageTransparency = 1,
        Parent = iconHolder
    })

    local textStartX = 48 * mobileScaleFactor
    local notifTitle = makeThingExist("TextLabel", {
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
        TextColor3 = Color3.new(1, 1, 1),
        Text = config.Title,
        BackgroundTransparency = 1,
        Position = hasDescription and UDim2.new(0, textStartX, 0, 8 * mobileScaleFactor) or UDim2.new(0, textStartX, 0.5, -9 * mobileScaleFactor),
        TextSize = 15 * mobileScaleFactor,
        Size = UDim2.new(1, -textStartX - 12 * mobileScaleFactor, 0, 18 * mobileScaleFactor),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextTransparency = 1,
        Parent = notificationFrame
    })

    local notifDescription = nil
    if hasDescription then
        notifDescription = makeThingExist("TextLabel", {
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),  -- BUG FIX: was SemiBold; description should use Medium
            TextColor3 = Color3.fromRGB(170, 170, 170),
            Text = config.Description,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, textStartX, 0, 28 * mobileScaleFactor),
            TextSize = 12.5 * mobileScaleFactor,
            Size = UDim2.new(1, -textStartX - 12 * mobileScaleFactor, 0, 16 * mobileScaleFactor),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextTransparency = 1,
            Parent = notificationFrame
        })
    end

    local progressTrack = makeThingExist("Frame", {
        BackgroundColor3 = Color3.fromRGB(28, 28, 28),
        Position = UDim2.new(0, 10 * mobileScaleFactor, 1, -6 * mobileScaleFactor),
        Size = UDim2.new(1, -20 * mobileScaleFactor, 0, 2 * mobileScaleFactor),
        BorderSizePixel = 0,
        Parent = notificationFrame
    })
    makeThingExist("UICorner", {CornerRadius = UDim.new(1, 0), Parent = progressTrack})

    local progressFill = makeThingExist("Frame", {
        BackgroundColor3 = self.config.AccentColor,
        Size = UDim2.new(1, 0, 1, 0),
        BorderSizePixel = 0,
        Parent = progressTrack
    })
    makeThingExist("UICorner", {CornerRadius = UDim.new(1, 0), Parent = progressFill})

    local progressTween = oMgThisTweenServiceIsSoCool:Create(
        progressFill,
        TweenInfo.new(config.Duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, 0, 1, 0)}
    )

    task.defer(function()
        if not notificationFrame or not notificationFrame.Parent then return end
        smoothMoveGoWoosh(notificationFrame, {Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0.05}, 0.44, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        smoothMoveGoWoosh(uiScaleRef, {Scale = 1}, 0.44, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        smoothMoveGoWoosh(glowEffect, {ImageTransparency = 0.8}, 0.3)
        smoothMoveGoWoosh(notificationStroke, {Color = self.config.AccentColor:Lerp(Color3.fromRGB(24, 24, 24), 0.65)}, 0.3)
        smoothMoveGoWoosh(notifImageLabel, {ImageTransparency = 0}, 0.24)
        smoothMoveGoWoosh(notifTitle, {TextTransparency = 0}, 0.24)
        if notifDescription then
            smoothMoveGoWoosh(notifDescription, {TextTransparency = 0}, 0.24)
        end
        progressTween:Play()
    end)

    task.delay(config.Duration, function()
        if notificationFrame and notificationFrame.Parent then
            progressTween:Cancel()
            smoothMoveGoWoosh(glowEffect, {ImageTransparency = 1}, 0.2)
            smoothMoveGoWoosh(notifImageLabel, {ImageTransparency = 1}, 0.2)
            smoothMoveGoWoosh(notifTitle, {TextTransparency = 1}, 0.2)
            if notifDescription then
                smoothMoveGoWoosh(notifDescription, {TextTransparency = 1}, 0.2)
            end
            smoothMoveGoWoosh(notificationFrame, {Position = UDim2.new(-1.25, 0, 0, 0), BackgroundTransparency = 1}, 0.38, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            smoothMoveGoWoosh(uiScaleRef, {Scale = 0.9}, 0.34, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            task.wait(0.4)
            if notificationFrame and notificationFrame.Parent then
                notificationFrame:Destroy()
            end
        end
    end)
    return notificationFrame
end

function FoxyLibrary:CreateSection(config)
    config = config or {}
    config.Name = config.Name or "Section"
    config.Icon = config.Icon or "rbxassetid://98092584632154"

    local sectionObj = {}
    sectionObj.tabsInSection = {}
    sectionObj.isExpanded = true
    sectionObj.Library = self

    sectionObj.containerFrame = makeThingExist("Frame", {
        BackgroundTransparency = 1, Size = UDim2.new(0, 158 * mobileScaleFactor, 0, 32 * mobileScaleFactor),
        ClipsDescendants = true, Parent = self.sectionHolderScroll
    })

    sectionObj.mainFrame = makeThingExist("Frame", {
        BackgroundColor3 = Color3.fromRGB(18, 18, 18), Position = UDim2.new(0, 1, 0, 2),
        Size = UDim2.new(0, 156 * mobileScaleFactor, 0, 28 * mobileScaleFactor), Parent = sectionObj.containerFrame
    })

    local strokeThing = makeThingExist("UIStroke", {Color = Color3.fromRGB(33, 33, 33), Parent = sectionObj.mainFrame})
    makeThingExist("UIGradient", {
        Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(1,1,1)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150,150,150)), ColorSequenceKeypoint.new(1, Color3.new(1,1,1))}),
        Rotation = 260, Parent = strokeThing
    })
    makeThingExist("UICorner", {CornerRadius = UDim.new(0, 7), Parent = sectionObj.mainFrame})

    makeThingExist("ImageLabel", {
        Image = config.Icon, BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0.5, -7 * mobileScaleFactor),
        Size = UDim2.new(0, 14 * mobileScaleFactor, 0, 14 * mobileScaleFactor), Parent = sectionObj.mainFrame
    })

    makeThingExist("TextLabel", {
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
        TextColor3 = Color3.new(1, 1, 1), Text = config.Name, BackgroundTransparency = 1,
        Position = UDim2.new(0, 32, 0.5, -8.5 * mobileScaleFactor), TextSize = 15 * mobileScaleFactor,
        Size = UDim2.new(0, 80, 0, 17 * mobileScaleFactor), TextXAlignment = Enum.TextXAlignment.Left,
        Parent = sectionObj.mainFrame
    })

    local expandButtonImg = makeThingExist("ImageButton", {
        Image = "rbxassetid://111626678408582", BackgroundTransparency = 1,
        Position = UDim2.new(1, -24, 0.5, -8 * mobileScaleFactor),
        Size = UDim2.new(0, 16 * mobileScaleFactor, 0, 16 * mobileScaleFactor), Parent = sectionObj.mainFrame
    })

    sectionObj.tabHolderFrame = makeThingExist("Frame", {
        BackgroundTransparency = 1, Position = UDim2.new(0, 11, 0, 39 * mobileScaleFactor),
        Size = UDim2.new(0, 146 * mobileScaleFactor, 0, 0), ClipsDescendants = true, Parent = sectionObj.containerFrame
    })

    sectionObj.tabLayoutThing = makeThingExist("UIListLayout", {Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder, Parent = sectionObj.tabHolderFrame})

    local function updateContainerSizeYay()
        local tabsHeight = sectionObj.tabLayoutThing.AbsoluteContentSize.Y
        sectionObj.tabHolderFrame.Size = UDim2.new(0, 146 * mobileScaleFactor, 0, tabsHeight)
        if sectionObj.isExpanded then
            smoothMoveGoWoosh(sectionObj.containerFrame, {Size = UDim2.new(0, 158 * mobileScaleFactor, 0, 32 * mobileScaleFactor + tabsHeight + 9)}, 0.25)
        end
    end

    self:_TrackConnection(sectionObj.tabLayoutThing:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateContainerSizeYay))

    self:_TrackConnection(expandButtonImg.MouseButton1Click:Connect(function()
        sectionObj.isExpanded = not sectionObj.isExpanded
        smoothMoveGoWoosh(expandButtonImg, {Rotation = sectionObj.isExpanded and 0 or -90}, 0.25)
        if sectionObj.isExpanded then
            local tabsHeight = sectionObj.tabLayoutThing.AbsoluteContentSize.Y
            smoothMoveGoWoosh(sectionObj.containerFrame, {Size = UDim2.new(0, 158 * mobileScaleFactor, 0, 32 * mobileScaleFactor + tabsHeight + 9)}, 0.25)
        else
            smoothMoveGoWoosh(sectionObj.containerFrame, {Size = UDim2.new(0, 158 * mobileScaleFactor, 0, 32 * mobileScaleFactor)}, 0.25)
        end
    end))

    function sectionObj:AddTab(tabConfig)
        tabConfig = tabConfig or {}
        tabConfig.Name = tabConfig.Name or "Tab"
        tabConfig.Description = tabConfig.Description or "Tab description"
        tabConfig.Icon = tabConfig.Icon or "rbxassetid://94219370057308"

        local tabObj = {}
        tabObj.tabNameForSearch = tabConfig.Name
        tabObj.searchTerms = {tabConfig.Name, tabConfig.Description}
        tabObj.groupsInTab = {}
        tabObj.groupPositions = {Left = 0, Right = 0}
        tabObj.isActive = false
        tabObj.Library = sectionObj.Library
        tabObj.defaultButtonSize = UDim2.new(0, 136 * mobileScaleFactor, 0, 28 * mobileScaleFactor)

        tabObj.buttonFrame = makeThingExist("Frame", {
            BackgroundColor3 = sectionObj.Library.config.AccentColor, BackgroundTransparency = 1,
            Size = tabObj.defaultButtonSize, ClipsDescendants = true, Parent = sectionObj.tabHolderFrame
        })
        makeThingExist("UICorner", {CornerRadius = UDim.new(0, 7), Parent = tabObj.buttonFrame})

        tabObj.iconImg = makeThingExist("ImageLabel", {
            ImageColor3 = Color3.fromRGB(89, 89, 89), Image = tabConfig.Icon, BackgroundTransparency = 1,
            Position = UDim2.new(0, 9, 0.5, -7 * mobileScaleFactor),
            Size = UDim2.new(0, 14 * mobileScaleFactor, 0, 14 * mobileScaleFactor), Parent = tabObj.buttonFrame
        })

        tabObj.nameLabel = makeThingExist("TextLabel", {
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
            TextColor3 = Color3.fromRGB(89, 89, 89), Text = tabConfig.Name, BackgroundTransparency = 1,
            Position = UDim2.new(0, 28, 0.5, -8 * mobileScaleFactor), TextSize = 13 * mobileScaleFactor,
            Size = UDim2.new(0, 105 * mobileScaleFactor, 0, 16 * mobileScaleFactor),
            TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
            ClipsDescendants = true, Parent = tabObj.buttonFrame
        })

        local tabClickButton = makeThingExist("TextButton", {Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Parent = tabObj.buttonFrame})

        tabObj.contentScroll = makeThingExist("ScrollingFrame", {
            BackgroundTransparency = 1, Position = UDim2.new(0, 4, 0, 4),
            Size = UDim2.new(1, -8, 1, -8), ScrollBarThickness = 0,
            CanvasSize = UDim2.new(0, 540 * mobileScaleFactor, 0, 0), Visible = false,
            Parent = sectionObj.Library.contentHolderFrame
        })

        tabObj.leftColumnFrame = makeThingExist("Frame", {BackgroundTransparency = 1, Size = UDim2.new(0, 262 * mobileScaleFactor, 0, 1000), Parent = tabObj.contentScroll})
        tabObj.rightColumnFrame = makeThingExist("Frame", {BackgroundTransparency = 1, Position = UDim2.new(0, 272 * mobileScaleFactor, 0, 0), Size = UDim2.new(0, 262 * mobileScaleFactor, 0, 1000), Parent = tabObj.contentScroll})

        local groupSpacingY = 15 * mobileScaleFactor
        local function relayoutGroupsYay()
            local sideOffsets = {Left = 0, Right = 0}
            for _, group in ipairs(tabObj.groupsInTab) do
                if group.mainFrame and group.mainFrame.Parent then
                    local side = group.side == "Right" and "Right" or "Left"
                    local nextY = sideOffsets[side]
                    group.mainFrame.Position = UDim2.new(0, 1, 0, nextY + 1)
                    sideOffsets[side] = nextY + group.mainFrame.Size.Y.Offset + groupSpacingY
                end
            end
            tabObj.groupPositions.Left = sideOffsets.Left
            tabObj.groupPositions.Right = sideOffsets.Right
            local maxHeight = math.max(sideOffsets.Left, sideOffsets.Right)
            tabObj.contentScroll.CanvasSize = UDim2.new(0, 540 * mobileScaleFactor, 0, maxHeight)
        end

        function tabObj:Activate()
            if tabObj.isActive then
                return
            end
            local previousTab = sectionObj.Library.currentTabYay
            if previousTab and previousTab ~= tabObj then
                previousTab:Deactivate(true)
            end
            sectionObj.Library.currentTabYay = tabObj
            tabObj.isActive = true
            tabObj.contentScroll.Position = UDim2.new(0, 14 * mobileScaleFactor, 0, 4)
            tabObj.contentScroll.Visible = true
            smoothMoveGoWoosh(tabObj.contentScroll, {Position = UDim2.new(0, 4, 0, 4)}, 0.26, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
            smoothMoveGoWoosh(tabObj.buttonFrame, {BackgroundTransparency = 0}, 0.22)
            smoothMoveGoWoosh(tabObj.iconImg, {ImageColor3 = Color3.new(1, 1, 1)}, 0.22)
            smoothMoveGoWoosh(tabObj.nameLabel, {TextColor3 = Color3.new(1, 1, 1)}, 0.22)
            sectionObj.Library.tabNameLabel.Text = tabConfig.Name
            sectionObj.Library.tabDescriptionLabel.Text = tabConfig.Description
        end

        function tabObj:Deactivate(skipAnimation)
            tabObj.isActive = false
            for _, group in ipairs(tabObj.groupsInTab) do
                for _, element in ipairs(group.elementsInGroup) do
                    if type(element) == "table" and type(element.Close) == "function" then
                        pcall(function()
                            element:Close()
                        end)
                    end
                end
            end
            if skipAnimation then
                tabObj.contentScroll.Visible = false
                tabObj.contentScroll.Position = UDim2.new(0, 4, 0, 4)
            else
                smoothMoveGoWoosh(tabObj.contentScroll, {Position = UDim2.new(0, -8 * mobileScaleFactor, 0, 4)}, 0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                task.delay(0.18, function()
                    if not tabObj.isActive and tabObj.contentScroll and tabObj.contentScroll.Parent then
                        tabObj.contentScroll.Visible = false
                        tabObj.contentScroll.Position = UDim2.new(0, 4, 0, 4)
                    end
                end)
            end
            smoothMoveGoWoosh(tabObj.buttonFrame, {BackgroundTransparency = 1}, 0.18)
            smoothMoveGoWoosh(tabObj.iconImg, {ImageColor3 = Color3.fromRGB(89, 89, 89)}, 0.18)
            smoothMoveGoWoosh(tabObj.nameLabel, {TextColor3 = Color3.fromRGB(89, 89, 89)}, 0.18)
        end

        tabClickButton.MouseButton1Click:Connect(function() if not tabObj.isActive then tabObj:Activate() end end)
        tabClickButton.MouseEnter:Connect(function()
            if not tabObj.isActive then
                smoothMoveGoWoosh(tabObj.nameLabel, {TextColor3 = Color3.fromRGB(150, 150, 150)}, 0.2)
                smoothMoveGoWoosh(tabObj.iconImg, {ImageColor3 = Color3.fromRGB(150, 150, 150)}, 0.2)
            end
        end)
        tabClickButton.MouseLeave:Connect(function()
            if not tabObj.isActive then
                smoothMoveGoWoosh(tabObj.nameLabel, {TextColor3 = Color3.fromRGB(89, 89, 89)}, 0.2)
                smoothMoveGoWoosh(tabObj.iconImg, {ImageColor3 = Color3.fromRGB(89, 89, 89)}, 0.2)
            end
        end)

        function tabObj:AddGroup(groupConfig)
            groupConfig = groupConfig or {}
            groupConfig.Name = groupConfig.Name or "Group"
            groupConfig.Side = groupConfig.Side or "Left"
            groupConfig.Icon = groupConfig.Icon or "rbxassetid://10723427199"
            if string.lower(tostring(groupConfig.Side)) == "right" then
                groupConfig.Side = "Right"
            else
                groupConfig.Side = "Left"
            end

            local groupObj = {}
            groupObj.groupNameForSearch = groupConfig.Name
            groupObj.searchTerms = {groupConfig.Name}
            groupObj.elementsInGroup = {}
            groupObj.Library = tabObj.Library
            groupObj.side = groupConfig.Side
            groupObj.elementYPos = 35 * mobileScaleFactor
            local function createAutoFlag(elementName)
                return tostring(tabObj.tabNameForSearch) .. "." .. tostring(groupObj.groupNameForSearch) .. "." .. tostring(elementName or "Value")
            end
            local function addSearchTerm(term)
                local normalized = normalizeSearchText(term)
                if normalized ~= "" then
                    table.insert(groupObj.searchTerms, tostring(term))
                end
            end

            local parentColumn = groupObj.side == "Left" and tabObj.leftColumnFrame or tabObj.rightColumnFrame
            local groupWidth = 260 * mobileScaleFactor

            groupObj.mainFrame = makeThingExist("Frame", {
                BackgroundColor3 = Color3.fromRGB(18, 18, 18), Position = UDim2.new(0, 1, 0, 1),
                Size = UDim2.new(0, groupWidth, 0, 50 * mobileScaleFactor),
                ClipsDescendants = true, Parent = parentColumn
            })

            local groupStrokeThing = makeThingExist("UIStroke", {Color = Color3.fromRGB(33, 33, 33), Parent = groupObj.mainFrame})
            makeThingExist("UIGradient", {
                Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(1,1,1)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150,150,150)), ColorSequenceKeypoint.new(1, Color3.new(1,1,1))}),
                Rotation = 260, Parent = groupStrokeThing
            })
            makeThingExist("UICorner", {CornerRadius = UDim.new(0, 11), Parent = groupObj.mainFrame})

            makeThingExist("ImageLabel", {
                Image = groupConfig.Icon, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 10 * mobileScaleFactor),
                Size = UDim2.new(0, 16 * mobileScaleFactor, 0, 16 * mobileScaleFactor), Parent = groupObj.mainFrame
            })

            makeThingExist("TextLabel", {
                FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
                TextColor3 = Color3.new(1, 1, 1), Text = groupConfig.Name, BackgroundTransparency = 1,
                Position = UDim2.new(0, 32, 0, 8 * mobileScaleFactor), TextSize = 15 * mobileScaleFactor,
                Size = UDim2.new(0, 215 * mobileScaleFactor, 0, 16 * mobileScaleFactor), TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd, Parent = groupObj.mainFrame
            })

            local function updateGroupSizeYay()
                local newHeight = groupObj.elementYPos + 10 * mobileScaleFactor
                groupObj.mainFrame.Size = UDim2.new(0, groupWidth, 0, newHeight)
                relayoutGroupsYay()
            end

            function groupObj:AddToggle(toggleConfig)
                toggleConfig = toggleConfig or {}
                toggleConfig.Name = toggleConfig.Name or "Toggle"
                toggleConfig.Default = toggleConfig.Default or false
                toggleConfig.Callback = toggleConfig.Callback or function() end
                toggleConfig.Flag = toggleConfig.Flag or createAutoFlag(toggleConfig.Name)
                addSearchTerm(toggleConfig.Name)

                local toggleObj = {}
                toggleObj.value = toggleConfig.Default
                local yPosition = groupObj.elementYPos

                toggleObj.labelText = makeThingExist("TextLabel", {
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
                    TextColor3 = Color3.fromRGB(124, 124, 124), Text = toggleConfig.Name, BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, yPosition), TextSize = 14 * mobileScaleFactor,
                    Size = UDim2.new(0, 195 * mobileScaleFactor, 0, 20 * mobileScaleFactor),
                    TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = groupObj.mainFrame
                })

                toggleObj.switchFrame = makeThingExist("Frame", {
                    BackgroundColor3 = toggleObj.value and groupObj.Library.config.AccentColor or Color3.fromRGB(32, 32, 32),
                    Position = UDim2.new(1, -44 * mobileScaleFactor, 0, yPosition),
                    Size = UDim2.new(0, 34 * mobileScaleFactor, 0, 21 * mobileScaleFactor), Parent = groupObj.mainFrame
                })
                makeThingExist("UICorner", {CornerRadius = UDim.new(1, 0), Parent = toggleObj.switchFrame})

                toggleObj.circleFrame = makeThingExist("Frame", {
                    BackgroundColor3 = toggleObj.value and Color3.new(1, 1, 1) or Color3.fromRGB(75, 75, 75),
                    Position = toggleObj.value and UDim2.new(0.462, 0, 0.143, 0) or UDim2.new(0.0104, 0, 0.143, 0),
                    Size = UDim2.new(0, 15 * mobileScaleFactor, 0, 15 * mobileScaleFactor), Parent = toggleObj.switchFrame
                })
                makeThingExist("UICorner", {CornerRadius = UDim.new(1, 0), Parent = toggleObj.circleFrame})

                local toggleClickButton = makeThingExist("TextButton", {Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Parent = toggleObj.switchFrame})

                function toggleObj:Set(value)
                    toggleObj.value = value
                    if toggleObj.value then
                        smoothMoveGoWoosh(toggleObj.switchFrame, {BackgroundColor3 = groupObj.Library.config.AccentColor}, 0.2)
                        smoothMoveGoWoosh(toggleObj.circleFrame, {Position = UDim2.new(0.462, 0, 0.143, 0), BackgroundColor3 = Color3.new(1, 1, 1)}, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                    else
                        smoothMoveGoWoosh(toggleObj.switchFrame, {BackgroundColor3 = Color3.fromRGB(32, 32, 32)}, 0.2)
                        smoothMoveGoWoosh(toggleObj.circleFrame, {Position = UDim2.new(0.0104, 0, 0.143, 0), BackgroundColor3 = Color3.fromRGB(75, 75, 75)}, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                    end
                    toggleConfig.Callback(toggleObj.value)
                end

                function toggleObj:Get()
                    return toggleObj.value
                end

                toggleClickButton.MouseButton1Click:Connect(function() toggleObj:Set(not toggleObj.value) end)
                if toggleConfig.Default then toggleConfig.Callback(true) end
                groupObj.Library:RegisterControl(toggleConfig.Flag, function()
                    return toggleObj:Get()
                end, function(value)
                    toggleObj:Set(value == true)
                end)

                groupObj.elementYPos = groupObj.elementYPos + 28 * mobileScaleFactor
                updateGroupSizeYay()
                table.insert(groupObj.elementsInGroup, toggleObj)
                return toggleObj
            end

            function groupObj:AddSlider(sliderConfig)
                sliderConfig = sliderConfig or {}
                sliderConfig.Name = sliderConfig.Name or "Slider"
                sliderConfig.Min = tonumber(sliderConfig.Min) or 0
                sliderConfig.Max = tonumber(sliderConfig.Max) or 100
                if sliderConfig.Max < sliderConfig.Min then
                    sliderConfig.Min, sliderConfig.Max = sliderConfig.Max, sliderConfig.Min
                end
                sliderConfig.Default = tonumber(sliderConfig.Default)
                if sliderConfig.Default == nil then
                    sliderConfig.Default = sliderConfig.Min
                end
                sliderConfig.Increment = math.abs(tonumber(sliderConfig.Increment) or 1)
                if sliderConfig.Increment < 1e-6 then
                    sliderConfig.Increment = 1
                end
                sliderConfig.Callback = sliderConfig.Callback or function() end
                sliderConfig.Flag = sliderConfig.Flag or createAutoFlag(sliderConfig.Name)
                addSearchTerm(sliderConfig.Name)

                local sliderPrecision = resolveSliderPrecision(sliderConfig.Min, sliderConfig.Max, sliderConfig.Increment, sliderConfig.Default)
                local sliderRange = sliderConfig.Max - sliderConfig.Min
                local function getSliderPercentage(value)
                    if sliderRange <= 0 then
                        return 0
                    end
                    return math.clamp((value - sliderConfig.Min) / sliderRange, 0, 1)
                end
                local function formatValue(value)
                    return formatSliderValue(value, sliderPrecision)
                end

                local sliderObj = {}
                sliderObj.value = normalizeSliderValue(sliderConfig.Default, sliderConfig.Min, sliderConfig.Max, sliderConfig.Increment, sliderPrecision)
                local yPosition = groupObj.elementYPos
                local sliderWidth = 238 * mobileScaleFactor

                sliderObj.labelText = makeThingExist("TextLabel", {
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
                    TextColor3 = Color3.fromRGB(124, 124, 124), Text = sliderConfig.Name, BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, yPosition), TextSize = 14 * mobileScaleFactor,
                    Size = UDim2.new(0, 155 * mobileScaleFactor, 0, 20 * mobileScaleFactor),
                    TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = groupObj.mainFrame
                })

                sliderObj.backgroundFrame = makeThingExist("Frame", {
                    BackgroundColor3 = Color3.fromRGB(32, 32, 32), Position = UDim2.new(0, 10, 0, yPosition + 22 * mobileScaleFactor),
                    Size = UDim2.new(0, sliderWidth, 0, 12 * mobileScaleFactor), Parent = groupObj.mainFrame
                })
                makeThingExist("UICorner", {CornerRadius = UDim.new(1, 0), Parent = sliderObj.backgroundFrame})

                local percentage = getSliderPercentage(sliderObj.value)
                sliderObj.fillFrame = makeThingExist("Frame", {
                    BackgroundColor3 = groupObj.Library.config.AccentColor,
                    Size = UDim2.new(0, sliderWidth * percentage, 0, 12 * mobileScaleFactor), Parent = sliderObj.backgroundFrame
                })
                makeThingExist("UICorner", {CornerRadius = UDim.new(1, 0), Parent = sliderObj.fillFrame})

                sliderObj.valueLabelText = makeThingExist("TextLabel", {
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
                    TextColor3 = Color3.fromRGB(124, 124, 124), Text = formatValue(sliderObj.value) .. " / " .. formatValue(sliderConfig.Max),
                    BackgroundTransparency = 1, Position = UDim2.new(1, -80 * mobileScaleFactor, 0, yPosition),
                    TextSize = 14 * mobileScaleFactor, Size = UDim2.new(0, 70 * mobileScaleFactor, 0, 20 * mobileScaleFactor),
                    TextXAlignment = Enum.TextXAlignment.Right, Parent = groupObj.mainFrame
                })

                local sliderClickButton = makeThingExist("TextButton", {Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Parent = sliderObj.backgroundFrame})

                function sliderObj:Set(value)
                    value = normalizeSliderValue(value, sliderConfig.Min, sliderConfig.Max, sliderConfig.Increment, sliderPrecision)
                    sliderObj.value = value
                    local percentage = getSliderPercentage(value)
                    smoothMoveGoWoosh(sliderObj.fillFrame, {Size = UDim2.new(0, sliderWidth * percentage, 0, 12 * mobileScaleFactor)}, 0.1)
                    sliderObj.valueLabelText.Text = formatValue(value) .. " / " .. formatValue(sliderConfig.Max)
                    sliderConfig.Callback(value)
                end

                function sliderObj:Get()
                    return sliderObj.value
                end

                local isDraggingSlider = false
                sliderClickButton.MouseButton1Down:Connect(function() isDraggingSlider = true end)
                groupObj.Library:_TrackConnection(thisInputServiceGoesHard.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDraggingSlider = false end
                end))
                groupObj.Library:_TrackConnection(thisInputServiceGoesHard.InputChanged:Connect(function(input)
                    if isDraggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local percentage = math.clamp((input.Position.X - sliderObj.backgroundFrame.AbsolutePosition.X) / sliderObj.backgroundFrame.AbsoluteSize.X, 0, 1)
                        local value = sliderConfig.Min + sliderRange * percentage
                        sliderObj:Set(value)
                    end
                end))

                if sliderObj.value ~= sliderConfig.Min then sliderConfig.Callback(sliderObj.value) end
                groupObj.Library:RegisterControl(sliderConfig.Flag, function()
                    return sliderObj:Get()
                end, function(value)
                    sliderObj:Set(tonumber(value) or sliderConfig.Min)
                end)
                groupObj.elementYPos = groupObj.elementYPos + 40 * mobileScaleFactor
                updateGroupSizeYay()
                table.insert(groupObj.elementsInGroup, sliderObj)
                return sliderObj
            end

            function groupObj:AddButton(buttonConfig)
                buttonConfig = buttonConfig or {}
                buttonConfig.Name = buttonConfig.Name or "Button"
                buttonConfig.Icon = buttonConfig.Icon
                buttonConfig.Locked = buttonConfig.Locked or false
                buttonConfig.Callback = buttonConfig.Callback or function() end
                addSearchTerm(buttonConfig.Name)

                local buttonObj = {}
                buttonObj.isLocked = buttonConfig.Locked
                local yPosition = groupObj.elementYPos
                local buttonWidth = 238 * mobileScaleFactor

                buttonObj.mainFrame = makeThingExist("Frame", {
                    BackgroundColor3 = buttonObj.isLocked and Color3.fromRGB(24, 24, 24) or Color3.fromRGB(32, 32, 32),
                    Position = UDim2.new(0, 10, 0, yPosition),
                    Size = UDim2.new(0, buttonWidth, 0, 26 * mobileScaleFactor), Parent = groupObj.mainFrame
                })
                makeThingExist("UICorner", {CornerRadius = UDim.new(0, 6), Parent = buttonObj.mainFrame})

                local buttonStrokeThing = makeThingExist("UIStroke", {Color = buttonObj.isLocked and Color3.fromRGB(32, 32, 32) or Color3.fromRGB(48, 48, 48), Parent = buttonObj.mainFrame})
                makeThingExist("UIGradient", {
                    Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(1,1,1)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150,150,150)), ColorSequenceKeypoint.new(1, Color3.new(1,1,1))}),
                    Rotation = 260, Parent = buttonStrokeThing
                })

                local textXPos = 8
                if buttonConfig.Icon then
                    makeThingExist("ImageLabel", {
                        ImageColor3 = buttonObj.isLocked and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(125, 125, 125),
                        Image = buttonConfig.Icon, BackgroundTransparency = 1,
                        Position = UDim2.new(0, 8, 0.5, -8 * mobileScaleFactor),
                        Size = UDim2.new(0, 16 * mobileScaleFactor, 0, 16 * mobileScaleFactor), Parent = buttonObj.mainFrame
                    })
                    textXPos = 30
                end

                buttonObj.labelText = makeThingExist("TextLabel", {
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
                    TextColor3 = buttonObj.isLocked and Color3.fromRGB(46, 46, 46) or Color3.fromRGB(120, 120, 120),
                    Text = buttonConfig.Name .. (buttonObj.isLocked and " (locked)" or ""), BackgroundTransparency = 1,
                    Position = UDim2.new(0, textXPos * mobileScaleFactor, 0, 0), TextSize = 14 * mobileScaleFactor,
                    Size = UDim2.new(1, -textXPos * mobileScaleFactor - 10, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = buttonObj.mainFrame
                })

                local buttonClickButton = makeThingExist("TextButton", {Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Parent = buttonObj.mainFrame})
                buttonClickButton.MouseButton1Click:Connect(function() if not buttonObj.isLocked then buttonConfig.Callback() end end)
                buttonClickButton.MouseEnter:Connect(function() if not buttonObj.isLocked then smoothMoveGoWoosh(buttonObj.mainFrame, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.2) end end)
                buttonClickButton.MouseLeave:Connect(function() if not buttonObj.isLocked then smoothMoveGoWoosh(buttonObj.mainFrame, {BackgroundColor3 = Color3.fromRGB(32, 32, 32)}, 0.2) end end)

                groupObj.elementYPos = groupObj.elementYPos + 32 * mobileScaleFactor
                updateGroupSizeYay()
                table.insert(groupObj.elementsInGroup, buttonObj)
                return buttonObj
            end

            function groupObj:AddKeybind(keybindConfig)
                keybindConfig = keybindConfig or {}
                keybindConfig.Name = keybindConfig.Name or "Keybind"
                keybindConfig.Default = keybindConfig.Default or Enum.KeyCode.Unknown
                keybindConfig.Callback = keybindConfig.Callback or function() end
                keybindConfig.ChangedCallback = keybindConfig.ChangedCallback or function() end
                keybindConfig.ModeChangedCallback = keybindConfig.ModeChangedCallback or function() end
                keybindConfig.Mode = tostring(keybindConfig.Mode or "Toggle")
                keybindConfig.Flag = keybindConfig.Flag or createAutoFlag(keybindConfig.Name)
                keybindConfig.ModeFlag = keybindConfig.ModeFlag or createAutoFlag(keybindConfig.Name .. ".Mode")
                addSearchTerm(keybindConfig.Name)
                addSearchTerm("hold")
                addSearchTerm("toggle")

                local keybindObj = {}
                keybindObj.value = keybindConfig.Default
                keybindObj.mode = string.lower(keybindConfig.Mode) == "hold" and "Hold" or "Toggle"
                keybindObj.isListening = false
                keybindObj.holdActive = false
                local yPosition = groupObj.elementYPos

                keybindObj.labelText = makeThingExist("TextLabel", {
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
                    TextColor3 = Color3.fromRGB(124, 124, 124), Text = keybindConfig.Name, BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, yPosition), TextSize = 14 * mobileScaleFactor,
                    Size = UDim2.new(0, 145 * mobileScaleFactor, 0, 20 * mobileScaleFactor),
                    TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = groupObj.mainFrame
                })

                local function normalizeMode(modeValue)
                    return string.lower(tostring(modeValue or "toggle")) == "hold" and "Hold" or "Toggle"
                end

                local function getKeyText()
                    return keybindObj.value == Enum.KeyCode.Unknown and "None" or keybindObj.value.Name
                end

                local keyText = getKeyText()
                local keyWidth = math.max(48 * mobileScaleFactor, howWideIsThisText(keyText, 12 * mobileScaleFactor) + 30 * mobileScaleFactor)

                keybindObj.buttonFrame = makeThingExist("Frame", {
                    BackgroundColor3 = Color3.fromRGB(32, 32, 32), Position = UDim2.new(1, -keyWidth - 10, 0, yPosition),
                    Size = UDim2.new(0, keyWidth, 0, 21 * mobileScaleFactor), Active = true, Parent = groupObj.mainFrame
                })
                makeThingExist("UICorner", {CornerRadius = UDim.new(1, 0), Parent = keybindObj.buttonFrame})

                local keybindStrokeThing = makeThingExist("UIStroke", {Color = Color3.fromRGB(40, 40, 40), Parent = keybindObj.buttonFrame})
                makeThingExist("UIGradient", {
                    Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(1,1,1)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150,150,150)), ColorSequenceKeypoint.new(1, Color3.new(1,1,1))}),
                    Rotation = 260, Parent = keybindStrokeThing
                })

                keybindObj.keyLabelText = makeThingExist("TextLabel", {
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
                    TextColor3 = Color3.fromRGB(113, 113, 113), Text = keyText, BackgroundTransparency = 1,
                    Position = UDim2.new(0, 2, 0, 0), TextSize = 12 * mobileScaleFactor,
                    Size = UDim2.new(1, -24 * mobileScaleFactor, 1, 0), TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = keybindObj.buttonFrame
                })
                makeThingExist("UIPadding", {PaddingLeft = UDim.new(0, 2), Parent = keybindObj.keyLabelText})

                keybindObj.keyboardIconImg = makeThingExist("ImageLabel", {
                    ImageColor3 = Color3.fromRGB(76, 76, 76), Image = "rbxassetid://10723416765", BackgroundTransparency = 1,
                    Position = UDim2.new(1, -18 * mobileScaleFactor, 0.5, -7 * mobileScaleFactor),
                    Size = UDim2.new(0, 14 * mobileScaleFactor, 0, 14 * mobileScaleFactor), Parent = keybindObj.buttonFrame
                })

                local keybindClickButton = makeThingExist("TextButton", {Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Active = true, Parent = keybindObj.buttonFrame})

                local modeMenuWidth = 120 * mobileScaleFactor
                local modeMenuHeight = 78 * mobileScaleFactor
                local modeMenuPositionConn = nil
                local modeMenuOutsideConn = nil
                keybindObj.isModeMenuOpen = false

                keybindObj.modeMenuFrame = makeThingExist("Frame", {
                    BackgroundColor3 = Color3.fromRGB(16, 16, 16),
                    Size = UDim2.new(0, modeMenuWidth, 0, 0),
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 9999,
                    Parent = groupObj.Library.dropdownHolderRef
                })
                makeThingExist("UICorner", {CornerRadius = UDim.new(0, 7), Parent = keybindObj.modeMenuFrame})
                makeThingExist("UIStroke", {Color = Color3.fromRGB(40, 40, 40), Parent = keybindObj.modeMenuFrame})

                makeThingExist("TextLabel", {
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
                    Text = "Keybind Mode",
                    TextColor3 = Color3.new(1, 1, 1),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 8, 0, 5 * mobileScaleFactor),
                    Size = UDim2.new(1, -16, 0, 16 * mobileScaleFactor),
                    TextSize = 12 * mobileScaleFactor,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 10000,
                    Parent = keybindObj.modeMenuFrame
                })

                local toggleModeFrame = makeThingExist("Frame", {
                    BackgroundColor3 = Color3.fromRGB(28, 28, 28),
                    Position = UDim2.new(0, 8, 0, 26 * mobileScaleFactor),
                    Size = UDim2.new(1, -16, 0, 20 * mobileScaleFactor),
                    ZIndex = 10000,
                    Parent = keybindObj.modeMenuFrame
                })
                makeThingExist("UICorner", {CornerRadius = UDim.new(0, 5), Parent = toggleModeFrame})

                local toggleModeLabel = makeThingExist("TextLabel", {
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
                    Text = "Toggle",
                    TextColor3 = Color3.fromRGB(124, 124, 124),
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    TextSize = 12 * mobileScaleFactor,
                    ZIndex = 10001,
                    Parent = toggleModeFrame
                })

                local holdModeFrame = makeThingExist("Frame", {
                    BackgroundColor3 = Color3.fromRGB(28, 28, 28),
                    Position = UDim2.new(0, 8, 0, 50 * mobileScaleFactor),
                    Size = UDim2.new(1, -16, 0, 20 * mobileScaleFactor),
                    ZIndex = 10000,
                    Parent = keybindObj.modeMenuFrame
                })
                makeThingExist("UICorner", {CornerRadius = UDim.new(0, 5), Parent = holdModeFrame})

                local holdModeLabel = makeThingExist("TextLabel", {
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
                    Text = "Hold",
                    TextColor3 = Color3.fromRGB(124, 124, 124),
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    TextSize = 12 * mobileScaleFactor,
                    ZIndex = 10001,
                    Parent = holdModeFrame
                })

                local toggleModeClickButton = makeThingExist("TextButton", {
                    Text = "",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    ZIndex = 10002,
                    Parent = toggleModeFrame
                })

                local holdModeClickButton = makeThingExist("TextButton", {
                    Text = "",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    ZIndex = 10002,
                    Parent = holdModeFrame
                })

                local function updateKeybindSizeYay(text)
                    local newWidth = math.max(48 * mobileScaleFactor, howWideIsThisText(text, 12 * mobileScaleFactor) + 30 * mobileScaleFactor)
                    smoothMoveGoWoosh(keybindObj.buttonFrame, {Size = UDim2.new(0, newWidth, 0, 21 * mobileScaleFactor), Position = UDim2.new(1, -newWidth - 10, 0, yPosition)}, 0.15)
                end

                local function updateModeVisuals()
                    local selectedBg = groupObj.Library.config.AccentColor:Lerp(Color3.fromRGB(16, 16, 16), 0.45)
                    local idleBg = Color3.fromRGB(28, 28, 28)
                    local selectedText = Color3.new(1, 1, 1)
                    local idleText = Color3.fromRGB(124, 124, 124)
                    local isToggleSelected = keybindObj.mode == "Toggle"

                    smoothMoveGoWoosh(toggleModeFrame, {BackgroundColor3 = isToggleSelected and selectedBg or idleBg}, 0.12)
                    smoothMoveGoWoosh(toggleModeLabel, {TextColor3 = isToggleSelected and selectedText or idleText}, 0.12)
                    smoothMoveGoWoosh(holdModeFrame, {BackgroundColor3 = isToggleSelected and idleBg or selectedBg}, 0.12)
                    smoothMoveGoWoosh(holdModeLabel, {TextColor3 = isToggleSelected and idleText or selectedText}, 0.12)
                end

                local function updateModeMenuPositionYay()
                    local buttonAbsPos = keybindObj.buttonFrame.AbsolutePosition
                    local buttonAbsSize = keybindObj.buttonFrame.AbsoluteSize
                    keybindObj.modeMenuFrame.Position = UDim2.new(0, buttonAbsPos.X + buttonAbsSize.X - modeMenuWidth, 0, buttonAbsPos.Y + buttonAbsSize.Y + 5)
                end

                local function closeModeMenu(isInstant)
                    keybindObj.isModeMenuOpen = false
                    if modeMenuPositionConn then
                        modeMenuPositionConn()
                        modeMenuPositionConn = nil
                    end
                    if modeMenuOutsideConn then
                        modeMenuOutsideConn:Disconnect()
                        modeMenuOutsideConn = nil
                    end
                    if isInstant then
                        keybindObj.modeMenuFrame.Size = UDim2.new(0, modeMenuWidth, 0, 0)
                        keybindObj.modeMenuFrame.Visible = false
                        return
                    end
                    smoothMoveGoWoosh(keybindObj.modeMenuFrame, {Size = UDim2.new(0, modeMenuWidth, 0, 0)}, 0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
                    task.delay(0.18, function()
                        if keybindObj.modeMenuFrame and keybindObj.modeMenuFrame.Parent and not keybindObj.isModeMenuOpen then
                            keybindObj.modeMenuFrame.Visible = false
                        end
                    end)
                end

                local function openModeMenu()
                    if keybindObj.isListening then return end
                    keybindObj.isModeMenuOpen = true
                    updateModeVisuals()
                    updateModeMenuPositionYay()
                    keybindObj.modeMenuFrame.Visible = true
                    smoothMoveGoWoosh(keybindObj.modeMenuFrame, {Size = UDim2.new(0, modeMenuWidth, 0, modeMenuHeight)}, 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

                    if modeMenuPositionConn then modeMenuPositionConn() end
                    modeMenuPositionConn = startFloatingPositionTracker(groupObj.Library, keybindObj.buttonFrame, function()
                        if keybindObj.isModeMenuOpen then
                            updateModeMenuPositionYay()
                        end
                    end)

                    if modeMenuOutsideConn then modeMenuOutsideConn:Disconnect() end
                    modeMenuOutsideConn = groupObj.Library:_TrackConnection(thisInputServiceGoesHard.InputBegan:Connect(function(input)
                        if not keybindObj.isModeMenuOpen then return end
                        local isPress = input.UserInputType == Enum.UserInputType.MouseButton1
                            or input.UserInputType == Enum.UserInputType.MouseButton2
                            or input.UserInputType == Enum.UserInputType.Touch
                        if not isPress then return end

                        local mousePos = input.Position
                        local menuPos = keybindObj.modeMenuFrame.AbsolutePosition
                        local menuSize = keybindObj.modeMenuFrame.AbsoluteSize
                        local buttonPos = keybindObj.buttonFrame.AbsolutePosition
                        local buttonSize = keybindObj.buttonFrame.AbsoluteSize

                        local insideMenu = mousePos.X >= menuPos.X and mousePos.X <= (menuPos.X + menuSize.X)
                            and mousePos.Y >= menuPos.Y and mousePos.Y <= (menuPos.Y + menuSize.Y)
                        local insideButton = mousePos.X >= buttonPos.X and mousePos.X <= (buttonPos.X + buttonSize.X)
                            and mousePos.Y >= buttonPos.Y and mousePos.Y <= (buttonPos.Y + buttonSize.Y)

                        if not insideMenu and not insideButton then
                            closeModeMenu(false)
                        end
                    end))
                end

                local function toggleModeMenu()
                    if keybindObj.isModeMenuOpen then
                        closeModeMenu(false)
                    else
                        openModeMenu()
                    end
                end

                local function setMode(modeValue, silent)
                    local newMode = normalizeMode(modeValue)
                    if newMode == keybindObj.mode then
                        updateModeVisuals()
                        return
                    end
                    if keybindObj.holdActive then
                        keybindObj.holdActive = false
                        keybindConfig.Callback(false)
                    end
                    keybindObj.mode = newMode
                    updateModeVisuals()
                    keybindConfig.ModeChangedCallback(newMode)
                    if not silent then
                        groupObj.Library:Notify({
                            Title = keybindConfig.Name .. " mode updated",
                            Description = "Now using " .. newMode .. " input",
                            Duration = 2.2,
                            Icon = "rbxassetid://6031075938"
                        })
                    end
                end

                function keybindObj:Set(key)
                    if keybindObj.holdActive then
                        keybindObj.holdActive = false
                        keybindConfig.Callback(false)
                    end
                    keybindObj.value = key
                    local newKeyText = getKeyText()
                    keybindObj.keyLabelText.Text = newKeyText
                    updateKeybindSizeYay(newKeyText)
                    keybindConfig.ChangedCallback(key)
                end

                function keybindObj:Get()
                    return keybindObj.value
                end

                function keybindObj:SetMode(modeValue, silent)
                    setMode(modeValue, silent)
                end

                function keybindObj:GetMode()
                    return keybindObj.mode
                end

                function keybindObj:Close()
                    keybindObj.isListening = false
                    if keybindObj.holdActive then
                        keybindObj.holdActive = false
                        keybindConfig.Callback(false)
                    end
                    closeModeMenu(true)
                end

                keybindClickButton.MouseButton1Click:Connect(function()
                    closeModeMenu(true)
                    keybindObj.isListening = true
                    keybindObj.keyLabelText.Text = "..."
                    updateKeybindSizeYay("...")
                    smoothMoveGoWoosh(keybindObj.buttonFrame, {BackgroundColor3 = Color3.fromRGB(48, 48, 48)}, 0.2)
                end)

                local modeMenuToggleDebounceAt = 0
                local function toggleModeMenuFromRightClick()
                    if keybindObj.isListening then
                        return
                    end
                    local now = os.clock()
                    if now - modeMenuToggleDebounceAt < 0.12 then
                        return
                    end
                    modeMenuToggleDebounceAt = now
                    toggleModeMenu()
                end

                keybindClickButton.MouseButton2Click:Connect(toggleModeMenuFromRightClick)
                keybindClickButton.InputBegan:Connect(function(input)
                    if input.UserInputType ~= Enum.UserInputType.MouseButton2 then
                        return
                    end
                    toggleModeMenuFromRightClick()
                end)

                toggleModeClickButton.MouseButton1Click:Connect(function()
                    setMode("Toggle", false)
                    closeModeMenu(false)
                end)

                holdModeClickButton.MouseButton1Click:Connect(function()
                    setMode("Hold", false)
                    closeModeMenu(false)
                end)

                groupObj.Library:_TrackConnection(thisInputServiceGoesHard.InputBegan:Connect(function(input, gameProcessed)
                    if keybindObj.isListening then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            keybindObj.isListening = false
                            local pickedKey = input.KeyCode
                            if pickedKey == Enum.KeyCode.Backspace or pickedKey == Enum.KeyCode.Delete then
                                pickedKey = Enum.KeyCode.Unknown
                            end
                            keybindObj:Set(pickedKey)
                            smoothMoveGoWoosh(keybindObj.buttonFrame, {BackgroundColor3 = Color3.fromRGB(32, 32, 32)}, 0.2)
                        end
                    elseif not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
                        if input.KeyCode == keybindObj.value and keybindObj.value ~= Enum.KeyCode.Unknown then
                            if keybindObj.mode == "Hold" then
                                if not keybindObj.holdActive then
                                    keybindObj.holdActive = true
                                    keybindConfig.Callback(true)
                                end
                            else
                                keybindConfig.Callback()
                            end
                        end
                    end
                end))

                groupObj.Library:_TrackConnection(thisInputServiceGoesHard.InputEnded:Connect(function(input)
                    if keybindObj.mode == "Hold" and keybindObj.holdActive and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == keybindObj.value then
                        keybindObj.holdActive = false
                        keybindConfig.Callback(false)
                    end
                end))

                keybindClickButton.MouseEnter:Connect(function()
                    if not keybindObj.isListening then smoothMoveGoWoosh(keybindObj.buttonFrame, {BackgroundColor3 = Color3.fromRGB(48, 48, 48)}, 0.2) end
                end)
                keybindClickButton.MouseLeave:Connect(function()
                    if not keybindObj.isListening then smoothMoveGoWoosh(keybindObj.buttonFrame, {BackgroundColor3 = Color3.fromRGB(32, 32, 32)}, 0.2) end
                end)

                toggleModeClickButton.MouseEnter:Connect(function()
                    if keybindObj.mode ~= "Toggle" then
                        smoothMoveGoWoosh(toggleModeFrame, {BackgroundColor3 = Color3.fromRGB(42, 42, 42)}, 0.12)
                    end
                end)
                toggleModeClickButton.MouseLeave:Connect(function()
                    updateModeVisuals()
                end)
                holdModeClickButton.MouseEnter:Connect(function()
                    if keybindObj.mode ~= "Hold" then
                        smoothMoveGoWoosh(holdModeFrame, {BackgroundColor3 = Color3.fromRGB(42, 42, 42)}, 0.12)
                    end
                end)
                holdModeClickButton.MouseLeave:Connect(function()
                    updateModeVisuals()
                end)

                groupObj.Library:RegisterControl(keybindConfig.Flag, function()
                    return keybindObj:Get()
                end, function(value)
                    if typeof(value) == "EnumItem" and value.EnumType == Enum.KeyCode then
                        keybindObj:Set(value)
                    end
                end)
                groupObj.Library:RegisterControl(keybindConfig.ModeFlag, function()
                    return keybindObj:GetMode()
                end, function(value)
                    keybindObj:SetMode(value, true)
                end)

                groupObj.elementYPos = groupObj.elementYPos + 28 * mobileScaleFactor
                updateGroupSizeYay()
                table.insert(groupObj.elementsInGroup, keybindObj)
                return keybindObj
            end

            function groupObj:AddKeybindToggle(keybindToggleConfig)
                keybindToggleConfig = keybindToggleConfig or {}
                keybindToggleConfig.Name = keybindToggleConfig.Name or "Keybind Toggle"
                keybindToggleConfig.Default = keybindToggleConfig.Default or Enum.KeyCode.Unknown
                keybindToggleConfig.ToggleDefault = keybindToggleConfig.ToggleDefault or false
                keybindToggleConfig.Callback = keybindToggleConfig.Callback or function() end
                keybindToggleConfig.ToggleCallback = keybindToggleConfig.ToggleCallback or function() end
                keybindToggleConfig.ChangedCallback = keybindToggleConfig.ChangedCallback or function() end
                keybindToggleConfig.Flag = keybindToggleConfig.Flag or createAutoFlag(keybindToggleConfig.Name .. ".Key")
                keybindToggleConfig.ToggleFlag = keybindToggleConfig.ToggleFlag or createAutoFlag(keybindToggleConfig.Name .. ".Enabled")
                addSearchTerm(keybindToggleConfig.Name)

                local keybindToggleObj = {}
                keybindToggleObj.keyValue = keybindToggleConfig.Default
                keybindToggleObj.toggleValue = keybindToggleConfig.ToggleDefault
                keybindToggleObj.isListening = false
                local yPosition = groupObj.elementYPos

                keybindToggleObj.labelText = makeThingExist("TextLabel", {
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
                    TextColor3 = Color3.fromRGB(124, 124, 124), Text = keybindToggleConfig.Name, BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, yPosition), TextSize = 14 * mobileScaleFactor,
                    Size = UDim2.new(0, 115 * mobileScaleFactor, 0, 20 * mobileScaleFactor),
                    TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = groupObj.mainFrame
                })

                local keyText = keybindToggleObj.keyValue == Enum.KeyCode.Unknown and "None" or keybindToggleObj.keyValue.Name
                local keyWidth = math.max(48 * mobileScaleFactor, howWideIsThisText(keyText, 12 * mobileScaleFactor) + 30 * mobileScaleFactor)

                keybindToggleObj.keybindButtonFrame = makeThingExist("Frame", {
                    BackgroundColor3 = Color3.fromRGB(32, 32, 32), Position = UDim2.new(1, -keyWidth - 10, 0, yPosition),
                    Size = UDim2.new(0, keyWidth, 0, 21 * mobileScaleFactor), Parent = groupObj.mainFrame
                })
                makeThingExist("UICorner", {CornerRadius = UDim.new(1, 0), Parent = keybindToggleObj.keybindButtonFrame})

                local keybindStrokeThing = makeThingExist("UIStroke", {Color = Color3.fromRGB(40, 40, 40), Parent = keybindToggleObj.keybindButtonFrame})

                keybindToggleObj.keyLabelText = makeThingExist("TextLabel", {
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
                    TextColor3 = Color3.fromRGB(113, 113, 113), Text = keyText, BackgroundTransparency = 1,
                    Position = UDim2.new(0, 6, 0, 0), TextSize = 12 * mobileScaleFactor,
                    Size = UDim2.new(1, -24 * mobileScaleFactor, 1, 0), TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = keybindToggleObj.keybindButtonFrame
                })

                keybindToggleObj.keyboardIconImg = makeThingExist("ImageLabel", {
                    ImageColor3 = Color3.fromRGB(76, 76, 76), Image = "rbxassetid://10723416765", BackgroundTransparency = 1,
                    Position = UDim2.new(1, -18 * mobileScaleFactor, 0.5, -7 * mobileScaleFactor),
                    Size = UDim2.new(0, 14 * mobileScaleFactor, 0, 14 * mobileScaleFactor), Parent = keybindToggleObj.keybindButtonFrame
                })

                keybindToggleObj.toggleSwitchFrame = makeThingExist("Frame", {
                    BackgroundColor3 = keybindToggleObj.toggleValue and groupObj.Library.config.AccentColor or Color3.fromRGB(32, 32, 32),
                    Position = UDim2.new(1, -keyWidth - 48 * mobileScaleFactor, 0, yPosition),
                    Size = UDim2.new(0, 34 * mobileScaleFactor, 0, 21 * mobileScaleFactor), Parent = groupObj.mainFrame
                })
                makeThingExist("UICorner", {CornerRadius = UDim.new(1, 0), Parent = keybindToggleObj.toggleSwitchFrame})

                keybindToggleObj.toggleCircleFrame = makeThingExist("Frame", {
                    BackgroundColor3 = keybindToggleObj.toggleValue and Color3.new(1, 1, 1) or Color3.fromRGB(75, 75, 75),
                    Position = keybindToggleObj.toggleValue and UDim2.new(0.462, 0, 0.143, 0) or UDim2.new(0.0104, 0, 0.143, 0),
                    Size = UDim2.new(0, 15 * mobileScaleFactor, 0, 15 * mobileScaleFactor), Parent = keybindToggleObj.toggleSwitchFrame
                })
                makeThingExist("UICorner", {CornerRadius = UDim.new(1, 0), Parent = keybindToggleObj.toggleCircleFrame})

                local toggleClickButton = makeThingExist("TextButton", {Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Parent = keybindToggleObj.toggleSwitchFrame})
                local keybindClickButton = makeThingExist("TextButton", {Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Parent = keybindToggleObj.keybindButtonFrame})

                function keybindToggleObj:SetToggle(value)
                    keybindToggleObj.toggleValue = value
                    if value then
                        smoothMoveGoWoosh(keybindToggleObj.toggleSwitchFrame, {BackgroundColor3 = groupObj.Library.config.AccentColor}, 0.2)
                        smoothMoveGoWoosh(keybindToggleObj.toggleCircleFrame, {Position = UDim2.new(0.462, 0, 0.143, 0), BackgroundColor3 = Color3.new(1, 1, 1)}, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                    else
                        smoothMoveGoWoosh(keybindToggleObj.toggleSwitchFrame, {BackgroundColor3 = Color3.fromRGB(32, 32, 32)}, 0.2)
                        smoothMoveGoWoosh(keybindToggleObj.toggleCircleFrame, {Position = UDim2.new(0.0104, 0, 0.143, 0), BackgroundColor3 = Color3.fromRGB(75, 75, 75)}, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                    end
                    keybindToggleConfig.ToggleCallback(value)
                end

                local function updateKeybindSizeYay(text)
                    local newWidth = math.max(48 * mobileScaleFactor, howWideIsThisText(text, 12 * mobileScaleFactor) + 30 * mobileScaleFactor)
                    smoothMoveGoWoosh(keybindToggleObj.keybindButtonFrame, {Size = UDim2.new(0, newWidth, 0, 21 * mobileScaleFactor), Position = UDim2.new(1, -newWidth - 10, 0, yPosition)}, 0.15)
                    smoothMoveGoWoosh(keybindToggleObj.toggleSwitchFrame, {Position = UDim2.new(1, -newWidth - 48 * mobileScaleFactor, 0, yPosition)}, 0.15)
                end

                function keybindToggleObj:SetKey(key)
                    keybindToggleObj.keyValue = key
                    local keyText = key == Enum.KeyCode.Unknown and "None" or key.Name
                    keybindToggleObj.keyLabelText.Text = keyText
                    updateKeybindSizeYay(keyText)
                    keybindToggleConfig.ChangedCallback(key)
                end

                function keybindToggleObj:GetKey()
                    return keybindToggleObj.keyValue
                end

                function keybindToggleObj:GetToggle()
                    return keybindToggleObj.toggleValue
                end

                toggleClickButton.MouseButton1Click:Connect(function() keybindToggleObj:SetToggle(not keybindToggleObj.toggleValue) end)
                keybindClickButton.MouseButton1Click:Connect(function()
                    keybindToggleObj.isListening = true
                    keybindToggleObj.keyLabelText.Text = "..."
                    updateKeybindSizeYay("...")
                    smoothMoveGoWoosh(keybindToggleObj.keybindButtonFrame, {BackgroundColor3 = Color3.fromRGB(48, 48, 48)}, 0.2)
                end)

                groupObj.Library:_TrackConnection(thisInputServiceGoesHard.InputBegan:Connect(function(input, gameProcessed)
                    if keybindToggleObj.isListening then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            keybindToggleObj.isListening = false
                            keybindToggleObj:SetKey(input.KeyCode)
                            smoothMoveGoWoosh(keybindToggleObj.keybindButtonFrame, {BackgroundColor3 = Color3.fromRGB(32, 32, 32)}, 0.2)
                        end
                    elseif not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
                        if input.KeyCode == keybindToggleObj.keyValue and keybindToggleObj.toggleValue then
                            keybindToggleConfig.Callback()
                        end
                    end
                end))

                keybindClickButton.MouseEnter:Connect(function() if not keybindToggleObj.isListening then smoothMoveGoWoosh(keybindToggleObj.keybindButtonFrame, {BackgroundColor3 = Color3.fromRGB(48, 48, 48)}, 0.2) end end)
                keybindClickButton.MouseLeave:Connect(function() if not keybindToggleObj.isListening then smoothMoveGoWoosh(keybindToggleObj.keybindButtonFrame, {BackgroundColor3 = Color3.fromRGB(32, 32, 32)}, 0.2) end end)

                if keybindToggleConfig.ToggleDefault then keybindToggleConfig.ToggleCallback(true) end
                groupObj.Library:RegisterControl(keybindToggleConfig.Flag, function()
                    return keybindToggleObj:GetKey()
                end, function(value)
                    if typeof(value) == "EnumItem" and value.EnumType == Enum.KeyCode then
                        keybindToggleObj:SetKey(value)
                    end
                end)
                groupObj.Library:RegisterControl(keybindToggleConfig.ToggleFlag, function()
                    return keybindToggleObj:GetToggle()
                end, function(value)
                    keybindToggleObj:SetToggle(value == true)
                end)
                groupObj.elementYPos = groupObj.elementYPos + 28 * mobileScaleFactor
                updateGroupSizeYay()
                table.insert(groupObj.elementsInGroup, keybindToggleObj)
                return keybindToggleObj
            end

            function groupObj:AddDropdown(dropdownConfig)
                dropdownConfig = dropdownConfig or {}
                dropdownConfig.Name = dropdownConfig.Name or "Dropdown"
                dropdownConfig.Options = dropdownConfig.Options or {"Option 1", "Option 2", "Option 3"}
                dropdownConfig.OptionsProvider = dropdownConfig.OptionsProvider or dropdownConfig.GetOptions
                dropdownConfig.AutoRefresh = dropdownConfig.AutoRefresh ~= false
                dropdownConfig.RefreshInterval = math.max(tonumber(dropdownConfig.RefreshInterval) or 0.85, 0.35)
                dropdownConfig.Callback = dropdownConfig.Callback or function() end
                dropdownConfig.Flag = dropdownConfig.Flag or createAutoFlag(dropdownConfig.Name)
                local dropdownOptionsSource = dropdownConfig.Options
                if type(dropdownConfig.OptionsProvider) == "function" then
                    local ok, providedOptions = pcall(dropdownConfig.OptionsProvider)
                    if ok and type(providedOptions) == "table" then
                        dropdownOptionsSource = providedOptions
                    end
                end
                dropdownConfig.Options = normalizeDropdownOptions(dropdownOptionsSource)
                dropdownConfig.Default = dropdownConfig.Default or dropdownConfig.Options[1] or "None"
                if not table.find(dropdownConfig.Options, dropdownConfig.Default) then
                    dropdownConfig.Default = dropdownConfig.Options[1] or "None"
                end
                addSearchTerm(dropdownConfig.Name)
                for _, option in ipairs(dropdownConfig.Options) do
                    addSearchTerm(tostring(option))
                end

                local dropdownObj = {}
                dropdownObj.value = dropdownConfig.Default
                dropdownObj.isOpen = false
                dropdownObj._optionsSignature = getDropdownOptionsSignature(dropdownOptionsSource)
                if dropdownObj._optionsSignature == "0" then
                    dropdownObj._optionsSignature = getDropdownOptionsSignature(dropdownConfig.Options)
                end
                local yPosition = groupObj.elementYPos

                dropdownObj.labelText = makeThingExist("TextLabel", {
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
                    TextColor3 = Color3.fromRGB(124, 124, 124), Text = dropdownConfig.Name, BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, yPosition), TextSize = 13 * mobileScaleFactor,
                    Size = UDim2.new(0, 130 * mobileScaleFactor, 0, 20 * mobileScaleFactor),
                    TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = groupObj.mainFrame
                })

                local displayText = tostring(dropdownObj.value or "None")
                local buttonWidth = math.max(70 * mobileScaleFactor, howWideIsThisText(displayText, 12 * mobileScaleFactor) + 30 * mobileScaleFactor)

                dropdownObj.buttonFrame = makeThingExist("Frame", {
                    BackgroundColor3 = Color3.fromRGB(32, 32, 32), Position = UDim2.new(1, -buttonWidth - 10, 0, yPosition),
                    Size = UDim2.new(0, buttonWidth, 0, 21 * mobileScaleFactor), Parent = groupObj.mainFrame
                })
                makeThingExist("UICorner", {CornerRadius = UDim.new(1, 0), Parent = dropdownObj.buttonFrame})

                local dropdownStrokeThing = makeThingExist("UIStroke", {Color = Color3.fromRGB(44, 44, 44), Parent = dropdownObj.buttonFrame})

                dropdownObj.selectedLabelText = makeThingExist("TextLabel", {
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
                    TextColor3 = Color3.fromRGB(84, 84, 84), Text = displayText, BackgroundTransparency = 1,
                    Position = UDim2.new(0, 8, 0, 0), TextSize = 12 * mobileScaleFactor,
                    Size = UDim2.new(1, -28 * mobileScaleFactor, 1, 0), TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd, Parent = dropdownObj.buttonFrame
                })

                dropdownObj.arrowImg = makeThingExist("ImageLabel", {
                    ImageColor3 = Color3.fromRGB(80, 80, 80), Image = "rbxassetid://111626678408582", BackgroundTransparency = 1,
                    Position = UDim2.new(1, -20 * mobileScaleFactor, 0.5, -7 * mobileScaleFactor),
                    Size = UDim2.new(0, 14 * mobileScaleFactor, 0, 14 * mobileScaleFactor), Parent = dropdownObj.buttonFrame
                })

                dropdownObj.optionHolderFrame = makeThingExist("Frame", {
                    BackgroundColor3 = Color3.fromRGB(16, 16, 16), Size = UDim2.new(0, 140 * mobileScaleFactor, 0, 0),
                    ClipsDescendants = true, Visible = false, ZIndex = 9999, Parent = groupObj.Library.dropdownHolderRef
                })
                makeThingExist("UICorner", {CornerRadius = UDim.new(0, 6), Parent = dropdownObj.optionHolderFrame})
                makeThingExist("UIStroke", {Color = Color3.fromRGB(40, 40, 40), Parent = dropdownObj.optionHolderFrame})

                makeThingExist("TextLabel", {
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
                    TextColor3 = Color3.new(1, 1, 1), Text = dropdownConfig.Name, BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 8 * mobileScaleFactor), TextSize = 14 * mobileScaleFactor,
                    Size = UDim2.new(1, -44 * mobileScaleFactor, 0, 20 * mobileScaleFactor), TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 10000, Parent = dropdownObj.optionHolderFrame
                })

                local dropdownCloseButton = makeThingExist("TextButton", {
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
                    Text = "X", TextColor3 = Color3.fromRGB(170, 170, 170), TextSize = 14 * mobileScaleFactor,
                    BackgroundColor3 = Color3.fromRGB(24, 24, 24), AutoButtonColor = false,
                    Position = UDim2.new(1, -25 * mobileScaleFactor, 0, 5 * mobileScaleFactor),
                    Size = UDim2.new(0, 18 * mobileScaleFactor, 0, 18 * mobileScaleFactor),
                    ZIndex = 10002, Parent = dropdownObj.optionHolderFrame
                })
                makeThingExist("UICorner", {CornerRadius = UDim.new(1, 0), Parent = dropdownCloseButton})

                dropdownObj.optionScrollFrame = makeThingExist("ScrollingFrame", {
                    BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 30 * mobileScaleFactor),
                    Size = UDim2.new(1, 0, 1, -35 * mobileScaleFactor), ScrollBarThickness = 3,
                    ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80), CanvasSize = UDim2.new(0, 0, 0, 0),
                    ZIndex = 10000, Parent = dropdownObj.optionHolderFrame
                })
                dropdownObj.optionScrollFrame:SetAttribute("FlowDisableSmoothScroll", true)

                dropdownObj.optionContainerFrame = makeThingExist("Frame", {
                    BackgroundTransparency = 1, Size = UDim2.new(1, -6, 0, 0),
                    ZIndex = 10000, Parent = dropdownObj.optionScrollFrame
                })

                local maxDropdownHeight = 200 * mobileScaleFactor
                local dropdownPositionUpdateConn = nil

                local function closeDropdown(isInstant)
                    dropdownObj.isOpen = false
                    if dropdownPositionUpdateConn then
                        dropdownPositionUpdateConn()
                        dropdownPositionUpdateConn = nil
                    end
                    if isInstant then
                        dropdownObj.optionHolderFrame.Size = UDim2.new(0, 140 * mobileScaleFactor, 0, 0)
                        dropdownObj.optionHolderFrame.Visible = false
                        dropdownObj.arrowImg.Rotation = 0
                        dropdownObj.buttonFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
                        dropdownStrokeThing.Color = Color3.fromRGB(44, 44, 44)
                        return
                    end
                    smoothMoveGoWoosh(dropdownObj.optionHolderFrame, {Size = UDim2.new(0, 140 * mobileScaleFactor, 0, 0)}, 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
                    smoothMoveGoWoosh(dropdownObj.arrowImg, {Rotation = 0}, 0.2)
                    smoothMoveGoWoosh(dropdownObj.buttonFrame, {BackgroundColor3 = Color3.fromRGB(32, 32, 32)}, 0.18)
                    smoothMoveGoWoosh(dropdownStrokeThing, {Color = Color3.fromRGB(44, 44, 44)}, 0.18)
                    task.delay(0.22, function()
                        if dropdownObj.optionHolderFrame.Parent and not dropdownObj.isOpen then
                            dropdownObj.optionHolderFrame.Visible = false
                        end
                    end)
                end

                dropdownCloseButton.MouseButton1Click:Connect(function()
                    closeDropdown(false)
                end)
                dropdownCloseButton.MouseEnter:Connect(function()
                    smoothMoveGoWoosh(dropdownCloseButton, {BackgroundColor3 = Color3.fromRGB(44, 44, 44), TextColor3 = Color3.fromRGB(220, 220, 220)}, 0.12)
                end)
                dropdownCloseButton.MouseLeave:Connect(function()
                    smoothMoveGoWoosh(dropdownCloseButton, {BackgroundColor3 = Color3.fromRGB(24, 24, 24), TextColor3 = Color3.fromRGB(138, 138, 138)}, 0.12)
                end)

                local function createOptionsYay()
                    for _, child in pairs(dropdownObj.optionContainerFrame:GetChildren()) do
                        if child:IsA("TextLabel") or child:IsA("TextButton") then child:Destroy() end
                    end
                    local optY = 0
                    for _, option in ipairs(dropdownConfig.Options) do
                        local isSelected = dropdownObj.value == option
                        local optionLabelText = makeThingExist("TextLabel", {
                            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
                            TextColor3 = isSelected and groupObj.Library.config.AccentColor or Color3.fromRGB(124, 124, 124),
                            Text = tostring(option), BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, optY),
                            TextSize = 14 * mobileScaleFactor, Size = UDim2.new(1, -24, 0, 18 * mobileScaleFactor),
                            TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
                            ZIndex = 10001, Parent = dropdownObj.optionContainerFrame
                        })
                        local optionClickButton = makeThingExist("TextButton", {
                            Text = "", BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, optY),
                            Size = UDim2.new(1, 0, 0, 20 * mobileScaleFactor), ZIndex = 10002, Parent = dropdownObj.optionContainerFrame
                        })
                        optionClickButton.MouseButton1Click:Connect(function()
                            dropdownObj.value = option
                            closeDropdown(false)
                            local optionText = tostring(option)
                            dropdownObj.selectedLabelText.Text = optionText
                            local newWidth = math.max(70 * mobileScaleFactor, howWideIsThisText(optionText, 12 * mobileScaleFactor) + 30 * mobileScaleFactor)
                            smoothMoveGoWoosh(dropdownObj.buttonFrame, {Size = UDim2.new(0, newWidth, 0, 21 * mobileScaleFactor), Position = UDim2.new(1, -newWidth - 10, 0, yPosition)}, 0.15)
                            createOptionsYay()
                            dropdownConfig.Callback(option)
                        end)
                        optionClickButton.MouseEnter:Connect(function() if dropdownObj.value ~= option then smoothMoveGoWoosh(optionLabelText, {TextColor3 = Color3.fromRGB(180, 180, 180)}, 0.2) end end)
                        optionClickButton.MouseLeave:Connect(function() if dropdownObj.value ~= option then smoothMoveGoWoosh(optionLabelText, {TextColor3 = Color3.fromRGB(124, 124, 124)}, 0.2) end end)
                        optY = optY + 22 * mobileScaleFactor
                    end
                    dropdownObj.optionContainerFrame.Size = UDim2.new(1, -6, 0, optY)
                    dropdownObj.optionScrollFrame.CanvasSize = UDim2.new(0, 0, 0, optY)
                end
                createOptionsYay()

                local dropdownClickButton = makeThingExist("TextButton", {Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Parent = dropdownObj.buttonFrame})

                local function updateDropdownPositionYay()
                    local buttonAbsPos = dropdownObj.buttonFrame.AbsolutePosition
                    local buttonAbsSize = dropdownObj.buttonFrame.AbsoluteSize
                    dropdownObj.optionHolderFrame.Position = UDim2.new(0, buttonAbsPos.X, 0, buttonAbsPos.Y + buttonAbsSize.Y + 5)
                end

                dropdownClickButton.MouseButton1Click:Connect(function()
                    dropdownObj.isOpen = not dropdownObj.isOpen
                    if dropdownObj.isOpen then
                        updateDropdownPositionYay()
                        dropdownObj.optionHolderFrame.Visible = true
                        local contentHeight = (35 + (#dropdownConfig.Options * 22)) * mobileScaleFactor
                        local height = math.min(contentHeight, maxDropdownHeight)
                        smoothMoveGoWoosh(dropdownObj.optionHolderFrame, {Size = UDim2.new(0, 140 * mobileScaleFactor, 0, height)}, 0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                        smoothMoveGoWoosh(dropdownObj.arrowImg, {Rotation = 180}, 0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                        if dropdownPositionUpdateConn then dropdownPositionUpdateConn() end
                        dropdownPositionUpdateConn = startFloatingPositionTracker(groupObj.Library, dropdownObj.buttonFrame, function()
                            if dropdownObj.isOpen then
                                updateDropdownPositionYay()
                            end
                        end)
                    else
                        closeDropdown(false)
                    end
                end)

                dropdownClickButton.MouseEnter:Connect(function()
                    smoothMoveGoWoosh(dropdownObj.buttonFrame, {BackgroundColor3 = Color3.fromRGB(48, 48, 48)}, 0.2)
                    smoothMoveGoWoosh(dropdownStrokeThing, {Color = Color3.fromRGB(83, 83, 83)}, 0.2)
                end)
                dropdownClickButton.MouseLeave:Connect(function()
                    if not dropdownObj.isOpen then
                        smoothMoveGoWoosh(dropdownObj.buttonFrame, {BackgroundColor3 = Color3.fromRGB(32, 32, 32)}, 0.2)
                        smoothMoveGoWoosh(dropdownStrokeThing, {Color = Color3.fromRGB(44, 44, 44)}, 0.2)
                    end
                end)

                function dropdownObj:Set(value)
                    if value == nil then return end
                    dropdownObj.value = value
                    local displayValue = tostring(value)
                    dropdownObj.selectedLabelText.Text = displayValue
                    local newWidth = math.max(70 * mobileScaleFactor, howWideIsThisText(displayValue, 12 * mobileScaleFactor) + 30 * mobileScaleFactor)
                    dropdownObj.buttonFrame.Size = UDim2.new(0, newWidth, 0, 21 * mobileScaleFactor)
                    dropdownObj.buttonFrame.Position = UDim2.new(1, -newWidth - 10, 0, yPosition)
                    createOptionsYay()
                    dropdownConfig.Callback(value)
                end

                function dropdownObj:Get()
                    return dropdownObj.value
                end

                function dropdownObj:UpdateOptions(newOptions)
                    if type(newOptions) ~= "table" then
                        return
                    end
                    dropdownOptionsSource = newOptions
                    dropdownObj._optionsSignature = getDropdownOptionsSignature(newOptions)
                    dropdownConfig.Options = normalizeDropdownOptions(newOptions)
                    for _, option in ipairs(dropdownConfig.Options) do
                        addSearchTerm(tostring(option))
                    end
                    if not table.find(dropdownConfig.Options, dropdownObj.value) then
                        dropdownObj.value = dropdownConfig.Options[1] or "None"
                    end
                    local displayValue = tostring(dropdownObj.value or "None")
                    dropdownObj.selectedLabelText.Text = displayValue
                    local newWidth = math.max(70 * mobileScaleFactor, howWideIsThisText(displayValue, 12 * mobileScaleFactor) + 30 * mobileScaleFactor)
                    dropdownObj.buttonFrame.Size = UDim2.new(0, newWidth, 0, 21 * mobileScaleFactor)
                    dropdownObj.buttonFrame.Position = UDim2.new(1, -newWidth - 10, 0, yPosition)
                    createOptionsYay()
                    if groupObj.Library._searchQuery ~= "" then
                        groupObj.Library:ApplySearchFilter(groupObj.Library._searchQuery)
                    end
                end

                if dropdownConfig.AutoRefresh then
                    task.spawn(function()
                        while not groupObj.Library._destroyed and dropdownObj.buttonFrame and dropdownObj.buttonFrame.Parent do
                            local latestOptions = dropdownOptionsSource
                            if type(dropdownConfig.OptionsProvider) == "function" then
                                local ok, providedOptions = pcall(dropdownConfig.OptionsProvider)
                                if ok and type(providedOptions) == "table" then
                                    latestOptions = providedOptions
                                end
                            end
                            local latestSignature = getDropdownOptionsSignature(latestOptions)
                            if latestSignature ~= dropdownObj._optionsSignature then
                                dropdownObj:UpdateOptions(latestOptions)
                            end
                            task.wait(dropdownConfig.RefreshInterval)
                        end
                    end)
                end

                function dropdownObj:Close()
                    closeDropdown(true)
                end
                groupObj.Library:RegisterControl(dropdownConfig.Flag, function()
                    return dropdownObj:Get()
                end, function(value)
                    if value ~= nil then
                        dropdownObj:Set(value)
                    end
                end)

                groupObj.elementYPos = groupObj.elementYPos + 28 * mobileScaleFactor
                updateGroupSizeYay()
                table.insert(groupObj.elementsInGroup, dropdownObj)
                return dropdownObj
            end

            function groupObj:AddMultiDropdown(multiDropdownConfig)
                multiDropdownConfig = multiDropdownConfig or {}
                multiDropdownConfig.Name = multiDropdownConfig.Name or "Multi Dropdown"
                multiDropdownConfig.Options = multiDropdownConfig.Options or {"Option 1", "Option 2", "Option 3"}
                multiDropdownConfig.OptionsProvider = multiDropdownConfig.OptionsProvider or multiDropdownConfig.GetOptions
                multiDropdownConfig.AutoRefresh = multiDropdownConfig.AutoRefresh ~= false
                multiDropdownConfig.RefreshInterval = math.max(tonumber(multiDropdownConfig.RefreshInterval) or 0.85, 0.35)
                multiDropdownConfig.Default = multiDropdownConfig.Default or {}
                multiDropdownConfig.Callback = multiDropdownConfig.Callback or function() end
                multiDropdownConfig.Flag = multiDropdownConfig.Flag or createAutoFlag(multiDropdownConfig.Name)
                local multiDropdownOptionsSource = multiDropdownConfig.Options
                if type(multiDropdownConfig.OptionsProvider) == "function" then
                    local ok, providedOptions = pcall(multiDropdownConfig.OptionsProvider)
                    if ok and type(providedOptions) == "table" then
                        multiDropdownOptionsSource = providedOptions
                    end
                end
                multiDropdownConfig.Options = normalizeDropdownOptions(multiDropdownOptionsSource)
                addSearchTerm(multiDropdownConfig.Name)
                for _, option in ipairs(multiDropdownConfig.Options) do
                    addSearchTerm(tostring(option))
                end

                local multiDropdownObj = {}
                multiDropdownObj.selectedValues = {}
                for _, v in ipairs(multiDropdownConfig.Default) do
                    if table.find(multiDropdownConfig.Options, v) then
                        multiDropdownObj.selectedValues[v] = true
                    end
                end
                multiDropdownObj.isOpen = false
                multiDropdownObj._optionsSignature = getDropdownOptionsSignature(multiDropdownOptionsSource)
                if multiDropdownObj._optionsSignature == "0" then
                    multiDropdownObj._optionsSignature = getDropdownOptionsSignature(multiDropdownConfig.Options)
                end
                local yPosition = groupObj.elementYPos

                multiDropdownObj.labelText = makeThingExist("TextLabel", {
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
                    TextColor3 = Color3.fromRGB(124, 124, 124), Text = multiDropdownConfig.Name, BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, yPosition), TextSize = 14 * mobileScaleFactor,
                    Size = UDim2.new(0, 100 * mobileScaleFactor, 0, 20 * mobileScaleFactor),
                    TextXAlignment = Enum.TextXAlignment.Left, Parent = groupObj.mainFrame
                })

                local function getDisplayText()
                    local selected = {}
                    for option, isSelected in pairs(multiDropdownObj.selectedValues) do
                        if isSelected then table.insert(selected, option) end
                    end
                    table.sort(selected, function(a, b)
                        return tostring(a) < tostring(b)
                    end)
                    if #selected == 0 then return "None"
                    elseif #selected == 1 then return selected[1]
                    elseif #selected <= 2 then return table.concat(selected, ", ")
                    else return #selected .. " selected" end
                end

                local function getSelectedArray()
                    local arr = {}
                    for option, isSelected in pairs(multiDropdownObj.selectedValues) do
                        if isSelected then table.insert(arr, option) end
                    end
                    table.sort(arr, function(a, b)
                        return tostring(a) < tostring(b)
                    end)
                    return arr
                end

                local displayText = getDisplayText()
                local buttonWidth = math.max(85 * mobileScaleFactor, howWideIsThisText(displayText, 12 * mobileScaleFactor) + 35 * mobileScaleFactor)

                multiDropdownObj.buttonFrame = makeThingExist("Frame", {
                    BackgroundColor3 = Color3.fromRGB(32, 32, 32), Position = UDim2.new(1, -buttonWidth - 10, 0, yPosition),
                    Size = UDim2.new(0, buttonWidth, 0, 21 * mobileScaleFactor), Parent = groupObj.mainFrame
                })
                makeThingExist("UICorner", {CornerRadius = UDim.new(1, 0), Parent = multiDropdownObj.buttonFrame})

                local dropdownStrokeThing = makeThingExist("UIStroke", {Color = Color3.fromRGB(44, 44, 44), Parent = multiDropdownObj.buttonFrame})

                multiDropdownObj.selectedLabelText = makeThingExist("TextLabel", {
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
                    TextColor3 = Color3.fromRGB(84, 84, 84), Text = displayText, BackgroundTransparency = 1,
                    Position = UDim2.new(0, 8, 0, 0), TextSize = 12 * mobileScaleFactor,
                    Size = UDim2.new(1, -28 * mobileScaleFactor, 1, 0), TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd, Parent = multiDropdownObj.buttonFrame
                })

                multiDropdownObj.arrowImg = makeThingExist("ImageLabel", {
                    ImageColor3 = Color3.fromRGB(80, 80, 80), Image = "rbxassetid://111626678408582", BackgroundTransparency = 1,
                    Position = UDim2.new(1, -20 * mobileScaleFactor, 0.5, -7 * mobileScaleFactor),
                    Size = UDim2.new(0, 14 * mobileScaleFactor, 0, 14 * mobileScaleFactor), Parent = multiDropdownObj.buttonFrame
                })

                multiDropdownObj.optionHolderFrame = makeThingExist("Frame", {
                    BackgroundColor3 = Color3.fromRGB(16, 16, 16), Size = UDim2.new(0, 160 * mobileScaleFactor, 0, 0),
                    ClipsDescendants = true, Visible = false, ZIndex = 9999, Parent = groupObj.Library.dropdownHolderRef
                })
                makeThingExist("UICorner", {CornerRadius = UDim.new(0, 6), Parent = multiDropdownObj.optionHolderFrame})
                makeThingExist("UIStroke", {Color = Color3.fromRGB(40, 40, 40), Parent = multiDropdownObj.optionHolderFrame})

                makeThingExist("TextLabel", {
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
                    TextColor3 = Color3.new(1, 1, 1), Text = multiDropdownConfig.Name, BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 8 * mobileScaleFactor), TextSize = 14 * mobileScaleFactor,
                    Size = UDim2.new(1, -44 * mobileScaleFactor, 0, 20 * mobileScaleFactor), TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 10000, Parent = multiDropdownObj.optionHolderFrame
                })

                local multiDropdownCloseButton = makeThingExist("TextButton", {
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
                    Text = "X", TextColor3 = Color3.fromRGB(170, 170, 170), TextSize = 14 * mobileScaleFactor,
                    BackgroundColor3 = Color3.fromRGB(24, 24, 24), AutoButtonColor = false,
                    Position = UDim2.new(1, -25 * mobileScaleFactor, 0, 5 * mobileScaleFactor),
                    Size = UDim2.new(0, 18 * mobileScaleFactor, 0, 18 * mobileScaleFactor),
                    ZIndex = 10002, Parent = multiDropdownObj.optionHolderFrame
                })
                makeThingExist("UICorner", {CornerRadius = UDim.new(1, 0), Parent = multiDropdownCloseButton})

                multiDropdownObj.optionScrollFrame = makeThingExist("ScrollingFrame", {
                    BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 30 * mobileScaleFactor),
                    Size = UDim2.new(1, 0, 1, -35 * mobileScaleFactor), ScrollBarThickness = 3,
                    ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80), CanvasSize = UDim2.new(0, 0, 0, 0),
                    ZIndex = 10000, Parent = multiDropdownObj.optionHolderFrame
                })
                multiDropdownObj.optionScrollFrame:SetAttribute("FlowDisableSmoothScroll", true)

                multiDropdownObj.optionContainerFrame = makeThingExist("Frame", {
                    BackgroundTransparency = 1, Size = UDim2.new(1, -6, 0, 0),
                    ZIndex = 10000, Parent = multiDropdownObj.optionScrollFrame
                })

                local maxMultiDropdownHeight = 220 * mobileScaleFactor
                local multiDropdownPositionConn = nil

                local function closeMultiDropdown(isInstant)
                    multiDropdownObj.isOpen = false
                    if multiDropdownPositionConn then
                        multiDropdownPositionConn()
                        multiDropdownPositionConn = nil
                    end
                    if isInstant then
                        multiDropdownObj.optionHolderFrame.Size = UDim2.new(0, 160 * mobileScaleFactor, 0, 0)
                        multiDropdownObj.optionHolderFrame.Visible = false
                        multiDropdownObj.arrowImg.Rotation = 0
                        multiDropdownObj.buttonFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
                        dropdownStrokeThing.Color = Color3.fromRGB(44, 44, 44)
                        return
                    end
                    smoothMoveGoWoosh(multiDropdownObj.optionHolderFrame, {Size = UDim2.new(0, 160 * mobileScaleFactor, 0, 0)}, 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
                    smoothMoveGoWoosh(multiDropdownObj.arrowImg, {Rotation = 0}, 0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
                    smoothMoveGoWoosh(multiDropdownObj.buttonFrame, {BackgroundColor3 = Color3.fromRGB(32, 32, 32)}, 0.18)
                    smoothMoveGoWoosh(dropdownStrokeThing, {Color = Color3.fromRGB(44, 44, 44)}, 0.18)
                    task.delay(0.22, function()
                        if multiDropdownObj.optionHolderFrame.Parent and not multiDropdownObj.isOpen then
                            multiDropdownObj.optionHolderFrame.Visible = false
                        end
                    end)
                end

                multiDropdownCloseButton.MouseButton1Click:Connect(function()
                    closeMultiDropdown(false)
                end)
                multiDropdownCloseButton.MouseEnter:Connect(function()
                    smoothMoveGoWoosh(multiDropdownCloseButton, {BackgroundColor3 = Color3.fromRGB(44, 44, 44), TextColor3 = Color3.fromRGB(220, 220, 220)}, 0.12)
                end)
                multiDropdownCloseButton.MouseLeave:Connect(function()
                    smoothMoveGoWoosh(multiDropdownCloseButton, {BackgroundColor3 = Color3.fromRGB(24, 24, 24), TextColor3 = Color3.fromRGB(138, 138, 138)}, 0.12)
                end)

                local function createMultiOptionsYay()
                    for _, child in pairs(multiDropdownObj.optionContainerFrame:GetChildren()) do
                        if child:IsA("Frame") or child:IsA("TextButton") then child:Destroy() end
                    end
                    local optY = 0
                    for _, option in ipairs(multiDropdownConfig.Options) do
                        local isSelected = multiDropdownObj.selectedValues[option] == true

                        local optionFrame = makeThingExist("Frame", {
                            BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, optY),
                            Size = UDim2.new(1, 0, 0, 22 * mobileScaleFactor), ZIndex = 10001,
                            Parent = multiDropdownObj.optionContainerFrame
                        })

                        local checkboxFrame = makeThingExist("Frame", {
                            BackgroundColor3 = isSelected and groupObj.Library.config.AccentColor or Color3.fromRGB(32, 32, 32),
                            Position = UDim2.new(0, 12, 0.5, -8 * mobileScaleFactor),
                            Size = UDim2.new(0, 16 * mobileScaleFactor, 0, 16 * mobileScaleFactor),
                            ZIndex = 10002, Parent = optionFrame
                        })
                        makeThingExist("UICorner", {CornerRadius = UDim.new(0, 4), Parent = checkboxFrame})

                        local checkmarkImg = makeThingExist("ImageLabel", {
                            Image = "rbxassetid://10709790644", ImageColor3 = Color3.new(1, 1, 1),
                            ImageTransparency = isSelected and 0 or 1, BackgroundTransparency = 1,
                            Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5),
                            Size = UDim2.new(0, 12 * mobileScaleFactor, 0, 12 * mobileScaleFactor),
                            ZIndex = 10003, Parent = checkboxFrame
                        })

                        local optionLabelText = makeThingExist("TextLabel", {
                            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
                            TextColor3 = isSelected and groupObj.Library.config.AccentColor or Color3.fromRGB(124, 124, 124),
                            Text = tostring(option), BackgroundTransparency = 1, Position = UDim2.new(0, 34, 0, 0),
                            TextSize = 14 * mobileScaleFactor, Size = UDim2.new(1, -46, 1, 0),
                            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 10002, Parent = optionFrame
                        })

                        local optionClickButton = makeThingExist("TextButton", {
                            Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
                            ZIndex = 10004, Parent = optionFrame
                        })

                        optionClickButton.MouseButton1Click:Connect(function()
                            multiDropdownObj.selectedValues[option] = not multiDropdownObj.selectedValues[option]
                            local nowSelected = multiDropdownObj.selectedValues[option]

                            smoothMoveGoWoosh(checkboxFrame, {BackgroundColor3 = nowSelected and groupObj.Library.config.AccentColor or Color3.fromRGB(32, 32, 32)}, 0.15)
                            smoothMoveGoWoosh(checkmarkImg, {ImageTransparency = nowSelected and 0 or 1}, 0.15)
                            smoothMoveGoWoosh(optionLabelText, {TextColor3 = nowSelected and groupObj.Library.config.AccentColor or Color3.fromRGB(124, 124, 124)}, 0.15)

                            local newDisplayText = getDisplayText()
                            multiDropdownObj.selectedLabelText.Text = newDisplayText
                            local newWidth = math.max(85 * mobileScaleFactor, howWideIsThisText(newDisplayText, 12 * mobileScaleFactor) + 35 * mobileScaleFactor)
                            smoothMoveGoWoosh(multiDropdownObj.buttonFrame, {Size = UDim2.new(0, newWidth, 0, 21 * mobileScaleFactor), Position = UDim2.new(1, -newWidth - 10, 0, yPosition)}, 0.15)

                            multiDropdownConfig.Callback(getSelectedArray())
                        end)

                        optionClickButton.MouseEnter:Connect(function()
                            if not multiDropdownObj.selectedValues[option] then
                                smoothMoveGoWoosh(optionLabelText, {TextColor3 = Color3.fromRGB(180, 180, 180)}, 0.15)
                                smoothMoveGoWoosh(checkboxFrame, {BackgroundColor3 = Color3.fromRGB(48, 48, 48)}, 0.15)
                            end
                        end)
                        optionClickButton.MouseLeave:Connect(function()
                            if not multiDropdownObj.selectedValues[option] then
                                smoothMoveGoWoosh(optionLabelText, {TextColor3 = Color3.fromRGB(124, 124, 124)}, 0.15)
                                smoothMoveGoWoosh(checkboxFrame, {BackgroundColor3 = Color3.fromRGB(32, 32, 32)}, 0.15)
                            end
                        end)

                        optY = optY + 24 * mobileScaleFactor
                    end
                    multiDropdownObj.optionContainerFrame.Size = UDim2.new(1, -6, 0, optY)
                    multiDropdownObj.optionScrollFrame.CanvasSize = UDim2.new(0, 0, 0, optY)
                end
                createMultiOptionsYay()

                local dropdownClickButton = makeThingExist("TextButton", {Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Parent = multiDropdownObj.buttonFrame})

                local function updateDropdownPositionYay()
                    local buttonAbsPos = multiDropdownObj.buttonFrame.AbsolutePosition
                    local buttonAbsSize = multiDropdownObj.buttonFrame.AbsoluteSize
                    multiDropdownObj.optionHolderFrame.Position = UDim2.new(0, buttonAbsPos.X, 0, buttonAbsPos.Y + buttonAbsSize.Y + 5)
                end

                dropdownClickButton.MouseButton1Click:Connect(function()
                    multiDropdownObj.isOpen = not multiDropdownObj.isOpen
                    if multiDropdownObj.isOpen then
                        updateDropdownPositionYay()
                        multiDropdownObj.optionHolderFrame.Visible = true
                        local contentHeight = (38 + (#multiDropdownConfig.Options * 24)) * mobileScaleFactor
                        local height = math.min(contentHeight, maxMultiDropdownHeight)
                        smoothMoveGoWoosh(multiDropdownObj.optionHolderFrame, {Size = UDim2.new(0, 160 * mobileScaleFactor, 0, height)}, 0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                        smoothMoveGoWoosh(multiDropdownObj.arrowImg, {Rotation = 180}, 0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                        if multiDropdownPositionConn then multiDropdownPositionConn() end
                        multiDropdownPositionConn = startFloatingPositionTracker(groupObj.Library, multiDropdownObj.buttonFrame, function()
                            if multiDropdownObj.isOpen then
                                updateDropdownPositionYay()
                            end
                        end)
                    else
                        closeMultiDropdown(false)
                    end
                end)

                dropdownClickButton.MouseEnter:Connect(function()
                    smoothMoveGoWoosh(multiDropdownObj.buttonFrame, {BackgroundColor3 = Color3.fromRGB(48, 48, 48)}, 0.2)
                    smoothMoveGoWoosh(dropdownStrokeThing, {Color = Color3.fromRGB(83, 83, 83)}, 0.2)
                end)
                dropdownClickButton.MouseLeave:Connect(function()
                    if not multiDropdownObj.isOpen then
                        smoothMoveGoWoosh(multiDropdownObj.buttonFrame, {BackgroundColor3 = Color3.fromRGB(32, 32, 32)}, 0.2)
                        smoothMoveGoWoosh(dropdownStrokeThing, {Color = Color3.fromRGB(44, 44, 44)}, 0.2)
                    end
                end)

                function multiDropdownObj:Set(values)
                    if type(values) ~= "table" then
                        values = {}
                    end
                    multiDropdownObj.selectedValues = {}
                    for _, v in ipairs(values) do
                        if table.find(multiDropdownConfig.Options, v) then
                            multiDropdownObj.selectedValues[v] = true
                        end
                    end
                    local newDisplayText = getDisplayText()
                    multiDropdownObj.selectedLabelText.Text = newDisplayText
                    local newWidth = math.max(85 * mobileScaleFactor, howWideIsThisText(newDisplayText, 12 * mobileScaleFactor) + 35 * mobileScaleFactor)
                    multiDropdownObj.buttonFrame.Size = UDim2.new(0, newWidth, 0, 21 * mobileScaleFactor)
                    multiDropdownObj.buttonFrame.Position = UDim2.new(1, -newWidth - 10, 0, yPosition)
                    createMultiOptionsYay()
                    multiDropdownConfig.Callback(getSelectedArray())
                end

                function multiDropdownObj:UpdateOptions(newOptions)
                    if type(newOptions) ~= "table" then
                        return
                    end
                    multiDropdownOptionsSource = newOptions
                    multiDropdownObj._optionsSignature = getDropdownOptionsSignature(newOptions)
                    multiDropdownConfig.Options = normalizeDropdownOptions(newOptions)
                    for _, option in ipairs(multiDropdownConfig.Options) do
                        addSearchTerm(tostring(option))
                    end
                    local filteredSelectedValues = {}
                    for option, isSelected in pairs(multiDropdownObj.selectedValues) do
                        if isSelected and table.find(multiDropdownConfig.Options, option) then
                            filteredSelectedValues[option] = true
                        end
                    end
                    multiDropdownObj.selectedValues = filteredSelectedValues
                    local newDisplayText = getDisplayText()
                    multiDropdownObj.selectedLabelText.Text = newDisplayText
                    local newWidth = math.max(85 * mobileScaleFactor, howWideIsThisText(newDisplayText, 12 * mobileScaleFactor) + 35 * mobileScaleFactor)
                    multiDropdownObj.buttonFrame.Size = UDim2.new(0, newWidth, 0, 21 * mobileScaleFactor)
                    multiDropdownObj.buttonFrame.Position = UDim2.new(1, -newWidth - 10, 0, yPosition)
                    createMultiOptionsYay()
                    if groupObj.Library._searchQuery ~= "" then
                        groupObj.Library:ApplySearchFilter(groupObj.Library._searchQuery)
                    end
                end

                if multiDropdownConfig.AutoRefresh then
                    task.spawn(function()
                        while not groupObj.Library._destroyed and multiDropdownObj.buttonFrame and multiDropdownObj.buttonFrame.Parent do
                            local latestOptions = multiDropdownOptionsSource
                            if type(multiDropdownConfig.OptionsProvider) == "function" then
                                local ok, providedOptions = pcall(multiDropdownConfig.OptionsProvider)
                                if ok and type(providedOptions) == "table" then
                                    latestOptions = providedOptions
                                end
                            end
                            local latestSignature = getDropdownOptionsSignature(latestOptions)
                            if latestSignature ~= multiDropdownObj._optionsSignature then
                                multiDropdownObj:UpdateOptions(latestOptions)
                            end
                            task.wait(multiDropdownConfig.RefreshInterval)
                        end
                    end)
                end

                function multiDropdownObj:Get() return getSelectedArray() end

                function multiDropdownObj:Close()
                    closeMultiDropdown(true)
                end
                groupObj.Library:RegisterControl(multiDropdownConfig.Flag, function()
                    return multiDropdownObj:Get()
                end, function(value)
                    if type(value) == "table" then
                        multiDropdownObj:Set(value)
                    end
                end)

                if #multiDropdownConfig.Default > 0 then multiDropdownConfig.Callback(getSelectedArray()) end
                groupObj.elementYPos = groupObj.elementYPos + 28 * mobileScaleFactor
                updateGroupSizeYay()
                table.insert(groupObj.elementsInGroup, multiDropdownObj)
                return multiDropdownObj
            end

            function groupObj:AddDivider()
                local yPosition = groupObj.elementYPos
                local dividerFrame = makeThingExist("Frame", {
                    BackgroundColor3 = Color3.fromRGB(36, 36, 36),
                    Position = UDim2.new(0, 10, 0, yPosition + 4 * mobileScaleFactor),
                    Size = UDim2.new(0.92, 0, 0, 1), Parent = groupObj.mainFrame
                })
                makeThingExist("UIGradient", {
                    Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(108, 108, 108)), ColorSequenceKeypoint.new(0.514, Color3.new(1, 1, 1)), ColorSequenceKeypoint.new(1, Color3.fromRGB(108, 108, 108))}),
                    Parent = dividerFrame
                })
                groupObj.elementYPos = groupObj.elementYPos + 12 * mobileScaleFactor
                updateGroupSizeYay()
                return dividerFrame
            end

            function groupObj:AddLabel(labelConfig)
                labelConfig = labelConfig or {}
                labelConfig.Text = labelConfig.Text or "Label"
                labelConfig.Wrap = labelConfig.Wrap == true
                addSearchTerm(labelConfig.Text)
                local yPosition = groupObj.elementYPos
                local labelMaxWidth = 238 * mobileScaleFactor
                local labelTextSize = 14 * mobileScaleFactor
                local measuredBounds = textServiceBeLikeText:GetTextSize(
                    tostring(labelConfig.Text),
                    labelTextSize,
                    Enum.Font.GothamSemibold,
                    Vector2.new(labelMaxWidth, labelConfig.Wrap and math.huge or (labelTextSize + 4))
                )
                local labelHeight = labelConfig.Wrap and math.max(20 * mobileScaleFactor, measuredBounds.Y) or (20 * mobileScaleFactor)
                local labelText = makeThingExist("TextLabel", {
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
                    TextColor3 = Color3.fromRGB(124, 124, 124), Text = labelConfig.Text, BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, yPosition), TextSize = labelTextSize,
                    Size = UDim2.new(0, labelMaxWidth, 0, labelHeight), TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = labelConfig.Wrap,
                    TextTruncate = labelConfig.Wrap and Enum.TextTruncate.None or Enum.TextTruncate.AtEnd,
                    ClipsDescendants = true,
                    Parent = groupObj.mainFrame
                })
                groupObj.elementYPos = groupObj.elementYPos + labelHeight + 6 * mobileScaleFactor
                updateGroupSizeYay()
                return labelText
            end

            function groupObj:AddTextInput(textInputConfig)
                textInputConfig = textInputConfig or {}
                textInputConfig.Name = textInputConfig.Name or "Input"
                textInputConfig.Placeholder = textInputConfig.Placeholder or "Enter text..."
                textInputConfig.Default = tostring(textInputConfig.Default or "")
                textInputConfig.Callback = textInputConfig.Callback or function() end
                textInputConfig.Flag = textInputConfig.Flag or createAutoFlag(textInputConfig.Name)
                addSearchTerm(textInputConfig.Name)
                addSearchTerm(textInputConfig.Placeholder)

                local textInputObj = {}
                textInputObj.value = textInputConfig.Default
                textInputObj.Flag = textInputConfig.Flag
                textInputObj.Name = textInputConfig.Name
                local yPosition = groupObj.elementYPos

                textInputObj.labelText = makeThingExist("TextLabel", {
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
                    TextColor3 = Color3.fromRGB(124, 124, 124), Text = textInputConfig.Name, BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, yPosition), TextSize = 14 * mobileScaleFactor,
                    Size = UDim2.new(0, 80 * mobileScaleFactor, 0, 20 * mobileScaleFactor),
                    TextXAlignment = Enum.TextXAlignment.Left, Parent = groupObj.mainFrame
                })

                textInputObj.inputFrame = makeThingExist("Frame", {
                    BackgroundColor3 = Color3.fromRGB(32, 32, 32),
                    Position = UDim2.new(0, 10, 0, yPosition + 22 * mobileScaleFactor),
                    Size = UDim2.new(0, 238 * mobileScaleFactor, 0, 26 * mobileScaleFactor),
                    Parent = groupObj.mainFrame
                })
                makeThingExist("UICorner", {CornerRadius = UDim.new(0, 6), Parent = textInputObj.inputFrame})
                makeThingExist("UIStroke", {Color = Color3.fromRGB(44, 44, 44), Parent = textInputObj.inputFrame})

                textInputObj.textBox = makeThingExist("TextBox", {
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
                    PlaceholderText = textInputConfig.Placeholder,
                    PlaceholderColor3 = Color3.fromRGB(80, 80, 80),
                    Text = textInputConfig.Default,
                    TextColor3 = Color3.fromRGB(200, 200, 200),
                    TextSize = 13 * mobileScaleFactor,
                    BackgroundTransparency = 1,
                    ClearTextOnFocus = false,
                    Position = UDim2.new(0, 8, 0, 0),
                    Size = UDim2.new(1, -16, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = textInputObj.inputFrame
                })

                textInputObj.textBox.Focused:Connect(function()
                    smoothMoveGoWoosh(textInputObj.inputFrame, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.2)
                end)

                textInputObj.textBox.FocusLost:Connect(function(enterPressed)
                    smoothMoveGoWoosh(textInputObj.inputFrame, {BackgroundColor3 = Color3.fromRGB(32, 32, 32)}, 0.2)
                    textInputObj.value = textInputObj.textBox.Text
                    textInputConfig.Callback(textInputObj.value, enterPressed)
                end)

                function textInputObj:Set(text)
                    local asString = tostring(text or "")
                    textInputObj.value = asString
                    textInputObj.textBox.Text = asString
                end

                function textInputObj:Get()
                    return textInputObj.value
                end

                function textInputObj:GetValue()
                    return textInputObj:Get()
                end

                function textInputObj:SetValue(text, silent)
                    textInputObj:Set(tostring(text or ""))
                    if not silent then
                        textInputConfig.Callback(textInputObj.value, false)
                    end
                end

                function textInputObj:ResetValue()
                    textInputObj:Set(textInputConfig.Default)
                end

                groupObj.Library:RegisterControl(textInputConfig.Flag, function()
                    return textInputObj:Get()
                end, function(value)
                    textInputObj:Set(tostring(value or ""))
                    textInputConfig.Callback(textInputObj.value, false)
                end)

                groupObj.elementYPos = groupObj.elementYPos + 54 * mobileScaleFactor
                updateGroupSizeYay()
                table.insert(groupObj.elementsInGroup, textInputObj)
                return textInputObj
            end

            function groupObj:AddTextbox(textboxConfig)
                textboxConfig = textboxConfig or {}

                local primaryCallback = textboxConfig.Callback
                if type(primaryCallback) ~= "function" then
                    primaryCallback = textboxConfig.Function
                end
                if type(primaryCallback) ~= "function" then
                    primaryCallback = function() end
                end

                local changedCallback = textboxConfig.ChangedCallback or textboxConfig.OnChanged
                local signalCallback = textboxConfig.OnPressed or textboxConfig.Signal
                local enterOnly = textboxConfig.EnterOnly == true
                local defaultText = tostring(textboxConfig.Default or textboxConfig.Value or "")

                local function fireTextboxCallbacks(value, enterPressed)
                    if enterOnly and not enterPressed then
                        return
                    end
                    primaryCallback(value, enterPressed)
                    if type(changedCallback) == "function" then
                        changedCallback(value, enterPressed)
                    end
                    if type(signalCallback) == "function" then
                        signalCallback(value, enterPressed)
                    end
                end

                local function fireTextboxCallbacksForced(value, enterPressed)
                    primaryCallback(value, enterPressed)
                    if type(changedCallback) == "function" then
                        changedCallback(value, enterPressed)
                    end
                    if type(signalCallback) == "function" then
                        signalCallback(value, enterPressed)
                    end
                end

                local textInputObj = groupObj:AddTextInput({
                    Name = textboxConfig.Name or textboxConfig.Title or textboxConfig.Text or "Textbox",
                    Placeholder = textboxConfig.Placeholder or textboxConfig.PlaceholderText or textboxConfig.Hint or "Enter text...",
                    Default = defaultText,
                    Callback = fireTextboxCallbacks,
                    Flag = textboxConfig.Flag or textboxConfig.ConfigId
                })

                textInputObj.Title = textboxConfig.Title or textboxConfig.Text or textboxConfig.Name or "Textbox"
                textInputObj.ConfigId = tostring(textboxConfig.ConfigId or textInputObj.Flag or textInputObj.Title)
                textInputObj.Box = textInputObj.textBox

                local baseSetValue = textInputObj.SetValue
                function textInputObj:SetValue(text, silent)
                    baseSetValue(self, text, true)
                    if not silent then
                        fireTextboxCallbacksForced(self:Get(), false)
                    end
                end

                return textInputObj
            end

            function groupObj:AddTextBox(textboxConfig)
                return groupObj:AddTextbox(textboxConfig)
            end

            function groupObj:AddColorPicker(colorPickerConfig)
                colorPickerConfig = colorPickerConfig or {}
                colorPickerConfig.Name = colorPickerConfig.Name or "Color"
                colorPickerConfig.Default = colorPickerConfig.Default or Color3.fromRGB(255, 100, 150)
                colorPickerConfig.Callback = colorPickerConfig.Callback or function() end
                colorPickerConfig.Flag = colorPickerConfig.Flag or createAutoFlag(colorPickerConfig.Name)
                addSearchTerm(colorPickerConfig.Name)

                local colorPickerObj = {}
                colorPickerObj.value = colorPickerConfig.Default
                colorPickerObj.isOpen = false
                local yPosition = groupObj.elementYPos

                local function rgbToHsv(color)
                    local r, g, b = color.R, color.G, color.B
                    local max, min = math.max(r, g, b), math.min(r, g, b)
                    local h, s, v = 0, 0, max
                    local d = max - min
                    s = max == 0 and 0 or d / max
                    if max ~= min then
                        if max == r then h = (g - b) / d + (g < b and 6 or 0)
                        elseif max == g then h = (b - r) / d + 2
                        elseif max == b then h = (r - g) / d + 4 end
                        h = h / 6
                    end
                    return h, s, v
                end

                local currentH, currentS, currentV = rgbToHsv(colorPickerConfig.Default)

                colorPickerObj.labelText = makeThingExist("TextLabel", {
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
                    TextColor3 = Color3.fromRGB(124, 124, 124), Text = colorPickerConfig.Name, BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, yPosition), TextSize = 14 * mobileScaleFactor,
                    Size = UDim2.new(0, 100 * mobileScaleFactor, 0, 20 * mobileScaleFactor),
                    TextXAlignment = Enum.TextXAlignment.Left, Parent = groupObj.mainFrame
                })

                colorPickerObj.colorPreview = makeThingExist("Frame", {
                    BackgroundColor3 = colorPickerObj.value,
                    Position = UDim2.new(1, -40 * mobileScaleFactor, 0, yPosition),
                    Size = UDim2.new(0, 30 * mobileScaleFactor, 0, 20 * mobileScaleFactor),
                    Parent = groupObj.mainFrame
                })
                makeThingExist("UICorner", {CornerRadius = UDim.new(0, 6), Parent = colorPickerObj.colorPreview})
                makeThingExist("UIStroke", {Color = Color3.fromRGB(60, 60, 60), Parent = colorPickerObj.colorPreview})

                colorPickerObj.pickerHolder = makeThingExist("Frame", {
                    BackgroundColor3 = Color3.fromRGB(24, 24, 24),
                    Size = UDim2.new(0, 200 * mobileScaleFactor, 0, 0),
                    ClipsDescendants = true, Visible = false, ZIndex = 9999,
                    Parent = groupObj.Library.dropdownHolderRef
                })
                makeThingExist("UICorner", {CornerRadius = UDim.new(0, 8), Parent = colorPickerObj.pickerHolder})
                makeThingExist("UIStroke", {Color = Color3.fromRGB(50, 50, 50), Parent = colorPickerObj.pickerHolder})

                colorPickerObj.svBox = makeThingExist("Frame", {
                    BackgroundColor3 = Color3.fromHSV(currentH, 1, 1),
                    Position = UDim2.new(0, 10, 0, 10),
                    Size = UDim2.new(1, -20, 0, 100 * mobileScaleFactor),
                    ZIndex = 10000, Parent = colorPickerObj.pickerHolder
                })
                makeThingExist("UICorner", {CornerRadius = UDim.new(0, 6), Parent = colorPickerObj.svBox})

                makeThingExist("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                        ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
                    }),
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 0),
                        NumberSequenceKeypoint.new(1, 1)
                    }), Parent = colorPickerObj.svBox
                })

                local valueOverlay = makeThingExist("Frame", {
                    BackgroundColor3 = Color3.new(0, 0, 0),
                    Size = UDim2.new(1, 0, 1, 0), ZIndex = 10001, Parent = colorPickerObj.svBox
                })
                makeThingExist("UICorner", {CornerRadius = UDim.new(0, 6), Parent = valueOverlay})
                makeThingExist("UIGradient", {
                    Color = ColorSequence.new(Color3.new(0, 0, 0)),
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 1),
                        NumberSequenceKeypoint.new(1, 0)
                    }),
                    Rotation = 90, Parent = valueOverlay
                })

                colorPickerObj.svCursor = makeThingExist("Frame", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(currentS, -6, 1 - currentV, -6),
                    Size = UDim2.new(0, 12, 0, 12), ZIndex = 10003, Parent = colorPickerObj.svBox
                })
                makeThingExist("UICorner", {CornerRadius = UDim.new(1, 0), Parent = colorPickerObj.svCursor})
                makeThingExist("UIStroke", {Color = Color3.new(1, 1, 1), Thickness = 2, Parent = colorPickerObj.svCursor})

                colorPickerObj.hueSlider = makeThingExist("Frame", {
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    Position = UDim2.new(0, 10, 0, 120 * mobileScaleFactor),
                    Size = UDim2.new(1, -20, 0, 14 * mobileScaleFactor),
                    ZIndex = 10000, Parent = colorPickerObj.pickerHolder
                })
                makeThingExist("UICorner", {CornerRadius = UDim.new(1, 0), Parent = colorPickerObj.hueSlider})
                makeThingExist("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
                        ColorSequenceKeypoint.new(0.167, Color3.fromHSV(0.167, 1, 1)),
                        ColorSequenceKeypoint.new(0.333, Color3.fromHSV(0.333, 1, 1)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
                        ColorSequenceKeypoint.new(0.667, Color3.fromHSV(0.667, 1, 1)),
                        ColorSequenceKeypoint.new(0.833, Color3.fromHSV(0.833, 1, 1)),
                        ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1))
                    }), Parent = colorPickerObj.hueSlider
                })

                colorPickerObj.hueCursor = makeThingExist("Frame", {
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    Position = UDim2.new(currentH, -7, 0.5, -7),
                    Size = UDim2.new(0, 14, 0, 14), ZIndex = 10001, Parent = colorPickerObj.hueSlider
                })
                makeThingExist("UICorner", {CornerRadius = UDim.new(1, 0), Parent = colorPickerObj.hueCursor})
                makeThingExist("UIStroke", {Color = Color3.fromRGB(40, 40, 40), Thickness = 2, Parent = colorPickerObj.hueCursor})

                local presetColors = {
                    Color3.fromRGB(38, 70, 83), Color3.fromRGB(42, 157, 143),
                    Color3.fromRGB(233, 196, 106), Color3.fromRGB(244, 162, 97),
                    Color3.fromRGB(231, 111, 81), Color3.fromRGB(190, 49, 49),
                    Color3.fromRGB(40, 55, 114), Color3.fromRGB(68, 114, 196),
                    Color3.fromRGB(78, 166, 206), Color3.fromRGB(108, 225, 226)
                }

                local presetY = 145 * mobileScaleFactor
                for i, preset in ipairs(presetColors) do
                    local col = (i - 1) % 5
                    local row = math.floor((i - 1) / 5)
                    local presetBtn = makeThingExist("Frame", {
                        BackgroundColor3 = preset,
                        Position = UDim2.new(0, 10 + col * 38 * mobileScaleFactor, 0, presetY + row * 28 * mobileScaleFactor),
                        Size = UDim2.new(0, 32 * mobileScaleFactor, 0, 22 * mobileScaleFactor),
                        ZIndex = 10000, Parent = colorPickerObj.pickerHolder
                    })
                    makeThingExist("UICorner", {CornerRadius = UDim.new(1, 0), Parent = presetBtn})

                    local presetClick = makeThingExist("TextButton", {
                        Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
                        ZIndex = 10001, Parent = presetBtn
                    })
                    presetClick.MouseButton1Click:Connect(function()
                        currentH, currentS, currentV = rgbToHsv(preset)
                        colorPickerObj.value = preset
                        colorPickerObj.colorPreview.BackgroundColor3 = preset
                        colorPickerObj.svBox.BackgroundColor3 = Color3.fromHSV(currentH, 1, 1)
                        colorPickerObj.svCursor.Position = UDim2.new(currentS, -6, 1 - currentV, -6)
                        colorPickerObj.hueCursor.Position = UDim2.new(currentH, -7, 0.5, -7)
                        colorPickerConfig.Callback(preset)
                    end)
                end

                local function updateColor()
                    colorPickerObj.value = Color3.fromHSV(currentH, currentS, currentV)
                    colorPickerObj.colorPreview.BackgroundColor3 = colorPickerObj.value
                    colorPickerObj.svBox.BackgroundColor3 = Color3.fromHSV(currentH, 1, 1)
                    colorPickerConfig.Callback(colorPickerObj.value)
                end

                local svClickBtn = makeThingExist("TextButton", {
                    Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
                    ZIndex = 10002, Parent = colorPickerObj.svBox
                })

                local svDragging = false
                svClickBtn.MouseButton1Down:Connect(function() svDragging = true end)
                groupObj.Library:_TrackConnection(thisInputServiceGoesHard.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        svDragging = false
                    end
                end))
                groupObj.Library:_TrackConnection(thisInputServiceGoesHard.InputChanged:Connect(function(input)
                    if svDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local absPos, absSize = colorPickerObj.svBox.AbsolutePosition, colorPickerObj.svBox.AbsoluteSize
                        currentS = math.clamp((input.Position.X - absPos.X) / absSize.X, 0, 1)
                        currentV = math.clamp(1 - (input.Position.Y - absPos.Y) / absSize.Y, 0, 1)
                        colorPickerObj.svCursor.Position = UDim2.new(currentS, -6, 1 - currentV, -6)
                        updateColor()
                    end
                end))

                local hueClickBtn = makeThingExist("TextButton", {
                    Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
                    ZIndex = 10002, Parent = colorPickerObj.hueSlider
                })

                local hueDragging = false
                hueClickBtn.MouseButton1Down:Connect(function() hueDragging = true end)
                groupObj.Library:_TrackConnection(thisInputServiceGoesHard.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        hueDragging = false
                    end
                end))
                groupObj.Library:_TrackConnection(thisInputServiceGoesHard.InputChanged:Connect(function(input)
                    if hueDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local absPos, absSize = colorPickerObj.hueSlider.AbsolutePosition, colorPickerObj.hueSlider.AbsoluteSize
                        currentH = math.clamp((input.Position.X - absPos.X) / absSize.X, 0, 1)
                        colorPickerObj.hueCursor.Position = UDim2.new(currentH, -7, 0.5, -7)
                        updateColor()
                    end
                end))

                local pickerClickBtn = makeThingExist("TextButton", {
                    Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
                    Parent = colorPickerObj.colorPreview
                })

                local colorPickerPositionConn = nil
                local function closeColorPicker(isInstant)
                    colorPickerObj.isOpen = false
                    if colorPickerPositionConn then
                        colorPickerPositionConn()
                        colorPickerPositionConn = nil
                    end
                    if isInstant then
                        colorPickerObj.pickerHolder.Size = UDim2.new(0, 200 * mobileScaleFactor, 0, 0)
                        colorPickerObj.pickerHolder.Visible = false
                        return
                    end
                    smoothMoveGoWoosh(colorPickerObj.pickerHolder, {
                        Size = UDim2.new(0, 200 * mobileScaleFactor, 0, 0)
                    }, 0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
                    task.delay(0.2, function()
                        if colorPickerObj.pickerHolder.Parent and not colorPickerObj.isOpen then
                            colorPickerObj.pickerHolder.Visible = false
                        end
                    end)
                end

                local function updatePickerPosition()
                    local absPos = colorPickerObj.colorPreview.AbsolutePosition
                    local absSize = colorPickerObj.colorPreview.AbsoluteSize
                    colorPickerObj.pickerHolder.Position = UDim2.new(0, absPos.X - 160 * mobileScaleFactor, 0, absPos.Y + absSize.Y + 5)
                end

                pickerClickBtn.MouseButton1Click:Connect(function()
                    colorPickerObj.isOpen = not colorPickerObj.isOpen
                    if colorPickerObj.isOpen then
                        updatePickerPosition()
                        colorPickerObj.pickerHolder.Visible = true
                        smoothMoveGoWoosh(colorPickerObj.pickerHolder, {
                            Size = UDim2.new(0, 200 * mobileScaleFactor, 0, 210 * mobileScaleFactor)
                        }, 0.26, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                        if colorPickerPositionConn then colorPickerPositionConn() end
                        colorPickerPositionConn = startFloatingPositionTracker(groupObj.Library, colorPickerObj.colorPreview, function()
                            if colorPickerObj.isOpen then
                                updatePickerPosition()
                            end
                        end)
                    else
                        closeColorPicker(false)
                    end
                end)

                function colorPickerObj:Set(color)
                    colorPickerObj.value = color
                    currentH, currentS, currentV = rgbToHsv(color)
                    colorPickerObj.colorPreview.BackgroundColor3 = color
                    colorPickerObj.svBox.BackgroundColor3 = Color3.fromHSV(currentH, 1, 1)
                    colorPickerObj.svCursor.Position = UDim2.new(currentS, -6, 1 - currentV, -6)
                    colorPickerObj.hueCursor.Position = UDim2.new(currentH, -7, 0.5, -7)
                    colorPickerConfig.Callback(color)
                end

                function colorPickerObj:Get() return colorPickerObj.value end

                function colorPickerObj:Close()
                    closeColorPicker(true)
                end
                groupObj.Library:RegisterControl(colorPickerConfig.Flag, function()
                    return colorPickerObj:Get()
                end, function(value)
                    if typeof(value) == "Color3" then
                        colorPickerObj:Set(value)
                    end
                end)

                colorPickerConfig.Callback(colorPickerConfig.Default)
                groupObj.elementYPos = groupObj.elementYPos + 28 * mobileScaleFactor
                updateGroupSizeYay()
                table.insert(groupObj.elementsInGroup, colorPickerObj)
                return colorPickerObj
            end

            table.insert(tabObj.groupsInTab, groupObj)
            updateGroupSizeYay()
            return groupObj
        end

        table.insert(sectionObj.tabsInSection, tabObj)
        table.insert(sectionObj.Library.tabsGoWoosh, tabObj)

        if #sectionObj.Library.tabsGoWoosh == 1 then tabObj:Activate() end

        task.defer(function()
            local tabsHeight = sectionObj.tabLayoutThing.AbsoluteContentSize.Y
            sectionObj.tabHolderFrame.Size = UDim2.new(0, 146 * mobileScaleFactor, 0, tabsHeight)
            sectionObj.containerFrame.Size = UDim2.new(0, 158 * mobileScaleFactor, 0, 32 * mobileScaleFactor + tabsHeight + 9)
        end)

        if sectionObj.Library._searchQuery ~= "" then
            sectionObj.Library:ApplySearchFilter(sectionObj.Library._searchQuery)
        end

        return tabObj
    end

    table.insert(self.sectionsAreAwesome, sectionObj)
    return sectionObj
end

function FoxyLibrary:SetAccentColor(color)
    if typeof(color) ~= "Color3" then
        return
    end
    self.config.AccentColor = color
    for _, section in ipairs(self.sectionsAreAwesome) do
        for _, tab in ipairs(section.tabsInSection or {}) do
            if tab.isActive and tab.buttonFrame then
                tab.buttonFrame.BackgroundColor3 = color
            end
            for _, group in ipairs(tab.groupsInTab or {}) do
                for _, element in ipairs(group.elementsInGroup or {}) do
                    if type(element) == "table" then
                        if element.switchFrame and element.value == true then
                            element.switchFrame.BackgroundColor3 = color
                        end
                        if element.fillFrame then
                            element.fillFrame.BackgroundColor3 = color
                        end
                        if element.toggleSwitchFrame and element.toggleValue == true then
                            element.toggleSwitchFrame.BackgroundColor3 = color
                        end
                    end
                end
            end
        end
    end
    self:_RefreshAccentCore()
    if self.uiSettingsToggleRefs then
        for _, toggleRef in ipairs(self.uiSettingsToggleRefs) do
            if toggleRef and type(toggleRef.Get) == "function" and type(toggleRef.Set) == "function" then
                toggleRef:Set(toggleRef:Get(), true)
            end
        end
    end
    self:_UpdateESPPreview(0)
end

function FoxyLibrary:Destroy()
    if self._destroyed then return end
    self._destroyed = true

    for _, section in ipairs(self.sectionsAreAwesome) do
        for _, tab in ipairs(section.tabsInSection or {}) do
            for _, group in ipairs(tab.groupsInTab or {}) do
                for _, element in ipairs(group.elementsInGroup or {}) do
                    if type(element) == "table" and type(element.Close) == "function" then
                        pcall(function()
                            element:Close()
                        end)
                    end
                end
            end
        end
    end

    if self.currentTabYay and type(self.currentTabYay.Deactivate) == "function" then
        pcall(function()
            self.currentTabYay:Deactivate()
        end)
        self.currentTabYay = nil
    end

    for i = #self._connections, 1, -1 do
        local conn = self._connections[i]
        if conn and typeof(conn) == "RBXScriptConnection" then
            pcall(function()
                if conn.Connected then
                    conn:Disconnect()
                end
            end)
        end
        self._connections[i] = nil
    end

    self._smoothScrollFrames = {}
    self._trackedControls = {}
    self:_ClearSnowflakes()
    self:_DestroyESPPreviewCharacter()
    self._fpsRollingWindow = table.create and table.create(self._fpsRollingSize or 60, 0) or {}
    self._fpsRollingTotal = 0
    self._fpsRollingIndex = 1
    self._fpsRollingCount = 0
    self._latestFPSValue = 0
    self._cachedViewportSize = Vector2.new(1280, 720)
    self._cachedViewportWidth = 1280
    self._cachedViewportHeight = 720
    self._cachedViewportAreaScale = 1
    self._espPreviewState = nil
    self._espPreviewProvider = nil
    self._espPreviewData = nil
    self._espPreviewWalkTrack = nil
    self._espPreviewAnimationId = nil
    self._espPreviewAvatar3DUserId = nil
    self._espPreviewAvatar3DImageUrl = nil
    self._espPreviewRotationYaw = nil
    self._espPreviewRotationTargetYaw = nil
    self._espPreviewAllowManualRotation = nil
    self._espPreviewPivotYOffset = nil
    self._espPreviewRotateCapture = nil
    self._espPreviewIsRotating = false
    self._espPreviewRotateInput = nil
    self._espPreviewRotateLastX = nil
    self._textGradientAnimationTime = nil
    self._gradientAnimationAccumulator = 0
    self._backgroundFxAccumulator = 0
    self._overlayUpdateAccumulator = 0
    self._snowSpawnAccumulator = 0
    self._gradientObjects = {}
    self._espPreviewProjectionCache = nil
    self._espPreviewProjectionDirty = true

    if self._blurEffectRef and self._blurEffectRef.Parent then
        self._blurEffectRef:Destroy()
    end
    self._blurEffectRef = nil

    if self._espPreviewPanel and self._espPreviewPanel.Parent then
        self._espPreviewPanel:Destroy()
    end
    self._espPreviewPanel = nil
    self._espPreviewViewport = nil
    self._espPreviewWorldModel = nil
    self._espPreviewCamera = nil
    self._espPreviewHighlight = nil
    self._espPreviewHeaderTag = nil
    self._espPreviewBox = nil
    self._espPreviewBoxStroke = nil
    self._espPreviewHealthTrack = nil
    self._espPreviewHealthFill = nil
    self._espPreviewDot = nil
    self._espPreviewTracer = nil
    self._espPreviewName = nil
    self._espPreviewItem = nil
    self._espPreviewDistance = nil
    self._espPreviewRotateCapture = nil

    if self.screenGuiYay and self.screenGuiYay.Parent then
        self.screenGuiYay:Destroy()
    end
end

return FoxyLibrary
end)()
