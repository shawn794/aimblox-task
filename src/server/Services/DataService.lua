--!nonstrict
local Players = game:GetService("Players")

local Shared = game.ReplicatedStorage.Shared

local ProfileService = require(Shared.ProfileService)
local Settings = require(Shared.Settings)
local Promise = require(Shared.Promise)

local SettingsStore = ProfileService.GetProfileStore("PlayerData", Settings.DefaultSettings)

local function createRemoteFunction(functionName: string, callback)
    local e = Instance.new("RemoteFunction")
    e.Name = functionName
    e.OnServerInvoke = callback
    e.Parent = game.ReplicatedStorage
end

local DataService = { Profiles = {} }

function DataService:SetScale(player: Player, scale: number)
    self.Profiles[player].Profile.Data.CharacterScale = scale
end

function DataService:SetWalkSpeed(player: Player, speed: number)
    self.Profiles[player].Profile.Data.WalkSpeed = speed
end

function DataService:GetProfile(player: Player)
    return Promise.new(function(resolve, reject)
        local profile = self.Profiles[player]
        repeat
            wait()
            profile = self.Profiles[player]
        until profile.Loaded == true
        resolve(profile.Profile.Data)
    end)
end

function DataService:PlayerAdded(player: Player)
    -- get player saved data
    print("Awaiting Profile for "..player.Name)
    self.Profiles[player] = {Loaded = false, Profile = nil}
    local profile = SettingsStore:LoadProfileAsync("Player_"..math.abs(player.UserId), "ForceLoad")
    if profile ~= nil then
        print("Profile found for "..player.Name)
        profile:Reconcile()
        profile:ListenToRelease(function()
            self.Profiles[player] = nil
            player:Kick("Your profile was released. If this continues to happen, screenshot it and send it to tomspell.")
        end)
        
        if player:IsDescendantOf(Players) == true then
            self.Profiles[player] = {Loaded = true, Profile = profile}
        else
            -- player left
            profile:Release()
        end
    else
        -- roblox refuses to load the profile
        player:Kick()
    end
end

function DataService:Init()
    for _, player in pairs(Players:GetPlayers()) do
        -- spawn a new thread, else it would take a while for multiple players to load, and then we could miss new players being added in the event listener below
        coroutine.wrap(function() self:PlayerAdded(player) end)()
    end
    Players.PlayerAdded:Connect(function(player)
        self:PlayerAdded(player)
    end)

    Players.PlayerRemoving:Connect(function(player)
        local profile = self.Profiles[player]
        if profile ~= nil and profile.Profile ~= nil then
            profile.Profile:Release()
            self.Profiles[player] = nil
        end
    end)

    createRemoteFunction("GetData", function (player: Player)
        local profile = self:GetProfile(player)
        repeat
            wait()
            profile = self.Profiles[player]
        until profile.Loaded == true
        return profile.Profile.Data
    end)

    createRemoteFunction("UpdateSettings", function(player: Player, settings: Settings.SettingsType)
        if settings.WalkSpeed and settings.CharacterScale and settings.Brightness and settings.Sounds ~= nil and settings.InputSens then
            self.Profiles[player].Profile.Data = settings
        end
    end)
end

return DataService