local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer

local UIController = {}

function UIController:Init()
    self.playerGui = Player.PlayerGui
    self.gui = self.playerGui:WaitForChild("Display")
end

return UIController