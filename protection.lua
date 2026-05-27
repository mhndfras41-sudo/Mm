-- ====================================================================
-- 👑 OWNER: 23l8l22 | SHIELD SYSTEM 👑
-- ====================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- [1] تنظيف سابق
if PlayerGui:FindFirstChild("ShieldUI") then PlayerGui.ShieldUI:Destroy() end

-- [2] إنشاء الواجهة
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

local BorderEffect = Instance.new("Frame", MainFrame)
BorderEffect.Size = UDim2.new(1, 4, 1, 4)
BorderEffect.Position = UDim2.new(0, -2, 0, -2)
BorderEffect.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
BorderEffect.BorderSizePixel = 0
BorderEffect.ZIndex = MainFrame.ZIndex - 1
Instance.new("UICorner", BorderEffect).CornerRadius = UDim.new(0, 14)

-- العنوان
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Text = " 🔰 23l8l22 PROTECTOR"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.BackgroundTransparency = 1

-- زر تشغيل الحماية
local ProtectionBtn = Instance.new("TextButton", MainFrame)
ProtectionBtn.Size = UDim2.new(0, 280, 0, 50)
ProtectionBtn.Position = UDim2.new(0, 20, 0, 55)
ProtectionBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
ProtectionBtn.Text = "تشغيل حماية" -- النص المطلوب
ProtectionBtn.TextColor3 = Color3.new(1, 1, 1)
ProtectionBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", ProtectionBtn).CornerRadius = UDim.new(0, 8)

-- توقيع الملك
local OwnerSign = Instance.new("TextLabel", MainFrame)
OwnerSign.Size = UDim2.new(1, 0, 0, 20)
OwnerSign.Position = UDim2.new(0, 0, 0, 125)
OwnerSign.Text = "👑 OWNER: 23l8l22"
OwnerSign.TextColor3 = Color3.fromRGB(100, 100, 100)
OwnerSign.Font = Enum.Font.Gotham
OwnerSign.TextSize = 12
OwnerSign.BackgroundTransparency = 1

-- [3] منطق الحماية
ProtectionBtn.MouseButton1Click:Connect(function()
    pcall(function()
        -- حذف الـ Logs
        local HD = PlayerGui:FindFirstChild("HDAdminInterface")
        if HD and HD:FindFirstChild("MenuTemplates") then
            HD.MenuTemplates:Destroy()
        end
        -- حذف الـ NightVision
        for _, obj in pairs(game:GetDescendants()) do
            if obj.Name == "NightVision" then
                obj:Destroy()
            end
        end
    end)
    
    -- تغيير النص واللون عند التشغيل
    ProtectionBtn.Text = "تم تشغيل حماية" -- النص المطلوب عند التشغيل
    ProtectionBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    BorderEffect.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
end)
