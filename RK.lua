local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Workspace = game:GetService("Workspace")

-- الريموتات
local CmdSignal = ReplicatedStorage:FindFirstChild("HDAdminHDClient") and ReplicatedStorage.HDAdminHDClient:FindFirstChild("Signals") and ReplicatedStorage.HDAdminHDClient.Signals:FindFirstChild("RequestCommandModification")
local ChatRemote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("DataService")

-- [بناء الواجهة الأساسية]
if PlayerGui:FindFirstChild("MHNDSPAMGui") then PlayerGui.MHNDSPAMGui:Destroy() end
local ScreenGui = Instance.new("ScreenGui", PlayerGui); ScreenGui.Name = "MHNDSPAMGui"; ScreenGui.ResetOnSpawn = false; ScreenGui.Enabled = true

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 320, 0, 400); MainFrame.Position = UDim2.new(0.5, -160, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); MainFrame.Active = true; MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- الحقوق
local Title = Instance.new("TextLabel", MainFrame); Title.Size = UDim2.new(1, 0, 0, 40); Title.Text = "RK KLAN"; Title.Font = Enum.Font.GothamBold; Title.BackgroundTransparency = 1; Title.TextColor3 = Color3.new(1,1,1)
RunService.Heartbeat:Connect(function() Title.TextColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1) end)

local Close = Instance.new("TextButton", MainFrame); Close.Size = UDim2.new(0, 30, 0, 30); Close.Position = UDim2.new(1, -35, 0, 5); Close.Text = "X"; Close.BackgroundTransparency = 1; Close.TextColor3 = Color3.new(1,1,1)
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- العناصر
local Container = Instance.new("Frame", MainFrame); Container.Size = UDim2.new(1, 0, 1, -40); Container.Position = UDim2.new(0, 0, 0, 40); Container.BackgroundTransparency = 1
local CmdBox = Instance.new("TextBox", Container); CmdBox.Size = UDim2.new(0, 280, 0, 40); CmdBox.Position = UDim2.new(0, 20, 0, 10); CmdBox.PlaceholderText = "Command"; CmdBox.Text = "/nv"; CmdBox.BackgroundColor3 = Color3.fromRGB(30,30,30); CmdBox.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", CmdBox)
local SpeedBox = Instance.new("TextBox", Container); SpeedBox.Size = UDim2.new(0, 280, 0, 40); SpeedBox.Position = UDim2.new(0, 20, 0, 60); SpeedBox.PlaceholderText = "Speed"; SpeedBox.Text = "0.2"; SpeedBox.BackgroundColor3 = Color3.fromRGB(30,30,30); CmdBox.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", SpeedBox)

local function CreateBtn(text, pos, color)
    local btn = Instance.new("TextButton", Container); btn.Size = UDim2.new(0, 280, 0, 40); btn.Position = pos; btn.Text = text; btn.BackgroundColor3 = color; btn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", btn)
    return btn
end

local SendBtn = CreateBtn("ارسال مره واحده", UDim2.new(0, 20, 0, 110), Color3.fromRGB(30,30,30))
local SpamBtn = CreateBtn("سبام", UDim2.new(0, 20, 0, 160), Color3.fromRGB(30,30,30))
local BatchBtn = CreateBtn("تخريب", UDim2.new(0, 20, 0, 210), Color3.fromRGB(0, 100, 200))
local ShieldBtn = CreateBtn("حماية", UDim2.new(0, 20, 0, 260), Color3.fromRGB(30,30,30))

-- المنطق النهائي
local spamActive = false

-- 1. زر الإرسال
SendBtn.MouseButton1Click:Connect(function() 
    if ChatRemote then ChatRemote:FireServer(CmdBox.Text) end
    if CmdSignal then CmdSignal:InvokeServer(CmdBox.Text) end
end)

-- 2. زر السبام
SpamBtn.MouseButton1Click:Connect(function()
    spamActive = not spamActive; SpamBtn.Text = spamActive and "STOP SPAM" or "START SPAM"
    if spamActive then task.spawn(function() while spamActive do 
        if ChatRemote then ChatRemote:FireServer(CmdBox.Text) end
        if CmdSignal then CmdSignal:InvokeServer(CmdBox.Text) end
        task.wait(tonumber(SpeedBox.Text) or 0.2) 
    end end) end
end)

-- 3. زر التخريب
BatchBtn.MouseButton1Click:Connect(function()
    local cmd = CmdBox.Text
    local players = Players:GetPlayers()
    local batch = {}
    for i, p in pairs(players) do
        if p ~= LocalPlayer then
            table.insert(batch, p.Name)
            if #batch == 3 or i == #players then
                for _, name in pairs(batch) do if CmdSignal then CmdSignal:InvokeServer(cmd .. " " .. name) end end
                task.wait(3)
                batch = {}
            end
        end
    end
end)

-- 4. الحماية (الشاملة التي توقف الأوامر وتحذف التأثيرات)
ShieldBtn.MouseButton1Click:Connect(function()
    pcall(function()
        -- إيقاف الأوامر المتراكمة لمنع التعليق
        if ChatRemote then 
            ChatRemote:FireServer("/clear")
            ChatRemote:FireServer("/stop")
        end
        if CmdSignal then 
            CmdSignal:InvokeServer("clear")
            CmdSignal:InvokeServer("stop")
        end

        -- حذف التأثيرات البصرية من الكاميرا والإضاءة
        for _, v in pairs(Workspace.CurrentCamera:GetChildren()) do
            if v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") then v:Destroy() end
        end
        for _, v in pairs(game:GetService("Lighting"):GetChildren()) do
            if v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") then v:Destroy() end
        end
        
        -- حذف عناصر الأدمين
        local HD = PlayerGui:FindFirstChild("HDAdminInterface")
        if HD then HD:Destroy() end
        
        -- حذف أي شيء متعلق بـ NV
        for _, obj in pairs(game:GetDescendants()) do
            if obj.Name == "NightVision" or obj.Name == "NV" or obj.Name == "Blur" then 
                obj:Destroy() 
            end
        end
    end)
    
    ShieldBtn.Text = "CLEANED!"
    ShieldBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    task.wait(2)
    ShieldBtn.Text = "ENABLE SHIELD"
    ShieldBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
end)
