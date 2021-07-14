local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ModelUtil = require(ReplicatedStorage.Shared.ModelUtil)

local AK47 = ReplicatedStorage.AK47

local function createEvent(eventName: string, callback)
    local e = Instance.new("RemoteEvent")
    e.Name = eventName
    e.OnServerEvent:Connect(callback)
    e.Parent = game.ReplicatedStorage
end

local function weldWeapon(character: Model, weapon: Model)
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local weld = Instance.new("Weld")
    weld.Part0 = humanoidRootPart
    weld.Part1 = weapon.PrimaryPart
    weld.C0 = humanoidRootPart.CFrame
    weld.C1 = humanoidRootPart.CFrame
    weld.Parent = humanoidRootPart

    weapon.Parent = character
end

local function scaleWeapon(character: Model, scale: number)
    local weapon = AK47:Clone()
    print(weapon:GetChildren())
    weapon.PrimaryPart = weapon:WaitForChild("Body")

    ModelUtil.Unweld(weapon)
    ModelUtil.Scale(weapon, scale)
    ModelUtil.Reweld(weapon)

    weldWeapon(character, weapon)
end

local PlayerService = {}

function PlayerService:ScaleCharacter(player: Player, character: Model, scale: number)
    local humanoid: Humanoid = character:WaitForChild("Humanoid")
    local bodyDepthScale: NumberValue = humanoid:WaitForChild("BodyDepthScale")
    local bodyHeightScale: NumberValue = humanoid:WaitForChild("BodyHeightScale")
    local bodyWidthScale: NumberValue = humanoid:WaitForChild("BodyWidthScale")
    local headScale: NumberValue = humanoid:WaitForChild("HeadScale")

    bodyDepthScale.Value = scale
    bodyHeightScale.Value = scale
    bodyWidthScale.Value = scale
    headScale.Value = scale

    self.DataService:SetScale(player, scale)
end

function PlayerService:CharacterAdded(player: Player, character: Model)
    self.DataService:GetProfile(player):andThen(function(playerSettings)
        print(playerSettings)
        local humanoid: Humanoid = character:WaitForChild("Humanoid")
        humanoid.WalkSpeed = playerSettings.WalkSpeed
        -- self:ScaleCharacter(player, character, playerSettings.CharacterScale)
    end)
    scaleWeapon(character, 1)
end

function PlayerService:Start(services)
    self.Services = services
    self.DataService = services["DataService"]
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            self:CharacterAdded(player, character)
        end)
    end)

    createEvent("ScaleEvent", function(player: Player, scale: number)
        self:ScaleCharacter(player, player.Character, scale)
    end)

    createEvent("WalkSpeedEvent", function(player: Player, speed: number)
        if speed > 100 then
            speed = 100
        end

        local humanoid: Humanoid = player.Character:WaitForChild("Humanoid")
        humanoid.WalkSpeed = speed
        self.DataService:SetWalkSpeed(player, speed)
    end)
end

return PlayerService