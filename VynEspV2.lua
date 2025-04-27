-- LocalScript inside StarterGui/ESPGui

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- UI Setup
local ESPGui = script.Parent

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ESPFolder"
ESPFolder.Parent = ESPGui

-- Main Panel
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 120)
MainFrame.Position = UDim2.new(0, 10, 0, 10)
MainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ESPGui

-- UICorner for smooth rounding
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = MainFrame

-- Buttons inside Main Panel
local ModeButton = Instance.new("TextButton")
ModeButton.Parent = MainFrame
ModeButton.Size = UDim2.new(0, 200, 0, 40)
ModeButton.Position = UDim2.new(0, 10, 0, 10)
ModeButton.Text = "Mode: Box Only"
ModeButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
ModeButton.TextColor3 = Color3.new(1, 1, 1)
ModeButton.BorderSizePixel = 0

local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = MainFrame
ToggleButton.Size = UDim2.new(0, 200, 0, 40)
ToggleButton.Position = UDim2.new(0, 10, 0, 60)
ToggleButton.Text = "ESP: ON"
ToggleButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.BorderSizePixel = 0

-- Minimize Button (Circle)
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Parent = ESPGui
MinimizeButton.Size = UDim2.new(0, 40, 0, 40)
MinimizeButton.Position = UDim2.new(0, 10, 0, 10)
MinimizeButton.BackgroundColor3 = Color3.new(1, 1, 1)
MinimizeButton.Text = "+"
MinimizeButton.TextColor3 = Color3.new(0,0,0)
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.TextScaled = true
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Visible = false
local circleCorner = Instance.new("UICorner", MinimizeButton)
circleCorner.CornerRadius = UDim.new(1, 0)

-- Settings
local showNames = false
local espEnabled = true
local minimized = false

-- Tweens
local shrinkInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local growInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

ModeButton.MouseButton1Click:Connect(function()
    showNames = not showNames
    if showNames then
        ModeButton.Text = "Mode: Box + Name"
    else
        ModeButton.Text = "Mode: Box Only"
    end
end)

ToggleButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        ToggleButton.Text = "ESP: ON"
    else
        ToggleButton.Text = "ESP: OFF"
        for _, child in ipairs(ESPFolder:GetChildren()) do
            child.Visible = false
        end
    end
end)

-- Minimize / Maximize Smooth Animation
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        if not minimized then
            minimized = true

            local shrinkTween = TweenService:Create(MainFrame, shrinkInfo, {
                Size = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1
            })
            shrinkTween:Play()
            shrinkTween.Completed:Wait()

            MainFrame.Visible = false
            MinimizeButton.Visible = true
        end
    end
end)

MinimizeButton.MouseButton1Click:Connect(function()
    if minimized then
        minimized = false

        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        MainFrame.BackgroundTransparency = 1

        local growTween = TweenService:Create(MainFrame, growInfo, {
            Size = UDim2.new(0, 220, 0, 120),
            BackgroundTransparency = 0
        })
        growTween:Play()

        MinimizeButton.Visible = false
    end
end)

-- Functions
local function createESP(player)
    local box = Instance.new("Frame")
    box.Name = player.Name .. "_Box"
    box.AnchorPoint = Vector2.new(0.5, 0.5)
    box.Size = UDim2.new(0, 100, 0, 100)
    box.Position = UDim2.new(0.5, 0, 0.5, 0)
    box.BorderSizePixel = 2
    box.BackgroundTransparency = 1
    box.BorderColor3 = Color3.new(1,1,1)
    box.Visible = false
    box.Parent = ESPFolder

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = player.Name .. "_Name"
    nameLabel.AnchorPoint = Vector2.new(0.5, 1)
    nameLabel.Size = UDim2.new(0, 100, 0, 20)
    nameLabel.Position = UDim2.new(0.5, 0, 0, -10)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextScaled = true
    nameLabel.Text = player.Name
    nameLabel.Visible = false
    nameLabel.Parent = ESPFolder
end

local function removeESP(player)
    local box = ESPFolder:FindFirstChild(player.Name .. "_Box")
    if box then box:Destroy() end

    local name = ESPFolder:FindFirstChild(player.Name .. "_Name")
    if name then name:Destroy() end
end

RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local box = ESPFolder:FindFirstChild(player.Name .. "_Box")
            local nameLabel = ESPFolder:FindFirstChild(player.Name .. "_Name")

            if not box then
                createESP(player)
                box = ESPFolder:FindFirstChild(player.Name .. "_Box")
                nameLabel = ESPFolder:FindFirstChild(player.Name .. "_Name")
            end

            if espEnabled then
                local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local distance = (Camera.CFrame.Position - hrp.Position).Magnitude
                    local size = math.clamp(3000 / distance, 20, 200)

                    box.Size = UDim2.new(0, size, 0, size * 1.5)
                    box.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y)
                    box.Visible = true

                    if showNames and nameLabel then
                        nameLabel.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y - (size * 0.75))
                        nameLabel.Visible = true
                    elseif nameLabel then
                        nameLabel.Visible = false
                    end
                else
                    if box then box.Visible = false end
                    if nameLabel then nameLabel.Visible = false end
                end
            else
                if box then box.Visible = false end
                if nameLabel then nameLabel.Visible = false end
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

-- Dragging function
local UserInputService = game:GetService("UserInputService")

local function makeDraggable(frame)
    local dragging
    local dragInput
    local dragStart
    local startPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                       startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Make both MainFrame and MinimizeButton draggable
makeDraggable(MainFrame)
makeDraggable(MinimizeButton)