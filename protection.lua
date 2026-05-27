-- 👑 OWNER: 23l8l22 | ULTIMATE SHIELD SYSTEM V5 👑
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Workspace = game:GetService("Workspace")

-- [1] تنظيف سابق للواجهة
if PlayerGui:FindFirstChild("ShieldUI") then PlayerGui.ShieldUI:Destroy() end

-- [2] إنشاء الواجهة الأساسية
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "ShieldUI"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 320, 0, 160)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -80)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local ProtectionBtn = Instance.new("TextButton", MainFrame)
ProtectionBtn.Size = UDim2.new(0, 280, 0, 50)
ProtectionBtn.Position = UDim2.new(0, 20, 0, 55)
ProtectionBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
ProtectionBtn.Text = "تشغيل الحماية الشاملة"
ProtectionBtn.TextColor3 = Color3.new(1, 1, 1)
ProtectionBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", ProtectionBtn).CornerRadius = UDim.new(0, 8)

-- [3] دالة التنظيف المستمرة
task.spawn(function()
    while true do
        local HD = PlayerGui:FindFirstChild("HDAdminInterface")
        if HD then
            -- حذف الإشعارات والـ Logs والـ ChatLogs
            if HD:FindFirstChild("Notices") then
                for _, notice in pairs(HD.Notices:GetChildren()) do notice:Destroy() end
            end
            if HD:FindFirstChild("MainFrame") and HD.MainFrame:FindFirstChild("Pages") then
                for _, page in pairs(HD.MainFrame.Pages:GetChildren()) do
                    if page.Name == "Logs" or page.Name == "ChatLogs" then page:Destroy() end
                end
            end
        end
        task.wait(0.3)
    end
end)

-- [4] منطق التنظيف الفوري (عند الضغط)
ProtectionBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local HD = PlayerGui:FindFirstChild("HDAdminInterface")
        
        -- مسح الـ Blur
        if Workspace.Camera:FindFirstChild("Blur") then Workspace.Camera.Blur:Destroy() end
        if Workspace:FindFirstChild("Sytem") and Workspace.Sytem:FindFirstChild("Blur") then Workspace.Sytem.Blur:Destroy() end
        
        -- مسح الـ CmdBar والـ CustomTopBar والـ MenuTemplates
        if HD then
            if HD:FindFirstChild("CmdBar") then HD.CmdBar:Destroy() end
            if HD:FindFirstChild("CustomTopBar") then HD.CustomTopBar:Destroy() end
            if HD:FindFirstChild("MenuTemplates") then HD.MenuTemplates:Destroy() end
        end
        
        -- مسح الـ NightVision
        for _, obj in pairs(game:GetDescendants()) do
            if obj.Name == "NightVision" then obj:Destroy() end
        end
    end)
    
    ProtectionBtn.Text = "تم تنظيف كل شيء!"
    ProtectionBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
end)
