local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "War Simulator",
    Icon = 0,
    LoadingEnabled = true,
    LoadingTitle = "War Simulator",
    LoadingSubtitle = "discord: xvc64",
    ConfigurationSaving = {
        Enabled = false,
        FolderName = nil,
        FileName = "War Sim script"
    },
    KeySystem = false
})

local MainTab = Window:CreateTab("yo hitbox xdlolkek", 4483362458)

local Player = game:GetService("Players").LocalPlayer
local DefaultSpeed = 16

MainTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 40},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "WalkSpeedSlider",
    Callback = function(Value)
        local character = Player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = Value
            end
        end
    end
})


local Flying = false
local FlySpeed = 40
local BodyVelocity = nil
local BodyGyro = nil

local function StartFly()
    local character = Player.Character
    if not character then return end
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoidRootPart or not humanoid then return end

    Flying = true
    humanoid.PlatformStand = true

    BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.Velocity = Vector3.new(0, 0, 0)
    BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    BodyVelocity.Parent = humanoidRootPart

    BodyGyro = Instance.new("BodyGyro")
    BodyGyro.P = 9000
    BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    BodyGyro.CFrame = humanoidRootPart.CFrame
    BodyGyro.Parent = humanoidRootPart

    local Camera = workspace.CurrentCamera
    local UserInputService = game:GetService("UserInputService")

    spawn(function()
        while Flying do
            local direction = Vector3.new(0, 0, 0)
            local camCF = Camera.CFrame

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                direction = direction + camCF.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                direction = direction - camCF.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                direction = direction - camCF.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                direction = direction + camCF.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                direction = direction + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                direction = direction - Vector3.new(0, 1, 0)
            end

            if direction.Magnitude > 0 then
                BodyVelocity.Velocity = direction.Unit * FlySpeed
            else
                BodyVelocity.Velocity = Vector3.new(0, 0, 0)
            end

            BodyGyro.CFrame = camCF

            game:GetService("RunService").RenderStepped:Wait()
        end
    end)
end

local function StopFly()
    Flying = false
    local character = Player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
    end
    if BodyVelocity then
        BodyVelocity:Destroy()
        BodyVelocity = nil
    end
    if BodyGyro then
        BodyGyro:Destroy()
        BodyGyro = nil
    end
end

MainTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(Value)
        if Value then
            StartFly()
        else
            StopFly()
        end
    end
})

MainTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 40},
    Increment = 5,
    Suffix = "Speed",
    CurrentValue = 40,
    Flag = "FlySpeedSlider",
    Callback = function(Value)
        FlySpeed = Value
    end
})


local HitboxEnabled = false
local HitboxSize = 10
local OriginalSizes = {}

local function ExpandSingleNpc(npc, size)
    local head = npc:FindFirstChild("Head")
    if head and head:IsA("BasePart") then
        if not OriginalSizes[npc] then
            OriginalSizes[npc] = head.Size
        end
        head.Size = Vector3.new(size, size, size)
        head.Transparency = 0.5
        head.CanCollide = false
    end
end

local function ExpandHitboxes(size)
    local NpcsFolder = workspace:FindFirstChild("Npcs")
    if not NpcsFolder then return end

    for _, npc in pairs(NpcsFolder:GetChildren()) do
        ExpandSingleNpc(npc, size)
    end
end

local function ResetHitboxes()
    local NpcsFolder = workspace:FindFirstChild("Npcs")
    if not NpcsFolder then return end

    for _, npc in pairs(NpcsFolder:GetChildren()) do
        local head = npc:FindFirstChild("Head")
        if head and head:IsA("BasePart") and OriginalSizes[npc] then
            head.Size = OriginalSizes[npc]
            head.Transparency = 0
        end
    end
    OriginalSizes = {}
end

local NpcsFolder = workspace:WaitForChild("Npcs")
NpcsFolder.ChildAdded:Connect(function(npc)
    if not HitboxEnabled then return end
    task.wait(0.5)
    ExpandSingleNpc(npc, HitboxSize)
end)

MainTab:CreateToggle({
    Name = "NPC Head Hitbox Expander",
    CurrentValue = false,
    Flag = "HitboxToggle",
    Callback = function(Value)
        HitboxEnabled = Value
        if Value then
            ExpandHitboxes(HitboxSize)
        else
            ResetHitboxes()
        end
    end
})

MainTab:CreateSlider({
    Name = "Hitbox Size",
    Range = {5, 50},
    Increment = 1,
    Suffix = "Studs",
    CurrentValue = 10,
    Flag = "HitboxSizeSlider",
    Callback = function(Value)
        HitboxSize = Value
        if HitboxEnabled then
            ExpandHitboxes(Value)
        end
    end
})
