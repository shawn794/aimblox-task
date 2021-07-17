local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")

local Scaler = require(game.ReplicatedStorage.Shared.Scaler)

local Player = Players.LocalPlayer
local Ambient = SoundService.Ambient
local AK47 = game.ReplicatedStorage.AK47

local GetData: RemoteFunction = game.ReplicatedStorage:WaitForChild("GetData")
local UpdateSettings: RemoteFunction = game.ReplicatedStorage:WaitForChild("UpdateSettings")
local ScaleEvent: RemoteEvent = game.ReplicatedStorage:WaitForChild("ScaleEvent")
local WalkSpeedEvent: RemoteEvent = game.ReplicatedStorage:WaitForChild("WalkSpeedEvent")

local function weldWeapon(character: Model, weapon: Model)
    local upperTorso = character:WaitForChild("UpperTorso")

    weapon.PrimaryPart.CFrame = CFrame.new(Vector3.new(0, 0, upperTorso.Size.Z/2+.1)) * CFrame.fromOrientation(math.rad(45), math.rad(90), 0)
    weapon.PrimaryPart.CFrame = upperTorso.CFrame:ToWorldSpace(weapon.PrimaryPart.CFrame)
    
    local weld = Instance.new("WeldConstraint")
    weld.Parent = upperTorso

    weld.Part0 = upperTorso
    weld.Part1 = weapon.PrimaryPart
end

local function scaleWeapon(character: Model, scale: number)
    local weapon = AK47:Clone()
    weapon.PrimaryPart = weapon:WaitForChild("Body")
    weapon.Parent = character

    Scaler.scaleModel(weapon, scale)

    weldWeapon(character, weapon)
end

local SettingsController = {}

function SettingsController:LocalBrightening(v)
    TweenService:Create(Lighting, TweenInfo.new(0.1), {Brightness = v}):Play()
end

function SettingsController:LocalScale(s)
    if Player.Character:FindFirstChild("AK47") then
        Player.Character.AK47:Destroy()
        scaleWeapon(Player.Character, s)
    end
    
    local humanoid: Humanoid = Player.Character:WaitForChild("Humanoid")
    local bodyDepthScale: NumberValue = humanoid:WaitForChild("BodyDepthScale")
    local bodyHeightScale: NumberValue = humanoid:WaitForChild("BodyHeightScale")
    local bodyWidthScale: NumberValue = humanoid:WaitForChild("BodyWidthScale")
    local headScale: NumberValue = humanoid:WaitForChild("HeadScale")

    TweenService:Create(bodyDepthScale, TweenInfo.new(0.1), {Value = s}):Play()
    TweenService:Create(bodyHeightScale, TweenInfo.new(0.1), {Value = s}):Play()
    TweenService:Create(bodyWidthScale, TweenInfo.new(0.1), {Value = s}):Play()
    TweenService:Create(headScale, TweenInfo.new(0.1), {Value = s}):Play()
end

function SettingsController:SetScale(s: number)
    if Player.Character:FindFirstChild("AK47") then
        Player.Character.AK47:Destroy()
    end
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
    Ambient.Playing = s
    UpdateSettings:InvokeServer(self.data)
end

function SettingsController:SetWalkSpeed(s: number)
    self.data.WalkSpeed = s
    WalkSpeedEvent:FireServer(s)
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
    Ambient.Playing = self.data.Sounds
    UserInputService.MouseDeltaSensitivity = self.data.InputSens
end

return SettingsController