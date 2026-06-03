local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- الريموتات المحدثة
local DataServiceEvent = ReplicatedStorage:FindFirstChild("RemoteEvents") and ReplicatedStorage.RemoteEvents:FindFirstChild("DataService")
local CmdSignal = ReplicatedStorage:FindFirstChild("HDAdminHDClient") and ReplicatedStorage.HDAdminHDClient:FindFirstChild("Signals") and ReplicatedStorage.HDAdminHDClient.Signals:FindFirstChild("RequestCommandModification")

if PlayerGui:FindFirstChild("M7CommandGui") then PlayerGui.M7CommandGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "M7CommandGui"
ScreenGui.ResetOnSpawn = false 

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 320, 0, 280); MainFrame.Position = UDim2.new(0.5, -160, 0.5, -140)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20); MainFrame.BorderSizePixel = 0; MainFrame.Active = true
local Corner = Instance.new("UICorner", MainFrame); Corner.CornerRadius = UDim.new(0, 12)

-- نظام سحب احترافي
local dragToggle, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = true; dragStart = input.Position; startPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragToggle = false end end)

-- العنوان
local Title = Instance.new("TextLabel", MainFrame); Title.Size = UDim2.new(1, 0, 0, 40); Title.Text = "M7 Command"; Title.TextColor3 = Color3.fromRGB(255, 255, 255); Title.Font = Enum.Font.GothamBold; Title.TextSize = 16; Title.BackgroundTransparency = 1
local Close = Instance.new("TextButton", MainFrame); Close.Size = UDim2.new(0, 30, 0, 30); Close.Position = UDim2.new(1, -35, 0, 5); Close.Text = "✕"; Close.BackgroundTransparency = 1; Close.TextColor3 = Color3.new(1,1,1)
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- الخانات
local function CreateBox(y, placeholder)
    local box = Instance.new("TextBox", MainFrame); box.Size = UDim2.new(0, 280, 0, 40); box.Position = UDim2.new(0, 20, 0, y); box.BackgroundColor3 = Color3.fromRGB(25, 25, 35); box.TextColor3 = Color3.new(1,1,1); box.PlaceholderText = placeholder; box.Text = ""
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
    return box
end

local CmdBox = CreateBox(50, "Command e.g. ;fly")
local SpeedBox = CreateBox(100, "Speed (s)")
SpeedBox.Text = "0.2"

-- الأزرار
local function CreateBtn(y, text, color)
    local btn = Instance.new("TextButton", MainFrame); btn.Size = UDim2.new(0, 280, 0, 40); btn.Position = UDim2.new(0, 20, 0, y); btn.BackgroundColor3 = color; btn.Text = text; btn.TextColor3 = Color3.new(1,1,1); btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local SendBtn = CreateBtn(150, "SEND REMOTE", Color3.fromRGB(0, 120, 255))
local SpamBtn = CreateBtn(200, "START SPAM", Color3.fromRGB(255, 60, 60))

-- تنفيذ الأوامر عبر الريموتات الجديدة
local function SendCmd(cmd)
    pcall(function()
        if DataServiceEvent then DataServiceEvent:FireServer(cmd) end
        if CmdSignal then CmdSignal:InvokeServer(cmd) end
    end)
end

SendBtn.MouseButton1Click:Connect(function() SendCmd(CmdBox.Text) end)

local spamActive = false
SpamBtn.MouseButton1Click:Connect(function()
    spamActive = not spamActive
    SpamBtn.Text = spamActive and "STOP SPAM" or "START SPAM"
    if spamActive then
        task.spawn(function()
            while spamActive do
                SendCmd(CmdBox.Text)
                task.wait(tonumber(SpeedBox.Text) or 0.2)
            end
        end)
    end
end)
