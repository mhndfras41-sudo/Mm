--[[
    MHND HUB
    HELPER MHND HUB - Player Copy Utility
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ========== Services Setup ==========
local DataService = nil
local HDAdminSignal = nil

local function getDataService()
    if not ReplicatedStorage then return nil end
    local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
    if remoteEvents then
        return remoteEvents:FindFirstChild("DataService")
    end
    return nil
end

local function getHDAdminSignal()
    if not ReplicatedStorage then return nil end
    local hdAdmin = ReplicatedStorage:FindFirstChild("HDAdminHDClient")
    if hdAdmin then
        local signals = hdAdmin:FindFirstChild("Signals")
        if signals then
            return signals:FindFirstChild("RequestCommandModification")
        end
    end
    return nil
end

DataService = getDataService()
HDAdminSignal = getHDAdminSignal()

-- Configuration variables
local gamedMode = false
local copyMode = "virtual"
local customSendDelay = 0.05

local selectedPlayers = {}
local savedPlayers = {}

local copyActive = false
local copyTask = nil
local activePlayer = nil
local currentCommands = ""

-- ========== Theme Colors ==========
local colors = {
    bg = Color3.fromRGB(15, 15, 15),
    bgLight = Color3.fromRGB(30, 30, 30),
    accent = Color3.fromRGB(255, 255, 255),
    accentDark = Color3.fromRGB(70, 70, 70),
    accentGlow = Color3.fromRGB(255, 255, 255),
    text = Color3.fromRGB(240, 240, 240),
    textDim = Color3.fromRGB(160, 160, 160),
    success = Color3.fromRGB(50, 200, 50),
    danger = Color3.fromRGB(220, 50, 50),
    warning = Color3.fromRGB(255, 150, 0),
    purple = Color3.fromRGB(150, 80, 255),
    grayTab = Color3.fromRGB(80, 90, 85)
}

-- ========== Presets ==========
local presets = {
    { name = "نسخ عادي", commands = "/logs sa /re sa /nv sa /clogs sa /logs sa /re sa /nv sa /clogs sa /logs sa /re sa /nv sa /clogs sa /logs sa /re sa /nv sa /clogs sa" },
    { name = "نسخ قوي", commands = "/logs sa /re sa /nv sa /logs sa /re sa /logs sa /re sa /logs sa /re sa /logs sa /re sa /logs sa /re sa /logs sa /re sa" },
    { name = "نسخ حلو", commands = "/char sa miri !dog sa /sit sa /jp sa /tp sa /Titlepk sa love" },
    { name = "نسخ قوي 2", commands = "/logs sa /re sa /res sa /nv sa /logs sa /re sa /res sa /logs sa /re sa /res sa /logs sa /re sa /res sa /logs sa /re sa /res sa /logs sa /re sa /res sa /logs sa /re sa /res sa" },
    { name = "نسخ حماية", commands = "/logs sa /re sa /logs sa /re sa /logs sa /re sa /logs sa /re sa /logs sa /re sa /logs sa /re sa /logs sa /re sa /logs sa /re sa /logs sa /re sa /logs sa /re sa /logs sa /re sa /logs sa /re sa /logs sa /re sa /logs sa /re sa /logs sa /re sa" },
    { name = "نسخ الهيد", commands = "/explode sa /re sa /logs sa /explode sa /re sa /logs sa /explode sa /re sa /logs sa /explode sa /re sa /logs sa /explode sa /re sa /logs sa /explode sa /re sa /logs sa" },
    { name = "نسخ الحماية القوية", commands = "/re sa /res sa /logs sa /re sa /res sa /logs sa /re sa /res sa /re sa /res sa /re sa /res sa /re sa /res sa /logs sa /re sa /res sa /logs sa /re sa /res sa /re sa /re sa /re sa /re sa /re sa /re sa /logs sa /re sa /res sa /logs sa /re sa /res sa" },
    { name = "نسخ غامض", commands = "/clogs sa /explode sa /re sa /loopwarp sa /logs sa /explode sa /nv sa /clogs sa /explode sa /re sa /clogs sa /explode sa /re sa /clogs sa /explode sa /re sa /clogs sa /explode sa /re sa /clogs sa /explode sa /re sa /clogs sa /explode sa /re sa" },
    { name = "نسخ هيد قوي", commands = "/explode sa /clogs sa /re sa /logs sa /nv sa /explode sa /clogs sa /re sa /explode sa /clogs sa /re sa /explode sa /clogs sa /re sa /explode sa /clogs sa /re sa /explode sa /clogs sa /re sa /explode sa /clogs sa /re sa" },
    { name = "نسخ غامض قوي", commands = "/explode sa /clogs sa /re sa /loopwarp sa /explode sa /logs sa /re sa /explode sa /clogs sa /re sa /loopwarp sa /explode sa /logs sa /re sa /explode sa /clogs sa /re sa /loopwarp sa /explode sa /logs sa /re sa /explode sa /clogs sa /re sa /loopwarp sa /explode sa /logs sa /re sa" },
}

local presetColors = {
    Color3.fromRGB(0, 120, 200),
    Color3.fromRGB(200, 120, 50),
    Color3.fromRGB(150, 80, 180),
    Color3.fromRGB(200, 70, 70),
    Color3.fromRGB(100, 150, 200),
    Color3.fromRGB(80, 200, 150),
    Color3.fromRGB(200, 200, 80),
    Color3.fromRGB(150, 100, 200),
    Color3.fromRGB(200, 100, 100),
    Color3.fromRGB(100, 200, 200),
}

local customPresets = {}

-- ========== Data Saving & Loading (Tabs) ==========
local function saveCustomTabs()
    pcall(function()
        writefile("MHND_HUB_CustomTabs.json", HttpService:JSONEncode(customPresets))
    end)
end

local function loadCustomTabs()
    local success, data = pcall(function() return readfile("MHND_HUB_CustomTabs.json") end)
    if success and data then
        local decoded = HttpService:JSONDecode(data)
        if type(decoded) == "table" then customPresets = decoded end
    else
        customPresets = {}
    end
end
loadCustomTabs()

-- ========== Command Execution ==========
local function sendCommand(cmd)
    if cmd == "" then return false end
    if HDAdminSignal then
        pcall(function() HDAdminSignal:InvokeServer(cmd) end)
    end
    if DataService then
        pcall(function() DataService:FireServer(cmd) end)
    end
    return true
end

local function getDelay()
    return customSendDelay
end

-- ========== Data Saving & Loading (Players) ==========
local function savePlayers()
    pcall(function()
        writefile("MHND_HUB_SavedPlayers.json", HttpService:JSONEncode(savedPlayers))
    end)
end

local function loadPlayers()
    local success, data = pcall(function() return readfile("MHND_HUB_SavedPlayers.json") end)
    if success and data then
        local decoded = HttpService:JSONDecode(data)
        if type(decoded) == "table" then savedPlayers = decoded end
    else
        savedPlayers = {}
    end
end
loadPlayers()

-- ========== Main UI Creation ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MHND_HUB_GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- Toggle Button
local ToggleButton = Instance.new("ImageButton")
ToggleButton.Size = UDim2.new(0, 80, 0, 80)
ToggleButton.Position = UDim2.new(0, 18, 0, 50)
ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleButton.BackgroundTransparency = 0.12
ToggleButton.Image = "rbxassetid://120436250543882"
ToggleButton.ScaleType = Enum.ScaleType.Fit
ToggleButton.BorderSizePixel = 0
ToggleButton.Active = true
ToggleButton.Draggable = true
ToggleButton.Parent = ScreenGui

Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 16)

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = colors.accent
ToggleStroke.Thickness = 3
ToggleStroke.Transparency = 0.15
ToggleStroke.Parent = ToggleButton

local ToggleLabel = Instance.new("TextLabel")
ToggleLabel.Size = UDim2.new(1, 0, 0, 22)
ToggleLabel.Position = UDim2.new(0, 0, 1, 4)
ToggleLabel.BackgroundTransparency = 1
ToggleLabel.Text = "MHND HUB"
ToggleLabel.TextColor3 = colors.accent
ToggleLabel.Font = Enum.Font.GothamBold
ToggleLabel.TextSize = 13
ToggleLabel.Parent = ToggleButton

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 640)
MainFrame.Position = UDim2.new(0, 110, 0, 20)
MainFrame.BackgroundColor3 = colors.bg
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = colors.accent
MainStroke.Thickness = 2
MainStroke.Transparency = 0.3
MainStroke.Parent = MainFrame

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundColor3 = colors.bgLight
Header.BorderSizePixel = 0
Header.Active = true
Header.Parent = MainFrame

Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 14)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 0, 22)
TitleLabel.Position = UDim2.new(0, 15, 0, 5)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "MHND HUB"
TitleLabel.TextColor3 = colors.accent
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextSize = 15
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local SubtitleLabel = Instance.new("TextLabel")
SubtitleLabel.Size = UDim2.new(1, -40, 0, 12)
SubtitleLabel.Position = UDim2.new(0, 15, 0, 27)
SubtitleLabel.BackgroundTransparency = 1
SubtitleLabel.Text = "HELPER MHND HUB"
SubtitleLabel.TextColor3 = colors.textDim
SubtitleLabel.Font = Enum.Font.Gotham
SubtitleLabel.TextSize = 9
SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
SubtitleLabel.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -38, 0.5, -15)
CloseButton.BackgroundColor3 = colors.danger
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 16
CloseButton.Parent = Header

Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0, 7)

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -10, 1, -48)
ScrollFrame.Position = UDim2.new(0, 5, 0, 46)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 3
ScrollFrame.ScrollBarImageColor3 = colors.accent
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 1100)
ScrollFrame.Parent = MainFrame

-- ========== Copy Settings Section ==========
local SettingsFrame = Instance.new("Frame")
SettingsFrame.Size = UDim2.new(1, -20, 0, 90)
SettingsFrame.Position = UDim2.new(0, 10, 0, 5)
SettingsFrame.BackgroundColor3 = colors.bgLight
SettingsFrame.BackgroundTransparency = 0.3
SettingsFrame.Parent = ScrollFrame

Instance.new("UICorner", SettingsFrame).CornerRadius = UDim.new(0, 10)

local SettingsLabel = Instance.new("TextLabel")
SettingsLabel.Size = UDim2.new(1, -10, 0, 20)
SettingsLabel.Position = UDim2.new(0, 5, 0, 5)
SettingsLabel.BackgroundTransparency = 1
SettingsLabel.Text = "⚙ إعدادات النسخ"
SettingsLabel.TextColor3 = colors.accent
SettingsLabel.Font = Enum.Font.GothamBold
SettingsLabel.TextSize = 11
SettingsLabel.TextXAlignment = Enum.TextXAlignment.Left
SettingsLabel.Parent = SettingsFrame

local ModeButtonsFrame = Instance.new("Frame")
ModeButtonsFrame.Size = UDim2.new(1, -10, 0, 24)
ModeButtonsFrame.Position = UDim2.new(0, 5, 0, 28)
ModeButtonsFrame.BackgroundTransparency = 1
ModeButtonsFrame.Parent = SettingsFrame

local function createModeButton(text, position)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.32, 0, 1, 0)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    button.Text = text
    button.TextColor3 = colors.text
    button.Font = Enum.Font.GothamBold
    button.TextSize = 11
    button.Parent = ModeButtonsFrame
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)
    return button
end

local VirtualModeButton = createModeButton("وهمي", UDim2.new(0, 0, 0, 0))
local NormalModeButton = createModeButton("عادي", UDim2.new(0.34, 0, 0, 0))
local GamedModeButton = createModeButton("غامض", UDim2.new(0.68, 0, 0, 0))

-- Speed Section
local SpeedContainer = Instance.new("Frame")
SpeedContainer.Size = UDim2.new(1, -10, 0, 24)
SpeedContainer.Position = UDim2.new(0, 5, 0, 56)
SpeedContainer.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
SpeedContainer.Parent = SettingsFrame

Instance.new("UICorner", SpeedContainer).CornerRadius = UDim.new(0, 6)

local SpeedTitleLabel = Instance.new("TextLabel")
SpeedTitleLabel.Size = UDim2.new(0.45, 0, 1, 0)
SpeedTitleLabel.Position = UDim2.new(0, 8, 0, 0)
SpeedTitleLabel.BackgroundTransparency = 1
SpeedTitleLabel.Text = "سرعة النسخ:"
SpeedTitleLabel.TextColor3 = colors.text
SpeedTitleLabel.Font = Enum.Font.GothamBold
SpeedTitleLabel.TextSize = 10
SpeedTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedTitleLabel.Parent = SpeedContainer

local SpeedInputBox = Instance.new("TextBox")
SpeedInputBox.Size = UDim2.new(0.5, 0, 1, -4)
SpeedInputBox.Position = UDim2.new(0.48, 0, 0, 2)
SpeedInputBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
SpeedInputBox.Text = tostring(customSendDelay)
SpeedInputBox.TextColor3 = colors.accentGlow
SpeedInputBox.Font = Enum.Font.GothamBold
SpeedInputBox.TextSize = 10
SpeedInputBox.ClearTextOnFocus = false
SpeedInputBox.Parent = SpeedContainer

Instance.new("UICorner", SpeedInputBox).CornerRadius = UDim.new(0, 4)

SpeedInputBox.FocusLost:Connect(function()
    local val = tonumber(SpeedInputBox.Text)
    if val and val >= 0 then
        customSendDelay = val
    else
        SpeedInputBox.Text = tostring(customSendDelay)
    end
end)

local function updateSettingsUI()
    VirtualModeButton.BackgroundColor3 = copyMode == "virtual" and colors.accentDark or Color3.fromRGB(45, 45, 45)
    NormalModeButton.BackgroundColor3 = copyMode == "normal" and colors.accentDark or Color3.fromRGB(45, 45, 45)
    GamedModeButton.BackgroundColor3 = copyMode == "gamed" and colors.accentDark or Color3.fromRGB(45, 45, 45)
    gamedMode = copyMode == "gamed"
end

VirtualModeButton.MouseButton1Click:Connect(function() copyMode = "virtual" updateSettingsUI() end)
NormalModeButton.MouseButton1Click:Connect(function() copyMode = "normal" updateSettingsUI() end)
GamedModeButton.MouseButton1Click:Connect(function() copyMode = "gamed" updateSettingsUI() end)

-- ========== Saved Players Section ==========
local SavedFrame = Instance.new("Frame")
SavedFrame.Size = UDim2.new(1, -20, 0, 90)
SavedFrame.Position = UDim2.new(0, 10, 0, 105)
SavedFrame.BackgroundColor3 = colors.bgLight
SavedFrame.BackgroundTransparency = 0.3
SavedFrame.Parent = ScrollFrame

Instance.new("UICorner", SavedFrame).CornerRadius = UDim.new(0, 10)

local SavedLabel = Instance.new("TextLabel")
SavedLabel.Size = UDim2.new(1, -10, 0, 20)
SavedLabel.Position = UDim2.new(0, 5, 0, 5)
SavedLabel.BackgroundTransparency = 1
SavedLabel.Text = "⭐ اللاعبون المحفوظون"
SavedLabel.TextColor3 = colors.accent
SavedLabel.Font = Enum.Font.GothamBold
SavedLabel.TextSize = 11
SavedLabel.TextXAlignment = Enum.TextXAlignment.Left
SavedLabel.Parent = SavedFrame

local SavedListContainer = Instance.new("Frame")
SavedListContainer.Size = UDim2.new(1, -10, 0, 30)
SavedListContainer.Position = UDim2.new(0, 5, 0, 28)
SavedListContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
SavedListContainer.Parent = SavedFrame

Instance.new("UICorner", SavedListContainer).CornerRadius = UDim.new(0, 6)

local SavedScroll = Instance.new("ScrollingFrame")
SavedScroll.Size = UDim2.new(1, -5, 1, -5)
SavedScroll.Position = UDim2.new(0, 2, 0, 2)
SavedScroll.BackgroundTransparency = 1
SavedScroll.BorderSizePixel = 0
SavedScroll.ScrollBarThickness = 2
SavedScroll.ScrollBarImageColor3 = colors.accent
SavedScroll.Parent = SavedListContainer

local SavedButtonsFrame = Instance.new("Frame")
SavedButtonsFrame.Size = UDim2.new(1, -10, 0, 22)
SavedButtonsFrame.Position = UDim2.new(0, 5, 0, 63)
SavedButtonsFrame.BackgroundTransparency = 1
SavedButtonsFrame.Parent = SavedFrame

local SaveButton = Instance.new("TextButton")
SaveButton.Size = UDim2.new(0.48, 0, 1, 0)
SaveButton.BackgroundColor3 = colors.accentDark
SaveButton.Text = "حفظ اللاعبين"
SaveButton.TextColor3 = Color3.new(1, 1, 1)
SaveButton.Font = Enum.Font.GothamBold
SaveButton.TextSize = 10
SaveButton.Parent = SavedButtonsFrame
Instance.new("UICorner", SaveButton).CornerRadius = UDim.new(0, 5)

local ClearSavedButton = Instance.new("TextButton")
ClearSavedButton.Size = UDim2.new(0.48, 0, 1, 0)
ClearSavedButton.Position = UDim2.new(0.52, 0, 0, 0)
ClearSavedButton.BackgroundColor3 = colors.danger
ClearSavedButton.Text = "مسح المحفوظات"
ClearSavedButton.TextColor3 = Color3.new(1, 1, 1)
ClearSavedButton.Font = Enum.Font.GothamBold
ClearSavedButton.TextSize = 10
ClearSavedButton.Parent = SavedButtonsFrame
Instance.new("UICorner", ClearSavedButton).CornerRadius = UDim.new(0, 5)

-- ========== Current Players Section ==========
local CurrentFrame = Instance.new("Frame")
CurrentFrame.Size = UDim2.new(1, -20, 0, 140)
CurrentFrame.Position = UDim2.new(0, 10, 0, 205)
CurrentFrame.BackgroundColor3 = colors.bgLight
CurrentFrame.BackgroundTransparency = 0.3
CurrentFrame.Parent = ScrollFrame

Instance.new("UICorner", CurrentFrame).CornerRadius = UDim.new(0, 10)

local CurrentLabel = Instance.new("TextLabel")
CurrentLabel.Size = UDim2.new(1, -10, 0, 20)
CurrentLabel.Position = UDim2.new(0, 5, 0, 5)
CurrentLabel.BackgroundTransparency = 1
CurrentLabel.Text = "👥 اللاعبون المتاحون"
CurrentLabel.TextColor3 = colors.accent
CurrentLabel.Font = Enum.Font.GothamBold
CurrentLabel.TextSize = 11
CurrentLabel.TextXAlignment = Enum.TextXAlignment.Left
CurrentLabel.Parent = CurrentFrame

local CurrentListContainer = Instance.new("Frame")
CurrentListContainer.Size = UDim2.new(1, -10, 0, 78)
CurrentListContainer.Position = UDim2.new(0, 5, 0, 28)
CurrentListContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
CurrentListContainer.Parent = CurrentFrame

Instance.new("UICorner", CurrentListContainer).CornerRadius = UDim.new(0, 6)

local CurrentScroll = Instance.new("ScrollingFrame")
CurrentScroll.Size = UDim2.new(1, -5, 1, -5)
CurrentScroll.Position = UDim2.new(0, 2, 0, 2)
CurrentScroll.BackgroundTransparency = 1
CurrentScroll.BorderSizePixel = 0
CurrentScroll.ScrollBarThickness = 2
CurrentScroll.ScrollBarImageColor3 = colors.accent
CurrentScroll.Parent = CurrentListContainer

local SelectedCountLabel = Instance.new("TextLabel")
SelectedCountLabel.Size = UDim2.new(1, -5, 0, 22)
SelectedCountLabel.Position = UDim2.new(0, 5, 0, 110)
SelectedCountLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
SelectedCountLabel.Text = "لا يوجد لاعبين محددين"
SelectedCountLabel.TextColor3 = colors.text
SelectedCountLabel.Font = Enum.Font.GothamBold
SelectedCountLabel.TextSize = 10
SelectedCountLabel.Parent = CurrentFrame

Instance.new("UICorner", SelectedCountLabel).CornerRadius = UDim.new(0, 6)

-- ========== Active Player Section ==========
local ActivePlayerFrame = Instance.new("Frame")
ActivePlayerFrame.Size = UDim2.new(1, -20, 0, 24)
ActivePlayerFrame.Position = UDim2.new(0, 10, 0, 355)
ActivePlayerFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ActivePlayerFrame.Parent = ScrollFrame

Instance.new("UICorner", ActivePlayerFrame).CornerRadius = UDim.new(0, 6)

local ActivePlayerLabel = Instance.new("TextLabel")
ActivePlayerLabel.Size = UDim2.new(1, -5, 1, 0)
ActivePlayerLabel.BackgroundTransparency = 1
ActivePlayerLabel.Text = "اللاعب النشط: غير متوفر"
ActivePlayerLabel.TextColor3 = colors.text
ActivePlayerLabel.Font = Enum.Font.GothamBold
ActivePlayerLabel.TextSize = 10
ActivePlayerLabel.TextXAlignment = Enum.TextXAlignment.Center
ActivePlayerLabel.Parent = ActivePlayerFrame

-- ========== Commands Section ==========
local CommandsFrame = Instance.new("Frame")
CommandsFrame.Size = UDim2.new(1, -20, 0, 175)
CommandsFrame.Position = UDim2.new(0, 10, 0, 389)
CommandsFrame.BackgroundColor3 = colors.bgLight
CommandsFrame.BackgroundTransparency = 0.3
CommandsFrame.Parent = ScrollFrame

Instance.new("UICorner", CommandsFrame).CornerRadius = UDim.new(0, 10)

local CommandsLabel = Instance.new("TextLabel")
CommandsLabel.Size = UDim2.new(1, -10, 0, 20)
CommandsLabel.Position = UDim2.new(0, 5, 0, 5)
CommandsLabel.BackgroundTransparency = 1
CommandsLabel.Text = "📋 تبويبات النسخ"
CommandsLabel.TextColor3 = colors.accent
CommandsLabel.Font = Enum.Font.GothamBold
CommandsLabel.TextSize = 11
CommandsLabel.TextXAlignment = Enum.TextXAlignment.Left
CommandsLabel.Parent = CommandsFrame

local CommandInput = Instance.new("TextBox")
CommandInput.Size = UDim2.new(1, -10, 0, 95)
CommandInput.Position = UDim2.new(0, 5, 0, 28)
CommandInput.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
CommandInput.MultiLine = true
CommandInput.ClearTextOnFocus = false
CommandInput.Text = presets[1].commands
CommandInput.TextColor3 = colors.accentGlow
CommandInput.Font = Enum.Font.Code
CommandInput.TextSize = 10
CommandInput.TextXAlignment = Enum.TextXAlignment.Left
CommandInput.TextYAlignment = Enum.TextYAlignment.Top
CommandInput.Parent = CommandsFrame

Instance.new("UICorner", CommandInput).CornerRadius = UDim.new(0, 6)

local ActionButtonsFrame = Instance.new("Frame")
ActionButtonsFrame.Size = UDim2.new(1, -10, 0, 35)
ActionButtonsFrame.Position = UDim2.new(0, 5, 0, 130)
ActionButtonsFrame.BackgroundTransparency = 1
ActionButtonsFrame.Parent = CommandsFrame

local StartButton = Instance.new("TextButton")
StartButton.Size = UDim2.new(0.48, 0, 1, 0)
StartButton.BackgroundColor3 = colors.accentDark
StartButton.Text = "تفعيل النسخ"
StartButton.TextColor3 = Color3.new(1, 1, 1)
StartButton.Font = Enum.Font.GothamBold
StartButton.TextSize = 11
StartButton.Parent = ActionButtonsFrame
Instance.new("UICorner", StartButton).CornerRadius = UDim.new(0, 6)

local StopButton = Instance.new("TextButton")
StopButton.Size = UDim2.new(0.48, 0, 1, 0)
StopButton.Position = UDim2.new(0.52, 0, 0, 0)
StopButton.BackgroundColor3 = colors.danger
StopButton.Text = "إيقاف النسخ"
StopButton.TextColor3 = Color3.new(1, 1, 1)
StopButton.Font = Enum.Font.GothamBold
StopButton.TextSize = 11
StopButton.Parent = ActionButtonsFrame
Instance.new("UICorner", StopButton).CornerRadius = UDim.new(0, 6)

-- ========== Presets Tabs ScrollFrame ==========
local TabsScrollFrame = Instance.new("ScrollingFrame")
TabsScrollFrame.Size = UDim2.new(1, -20, 0, 280)
TabsScrollFrame.Position = UDim2.new(0, 10, 0, 575)
TabsScrollFrame.BackgroundTransparency = 1
TabsScrollFrame.BorderSizePixel = 0
TabsScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 350)
TabsScrollFrame.ScrollBarThickness = 3
TabsScrollFrame.ScrollBarImageColor3 = colors.accent
TabsScrollFrame.Parent = ScrollFrame

local function refreshTabsLayout()
    for _, child in ipairs(TabsScrollFrame:GetChildren()) do
        if child:IsA("GuiObject") then child:Destroy() end
    end

    local yOffset = 0
    for i, preset in ipairs(presets) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 26)
        btn.Position = UDim2.new(0, 0, 0, yOffset)
        btn.BackgroundColor3 = presetColors[i] or colors.grayTab
        btn.Text = preset.name
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        btn.Parent = TabsScrollFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        btn.MouseButton1Click:Connect(function()
            CommandInput.Text = preset.commands
        end)

        yOffset = yOffset + 32
    end
    TabsScrollFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

-- ========== List Refresh Functions ==========
local function updateSelectedCount()
    local count = 0
    for _ in pairs(selectedPlayers) do count = count + 1 end
    if count == 0 then
        SelectedCountLabel.Text = "لا يوجد لاعبين محددين"
    else
        SelectedCountLabel.Text = "عدد اللاعبين المحددين: " .. count
    end
end

local function refreshCurrentList()
    for _, child in ipairs(CurrentScroll:GetChildren()) do
        if child:IsA("GuiObject") then child:Destroy() end
    end

    local yOffset = 0
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local pName = player.Name
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -4, 0, 22)
            btn.Position = UDim2.new(0, 2, 0, yOffset)
            btn.BackgroundColor3 = selectedPlayers[pName] and colors.accentDark or Color3.fromRGB(35, 35, 35)
            btn.Text = pName
            btn.TextColor3 = colors.text
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 10
            btn.Parent = CurrentScroll

            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

            btn.MouseButton1Click:Connect(function()
                if selectedPlayers[pName] then
                    selectedPlayers[pName] = nil
                    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                else
                    selectedPlayers[pName] = true
                    btn.BackgroundColor3 = colors.accentDark
                end
                updateSelectedCount()
            end)

            yOffset = yOffset + 26
        end
    end
    CurrentScroll.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

local function refreshSavedList()
    for _, child in ipairs(SavedScroll:GetChildren()) do
        if child:IsA("GuiObject") then child:Destroy() end
    end

    local yOffset = 0
    for name, _ in pairs(savedPlayers) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -4, 0, 22)
        btn.Position = UDim2.new(0, 2, 0, yOffset)
        btn.BackgroundColor3 = colors.accentDark
        btn.Text = name
        btn.TextColor3 = colors.text
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 10
        btn.Parent = SavedScroll

        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

        btn.MouseButton1Click:Connect(function()
            selectedPlayers[name] = true
            refreshCurrentList()
            updateSelectedCount()
        end)

        yOffset = yOffset + 26
    end
    SavedScroll.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

local function findOnlineSelected()
    for name in pairs(selectedPlayers) do
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Name == name then return name end
        end
    end
    for name in pairs(savedPlayers) do
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Name == name then return name end
        end
    end
    return nil
end

local function removeOfflineSelected()
    local toRemove = {}
    for name in pairs(selectedPlayers) do
        local found = false
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Name == name then found = true break end
        end
        if not found then table.insert(toRemove, name) end
    end
    for _, name in ipairs(toRemove) do
        selectedPlayers[name] = nil
        if activePlayer == name then
            ActivePlayerLabel.Text = "اللاعب النشط: غادر"
            activePlayer = nil
        end
    end
    if #toRemove > 0 then
        refreshCurrentList()
        updateSelectedCount()
    end
end

local function getSelectedPlayersList()
    local list = {}
    for name in pairs(selectedPlayers) do table.insert(list, name) end
    return list
end

local function processPlayerName(name)
    if copyMode == "virtual" then return name end
    return name:sub(1, 3)
end

-- ========== Script Execution Logic ==========
StartButton.MouseButton1Click:Connect(function()
    if copyActive then return end

    removeOfflineSelected()
    currentCommands = CommandInput.Text

    if not gamedMode then
        local target = findOnlineSelected()
        if not target then
            StartButton.Text = "اختر لاعب!"
            task.wait(1)
            StartButton.Text = "تفعيل النسخ"
            return
        end
        activePlayer = target
        ActivePlayerLabel.Text = "اللاعب النشط: " .. target
    else
        local selected = getSelectedPlayersList()
        if #selected == 0 then
            StartButton.Text = "اختر لاعبين!"
            task.wait(1)
            StartButton.Text = "تفعيل النسخ"
            return
        end
        activePlayer = selected[1]
    end

    local commands = {}
    for line in currentCommands:gmatch("[^\r\n]+") do
        if line ~= "" then table.insert(commands, line) end
    end

    copyActive = true
    StartButton.Text = "جاري التشغيل..."
    StartButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)

    copyTask = task.spawn(function()
        while copyActive do
            if not gamedMode then
                local found = false
                for _, player in ipairs(Players:GetPlayers()) do
                    if player.Name == activePlayer then found = true break end
                end
                if not found then
                    removeOfflineSelected()
                    local nextTarget = findOnlineSelected()
                    if not nextTarget then
                        copyActive = false
                        StartButton.Text = "تفعيل النسخ"
                        StartButton.BackgroundColor3 = colors.accentDark
                        ActivePlayerLabel.Text = "انتهى"
                        break
                    else
                        activePlayer = nextTarget
                        ActivePlayerLabel.Text = "اللاعب النشط: " .. activePlayer
                    end
                end

                local shortName = processPlayerName(activePlayer)
                for _, cmd in ipairs(commands) do
                    if not copyActive then break end
                    local finalCmd = cmd:gsub(" sa", " " .. shortName)
                    sendCommand(finalCmd)
                    task.wait(getDelay())
                end
                task.wait(0.1)
            else
                local selected = getSelectedPlayersList()
                if #selected == 0 then
                    copyActive = false
                    StartButton.Text = "تفعيل النسخ"
                    StartButton.BackgroundColor3 = colors.accentDark
                    ActivePlayerLabel.Text = "انتهى"
                    break
                end

                local names = {}
                for i, name in ipairs(selected) do
                    if i > 4 then break end
                    names[i] = processPlayerName(name)
                end
                local combined = table.concat(names, ", ")

                for _, cmd in ipairs(commands) do
                    if not copyActive then break end
                    local finalCmd = cmd
                    finalCmd = finalCmd:gsub("sa,sa,sa,sa", combined)
                    finalCmd = finalCmd:gsub("sa,sa,sa", combined)
                    finalCmd = finalCmd:gsub("sa,sa", combined)
                    finalCmd = finalCmd:gsub("sa", combined)
                    sendCommand(finalCmd)
                    task.wait(getDelay())
                end
                ActivePlayerLabel.Text = "الوضع الجماعي: " .. combined
            end
        end
    end)
end)

StopButton.MouseButton1Click:Connect(function()
    copyActive = false
    if copyTask then task.cancel(copyTask) copyTask = nil end
    StartButton.Text = "تفعيل النسخ"
    StartButton.BackgroundColor3 = colors.accentDark
    ActivePlayerLabel.Text = "اللاعب النشط: متوقف"
end)

SaveButton.MouseButton1Click:Connect(function()
    for name in pairs(selectedPlayers) do savedPlayers[name] = true end
    savePlayers()
    refreshSavedList()
end)

ClearSavedButton.MouseButton1Click:Connect(function()
    savedPlayers = {}
    savePlayers()
    refreshSavedList()
end)

local guiOpen = false
ToggleButton.MouseButton1Click:Connect(function()
    guiOpen = not guiOpen
    if guiOpen then
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back), {Size = UDim2.new(0, 350, 0, 640)}):Play()
        removeOfflineSelected()
        refreshCurrentList()
        refreshSavedList()
        updateSelectedCount()
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        task.wait(0.2)
        MainFrame.Visible = false
    end
end)

task.spawn(function()
    while true do
        task.wait(2)
        removeOfflineSelected()
        if MainFrame.Visible then refreshCurrentList() end
    end
end)

updateSettingsUI()
refreshCurrentList()
refreshSavedList()
updateSelectedCount()
refreshTabsLayout()

print("MHND HUB Loaded Successfully")
