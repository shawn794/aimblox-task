local Scaler = require(game.ReplicatedStorage.Shared.Scaler)
local AK47 = game.ReplicatedStorage.AK47

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

    Scaler.ScaleModel(weapon, scale)

    weldWeapon(character, weapon)
end

return {
    ScaleWeapon = scaleWeapon
}