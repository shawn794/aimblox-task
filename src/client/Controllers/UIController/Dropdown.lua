local TweenService = game:GetService("TweenService")

local Janitor = require(game.ReplicatedStorage.Shared.Janitor)
local Button = require(script.Parent.Button)

local Dropdown = {}
Dropdown.__index = Dropdown

function Dropdown.new(dropdownContainer: Frame, defaultChoice: string)
    local self = setmetatable({}, Dropdown)
    self:constructor(dropdownContainer, defaultChoice)
    return self
end

function Dropdown:constructor(dropdownContainer: Frame, defaultChoice: string)
    self.janitor = Janitor.new()

    self.container = dropdownContainer
    self.holder = dropdownContainer:FindFirstChild("Holder")
    self.button = dropdownContainer:FindFirstChildOfClass("ImageButton")

    assert(self.holder ~= nil and self.button ~= nil, "Missing key components")

    self.open = false
    self.tweening = false

    self.janitor:Add(self.button.MouseButton1Click:Connect(function()
        if self.tweening then return end
        self.tweening = true
        if self.open then
            TweenService:Create(self.holder, TweenInfo.new(0.75), {Position = UDim2.new(0.5, 0, 0, 0)}):Play()
            local t = TweenService:Create(self.button.Signifier, TweenInfo.new(0.75), {Rotation = 180})
            t:Play()
            t.Completed:Wait()
            self.open = false
        else
            TweenService:Create(self.holder, TweenInfo.new(0.75), {Position = UDim2.new(0.5, 0, 1, 0)}):Play()
            local t = TweenService:Create(self.button.Signifier, TweenInfo.new(0.75), {Rotation = 359})
            t:Play()
            t.Completed:Wait()
            self.button.Signifier.Rotation = 0
            self.open = true
        end
        self.tweening = false
    end))

    self.buttonChangedEvent = Instance.new("BindableEvent")
    self.ButtonChanged = self.buttonChangedEvent.Event

    self.buttons = {}

    for _, button in pairs(self.holder:GetChildren()) do
        if button:IsA("ImageButton") then
            local bool = button.Name == defaultChoice
            local class = Button.new(button, not bool)
            class.Changed:Connect(function(bool)
                button.Overlay.Visible = bool
                self.buttonChangedEvent:Fire(button.Name)

                for buttonName, buttonInfo in pairs(self.buttons) do
                    if buttonName ~= button.Name then
                        buttonInfo.Class:SetState(true)
                        buttonInfo.Button.Overlay.Visible = true
                    end
                end
            end)
            button.Overlay.Visible = not bool
            
            self.buttons[button.Name] = {Button = button, Class = class}
        end
    end
end

function Dropdown:Destroy()
    self.janitor:Destroy()
    setmetatable(self, nil)
end

return Dropdown