local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Slider = require(script.Slider)
local Button = require(script.Button)
local Dropdown = require(script.Dropdown)

local Player = Players.LocalPlayer

local UIController = {}

function UIController:CreateDropdowns()
    local function buttonChange(button: ImageButton, bool: boolean)
        if bool then
            TweenService:Create(button.Overlay, TweenInfo.new(0.5), {BackgroundColor3 = Color3.fromRGB(120, 186, 185)}):Play()
        else
            TweenService:Create(button.Overlay, TweenInfo.new(0.5), {BackgroundColor3 = Color3.fromRGB(32, 50, 49)}):Play()
        end
    end
    local walkspeedDropdown = Dropdown.new(self.panel.SettingsList.WalkspeedDropdown, string.format("%.0f",self.data.WalkSpeed))
    walkspeedDropdown.ButtonChanged:Connect(function(button)
        self.settingsController:SetWalkSpeed(tonumber(button))
    end)
end

function UIController:CreateButtons()
    local function soundsChange(button: ImageButton, bool: boolean)
        local overlay = button:WaitForChild("Overlay")
        local label = button:WaitForChild("TextLabel")
        overlay.Visible = bool
        if bool then
            -- TweenService:Create(overlay, TweenInfo.new(0.5), {BackgroundColor3 = Color3.fromRGB(120, 186, 185)}):Play()
            label.Text = "ON"
        else
            -- TweenService:Create(overlay, TweenInfo.new(0.5), {BackgroundColor3 = Color3.fromRGB(32, 50, 49)}):Play()
            label.Text = "OFF"
        end
    end
    soundsChange(self.panel.SettingsList.Sounds.Button, self.data.Sounds)
    local soundsButton = Button.new(self.panel.SettingsList.Sounds.Button, self.data.Sounds, soundsChange)
    soundsButton.Changed:Connect(function(bool: boolean)
        self.settingsController:SetSounds(bool)
    end)
end

function UIController:CreateSliders()
    self.panel.SettingsList.BrightnessSlider.Frame.Level.Text = self.data.Brightness
    local brightnessSlider = Slider.new(self.panel.SettingsList.BrightnessSlider.Frame.Bar, self.data.Brightness/10)
    brightnessSlider.Changed:Connect(function(value: number)
        value = tonumber(string.format("%.1f", value * 10))
        self.panel.SettingsList.BrightnessSlider.Frame.Level.Text = value
        self.settingsController:LocalBrightening(value)
    end)
    brightnessSlider.Finished:Connect(function(value)
        self.settingsController:SetBrightness(tonumber(string.format("%.1f", value * 10)))
        self.data = self.settingsController:GetData()
    end)

    self.panel.SettingsList.SensitivitySlider.Frame.Level.Text = self.data.InputSens
    local sensitivitySlider = Slider.new(self.panel.SettingsList.SensitivitySlider.Frame.Bar, self.data.InputSens/10)
    sensitivitySlider.Changed:Connect(function(value: number)
        value = tonumber(string.format("%.0f", value * 10))
        self.panel.SettingsList.SensitivitySlider.Frame.Level.Text = value
    end)
    sensitivitySlider.Finished:Connect(function(value: number)
        self.settingsController:SetSens(tonumber(string.format("%.0f", value * 10)))
        self.data = self.settingsController:GetData()
    end)

    self.panel.SettingsList.ScaleSlider.Frame.Level.Text = self.data.CharacterScale
    local scaleSlider = Slider.new(self.panel.SettingsList.ScaleSlider.Frame.Bar, self.data.CharacterScale/50)
    scaleSlider.Changed:Connect(function(value: number)
        value = tonumber(string.format("%.1f", value * 50))
        self.settingsController:LocalScale(value)
        self.panel.SettingsList.ScaleSlider.Frame.Level.Text = value
    end)
    scaleSlider.Finished:Connect(function(value: number)
        value = tonumber(string.format("%.1f", value * 50))
        self.settingsController:SetScale(value)
        self.data = self.settingsController:GetData()
    end)
end

function UIController:Start(controllers)
    self.data = controllers.SettingsController:GetData()
    self.settingsController = controllers.SettingsController
    self:CreateSliders()
    self:CreateButtons()
    self:CreateDropdowns()
end

function UIController:Init()
    self.playerGui = Player.PlayerGui
    self.gui = self.playerGui:WaitForChild("Display")
    self.panel = self.gui.Settings.Panel
    self.open = self.gui.Settings.OpenSettings

    self.open.MouseButton1Click:Connect(function()
        TweenService:Create(self.panel, TweenInfo.new(1, Enum.EasingStyle.Back), {Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
        TweenService:Create(self.open, TweenInfo.new(1, Enum.EasingStyle.Back), {Position = UDim2.new(0.995, 0, 1.295, 0)}):Play()
    end)

    self.panel.Exit.MouseButton1Click:Connect(function()
        TweenService:Create(self.panel, TweenInfo.new(1, Enum.EasingStyle.Back), {Position = UDim2.new(0.5, 0, 1.5, 0)}):Play()
        TweenService:Create(self.open, TweenInfo.new(1, Enum.EasingStyle.Back), {Position = UDim2.new(0.995, 0, 0.995, 0)}):Play()
    end)
end

return UIController