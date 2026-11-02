
--========================================================
-- ULTIMATE HORROR CONTROL V5
-- PLAYER ESP | NPC ESP | KEY ESP | CODE ESP
-- FLY | FLY SPEED | WALKSPEED | NOCLIP
-- DRAGGABLE GUI | MINIMIZE | DISTANCE LABELS
--========================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remove previous copy
local old = playerGui:FindFirstChild("UltimateHorrorGUI")
if old then old:Destroy() end

--========================================================
-- SETTINGS
--========================================================

local settings = {
    PlayerESP = false,
    NPCESP = false,
    KeyESP = false,
    CodeESP = false,
    Fly = false,
    NoClip = false,
    WalkSpeed = false,
    FlySpeed = 60,
    WalkSpeedValue = 32
}

local COLORS = {
    Player = Color3.fromRGB(0, 255, 100),
    NPC = Color3.fromRGB(255, 65, 65),
    Key = Color3.fromRGB(0, 220, 255),
    Code = Color3.fromRGB(190, 90, 255)
}

local tracked = {}
local originalCollision = {}
local minimized = false
local scanTimer = 0

local NPC_WORDS = {
    "monster", "entity", "enemy", "creature", "ghost",
    "demon", "killer", "beast", "chaser", "stalker",
    "shadow", "mimic", "hunter", "mutant", "zombie",
    "skeleton", "boss", "figure", "seeker", "npc"
}

local CODE_WORDS = {
    "code", "letter", "paper", "papers", "note",
    "document", "clue", "message", "password",
    "cipher", "symbol", "secret", "hint", "journal",
    "riddle", "puzzle", "passcode", "combination",
    "diary", "memo", "scroll", "newspaper",
    "instruction", "keypad"
}

--========================================================
-- GUI
--========================================================

local gui = Instance.new("ScreenGui")
gui.Name = "UltimateHorrorGUI"
gui.ResetOnSpawn = false
gui.DisplayOrder = 100
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(290, 490)
frame.Position = UDim2.new(0, 25, 0.25, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 23, 34)
frame.BorderSizePixel = 0
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(150, 80, 240)
stroke.Thickness = 1.5
stroke.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -48, 0, 42)
title.Position = UDim2.fromOffset(12, 0)
title.BackgroundTransparency = 1
title.Text = "Universal Script V5"
title.TextColor3 = Color3.fromRGB(205, 160, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(32, 30)
minimize.Position = UDim2.new(1, -39, 0, 6)
minimize.BackgroundColor3 = Color3.fromRGB(55, 60, 80)
minimize.TextColor3 = Color3.new(1, 1, 1)
minimize.Text = "-"
minimize.Font = Enum.Font.GothamBold
minimize.TextSize = 20
minimize.Parent = frame
Instance.new("UICorner", minimize)

local content = Instance.new("ScrollingFrame")
content.Position = UDim2.fromOffset(8, 48)
content.Size = UDim2.new(1, -16, 1, -56)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 4
content.CanvasSize = UDim2.fromOffset(0, 600)
content.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 7)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = content

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    content.CanvasSize = UDim2.fromOffset(
        0, layout.AbsoluteContentSize.Y + 12
    )
end)

local function section(text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -4, 0, 24)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(190, 160, 240)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = content
    return label
end

local function button(text)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -4, 0, 36)
    b.BackgroundColor3 = Color3.fromRGB(48, 53, 70)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.Parent = content
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
    return b
end

local function input(placeholder, value)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -4, 0, 34)
    box.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
    box.TextColor3 = Color3.new(1, 1, 1)
    box.PlaceholderColor3 = Color3.fromRGB(160, 160, 175)
    box.PlaceholderText = placeholder
    box.Text = tostring(value)
    box.ClearTextOnFocus = false
    box.Font = Enum.Font.Gotham
    box.TextSize = 13
    box.Parent = content
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 7)
    return box
end

--========================================================
-- DRAGGING
--========================================================

local dragging = false
local dragStart
local startPosition

title.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = i.Position
        startPosition = frame.Position
    end
end)

UIS.InputChanged:Connect(function(i)
    if not dragging then return end

    if i.UserInputType == Enum.UserInputType.MouseMovement
    or i.UserInputType == Enum.UserInputType.Touch then
        local delta = i.Position - dragStart
        frame.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

--========================================================
-- ESP HELPERS
--========================================================

local function getTarget(object)
    if object:IsA("BasePart") then
        return object
    elseif object:IsA("Tool") then
        return object:FindFirstChild("Handle")
            or object:FindFirstChildWhichIsA("BasePart")
    elseif object:IsA("Model") then
        return object:FindFirstChild("HumanoidRootPart", true)
            or object:FindFirstChild("Head", true)
            or object.PrimaryPart
            or object:FindFirstChildWhichIsA("BasePart", true)
    end
    return nil
end

local function removeESP(object)
    local data = tracked[object]
    if not data then return end

    if data.Highlight then data.Highlight:Destroy() end
    if data.Billboard then data.Billboard:Destroy() end

    tracked[object] = nil
end

local function addESP(object, category)
    if tracked[object] then return end

    if not object:IsA("Model")
    and not object:IsA("BasePart")
    and not object:IsA("Tool") then
        return
    end

    local target = getTarget(object)
    if not target then return end

    local color = COLORS[category]
    if not color then return end

    -- Only highlight the actual object, never its entire Workspace parent.
    local adornee = object:IsA("Tool") and target or object

    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Outline"
    highlight.Adornee = adornee
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0
    highlight.OutlineColor = color
    highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    highlight.Parent = gui

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Label"
    billboard.Adornee = target
    billboard.Size = UDim2.fromOffset(160, 38)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 1000
    billboard.Parent = gui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.TextColor3 = color
    label.TextStrokeTransparency = 0.15
    label.TextSize = 13
    label.Font = Enum.Font.GothamBold
    label.Text = category
    label.Parent = billboard

    tracked[object] = {
        Highlight = highlight,
        Billboard = billboard,
        Label = label,
        Category = category
    }
end

--========================================================
-- CODE ESP DETECTION - FIXED
--========================================================

local function hasWord(text, words)
    text = string.lower(tostring(text))

    for _, word in ipairs(words) do
        if text:find(word, 1, true) then
            return true
        end
    end

    return false
end

local function getReadableText(object)
    local result = {}

    for _, child in ipairs(object:GetDescendants()) do
        if child:IsA("TextLabel")
        or child:IsA("TextButton")
        or child:IsA("TextBox") then
            if child.Visible and child.Text ~= "" then
                table.insert(result, child.Text)
            end
        elseif child:IsA("StringValue") then
            if child.Value ~= "" then
                table.insert(result, child.Value)
            end
        end
    end

    return table.concat(result, " ")
end

local function isPlayerCharacter(model)
    return Players:GetPlayerFromCharacter(model) ~= nil
end

local function getCategory(object)
    if not object:IsA("Model")
    and not object:IsA("BasePart")
    and not object:IsA("Tool") then
        return nil
    end

    if object:IsA("Model") and isPlayerCharacter(object) then
        return nil
    end

    if object:IsA("BasePart") then
        local parentModel = object:FindFirstAncestorOfClass("Model")
        if parentModel and isPlayerCharacter(parentModel) then
            return nil
        end
    end

    local name = string.lower(object.Name)

    -- KEY ESP
    if settings.KeyESP and name:find("key", 1, true) then
        return "Key"
    end

    -- CODE ESP:
    -- 1. Match the object's own name.
    -- 2. For Models and Tools, inspect readable clue text.
    -- 3. Do NOT treat arbitrary numbers in object names as codes.
    if settings.CodeESP then
        if hasWord(name, CODE_WORDS) then
            return "Code"
        end

        if object:IsA("Model") or object:IsA("Tool") then
            local readable = getReadableText(object)

            if hasWord(readable, CODE_WORDS) then
                return "Code"
            end
        end
    end

    -- NPC ESP
    if settings.NPCESP and object:IsA("Model") then
        if hasWord(name, NPC_WORDS)
        or object:FindFirstChildOfClass("Humanoid")
        or object:FindFirstChildWhichIsA("AnimationController", true) then
            return "NPC"
        end
    end

    return nil
end

--========================================================
-- SCAN
--========================================================

local function scanPlayers()
    if not settings.PlayerESP then return end

    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player and other.Character then
            addESP(other.Character, "Player")
        end
    end
end

local function scanWorld()
    for _, object in ipairs(Workspace:GetDescendants()) do
        local category = getCategory(object)

        if category then
            addESP(object, category)
        end
    end

    scanPlayers()
end

Workspace.DescendantAdded:Connect(function(object)
    task.delay(0.3, function()
        if object.Parent then
            local category = getCategory(object)
            if category then
                addESP(object, category)
            end
        end
    end)
end)

--========================================================
-- ESP BUTTONS
--========================================================

section("ESP FEATURES")

local playerButton = button("PLAYER ESP: OFF")
local npcButton = button("NPC ESP: OFF")
local keyButton = button("KEY ESP: OFF")
local codeButton = button("CODE / LETTER ESP: OFF")

local function toggleESP(setting, category, b, label)
    settings[setting] = not settings[setting]
    local active = settings[setting]

    b.Text = label .. ": " .. (active and "ON" or "OFF")
    b.BackgroundColor3 = active
        and COLORS[category]
        or Color3.fromRGB(48, 53, 70)

    if active then
        scanWorld()
    else
        for object, data in pairs(tracked) do
            if data.Category == category then
                removeESP(object)
            end
        end
    end
end

playerButton.MouseButton1Click:Connect(function()
    toggleESP("PlayerESP", "Player", playerButton, "PLAYER ESP")
end)

npcButton.MouseButton1Click:Connect(function()
    toggleESP("NPCESP", "NPC", npcButton, "NPC ESP")
end)

keyButton.MouseButton1Click:Connect(function()
    toggleESP("KeyESP", "Key", keyButton, "KEY ESP")
end)

codeButton.MouseButton1Click:Connect(function()
    toggleESP("CodeESP", "Code", codeButton, "CODE / LETTER ESP")
end)

--========================================================
-- FLY
--========================================================

section("MOVEMENT")

local flySpeedBox = input("Fly speed", settings.FlySpeed)
local flyButton = button("FLY: OFF")

local flyVelocity
local flyAttachment
local flyOrientation
local flyConnection

local function stopFly()
    settings.Fly = false

    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end

    if flyVelocity then flyVelocity:Destroy() end
    if flyOrientation then flyOrientation:Destroy() end
    if flyAttachment then flyAttachment:Destroy() end

    flyVelocity = nil
    flyOrientation = nil
    flyAttachment = nil

    flyButton.Text = "FLY: OFF"
end

local function startFly()
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    stopFly()
    settings.Fly = true

    flyAttachment = Instance.new("Attachment")
    flyAttachment.Parent = root

    flyVelocity = Instance.new("LinearVelocity")
    flyVelocity.Attachment0 = flyAttachment
    flyVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    flyVelocity.MaxForce = math.huge
    flyVelocity.VectorVelocity = Vector3.zero
    flyVelocity.Parent = root

    flyOrientation = Instance.new("AlignOrientation")
    flyOrientation.Attachment0 = flyAttachment
    flyOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
    flyOrientation.MaxTorque = math.huge
    flyOrientation.Responsiveness = 20
    flyOrientation.Parent = root

    flyButton.Text = "FLY: ON"

    flyConnection = RunService.RenderStepped:Connect(function()
        if not settings.Fly or not root.Parent then
            stopFly()
            return
        end

        if UIS:GetFocusedTextBox() then
            flyVelocity.VectorVelocity = Vector3.zero
            return
        end

        local camera = Workspace.CurrentCamera
        if not camera then return end

        local direction = Vector3.zero

        if UIS:IsKeyDown(Enum.KeyCode.W) then
            direction += camera.CFrame.LookVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.S) then
            direction -= camera.CFrame.LookVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.A) then
            direction -= camera.CFrame.RightVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.D) then
            direction += camera.CFrame.RightVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            direction += Vector3.yAxis
        end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
            direction -= Vector3.yAxis
        end

        if direction.Magnitude > 0 then
            direction = direction.Unit
        end

        flyVelocity.VectorVelocity = direction * settings.FlySpeed
        flyOrientation.CFrame = camera.CFrame.Rotation
    end)
end

flySpeedBox.FocusLost:Connect(function()
    local value = tonumber(flySpeedBox.Text)

    if value then
        settings.FlySpeed = math.clamp(value, 1, 500)
    end

    flySpeedBox.Text = tostring(settings.FlySpeed)
end)

flyButton.MouseButton1Click:Connect(function()
    if settings.Fly then
        stopFly()
    else
        startFly()
    end
end)

--========================================================
-- WALKSPEED
--========================================================

local walkSpeedBox = input("WalkSpeed value", settings.WalkSpeedValue)
local walkButton = button("WALKSPEED: OFF")

walkSpeedBox.FocusLost:Connect(function()
    local value = tonumber(walkSpeedBox.Text)

    if value then
        settings.WalkSpeedValue = math.clamp(value, 1, 200)
    end

    walkSpeedBox.Text = tostring(settings.WalkSpeedValue)
end)

local function applyWalkSpeed()
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if humanoid and settings.WalkSpeed then
        humanoid.WalkSpeed = settings.WalkSpeedValue
    end
end

walkButton.MouseButton1Click:Connect(function()
    settings.WalkSpeed = not settings.WalkSpeed
    walkButton.Text = "WALKSPEED: " ..
        (settings.WalkSpeed and "ON" or "OFF")

    if not settings.WalkSpeed then
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")

        if humanoid then
            humanoid.WalkSpeed = 16
        end
    else
        applyWalkSpeed()
    end
end)

--========================================================
-- NOCLIP
--========================================================

local noclipButton = button("NOCLIP: OFF")

local function restoreCollision()
    for part, original in pairs(originalCollision) do
        if part and part.Parent then
            part.CanCollide = original
        end
    end

    table.clear(originalCollision)
end

noclipButton.MouseButton1Click:Connect(function()
    settings.NoClip = not settings.NoClip
    noclipButton.Text = "NOCLIP: " ..
        (settings.NoClip and "ON" or "OFF")

    if not settings.NoClip then
        restoreCollision()
    end
end)

RunService.Stepped:Connect(function()
    if not settings.NoClip then return end

    local character = player.Character
    if not character then return end

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            if originalCollision[part] == nil then
                originalCollision[part] = part.CanCollide
            end

            part.CanCollide = false
        end
    end
end)

--========================================================
-- DISTANCE LABELS / CLEANUP
--========================================================

RunService.RenderStepped:Connect(function()
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")

    for object, data in pairs(tracked) do
        if not object.Parent then
            removeESP(object)
        else
            local target = getTarget(object)

            if not target or not target.Parent then
                removeESP(object)
            elseif root then
                local distance = (root.Position - target.Position).Magnitude
                data.Label.Text = object.Name .. "\n"
                    .. math.floor(distance) .. " studs"
            end
        end
    end
end)

--========================================================
-- RESPAWN SUPPORT
--========================================================

player.CharacterAdded:Connect(function()
    stopFly()
    restoreCollision()

    task.wait(0.6)

    if settings.WalkSpeed then
        applyWalkSpeed()
    end

    if settings.PlayerESP then
        scanPlayers()
    end
end)

--========================================================
-- MINIMIZE
--========================================================

minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    content.Visible = not minimized

    frame.Size = minimized
        and UDim2.fromOffset(290, 44)
        or UDim2.fromOffset(290, 490)

    minimize.Text = minimized and "+" or "-"
end)

--========================================================
-- PERIODIC SCAN
--========================================================

RunService.Heartbeat:Connect(function(dt)
    scanTimer += dt

    if scanTimer >= 1.5 then
        scanTimer = 0

        if settings.PlayerESP or settings.NPCESP
        or settings.KeyESP or settings.CodeESP then
            scanWorld()
        end
    end

    if settings.WalkSpeed then
        applyWalkSpeed()
    end
end)

--========================================================
-- CLEANUP
--========================================================

gui.Destroying:Connect(function()
    stopFly()
    restoreCollision()

    for object in pairs(tracked) do
        removeESP(object)
    end
end)

print("ULTIMATE HORROR CONTROL V5 LOADED")

--========================================================
-- ULTIMATE HORROR CONTROL V5
-- PLAYER ESP | NPC ESP | KEY ESP | CODE ESP
-- FLY | FLY SPEED | WALKSPEED | NOCLIP
-- DRAGGABLE GUI | MINIMIZE | DISTANCE LABELS
--========================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remove previous copy
local old = playerGui:FindFirstChild("UltimateHorrorGUI")
if old then old:Destroy() end

--========================================================
-- SETTINGS
--========================================================

local settings = {
    PlayerESP = false,
    NPCESP = false,
    KeyESP = false,
    CodeESP = false,
    Fly = false,
    NoClip = false,
    WalkSpeed = false,
    FlySpeed = 60,
    WalkSpeedValue = 32
}

local COLORS = {
    Player = Color3.fromRGB(0, 255, 100),
    NPC = Color3.fromRGB(255, 65, 65),
    Key = Color3.fromRGB(0, 220, 255),
    Code = Color3.fromRGB(190, 90, 255)
}

local tracked = {}
local originalCollision = {}
local minimized = false
local scanTimer = 0

local NPC_WORDS = {
    "monster", "entity", "enemy", "creature", "ghost",
    "demon", "killer", "beast", "chaser", "stalker",
    "shadow", "mimic", "hunter", "mutant", "zombie",
    "skeleton", "boss", "figure", "seeker"
}

local CODE_WORDS = {
    "code", "letter", "paper", "papers", "note",
    "document", "clue", "message", "password",
    "cipher", "symbol", "secret", "hint", "journal",
    "riddle", "puzzle", "passcode", "combination",
    "diary", "memo", "scroll", "newspaper",
    "instruction", "keypad"
}

--========================================================
-- GUI
--========================================================

local gui = Instance.new("ScreenGui")
gui.Name = "UltimateHorrorGUI"
gui.ResetOnSpawn = false
gui.DisplayOrder = 100
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(290, 490)
frame.Position = UDim2.new(0, 25, 0.25, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 23, 34)
frame.BorderSizePixel = 0
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(150, 80, 240)
stroke.Thickness = 1.5
stroke.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -48, 0, 42)
title.Position = UDim2.fromOffset(12, 0)
title.BackgroundTransparency = 1
title.Text = "ULTIMATE HORROR ESP"
title.TextColor3 = Color3.fromRGB(205, 160, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(32, 30)
minimize.Position = UDim2.new(1, -39, 0, 6)
minimize.BackgroundColor3 = Color3.fromRGB(55, 60, 80)
minimize.TextColor3 = Color3.new(1, 1, 1)
minimize.Text = "-"
minimize.Font = Enum.Font.GothamBold
minimize.TextSize = 20
minimize.Parent = frame
Instance.new("UICorner", minimize)

local content = Instance.new("ScrollingFrame")
content.Position = UDim2.fromOffset(8, 48)
content.Size = UDim2.new(1, -16, 1, -56)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 4
content.CanvasSize = UDim2.fromOffset(0, 600)
content.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 7)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = content

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    content.CanvasSize = UDim2.fromOffset(
        0, layout.AbsoluteContentSize.Y + 12
    )
end)

local function section(text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -4, 0, 24)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(190, 160, 240)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = content
    return label
end

local function button(text)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -4, 0, 36)
    b.BackgroundColor3 = Color3.fromRGB(48, 53, 70)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.Parent = content
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
    return b
end

local function input(placeholder, value)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -4, 0, 34)
    box.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
    box.TextColor3 = Color3.new(1, 1, 1)
    box.PlaceholderColor3 = Color3.fromRGB(160, 160, 175)
    box.PlaceholderText = placeholder
    box.Text = tostring(value)
    box.ClearTextOnFocus = false
    box.Font = Enum.Font.Gotham
    box.TextSize = 13
    box.Parent = content
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 7)
    return box
end

--========================================================
-- DRAGGING
--========================================================

local dragging = false
local dragStart
local startPosition

title.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = i.Position
        startPosition = frame.Position
    end
end)

UIS.InputChanged:Connect(function(i)
    if not dragging then return end

    if i.UserInputType == Enum.UserInputType.MouseMovement
    or i.UserInputType == Enum.UserInputType.Touch then
        local delta = i.Position - dragStart
        frame.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

--========================================================
-- ESP HELPERS
--========================================================

local function getTarget(object)
    if object:IsA("BasePart") then
        return object
    elseif object:IsA("Tool") then
        return object:FindFirstChild("Handle")
            or object:FindFirstChildWhichIsA("BasePart")
    elseif object:IsA("Model") then
        return object:FindFirstChild("HumanoidRootPart", true)
            or object:FindFirstChild("Head", true)
            or object.PrimaryPart
            or object:FindFirstChildWhichIsA("BasePart", true)
    end
    return nil
end

local function removeESP(object)
    local data = tracked[object]
    if not data then return end

    if data.Highlight then data.Highlight:Destroy() end
    if data.Billboard then data.Billboard:Destroy() end

    tracked[object] = nil
end

local function addESP(object, category)
    if tracked[object] then return end

    if not object:IsA("Model")
    and not object:IsA("BasePart")
    and not object:IsA("Tool") then
        return
    end

    local target = getTarget(object)
    if not target then return end

    local color = COLORS[category]
    if not color then return end

    -- Only highlight the actual object, never its entire Workspace parent.
    local adornee = object:IsA("Tool") and target or object

    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Outline"
    highlight.Adornee = adornee
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0
    highlight.OutlineColor = color
    highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    highlight.Parent = gui

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Label"
    billboard.Adornee = target
    billboard.Size = UDim2.fromOffset(160, 38)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 1000
    billboard.Parent = gui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.TextColor3 = color
    label.TextStrokeTransparency = 0.15
    label.TextSize = 13
    label.Font = Enum.Font.GothamBold
    label.Text = category
    label.Parent = billboard

    tracked[object] = {
        Highlight = highlight,
        Billboard = billboard,
        Label = label,
        Category = category
    }
end

--========================================================
-- CODE ESP DETECTION - FIXED
--========================================================

local function hasWord(text, words)
    text = string.lower(tostring(text))

    for _, word in ipairs(words) do
        if text:find(word, 1, true) then
            return true
        end
    end

    return false
end

local function getReadableText(object)
    local result = {}

    for _, child in ipairs(object:GetDescendants()) do
        if child:IsA("TextLabel")
        or child:IsA("TextButton")
        or child:IsA("TextBox") then
            if child.Visible and child.Text ~= "" then
                table.insert(result, child.Text)
            end
        elseif child:IsA("StringValue") then
            if child.Value ~= "" then
                table.insert(result, child.Value)
            end
        end
    end

    return table.concat(result, " ")
end

local function isPlayerCharacter(model)
    return Players:GetPlayerFromCharacter(model) ~= nil
end

local function getCategory(object)
    if not object:IsA("Model")
    and not object:IsA("BasePart")
    and not object:IsA("Tool") then
        return nil
    end

    if object:IsA("Model") and isPlayerCharacter(object) then
        return nil
    end

    if object:IsA("BasePart") then
        local parentModel = object:FindFirstAncestorOfClass("Model")
        if parentModel and isPlayerCharacter(parentModel) then
            return nil
        end
    end

    local name = string.lower(object.Name)

    -- KEY ESP
    if settings.KeyESP and name:find("key", 1, true) then
        return "Key"
    end

    -- CODE ESP:
    -- 1. Match the object's own name.
    -- 2. For Models and Tools, inspect readable clue text.
    -- 3. Do NOT treat arbitrary numbers in object names as codes.
    if settings.CodeESP then
        if hasWord(name, CODE_WORDS) then
            return "Code"
        end

        if object:IsA("Model") or object:IsA("Tool") then
            local readable = getReadableText(object)

            if hasWord(readable, CODE_WORDS) then
                return "Code"
            end
        end
    end

    -- NPC ESP
    if settings.NPCESP and object:IsA("Model") then
        if hasWord(name, NPC_WORDS)
        or object:FindFirstChildOfClass("Humanoid")
        or object:FindFirstChildWhichIsA("AnimationController", true) then
            return "NPC"
        end
    end

    return nil
end

--========================================================
-- SCAN
--========================================================

local function scanPlayers()
    if not settings.PlayerESP then return end

    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player and other.Character then
            addESP(other.Character, "Player")
        end
    end
end

local function scanWorld()
    for _, object in ipairs(Workspace:GetDescendants()) do
        local category = getCategory(object)

        if category then
            addESP(object, category)
        end
    end

    scanPlayers()
end

Workspace.DescendantAdded:Connect(function(object)
    task.delay(0.3, function()
        if object.Parent then
            local category = getCategory(object)
            if category then
                addESP(object, category)
            end
        end
    end)
end)

--========================================================
-- ESP BUTTONS
--========================================================

section("ESP FEATURES")

local playerButton = button("PLAYER ESP: OFF")
local npcButton = button("NPC ESP: OFF")
local keyButton = button("KEY ESP: OFF")
local codeButton = button("CODE / LETTER ESP: OFF")

local function toggleESP(setting, category, b, label)
    settings[setting] = not settings[setting]
    local active = settings[setting]

    b.Text = label .. ": " .. (active and "ON" or "OFF")
    b.BackgroundColor3 = active
        and COLORS[category]
        or Color3.fromRGB(48, 53, 70)

    if active then
        scanWorld()
    else
        for object, data in pairs(tracked) do
            if data.Category == category then
                removeESP(object)
            end
        end
    end
end

playerButton.MouseButton1Click:Connect(function()
    toggleESP("PlayerESP", "Player", playerButton, "PLAYER ESP")
end)

npcButton.MouseButton1Click:Connect(function()
    toggleESP("NPCESP", "NPC", npcButton, "NPC ESP")
end)

keyButton.MouseButton1Click:Connect(function()
    toggleESP("KeyESP", "Key", keyButton, "KEY ESP")
end)

codeButton.MouseButton1Click:Connect(function()
    toggleESP("CodeESP", "Code", codeButton, "CODE / LETTER ESP")
end)

--========================================================
-- FLY
--========================================================

section("MOVEMENT")

local flySpeedBox = input("Fly speed", settings.FlySpeed)
local flyButton = button("FLY: OFF")

local flyVelocity
local flyAttachment
local flyOrientation
local flyConnection

local function stopFly()
    settings.Fly = false

    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end

    if flyVelocity then flyVelocity:Destroy() end
    if flyOrientation then flyOrientation:Destroy() end
    if flyAttachment then flyAttachment:Destroy() end

    flyVelocity = nil
    flyOrientation = nil
    flyAttachment = nil

    flyButton.Text = "FLY: OFF"
end

local function startFly()
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    stopFly()
    settings.Fly = true

    flyAttachment = Instance.new("Attachment")
    flyAttachment.Parent = root

    flyVelocity = Instance.new("LinearVelocity")
    flyVelocity.Attachment0 = flyAttachment
    flyVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    flyVelocity.MaxForce = math.huge
    flyVelocity.VectorVelocity = Vector3.zero
    flyVelocity.Parent = root

    flyOrientation = Instance.new("AlignOrientation")
    flyOrientation.Attachment0 = flyAttachment
    flyOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
    flyOrientation.MaxTorque = math.huge
    flyOrientation.Responsiveness = 20
    flyOrientation.Parent = root

    flyButton.Text = "FLY: ON"

    flyConnection = RunService.RenderStepped:Connect(function()
        if not settings.Fly or not root.Parent then
            stopFly()
            return
        end

        if UIS:GetFocusedTextBox() then
            flyVelocity.VectorVelocity = Vector3.zero
            return
        end

        local camera = Workspace.CurrentCamera
        if not camera then return end

        local direction = Vector3.zero

        if UIS:IsKeyDown(Enum.KeyCode.W) then
            direction += camera.CFrame.LookVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.S) then
            direction -= camera.CFrame.LookVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.A) then
            direction -= camera.CFrame.RightVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.D) then
            direction += camera.CFrame.RightVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            direction += Vector3.yAxis
        end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
            direction -= Vector3.yAxis
        end

        if direction.Magnitude > 0 then
            direction = direction.Unit
        end

        flyVelocity.VectorVelocity = direction * settings.FlySpeed
        flyOrientation.CFrame = camera.CFrame.Rotation
    end)
end

flySpeedBox.FocusLost:Connect(function()
    local value = tonumber(flySpeedBox.Text)

    if value then
        settings.FlySpeed = math.clamp(value, 1, 500)
    end

    flySpeedBox.Text = tostring(settings.FlySpeed)
end)

flyButton.MouseButton1Click:Connect(function()
    if settings.Fly then
        stopFly()
    else
        startFly()
    end
end)

--========================================================
-- WALKSPEED
--========================================================

local walkSpeedBox = input("WalkSpeed value", settings.WalkSpeedValue)
local walkButton = button("WALKSPEED: OFF")

walkSpeedBox.FocusLost:Connect(function()
    local value = tonumber(walkSpeedBox.Text)

    if value then
        settings.WalkSpeedValue = math.clamp(value, 1, 200)
    end

    walkSpeedBox.Text = tostring(settings.WalkSpeedValue)
end)

local function applyWalkSpeed()
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if humanoid and settings.WalkSpeed then
        humanoid.WalkSpeed = settings.WalkSpeedValue
    end
end

walkButton.MouseButton1Click:Connect(function()
    settings.WalkSpeed = not settings.WalkSpeed
    walkButton.Text = "WALKSPEED: " ..
        (settings.WalkSpeed and "ON" or "OFF")

    if not settings.WalkSpeed then
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")

        if humanoid then
            humanoid.WalkSpeed = 16
        end
    else
        applyWalkSpeed()
    end
end)

--========================================================
-- NOCLIP
--========================================================

local noclipButton = button("NOCLIP: OFF")

local originalCollision = {}
local noclipConnection = nil

local function saveAndDisableCollision()
    local character = player.Character
    if not character then return end

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then

            -- Save the original setting only once.
            if originalCollision[part] == nil then
                originalCollision[part] = part.CanCollide
            end

            part.CanCollide = false
        end
    end
end

local function restoreCollision()
    -- Stop NoClip before restoring collision.
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end

    for part, originalValue in pairs(originalCollision) do
        if part and part.Parent then
            part.CanCollide = originalValue
        end
    end

    table.clear(originalCollision)
end

local function enableNoClip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end

    settings.NoClip = true

    saveAndDisableCollision()

    noclipConnection = RunService.Stepped:Connect(function()
        if not settings.NoClip then return end
        saveAndDisableCollision()
    end)

    noclipButton.Text = "NOCLIP: ON"
    noclipButton.BackgroundColor3 = Color3.fromRGB(190, 90, 255)
end

local function disableNoClip()
    settings.NoClip = false

    -- Disconnect first, then restore.
    restoreCollision()

    noclipButton.Text = "NOCLIP: OFF"
    noclipButton.BackgroundColor3 = Color3.fromRGB(48, 53, 70)
end

noclipButton.MouseButton1Click:Connect(function()
    if settings.NoClip then
        disableNoClip()
    else
        enableNoClip()
    end
end)

--========================================================
-- DISTANCE LABELS / CLEANUP
--========================================================

RunService.RenderStepped:Connect(function()
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")

    for object, data in pairs(tracked) do
        if not object.Parent then
            removeESP(object)
        else
            local target = getTarget(object)

            if not target or not target.Parent then
                removeESP(object)
            elseif root then
                local distance = (root.Position - target.Position).Magnitude
                data.Label.Text = object.Name .. "\n"
                    .. math.floor(distance) .. " studs"
            end
        end
    end
end)

--========================================================
-- RESPAWN SUPPORT
--========================================================

player.CharacterAdded:Connect(function()
    stopFly()
    restoreCollision()

    task.wait(0.6)

    if settings.WalkSpeed then
        applyWalkSpeed()
    end

    if settings.PlayerESP then
        scanPlayers()
    end
end)

--========================================================
-- MINIMIZE
--========================================================

minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    content.Visible = not minimized

    frame.Size = minimized
        and UDim2.fromOffset(290, 44)
        or UDim2.fromOffset(290, 490)

    minimize.Text = minimized and "+" or "-"
end)

--========================================================
-- PERIODIC SCAN
--========================================================

RunService.Heartbeat:Connect(function(dt)
    scanTimer += dt

    if scanTimer >= 1.5 then
        scanTimer = 0

        if settings.PlayerESP or settings.NPCESP
        or settings.KeyESP or settings.CodeESP then
            scanWorld()
        end
    end

    if settings.WalkSpeed then
        applyWalkSpeed()
    end
end)

--========================================================
-- CLEANUP
--========================================================

gui.Destroying:Connect(function()
    stopFly()
    restoreCollision()

    for object in pairs(tracked) do
        removeESP(object)
    end
end)

print("ULTIMATE HORROR CONTROL V5 LOADED")
