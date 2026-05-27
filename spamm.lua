====================================================================
-- 🔥 23l8l22 DRAGGABLE ULTIMATE PANEL v8 (COMBINED BOX & FIX SYNTAX) 🔥
-- ====================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- تنظيف الواجهة القديمة لمنع التداخل
if PlayerGui:FindFirstChild("ZelTargetPanel_23l8l22") then
    PlayerGui.ZelTargetPanel_23l8l22:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZelTargetPanel_23l8l22"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 360, 0, 280)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -140)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- نظام السحب السلس والذكي للموبايل
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then update(input) end
end)

-- بار النيون المتوهج
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 4)
TopBar.BackgroundColor3 = Color3.fromRGB(255, 0, 127)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 12)
TopCorner.Parent = TopBar

-- توقيع المالك الأسطوري
local OwnerTitle = Instance.new("TextLabel")
OwnerTitle.Size = UDim2.new(1, -40, 0, 35)
OwnerTitle.Position = UDim2.new(0, 15, 0, 4)
OwnerTitle.BackgroundTransparency = 1
OwnerTitle.Text = "👑 OWNER: 23l8l22"
OwnerTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
OwnerTitle.TextSize = 14
OwnerTitle.Font = Enum.Font.GothamBold
OwnerTitle.TextXAlignment = Enum.TextXAlignment.Left
OwnerTitle.Parent = MainFrame

-- زر الإغلاق (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = MainFrame
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- ====================================================================
-- [الجانب الأيسر: قائمة اللاعبين واختيار الهدف]
-- ====================================================================
local ListLabel = Instance.new("TextLabel")
ListLabel.Size = UDim2.new(0, 160, 0, 20)
ListLabel.Position = UDim2.new(0, 15, 0, 45)
ListLabel.BackgroundTransparency = 1
ListLabel.Text = "🎯 اختر الهدف من السيرفر:"
ListLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
ListLabel.TextSize = 11
ListLabel.Font = Enum.Font.GothamBold
ListLabel.TextXAlignment = Enum.TextXAlignment.Left
ListLabel.Parent = MainFrame

local PlayerScroller = Instance.new("ScrollingFrame")
PlayerScroller.Size = UDim2.new(0, 160, 0, 160)
PlayerScroller.Position = UDim2.new(0, 15, 0, 70)
PlayerScroller.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
PlayerScroller.BorderSizePixel = 0
PlayerScroller.ScrollBarThickness = 4
PlayerScroller.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerScroller.Parent = MainFrame

local ScrollCorner = Instance.new("UICorner")
ScrollCorner.CornerRadius = UDim.new(0, 6)
ScrollCorner.Parent = PlayerScroller

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 4)
ListLayout.Parent = PlayerScroller

local SelectedTargetName = ""

-- تحديث السيرفر بالكامل وإظهار الكل
local function UpdatePlayerList()
    for _, child in pairs(PlayerScroller:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    local allPlayers = Players:GetPlayers()
    PlayerScroller.CanvasSize = UDim2.new(0, 0, 0, (#allPlayers * 32))
    
    for _, p in pairs(allPlayers) do
        if p ~= LocalPlayer then
            local PBtn = Instance.new("TextButton")
            PBtn.Size = UDim2.new(1, -6, 0, 28)
            PBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
            PBtn.Text = " " .. p.Name
            PBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
            PBtn.TextSize = 11
            PBtn.Font = Enum.Font.Gotham
            PBtn.TextXAlignment = Enum.TextXAlignment.Left
            PBtn.BorderSizePixel = 0
            PBtn.Parent = PlayerScroller
            
            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 4)
            BtnCorner.Parent = PBtn
            
            PBtn.MouseButton1Click:Connect(function()
                SelectedTargetName = p.Name
                ListLabel.Text = "🎯 الهدف الحالي: " .. p.Name
                ListLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
            end)
        end
    end
end
UpdatePlayerList()
Players.PlayerAdded:Connect(UpdatePlayerList)
Players.PlayerRemoving:Connect(UpdatePlayerList)

-- تغيير اسم الزر إلى "تجهيز" فقط ⚙️
local SetupButton = Instance.new("TextButton")
SetupButton.Size = UDim2.new(0, 160, 0, 35)
SetupButton.Position = UDim2.new(0, 15, 0, 235)
SetupButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
SetupButton.Text = "⚙️ تجهيز"
SetupButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SetupButton.TextSize = 13
SetupButton.Font = Enum.Font.GothamBold
SetupButton.Parent = MainFrame
local SetupCorner = Instance.new("UICorner")
SetupCorner.CornerRadius = UDim.new(0, 6)
SetupCorner.Parent = SetupButton

-- ====================================================================
-- [الجانب الأيمن: الخانة المدمجة الجديدة والتشغيل]
-- ====================================================================
local CustomLabel = Instance.new("TextLabel")
CustomLabel.Size = UDim2.new(0, 160, 0, 20)
CustomLabel.Position = UDim2.new(0, 185, 0, 45)
CustomLabel.BackgroundTransparency = 1
CustomLabel.Text = "✏️ هجوم حر ومخصص:"
CustomLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
CustomLabel.TextSize = 11
CustomLabel.Font = Enum.Font.GothamBold
CustomLabel.TextXAlignment = Enum.TextXAlignment.Left
CustomLabel.Parent = MainFrame

-- الخانة المدمجة الجديدة كلياً (تكتب فيها الأمر والاسم معاً)
local CombinedBox = Instance.new("TextBox")
CombinedBox.Size = UDim2.new(0, 160, 0, 72) -- جعلناها أكبر لتستوعب الكتابة المستمرة
CombinedBox.Position = UDim2.new(0, 185, 0, 70)
CombinedBox.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
CombinedBox.Text = ";nv user" -- النص التوضيحي الذي طلبته 🎯
CombinedBox.TextColor3 = Color3.fromRGB(150, 150, 150)
CombinedBox.TextSize = 11
CombinedBox.Font = Enum.Font.Gotham
CombinedBox.TextWrapped = true
CombinedBox.ClearTextOnFocus = true
CombinedBox.Parent = MainFrame
local BoxCorner = Instance.new("UICorner")
BoxCorner.CornerRadius = UDim.new(0, 6)
BoxCorner.Parent = CombinedBox

local AttackButton = Instance.new("TextButton")
AttackButton.Size = UDim2.new(0, 160, 0, 75)
AttackButton.Position = UDim2.new(0, 185, 0, 155)
AttackButton.BackgroundColor3 = Color3.fromRGB(255, 0, 127)
AttackButton.Text = "🚀 بدء تدمير الهدف"
AttackButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AttackButton.TextSize = 13
AttackButton.Font = Enum.Font.GothamBold
AttackButton.Parent = MainFrame
local AttackCorner = Instance.new("UICorner")
AttackCorner.CornerRadius = UDim.new(0, 8)
AttackCorner.Parent = AttackButton

local Credits = Instance.new("TextLabel")
Credits.Size = UDim2.new(0, 160, 0, 20)
Credits.Position = UDim2.new(0, 185, 0, 242)
Credits.BackgroundTransparency = 1
Credits.Text = "MADE BY 23l8l22 © 2026"
Credits.TextColor3 = Color3.fromRGB(255, 0, 127)
Credits.TextSize = 9
Credits.Font = Enum.Font.GothamBold
Credits.Parent = MainFrame

-- ====================================================================
-- [محرك الإرسال والتدمير السريع الخارق]
-- ====================================================================
local spamActive = false
local FinalPayload = ""

local function FireRemotes(cmdText)
    if cmdText == "" then return end
    local clean = cmdText:gsub("%s+$", "")
    local dotted = clean
    -- إذا لم يبدأ بنقطة أو فاصلة منقوطة، نضع له نقطة لضمان عمل الريموت المباشر
    if not string.match(clean, "^%.") and not string.match(clean, "^;") then
        dotted = "." .. clean
    end
    
    pcall(function()
        local chatEvent = ReplicatedStorage:FindFirstChild("RemoteEvents") and ReplicatedStorage.RemoteEvents:FindFirstChild("ChatEvent")
        if chatEvent and chatEvent:IsA("RemoteEvent") then chatEvent:FireServer(clean) end
    end)
    pcall(function()
        local hdSignals = ReplicatedStorage:FindFirstChild("HDAdminHDClient") and ReplicatedStorage.HDAdminHDClient:FindFirstChild("Signals")
        if hdSignals then
            local cmdMod = hdSignals:FindFirstChild("RequestCommandModification")
            if cmdMod and cmdMod:IsA("RemoteFunction") then
                cmdMod:InvokeServer(dotted)
                cmdMod:InvokeServer(clean)
            end
        end
    end)
end
