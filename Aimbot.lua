-- Gui to Lua
-- Version: 3.2

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- القائمة البيضاء: ضيف هنا أسماء اللاعبين اللي تبي تستهدفهم (نفس الاسم في اللعبة)
local Whitelist = {
    "Player1",
    "Player2",
    -- ضع أسماء أخرى هنا أو اترك الجدول فاضي يعني يستهدف أقرب لاعب من القائمة البيضاء
}

local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local Frame_2 = Instance.new("Frame")
local TextLabel = Instance.new("TextLabel")
local TextButton = Instance.new("TextButton")
local TextButton_2 = Instance.new("TextButton")
local TextLabel_2 = Instance.new("TextLabel")

ScreenGui.Name = "AimbotGui"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
Frame.BorderColor3 = Color3.fromRGB(16, 16, 16)
Frame.Position = UDim2.new(0.326, 0, 0.442, 0)
Frame.Size = UDim2.new(0.346, 0, 0.194, 0)
Frame.Active = true
Frame.Selectable = true
Frame.Draggable = true

Frame_2.Parent = Frame
Frame_2.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
Frame_2.BorderColor3 = Color3.fromRGB(16, 16, 16)
Frame_2.Size = UDim2.new(1, 0, 0.267, 0)

TextLabel.Parent = Frame_2
TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.BackgroundTransparency = 1
TextLabel.Size = UDim2.new(1, 0, 1, 0)
TextLabel.Font = Enum.Font.SourceSansSemibold
TextLabel.Text = "تصميم انور"
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.TextSize = 16

TextButton.Parent = Frame_2
TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextButton.BackgroundTransparency = 1
TextButton.Position = UDim2.new(0.93, 0, 0, 0)
TextButton.Size = UDim2.new(0.07, 0, 1, 0)
TextButton.Font = Enum.Font.SourceSansSemibold
TextButton.Text = "_"
TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TextButton.TextSize = 14

TextButton_2.Parent = Frame
TextButton_2.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TextButton_2.BorderColor3 = Color3.fromRGB(20, 20, 20)
TextButton_2.Position = UDim2.new(0.05, 0, 0.49, 0)
TextButton_2.Size = UDim2.new(0.1, 0, 0.3, 0)
TextButton_2.Font = Enum.Font.SourceSansSemibold
TextButton_2.Text = ""
TextButton_2.TextColor3 = Color3.fromRGB(255, 255, 255)
TextButton_2.TextScaled = true
TextButton_2.TextSize = 20
TextButton_2.TextWrapped = true

TextLabel_2.Parent = TextButton_2
TextLabel_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextLabel_2.BackgroundTransparency = 1
TextLabel_2.Position = UDim2.new(1.55, 0, 0, 0)
TextLabel_2.Size = UDim2.new(17.8, 0, 1, 0)
TextLabel_2.Font = Enum.Font.SourceSansSemibold
TextLabel_2.Text = "Aimbot"
TextLabel_2.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel_2.TextSize = 16
TextLabel_2.TextWrapped = true
TextLabel_2.TextXAlignment = Enum.TextXAlignment.Left

local AimEnabled = false
local TargetPlayer = nil
local PredictionAmount = 0.1
local headHitChance = 0.65

-- دالة للبحث عن أقرب لاعب في القائمة البيضاء على الشاشة
local function getClosestWhitelistPlayer()
    local nearest = nil
    local shortestDist = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid")
            and player.Character.Humanoid.Health > 0 then

            -- فقط إذا الاسم موجود في القائمة البيضاء أو إذا القائمة فاضية يعني نسمح للجميع
            if #Whitelist == 0 or table.find(Whitelist, player.Name) then
                local screenPos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        nearest = player
                    end
                end
            end
        end
    end
    return nearest
end

local function updateTargetName(name)
    if name then
        TextLabel_2.Text = "Aimbot على: " .. name
    else
        TextLabel_2.Text = "Aimbot"
    end
end

local function toggleAim()
    AimEnabled = not AimEnabled
    if AimEnabled then
        TextButton_2.Text = "ON"
    else
        TextButton_2.Text = ""
        updateTargetName(nil)
    end
end

TextButton_2.MouseButton1Click:Connect(toggleAim)

RunService.RenderStepped:Connect(function()
    if AimEnabled then
        TargetPlayer = getClosestWhitelistPlayer()
        if TargetPlayer and TargetPlayer.Character then
            updateTargetName(TargetPlayer.Name)
            local hrp = TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
            local head = TargetPlayer.Character:FindFirstChild("Head")
            if hrp and head then
                local camPos = Camera.CFrame.Position
                local predictedPos = hrp.Position + hrp.Velocity * PredictionAmount
                local aimPos
                if math.random() < headHitChance then
                    aimPos = head.Position
                else
                    aimPos = predictedPos
                end
                local newCFrame = CFrame.new(camPos, aimPos)
                Camera.CFrame = Camera.CFrame:Lerp(newCFrame, 0.4)
            end
        else
            updateTargetName(nil)
        end
    end
end)

-- المحافظة على عمل السكربت بعد الموت أو إعادة الراوند
LocalPlayer.CharacterAdded:Connect(function()
    -- لا حاجة لإزالة الـ GUI أو إيقاف السكربت، يبقى شغال
end)

TextButton.MouseButton1Down:Connect(function()
    local state = Frame.BackgroundTransparency == 0
    if state then
        Frame.BackgroundTransparency = 1
        for _, v in pairs(Frame:GetChildren()) do
            if v:IsA("TextButton") and v ~= TextButton then
                v.Visible = false
            elseif v:IsA("TextLabel") then
                v.Visible = false
            end
        end
        TextButton.Text = "+"
    else
        Frame.BackgroundTransparency = 0
        for _, v in pairs(Frame:GetChildren()) do
            if v:IsA("TextButton") then
                v.Visible = true
            elseif v:IsA("TextLabel") then
                v.Visible = true
            end
        end
        TextButton.Text = "_"
    end
end)
