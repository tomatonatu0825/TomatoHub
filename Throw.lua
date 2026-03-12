--[[
    TOMATO HUB - [物や人を投げる] 
    外見：虹色・起動音あり
    中身：ボタンとロジックを完全に接続済み
]]

local player = game.Players.LocalPlayer
local players = game:GetService("Players")
local soundService = game:GetService("SoundService")

-- 1. 👿 悪魔の起動ボイス（実行した瞬間に鳴る）
local function playStartUpVoice()
    local s = Instance.new("Sound", soundService)
    s.SoundId = "rbxassetid://212684131"
    s.Volume = 3
    s:Play()
    game:GetService("Debris"):AddItem(s, 5)
end
playStartUpVoice()

-- 2. 内部設定
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")
local rgb = Color3.new(0,0,0)

local settings = {
    targetPlayer = nil,
    isKilling = false,
    isFlinging = false,
    throwPower = 500
}

-- RGBアニメーション
task.spawn(function()
    local h = 0
    while true do
        h = h + 1/360
        if h > 1 then h = 0 end
        rgb = Color3.fromHSV(h, 1, 1)
        task.wait(1/60)
    end
end)

-- 3. UIデザイン（外見固定）
local ScreenGui = Instance.new("ScreenGui", player.PlayerGui)
ScreenGui.Name = "TomatoHub_Throw_LogicFinal"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 220, 0, 480)
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Active = true
MainFrame.Draggable = true 

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness = 3
task.spawn(function() while true do MainStroke.Color = rgb task.wait(1/60) end end)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "TOMATO HUB"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Font = Enum.Font.GothamBold

-- 4. プレイヤーリスト
local Scroll = Instance.new("ScrollingFrame", MainFrame)
Scroll.Size = UDim2.new(0.9, 0, 0, 150)
Scroll.Position = UDim2.new(0.05, 0, 0, 45)
Scroll.CanvasSize = UDim2.new(0, 0, 5, 0)
Scroll.ScrollBarThickness = 3
Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 5)

local function updateList()
    for _, child in pairs(Scroll:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    for _, p in pairs(players:GetPlayers()) do
        if p ~= player then
            local btn = Instance.new("TextButton", Scroll)
            btn.Size = UDim2.new(1, -5, 0, 30)
            btn.Text = p.DisplayName or p.Name
            btn.BackgroundColor3 = (settings.targetPlayer == p) and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(35, 35, 35)
            btn.TextColor3 = (settings.targetPlayer == p) and Color3.new(0,0,0) or Color3.new(1,1,1)
            Instance.new("UICorner", btn)
            btn.MouseButton1Click:Connect(function() settings.targetPlayer = p updateList() end)
        end
    end
end
updateList()
players.PlayerAdded:Connect(updateList)
players.PlayerRemoving:Connect(updateList)

-- 5. ★ボタンとロジックの完全接続★

-- [投げパワー強化]
task.spawn(function()
    while true do
        for _, obj in pairs(workspace:GetChildren()) do
            -- 投げゲーの「掴んでるSelectionBox」を検知して速度を上書き
            if obj:IsA("BasePart") and not obj.Anchored and obj:FindFirstChild("SelectionBox") then
                obj.Velocity = root.CFrame.LookVector * settings.throwPower
            end
        end
        task.wait(0.1)
    end
end)

-- [Kill & Kick 実行ループ]
local dummy = nil
task.spawn(function()
    while true do
        -- AUTO KILLがONでターゲットがいれば殺し続ける
        if settings.isKilling and settings.targetPlayer and settings.targetPlayer.Character then
            local h = settings.targetPlayer.Character:FindFirstChild("Humanoid")
            if h and h.Health > 0 then h.Health = 0 end
        end
        
        -- SERVER KICKがONでターゲットがいれば人形で飛ばし続ける
        if settings.isFlinging and settings.targetPlayer and settings.targetPlayer.Character then
            if not dummy then 
                dummy = Instance.new("Part", workspace) 
                dummy.Color = Color3.new(1,1,0) 
                dummy.Transparency = 0.5 
                dummy.CanCollide = false 
                Instance.new("SpecialMesh", dummy).MeshType = Enum.MeshType.Head 
            end
            local tr = settings.targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if tr then
                dummy.CFrame = tr.CFrame
                tr.Velocity = Vector3.new(999999, 999999, 999999)
                tr.RotVelocity = Vector3.new(999999, 999999, 999999)
            end
        else
            if dummy then dummy:Destroy() dummy = nil end
        end
        task.wait()
    end
end)

-- ボタン作成
local function createTgl(name, yPos, conf)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", btn)
    
    btn.MouseButton1Click:Connect(function()
        settings[conf] = not settings[conf] -- ここでtrue/falseが切り替わる
        btn.Text = name .. ": " .. (settings[conf] and "ON" or "OFF")
        btn.BackgroundColor3 = settings[conf] and Color3.fromRGB(60, 60, 60) or Color3.fromRGB(30, 30, 30)
    end)
end

createTgl("AUTO KILL", 210, "isKilling")
createTgl("SERVER KICK", 260, "isFlinging")

-- パワーボタン
local Pwr = Instance.new("TextButton", MainFrame)
Pwr.Size = UDim2.new(0.9, 0, 0, 40)
Pwr.Position = UDim2.new(0.05, 0, 0, 310)
Pwr.Text = "Power: 500"
Pwr.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Pwr.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", Pwr)

Pwr.MouseButton1Click:Connect(function()
    if settings.throwPower < 5000 then settings.throwPower = settings.throwPower + 1500 else settings.throwPower = 500 end
    Pwr.Text = "Power: " .. settings.throwPower
end)

-- リスポーン対策
player.CharacterAdded:Connect(function(newChar)
    char = newChar
    root = char:WaitForChild("HumanoidRootPart")
end)
