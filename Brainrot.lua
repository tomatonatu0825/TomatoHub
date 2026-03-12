--[[
    TOMATO HUB - Steal Brainrot PvP
    Setting: Optimized for Mobile & Tablet
]]

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")
local rgb = Color3.new(0,0,0)

-- --- 1. RGB System ---
task.spawn(function()
    local h = 0
    while true do
        h = h + 1/360
        if h > 1 then h = 0 end
        rgb = Color3.fromHSV(h, 1, 1)
        task.wait(1/60)
    end
end)

-- --- 2. UI Setup ---
local ScreenGui = Instance.new("ScreenGui", player.PlayerGui)
ScreenGui.Name = "TomatoHub_Brainrot"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 200, 0, 350)
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Active = true
MainFrame.Draggable = true 

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness = 3
task.spawn(function() while true do MainStroke.Color = rgb task.wait(1/60) end end)

-- Header
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Text = "TOMATO HUB BR"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold

-- --- 3. Functional Settings (ここを設定したよ！) ---

local settings = {
    autoAttack = false,
    highJump = false,
    playerTP = false,
    hitbox = false
}

-- 共通のボタン作成関数
local function createBtn(name, yPos, configKey, action)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    
    btn.MouseButton1Click:Connect(function()
        settings[configKey] = not settings[configKey]
        btn.Text = name .. ": " .. (settings[configKey] and "ON" or "OFF")
        btn.BackgroundColor3 = settings[configKey] and Color3.fromRGB(60, 60, 60) or Color3.fromRGB(25, 25, 25)
        if action then action(settings[configKey]) end
    end)
end

-- 設定：自動攻撃
createBtn("Auto Attack", 45, "autoAttack", function(val)
    task.spawn(function()
        while settings.autoAttack do
            local tool = char:FindFirstChildOfClass("Tool") or player.Backpack:FindFirstChildOfClass("Tool")
            if tool then
                tool.Parent = char
                tool:Activate()
            end
            task.wait(0.1)
        end
    end)
end)

-- 設定：ハイジャンプ
createBtn("High Jump", 90, "highJump", function(val)
    hum.JumpPower = val and 150 or 50
    hum.UseJumpPower = true
end)

-- 設定：プレイヤー瞬間移動
createBtn("Player TP", 135, "playerTP", function(val)
    task.spawn(function()
        while settings.playerTP do
            for _, v in pairs(game.Players:GetPlayers()) do
                if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    root.CFrame = v.Character.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
                    break 
                end
            end
            task.wait(0.5)
        end
    end)
end)

-- 設定：ヒットボックス拡大
createBtn("Big Hitbox", 180, "hitbox", function(val)
    task.spawn(function()
        while true do
            if not settings.hitbox then break end
            for _, v in pairs(game.Players:GetPlayers()) do
                if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = v.Character.HumanoidRootPart
                    hrp.Size = Vector3.new(10, 10, 10)
                    hrp.Transparency = 0.7
                    hrp.CanCollide = false
                end
            end
            task.wait(1)
        end
        -- OFFにした時にサイズを戻す処理
        if not settings.hitbox then
            for _, v in pairs(game.Players:GetPlayers()) do
                if v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    v.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                    v.Character.HumanoidRootPart.Transparency = 1
                end
            end
        end
    end)
end)

-- キャラクターがリスポーンしても動くように設定
player.CharacterAdded:Connect(function(newChar)
    char = newChar
    hum = char:WaitForChild("Humanoid")
    root = char:WaitForChild("HumanoidRootPart")
end)
