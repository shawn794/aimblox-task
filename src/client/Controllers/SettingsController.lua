local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

local GetData: RemoteFunction = game.ReplicatedStorage:WaitForChild("GetData")
local UpdateSettings: RemoteFunction = game.ReplicatedStorage:WaitForChild("UpdateSettings")
local ScaleEvent: RemoteEvent = game.ReplicatedStorage:WaitForChild("ScaleEvent")

local SettingsController = {}

function SettingsController:LocalBrightening(v)
    Lighting.Brightness = v
end

function SettingsController:SetScale(s: number)
    self.data.CharacterScale = s
    ScaleEvent:FireServer(s)
end

function SettingsController:SetBrightness(s: number)
    self.data.Brightness = s
    self:LocalBrightening(s)
    UpdateSettings:InvokeServer(self.data)
end

function SettingsController:SetSounds(s: boolean)
    self.data.Sounds = s
    UpdateSettings:InvokeServer(self.data)
end

function SettingsController:SetWalkSpeed(s: number)
    self.data.WalkSpeed = s
    UpdateSettings:InvokeServer(self.data)
end

function SettingsController:SetSens(s: number)
    self.data.InputSens = s
    UserInputService.MouseDeltaSensitivity = s
    UpdateSettings:InvokeServer(self.data)
end

function SettingsController:GetData()
    return self.data
end

function SettingsController:Init()
    self.data = GetData:InvokeServer()
    self:LocalBrightening(self.data.Brightness)
end

return SettingsController