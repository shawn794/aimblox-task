local Players = game:GetService("Players")

local function createEvent(eventName: string, callback)
    local e = Instance.new("RemoteEvent")
    e.Name = eventName
    e.OnServerEvent:Connect(callback)
    e.Parent = game.ReplicatedStorage
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
        self:ScaleCharacter(player, character, playerSettings.CharacterScale)
    end)
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