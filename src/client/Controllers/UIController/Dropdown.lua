local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local Janitor = require(game.ReplicatedStorage.Shared.Janitor)
local Button = require(script.Parent.Button)

local OVERLAY_OFF = Color3.fromRGB(186, 120, 121)
local OVERLAY_ON = Color3.fromRGB(120, 186, 185)

local BUTTON_OFF = Color3.fromRGB(134, 87, 88)
local BUTTON_ON = Color3.fromRGB(87, 134, 133)

local function tween(thing, info, props)
    return TweenService:Create(thing, info, props)
end

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
        local click = coroutine.wrap(function()
            self.button.Overlay.Visible = false
            wait(0.1)
            self.button.Overlay.Visible = true
        end)
        click()
        SoundService.Button:Play()
        if self.open then
            tween(self.button, TweenInfo.new(0.75), {BackgroundColor3 = BUTTON_ON}):Play()
            tween(self.button.Overlay, TweenInfo.new(0.75), {BackgroundColor3 = OVERLAY_ON}):Play()
            tween(dropdownContainer.Parent, TweenInfo.new(0.75), {CanvasPosition = Vector2.new(0, 0)}):Play()
            tween(self.holder, TweenInfo.new(0.75), {Position = UDim2.new(0.5, 0, 0, 0)}):Play()
            local t = tween(self.button.Signifier, TweenInfo.new(0.75), {Rotation = 180})
            t:Play()
            t.Completed:Wait()
            self.open = false
        else
            tween(self.button, TweenInfo.new(0.75), {BackgroundColor3 = BUTTON_OFF}):Play()
            tween(self.button.Overlay, TweenInfo.new(0.75), {BackgroundColor3 = OVERLAY_OFF}):Play()
            tween(dropdownContainer.Parent, TweenInfo.new(0.75), {CanvasPosition = Vector2.new(0, 170)}):Play()
            tween(self.holder, TweenInfo.new(0.75), {Position = UDim2.new(0.5, 0, 1, 0)}):Play()
            local t = tween(self.button.Signifier, TweenInfo.new(0.75), {Rotation = 359})
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
            local overlay = button:WaitForChild("Overlay")
            local bool = button.Name == defaultChoice
            -- pass not bool, as we want the selected ones to look like the false equivalent            
            local class = Button.new(button, not bool, buttonChangeFunction)
            class.Changed:Connect(function(bool)
                local click = coroutine.wrap(function()
                    overlay.Visible = false
                    wait(0.1)
                    overlay.Visible = true
                end)
                click()
                buttonChangeFunction(button, false)

                self.buttonChangedEvent:Fire(button.Name)

                for buttonName, buttonInfo in pairs(self.buttons) do
                    if buttonName ~= button.Name then
                        buttonInfo.Class:SetState(true)
                    end
                end
            end)

            if buttonChangeFunction ~= nil then
                -- pass not bool, as we want the selected ones to look like the false equivalent
                buttonChangeFunction(button, not bool)
            end
            
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