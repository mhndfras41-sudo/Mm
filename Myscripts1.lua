-- 👑 23l8l22 | EXCLUSIVE MASTER LOADER [PERMANENT] 👑
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

-- [1] إنشاء الواجهة (مع تفعيل عدم الاختفاء عند الموت)
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "MasterLoader_23l8l22"
ScreenGui.ResetOnSpawn = false -- لن تختفي الواجهة عند الموت

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 260, 0, 220)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- [2] إطار النيون المتحرك
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Thickness = 3
task.spawn(function()
    while ScreenGui.Parent do
        for i = 0, 1, 0.02 do
            UIStroke.Color = Color3.fromHSV(i, 1, 1)
            task.wait(0.05)
        end
    end
end)

-- [3] الحقوق
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "👑 23l8l22 MASTER"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.BackgroundTransparency = 1

-- [4] دالة إنشاء الأزرار
local function CreateBtn(text, pos, link)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0.8, 0, 0, 40)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamSemibold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    btn.MouseButton1Click:Connect(function()
        btn.Text = "جاري التحميل..."
        task.spawn(function()
            local success, err = pcall(function() loadstring(game:HttpGet(link))() end)
            if success then btn.Text = "تم التفعيل!" else btn.Text = "خطأ!" end
            task.wait(2)
            btn.Text = text
        end)
    end)
end

-- [5] إضافة الأزرار (تم تحديث رابط التخريب)
CreateBtn("سكربت نسخ", UDim2.new(0.1, 0, 0.25, 0), "https://raw.githubusercontent.com/mhndfras41-sudo/Mm/refs/heads/main/Spam.lua")
CreateBtn("سكربت مضاد نسخ", UDim2.new(0.1, 0, 0.45, 0), "https://raw.githubusercontent.com/mhndfras41-sudo/Mm/refs/heads/main/protection.lua")
CreateBtn("سكربت تخريب", UDim2.new(0.1, 0, 0.65, 0), "https://raw.githubusercontent.com/mhndfras41-sudo/Mm/refs/heads/main/t7'reb1.lua")

-- زر إغلاق
local Close = Instance.new("TextButton", MainFrame)
Close.Size = UDim2.new(0, 20, 0, 20); Close.Position = UDim2.new(1, -25, 0, 5)
Close.Text = "X"; Close.BackgroundTransparency = 1; Close.TextColor3 = Color3.new(1,0,0)
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
