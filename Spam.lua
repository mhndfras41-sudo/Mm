local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- الريموتات (تأكد من مساراتها في مابك)
local DataServiceEvent = ReplicatedStorage:FindFirstChild("RemoteEvents") and ReplicatedStorage.RemoteEvents:FindFirstChild("DataService")
local CmdSignal = ReplicatedStorage:FindFirstChild("HDAdminHDClient") and ReplicatedStorage.HDAdminHDClient:FindFirstChild("Signals") and ReplicatedStorage.HDAdminHDClient.Signals:FindFirstChild("RequestCommandModification")

if PlayerGui:FindFirstChild("MHNDSPAMGui") then PlayerGui.MHNDSPAMGui:Destroy() end
local ScreenGui = Instance.new("ScreenGui", PlayerGui); ScreenGui.Name = "MHNDSPAMGui"; ScreenGui.ResetOnSpawn = false 

-- الإطار الرئيسي
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 320, 0, 280); MainFrame.Position = UDim2.new(0.5, -160, 0.5, -140)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); MainFrame.Active = true; MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- العناصر
local Title = Instance.new("TextLabel", MainFrame); Title.Size = UDim2.new(0.5, 0, 0, 40); Title.Text = "MHND PRO"; Title.Font = Enum.Font.GothamBold; Title.BackgroundTransparency = 1
RunService.Heartbeat:Connect(function() Title.TextColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1) end)

local PlusBtn = Instance.new("TextButton", MainFrame); PlusBtn.Size = UDim2.new(0, 30, 0, 30); PlusBtn.Position = UDim2.new(1, -70, 0, 5); PlusBtn.Text = "+"; PlusBtn.BackgroundTransparency = 1; PlusBtn.TextColor3 = Color3.new(1,1,1); PlusBtn.Visible = false
local MinBtn = Instance.new("TextButton", MainFrame); MinBtn.Size = UDim2.new(0, 30, 0, 30); MinBtn.Position = UDim2.new(1, -70, 0, 5); MinBtn.Text = "-"; MinBtn.BackgroundTransparency = 1; MinBtn.TextColor3 = Color3.new(1,1,1)
local Close = Instance.new("TextButton", MainFrame); Close.Size = UDim2.new(0, 30, 0, 30); Close.Position = UDim2.new(1, -35, 0, 5); Close.Text = "X"; Close.BackgroundTransparency = 1; Close.TextColor3 = Color3.new(1,1,1)
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local Container = Instance.new("Frame", MainFrame); Container.Size = UDim2.new(1, 0, 1, -40); Container.Position = UDim2.new(0, 0, 0, 40); Container.BackgroundTransparency = 1

local CmdBox = Instance.new("TextBox", Container); CmdBox.Size = UDim2.new(0, 280, 0, 40); CmdBox.Position = UDim2.new(0, 20, 0, 10); CmdBox.PlaceholderText = "Command"; CmdBox.Text = "/nv user"; CmdBox.BackgroundColor3 = Color3.fromRGB(30,30,30); CmdBox.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", CmdBox)
local SpeedBox = Instance.new("TextBox", Container); SpeedBox.Size = UDim2.new(0, 280, 0, 40); SpeedBox.Position = UDim2.new(0, 20, 0, 60); SpeedBox.PlaceholderText = "Speed"; SpeedBox.Text = "0.2"; SpeedBox.BackgroundColor3 = Color3.fromRGB(30,30,30); SpeedBox.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", SpeedBox)
local SendBtn = Instance.new("TextButton", Container); SendBtn.Size = UDim2.new(0, 280, 0, 40); SendBtn.Position = UDim2.new(0, 20, 0, 110); SendBtn.Text = "SEND ONE"; SendBtn.BackgroundColor3 = Color3.fromRGB(30,30,30); SendBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", SendBtn)
local SpamBtn = Instance.new("TextButton", Container); SpamBtn.Size = UDim2.new(0, 280, 0, 40); SpamBtn.Position = UDim2.new(0, 20, 0, 160); SpamBtn.Text = "START SPAM"; SpamBtn.BackgroundColor3 = Color3.fromRGB(30,30,30); SpamBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", SpamBtn)

-- منطق التبديل الاحترافي
MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Size = UDim2.new(0, 150, 0, 40); Container.Visible = false; MinBtn.Visible = false; Close.Visible = false; PlusBtn.Visible = true
end)

PlusBtn.MouseButton1Click:Connect(function()
    MainFrame.Size = UDim2.new(0, 320, 0, 280); Container.Visible = true; MinBtn.Visible = true; Close.Visible = true; PlusBtn.Visible = false
end)

-- منطق الريموتات
local function SendCmd(cmd) pcall(function() if DataServiceEvent then DataServiceEvent:FireServer(cmd) end; if CmdSignal then CmdSignal:InvokeServer(cmd) end end) end
SendBtn.MouseButton1Click:Connect(function() SendCmd(CmdBox.Text) end)
local spamActive = false
SpamBtn.MouseButton1Click:Connect(function()
    spamActive = not spamActive; SpamBtn.Text = spamActive and "STOP SPAM" or "START SPAM"
    if spamActive then task.spawn(function() while spamActive do SendCmd(CmdBox.Text); task.wait(tonumber(SpeedBox.Text) or 0.2) end end) end
end)
