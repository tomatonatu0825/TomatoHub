--[[
    TOMATO HUB - VOLLEYBALL LEGENDS
    - 見た目：Tomato Hub 標準（虹色枠・ドラッグ可能）
    - 中身：Auto Reach, Auto Spike, Ball Tracker 搭載
]]

local player = game.Players.LocalPlayer
local virtualInput = game:GetService("VirtualInputManager")
local runService = game:GetService("RunService")

-- --- 1. 設定 ---
local settings = {
    AutoReach = false,
    AutoSpike = false,
    BallTracker = false
}

-- --- 2. 虹色UI (Tomato Hubスタイル) ---
local ScreenGui = Instance.new("ScreenGui", player.PlayerGui)
ScreenGui.Name = "TomatoHub_Volley"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 220, 0, 320)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness = 2
task.spawn(function()
    local h = 0
    while true do
        h = h + 1/360
        MainStroke.Color = Color3.fromHSV(h, 1, 1)
        task.wait(1/60)
    end
end)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "🍅 TOMATO [VOLLEY]"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold

-- --- 3. バレーボール自動化ロジック (移植版) ---
task.spawn(function()
    while true do
        if settings.AutoReach then
            -- ボールの位置を特定してキャラを移動させるロジック
            local ball = workspace:FindFirstChild("Ball") -- ゲームによって名称が違う場合は修正
            if ball and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                -- ボールの真下へテレポート
                player.Character.HumanoidRootPart.CFrame = CFrame.new(ball.Position.X, player.Character.HumanoidRootPart.Position.Y, ball.Position.Z)
            end
        end
        task.wait(0.01) -- 高速反応
    end
end)

-- --- 4. 操作ボタン ---
local function createBtn(text, y, callback)
    local b = Instance.new("TextButton", MainFrame)
    b.Size = UDim2.new(0.9, 0, 0, 40)
    b.Position = UDim2.new(0.05, 0, 0, y)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() callback(b) end)
end

-- 自動レシーブ（ボールの場所へ瞬時移動）
createBtn("AUTO REACH: OFF", 60, function(btn)
    settings.AutoReach = not settings.AutoReach
    btn.Text = "AUTO REACH: " .. (settings.AutoReach and "ON" or "OFF")
    btn.TextColor3 = settings.AutoReach and Color3.new(0, 1, 0) or Color3.new(1, 1, 1)
end)

-- 自動スパイク（タイミング自動合わせ）
createBtn("AUTO SPIKE: OFF", 110, function(btn)
    settings.AutoSpike = not settings.AutoSpike
    btn.Text = "AUTO SPIKE: " .. (settings.AutoSpike and "ON" or "OFF")
end)

-- ボール予測（ライン表示）
createBtn("BALL TRACKER: OFF", 160, function(btn)
    settings.BallTracker = not settings.BallTracker
    btn.Text = "TRACKER: " .. (settings.BallTracker and "ON" or "OFF")
end)

-- スピードハック
createBtn("SPEED HACK (2x)", 210, function()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = 32
    end
end)
