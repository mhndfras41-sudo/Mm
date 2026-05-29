local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "MasterPanel_23l8l22"
ScreenGui.ResetOnSpawn = false 

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 320); MainFrame.Position = UDim2.new(0.5, -125, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10); MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local dragging, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)

local UIStroke = Instance.new("UIStroke", MainFrame); UIStroke.Thickness = 3
task.spawn(function()
    while ScreenGui.Parent do
        for i = 0, 1, 0.02 do UIStroke.Color = Color3.fromHSV(i, 1, 1); task.wait(0.05) end
    end
end)

local HD_Remote = game:GetService("ReplicatedStorage"):WaitForChild("HDAdminHDClient", 5):WaitForChild("Signals", 5):WaitForChild("RequestCommandModification", 5)

local function ExecuteRandom(cmd)
    local targets = Players:GetPlayers()
    for _, p in pairs(targets) do
        if p ~= LocalPlayer and HD_Remote then
            task.spawn(function() HD_Remote:InvokeServer(cmd .. " " .. p.Name) end)
            task.wait(math.random(0.08, 0.15))
        end
    end
end

local function CreateButton(text, y, cmd)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0.85, 0, 0, 45); btn.Position = UDim2.new(0.075, 0, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25); btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255); btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(function() ExecuteRandom(cmd) end)
end

CreateButton("ICE RANDOM", 30, ";ice"); CreateButton("JAIL RANDOM", 85, ";jc")
CreateButton("TP RANDOM", 140, ";tp"); CreateButton("KILL RANDOM", 195, ";kill")
CreateButton("FAT RANDOM", 250, ";fat")
