--[[
    TOMATO HUB - Jujutsu Shenanigans Edition
    Optimized for Mobile & Tablet
    Features: Rainbow UI, Infinite Dash, WalkSpeed Slider, and more.
]]

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera
local VIM = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- --- 1. Start-up Effect (Laugh) ---
local startSound = Instance.new("Sound", root)
startSound.SoundId = "rbxassetid://153303102" 
startSound.Volume = 2
startSound:Play()
game:GetService("Debris"):AddItem(startSound, 6)

-- --- 2. RGB Control ---
local rgb = Color3.new(0,0,0)
task.spawn(function()
    local h = 0
    while true do
        h = h + 1/360
        if h > 1 then h = 0 end
        rgb = Color3.fromHSV(h, 1, 1)
        task.wait(1/60)
    end
end)

-- --- 3. UI Construction ---
local ScreenGui = Instance.new("ScreenGui", player.PlayerGui)
ScreenGui.Name = "TomatoHub_Speed_Edition"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 200, 0, 320)
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Visible = true

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
Title.Size = UDim2.new(1, -45, 1, 0)
Title.Position = UDim2.new(0, 45, 0, 0)
Title.Text = "TOMATO HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold

-- Icon
local MiniIcon = Instance.new("ImageLabel", Header)
MiniIcon.Size = UDim2.new(0, 25, 0, 25)
MiniIcon.Position = UDim2.new(0, 10, 0, 5)
MiniIcon.Image = "rbxassetid://18400030275"
MiniIcon.BackgroundTransparency = 1

-- Open Button
local OpenBtn = Instance.new("ImageButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 65, 0, 65)
OpenBtn.Position = UDim2.new(0.1, 0, 0.5, -32)
OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
OpenBtn.Image = "rbxassetid://18400030275"
OpenBtn.Visible = false
OpenBtn.Active = true
OpenBtn.Draggable = true 
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
local OpenStroke = Instance.new("UIStroke", OpenBtn)
OpenStroke.Thickness = 4
task.spawn(function() while true do OpenStroke.Color = rgb task.wait(1/60) end end)

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0, 5)
CloseBtn.Text = "-"
CloseBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)

CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false OpenBtn.Visible = true end)
OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = true OpenBtn.Visible = false end)

-- Toggles
local kokusenActive, guardActive, dashActive, lockActive = false, false, false, false
local walkSpeedValue = 16 

local function createToggleBtn(name, yPos)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    local btnStroke = Instance.new("UIStroke", btn)
    btnStroke.Thickness = 1
    task.spawn(function() while true do btnStroke.Color = rgb task.wait(1/60) end end)
    
    btn.MouseButton1Click:Connect(function()
        if name == "Kokusen" then kokusenActive = not kokusenActive
        elseif name == "Guard" then guardActive = not guardActive
        elseif name == "Dash" then dashActive = not dashActive
        elseif name == "Lock" then lockActive = not lockActive end
        local active = (name == "Kokusen" and kokusenActive or name == "Guard" and guardActive or name == "Dash" and dashActive or name == "Lock" and lockActive)
        btn.Text = name .. ": " .. (active and "ON" or "OFF")
        btn.BackgroundColor3 = active and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(25, 25, 25)
    end)
end

createToggleBtn("Kokusen", 40)
createToggleBtn("Guard", 85)
createToggleBtn("Dash", 130)
createToggleBtn("Lock", 175)

-- Speed Slider
local SpeedLabel = Instance.new("TextLabel", MainFrame)
SpeedLabel.Size = UDim2.new(0.9, 0, 0, 20)
SpeedLabel.Position = UDim2.new(0.05, 0, 0, 220)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Walk Speed: 16"
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.Font = Enum.Font.Gotham

local SpeedSlider = Instance.new("TextButton", MainFrame)
SpeedSlider.Size = UDim2.new(0.9, 0, 0, 10)
SpeedSlider.Position = UDim2.new(0.05, 0, 0, 250)
SpeedSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpeedSlider.Text = ""
Instance.new("UICorner", SpeedSlider).CornerRadius = UDim.new(1, 0)

local SpeedFill = Instance.new("Frame", SpeedSlider)
SpeedFill.Size = UDim2.new(0.2, 0, 1, 0)
SpeedFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", SpeedFill).CornerRadius = UDim.new(1, 0)
task.spawn(function() while true do SpeedFill.BackgroundColor3 = rgb task.wait(1/60) end end)

local dragging = false
SpeedSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end
end)
game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if dragging then
        local mousePos = game:GetService("UserInputService"):GetMouseLocation().X
        local relativePos = mousePos - SpeedSlider.AbsolutePosition.X
        local percentage = math.clamp(relativePos / SpeedSlider.AbsoluteSize.X, 0, 1)
        SpeedFill.Size = UDim2.new(percentage, 0, 1, 0)
        walkSpeedValue = math.floor(16 + (percentage * 184))
        SpeedLabel.Text = "Walk Speed: " .. tostring(walkSpeedValue)
        if hum then hum.WalkSpeed = walkSpeedValue end
    end
end)

-- Main Logic
RunService.RenderStepped:Connect(function()
    if lockActive then
        local target = nil
        local d = 50
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (root.Position - p.Character.HumanoidRootPart.Position).Magnitude
                if dist < d then target = p.Character d = dist end
            end
        end
        if target and target:FindFirstChild("HumanoidRootPart") then
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, target.HumanoidRootPart.Position)
            root.CFrame = CFrame.lookAt(root.Position, Vector3.new(target.HumanoidRootPart.Position.X, root.Position.Y, target.HumanoidRootPart.Position.Z))
        end
    end
    if char.Parent == nil then
        char = player.CharacterAdded:Wait()
        hum = char:WaitForChild("Humanoid")
        root = char:WaitForChild("HumanoidRootPart")
    end
    if hum and hum.WalkSpeed ~= walkSpeedValue then hum.WalkSpeed = walkSpeedValue end
end)
