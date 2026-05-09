local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local playerGui = player:WaitForChild("PlayerGui")

-- 重複防止
if playerGui:FindFirstChild("TomatoHub") then playerGui.TomatoHub:Destroy() end
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "TomatoHub"; screenGui.ResetOnSpawn = false

-- === 設定保存 ===
local config = {positions = {}, editMode = false}
local function saveConfig() if writefile then writefile("TomatoFinal_V5.json", HttpService:JSONEncode(config)) end end
local function loadConfig() if isfile and isfile("TomatoFinal_V5.json") then config = HttpService:JSONDecode(readfile("TomatoFinal_V5.json")) end end
loadConfig()

-- === UIドラッグ関数 ===
local function makeDraggable(frame, id)
    local dragging, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and config.editMode then
            dragging = true; dragStart = input.Position; startPos = frame.Position
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            frame.Position = newPos
            config.positions[id] = {newPos.X.Scale, newPos.X.Offset, newPos.Y.Scale, newPos.Y.Offset}
            saveConfig()
        end
    end)
    game:GetService("UserInputService").InputEnded:Connect(function(input) dragging = false end)
    if config.positions[id] then
        local p = config.positions[id]; frame.Position = UDim2.new(p[1], p[2], p[3], p[4])
    end
end

-- === 1. 右上の看板 (Discordリンク & 表示) ===
local topBoard = Instance.new("Frame", screenGui)
topBoard.Size = UDim2.new(0, 180, 0, 55); topBoard.Position = UDim2.new(1, -190, 0, 10)
topBoard.BackgroundColor3 = Color3.fromRGB(20, 20, 20); topBoard.BorderSizePixel = 0
Instance.new("UICorner", topBoard); makeDraggable(topBoard, "TopBoard")
local uiStroke = Instance.new("UIStroke", topBoard); uiStroke.Color = Color3.fromRGB(255, 50, 50); uiStroke.Thickness = 2

local miniLogo = Instance.new("TextLabel", topBoard)
miniLogo.Size = UDim2.new(1, 0, 0, 25); miniLogo.Text = "🍅 TOMATO HUB"; miniLogo.TextColor3 = Color3.fromRGB(255, 50, 50)
miniLogo.Font = "GothamBold"; miniLogo.TextSize = 14; miniLogo.BackgroundTransparency = 1

local discordLabel = Instance.new("TextLabel", topBoard)
discordLabel.Size = UDim2.new(1, 0, 0, 20); discordLabel.Position = UDim2.new(0, 0, 0, 25)
discordLabel.Text = "https://discord.gg/Xvactgsfjx"; discordLabel.TextColor3 = Color3.fromRGB(150, 150, 255)
discordLabel.Font = "Code"; discordLabel.TextSize = 10; discordLabel.BackgroundTransparency = 1

local toggleBtn = Instance.new("TextButton", topBoard)
toggleBtn.Size = UDim2.new(1, 0, 1, 0); toggleBtn.BackgroundTransparency = 1; toggleBtn.Text = ""

-- === 2. メインメニュー (さらにコンパクト化) ===
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 200, 0, 240); mainFrame.Position = UDim2.new(0.5, -100, 0.5, -120)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15); mainFrame.Visible = false; Instance.new("UICorner", mainFrame)
makeDraggable(mainFrame, "MainFrame")

local closeBtn = Instance.new("TextButton", screenGui); closeBtn.Size = UDim2.new(0, 30, 0, 30); closeBtn.Text = "×"; closeBtn.BackgroundColor3 = Color3.fromRGB(255, 30, 30); closeBtn.TextColor3 = Color3.new(1,1,1); closeBtn.Visible = false; Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1,0)

-- タブ
local tabHolder = Instance.new("Frame", mainFrame); tabHolder.Size = UDim2.new(1, 0, 0, 25); tabHolder.BackgroundTransparency = 1
Instance.new("UIListLayout", tabHolder).FillDirection = "Horizontal"
local pages = {}
local function createTab(name, id)
    local b = Instance.new("TextButton", tabHolder); b.Size = UDim2.new(0.33, 0, 1, 0); b.Text = name; b.BackgroundColor3 = Color3.fromRGB(30, 30, 30); b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"; b.TextSize = 9
    local p = Instance.new("ScrollingFrame", mainFrame); p.Size = UDim2.new(1, -10, 1, -40); p.Position = UDim2.new(0, 5, 0, 35); p.Visible = (id == "Main"); p.BackgroundTransparency = 1; p.ScrollBarThickness = 0
    Instance.new("UIListLayout", p).Padding = UDim.new(0, 5); pages[id] = p
    b.MouseButton1Click:Connect(function() for _, v in pairs(pages) do v.Visible = false end; p.Visible = true end)
end
createTab("戦闘", "Main"); createTab("移動", "Move"); createTab("システム", "Sys")

-- 機能作成関数
local function addF(name, parent, callback)
    local b = Instance.new("TextButton", parent); b.Size = UDim2.new(1, 0, 0, 30); b.Text = name .. ": OFF"; b.BackgroundColor3 = Color3.fromRGB(40, 40, 40); b.TextColor3 = Color3.new(1,1,1); b.Font = "Gotham"; b.TextSize = 10; Instance.new("UICorner", b)
    local s = false; b.MouseButton1Click:Connect(function() s = not s; b.Text = name .. (s and ": ON" or ": OFF"); b.BackgroundColor3 = s and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 40); callback(s) end)
end

-- 戦闘タブ
local autoFire, hitbox, meBig = false, false, false
addF("オート射撃", pages.Main, function(s) autoFire = s end)
addF("ヒットボックス拡大", pages.Main, function(s) hitbox = s end)
addF("自分も巨大化", pages.Main, function(s) meBig = s end)

-- 移動タブ
local tpJump, backTp = false, false
local flyJumpBtn = Instance.new("TextButton", screenGui); flyJumpBtn.Size = UDim2.new(0, 65, 0, 65); flyJumpBtn.Text = "特殊移動"; flyJumpBtn.BackgroundColor3 = Color3.fromRGB(40,180,40); flyJumpBtn.Visible = false; Instance.new("UICorner", flyJumpBtn).CornerRadius = UDim.new(1,0); makeDraggable(flyJumpBtn, "FlyJump")
local tpBtn = Instance.new("TextButton", screenGui); tpBtn.Size = UDim2.new(0, 65, 0, 65); tpBtn.Text = "背後TP"; tpBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 220); tpBtn.Visible = false; Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(1,0); makeDraggable(tpBtn, "TP")
addF("特殊移動ボタン", pages.Move, function(s) flyJumpBtn.Visible = s end)
addF("背後TPボタン", pages.Move, function(s) tpBtn.Visible = s end)

-- システムタブ
addF("ボタン編集モード", pages.Sys, function(s) config.editMode = s end)
local rst = Instance.new("TextButton", pages.Sys); rst.Size = UDim2.new(1,0,0,30); rst.Text = "配置リセット"; rst.BackgroundColor3 = Color3.fromRGB(80,0,0); rst.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", rst); rst.MouseButton1Click:Connect(function() config.positions = {}; saveConfig(); player:Kick("再起動") end)

-- === 3. 動作ロジック ===
flyJumpBtn.MouseButton1Click:Connect(function()
    local hrp = player.Character.HumanoidRootPart; local old = hrp.CFrame
    hrp.CFrame = old + Vector3.new(0, 18, 0); task.wait(0.3); hrp.CFrame = old
end)

tpBtn.MouseButton1Click:Connect(function()
    local target, dist = nil, 600
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Team ~= player.Team and p.Character and p.Character.Humanoid.Health > 0 then
            local d = (player.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then target = p; dist = d end
        end
    end
    if target then player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3.5) end
end)

RunService.RenderStepped:Connect(function()
    if mainFrame.Visible then closeBtn.Position = UDim2.new(0, mainFrame.AbsolutePosition.X + mainFrame.AbsoluteSize.X - 10, 0, mainFrame.AbsolutePosition.Y - 15); closeBtn.Visible = true else closeBtn.Visible = false end
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hum = p.Character:FindFirstChild("Humanoid")
            if p == player then
                p.Character.HumanoidRootPart.Size = meBig and Vector3.new(15,15,15) or Vector3.new(2,2,1)
                p.Character.HumanoidRootPart.Transparency = meBig and 0.8 or 1; continue
            end
            if (p.Team and p.Team == player.Team) or (hum and hum.Health <= 0) then p.Character.HumanoidRootPart.Size = Vector3.new(2,2,1); continue end
            p.Character.HumanoidRootPart.Size = hitbox and Vector3.new(15,15,15) or Vector3.new(2,2,1)
            p.Character.HumanoidRootPart.Transparency = hitbox and 0.8 or 1
            if autoFire and p.Character:FindFirstChild("Head") then
                local head = p.Character.Head; local pos, onScreen = camera:WorldToViewportPoint(head.Position)
                if onScreen and (Vector2.new(pos.X, pos.Y) - Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)).Magnitude < 75 then
                    camera.CFrame = CFrame.new(camera.CFrame.Position, head.Position)
                    local t = player.Character:FindFirstChildOfClass("Tool"); if t then t:Activate() end
                end
            end
        end
    end
end)

toggleBtn.MouseButton1Click:Connect(function() mainFrame.Visible = not mainFrame.Visible end)
closeBtn.MouseButton1Click:Connect(function() mainFrame.Visible = false end)

-- === 4. 演出 ===
local function startIntro()
    local s = Instance.new("TextLabel", screenGui); s.Size = UDim2.new(0, 600, 0, 150); s.Position = UDim2.new(0.5, 0, 0.5, 0); s.AnchorPoint = Vector2.new(0.5, 0.5); s.BackgroundTransparency = 1; s.Text = "TOMATO HUB"; s.TextColor3 = Color3.fromRGB(255, 50, 50); s.Font = "SpecialElite"; s.TextSize = 1; s.ZIndex = 5000; TweenService:Create(s, TweenInfo.new(1, Enum.EasingStyle.Back), {TextSize = 100}):Play(); task.wait(2); s:Destroy(); mainFrame.Visible = true
end
task.spawn(startIntro)
