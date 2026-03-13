--[[
    TOMATO HUB - FISCH STEALTH
    - 目立つ演出（赤床、スパム音）を全削除
    - 性能はViKai級のまま、隠密性をアップ
]]

local player = game.Players.LocalPlayer
local virtualInput = game:GetService("VirtualInputManager")

-- --- 1. 設定 ---
local settings = { AutoFish = false, WalkOnWater = false, AutoSell = false }

-- --- 2. 虹色UI ---
local ScreenGui = Instance.new("ScreenGui", player.PlayerGui)
ScreenGui.Name = "TomatoHub_Stealth"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 200, 0, 280) 
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
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
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "🍅 TOMATO HUB"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold

-- --- 3. ボタン作成 ---
local function createBtn(text, y, callback)
    local b = Instance.new("TextButton", MainFrame)
    b.Size = UDim2.new(0.9, 0, 0, 35)
    b.Position = UDim2.new(0.05, 0, 0, y)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() callback(b) end)
end

-- 自動釣り
createBtn("AUTO FISH: OFF", 50, function(btn)
    settings.AutoFish = not settings.AutoFish
    btn.Text = "AUTO FISH: " .. (settings.AutoFish and "ON" or "OFF")
    btn.TextColor3 = settings.AutoFish and Color3.new(0, 1, 0) or Color3.new(1, 1, 1)
end)

-- 透明な水上歩行
createBtn("WATER WALK: OFF", 95, function(btn)
    settings.WalkOnWater = not settings.WalkOnWater
    btn.Text = "WATER WALK: " .. (settings.WalkOnWater and "ON" or "OFF")
    if settings.WalkOnWater then
        local p = Instance.new("Part", workspace)
        p.Name = "TomatoWater"
        p.Size = Vector3.new(10000, 1, 10000)
        p.Position = Vector3.new(0, -2, 0)
        p.Anchored = true
        p.Transparency = 1 -- 完全に透明！
    else
        if workspace:FindFirstChild("TomatoWater") then workspace.TomatoWater:Destroy() end
    end
end)

-- 自動売却
createBtn("AUTO SELL: OFF", 140, function(btn)
    settings.AutoSell = not settings.AutoSell
    btn.Text = "AUTO SELL: " .. (settings.AutoSell and "ON" or "OFF")
end)

-- テレポート（初期島）
createBtn("TP: MOOSEWOOD", 185, function()
    player.Character:MoveTo(Vector3.new(380, 50, 220))
end)

-- --- 4. ロジック実行ループ ---
task.spawn(function()
    while true do
        if settings.AutoFish then
            local char = player.Character
            local tool = char and char:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("events") and tool.events:FindFirstChild("cast") then
                tool.events.cast:FireServer(100)
            end
            local reelGui = player.PlayerGui:FindFirstChild("reel")
            if reelGui and reelGui:FindFirstChild("events") then
                reelGui.events.reeled:FireServer(100, true)
            end
        end
        
        -- 自動売却 (商人が近くにいる前提のイベント)
        if settings.AutoSell then
            local sellEvent = game:GetService("ReplicatedStorage"):FindFirstChild("events") and game.ReplicatedStorage.events:FindFirstChild("sell_all")
            if sellEvent then sellEvent:FireServer() end
        end
        
        task.wait(0.5)
    end
end)
