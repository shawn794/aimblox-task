local TweenService = game:GetService("TweenService")

local Janitor = require(game.ReplicatedStorage.Shared.Janitor)
local Button = require(script.Parent.Button)

--[[
    PascalCase methods and variables are public, camelCase methods and variables are private (except for new)
]]

local Dropdown = {}
Dropdown.__index = Dropdown

-- Creates a new dropdown wrapper
function Dropdown.new(dropdownContainer: Frame, defaultChoice: string, buttonChangeFunction)
    local self = setmetatable({}, Dropdown)
    self:constructor(dropdownContainer, defaultChoice, buttonChangeFunction)
    return self
end

-- internal constructor, should not be called externally
function Dropdown:constructor(dropdownContainer: Frame, defaultChoice: string, buttonChangeFunction)
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
            TweenService:Create(dropdownContainer.Parent, TweenInfo.new(0.75), {CanvasPosition = Vector2.new(0, 0)}):Play()
            TweenService:Create(self.holder, TweenInfo.new(0.75), {Position = UDim2.new(0.5, 0, 0, 0)}):Play()
            local t = TweenService:Create(self.button.Signifier, TweenInfo.new(0.75), {Rotation = 180})
            t:Play()
            t.Completed:Wait()
            self.open = false
        else
            TweenService:Create(dropdownContainer.Parent, TweenInfo.new(0.75), {CanvasPosition = Vector2.new(0, 170)}):Play()
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
    -- -- expose the BindableEvent Event for button state updates, fires the name of the button that is not selected
    self.ButtonChanged = self.buttonChangedEvent.Event

    self.buttons = {}

    for _, button in pairs(self.holder:GetChildren()) do
        if button:IsA("ImageButton") then
            local bool = button.Name == defaultChoice
            local class = Button.new(button, not bool, buttonChangeFunction)
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

-- class level Destructor, cleans up all listeners and destroys the class
function Dropdown:Destroy()
    self.janitor:Destroy()
    setmetatable(self, nil)
end

return Dropdown