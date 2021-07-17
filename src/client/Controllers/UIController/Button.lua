local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Janitor = require(game.ReplicatedStorage.Shared.Janitor)

--[[
    PascalCase methods and variables are public, camelCase methods and variables are private (except for new)
]]

local Button = {}
Button.__index = Button

-- Creates a new button wrapper
function Button.new(buttonFrame: ImageButton, bool: boolean, changeFunction)
    local self = setmetatable({}, Button)
    self:constructor(buttonFrame, bool, changeFunction)
    return self
end

-- internal constructor, should not be called externally
function Button:constructor(buttonFrame: ImageButton, bool: boolean, changeFunction)
    self.janitor = Janitor.new()
    self.bool = bool

    self.button = buttonFrame
    self.currentButtonColor = self.button.BackgroundColor3
    self.currentOverlayColor = self.button.Overlay.BackgroundColor3
    self.changeFunction = changeFunction

    self.changedEvent = Instance.new("BindableEvent")
    -- expose the BindableEvent Event for bool state updates
    self.Changed = self.changedEvent.Event

    self.janitor:Add(buttonFrame.MouseButton1Click:Connect(function()
        self.bool = not self.bool
        if changeFunction ~= nil then
            changeFunction(self.button, self.bool)
        end
        self.currentButtonColor = self.button.BackgroundColor3
        self.currentOverlayColor = self.button.Overlay.BackgroundColor3
        SoundService.Button:Play()
        self.changedEvent:Fire(self.bool)
    end))

    self.janitor:Add(buttonFrame.MouseEnter:Connect(function()
        local internalJanitor = Janitor.new()

        self.currentButtonColor = self.button.BackgroundColor3
        self.currentOverlayColor = self.button.Overlay.BackgroundColor3

        local previousButtonColor = buttonFrame.BackgroundColor3
        local lerpedButtonColor = previousButtonColor:Lerp(Color3.fromRGB(25, 25, 25), 0.25)
        TweenService:Create(buttonFrame, TweenInfo.new(0.25), {BackgroundColor3 = lerpedButtonColor}):Play()

        local previousOverlayColor = buttonFrame.Overlay.BackgroundColor3
        local lerpedOverlayColor = previousOverlayColor:Lerp(Color3.fromRGB(25, 25, 25), 0.25)
        TweenService:Create(buttonFrame.Overlay, TweenInfo.new(0.25), {BackgroundColor3 = lerpedOverlayColor}):Play()

        internalJanitor:Add(buttonFrame.MouseLeave:Connect(function()
            TweenService:Create(buttonFrame, TweenInfo.new(0.25), {BackgroundColor3 = self.currentButtonColor}):Play()
            TweenService:Create(buttonFrame.Overlay, TweenInfo.new(0.25), {BackgroundColor3 = self.currentOverlayColor}):Play()
            internalJanitor:Destroy()
        end))
    end))
end

-- external class method to change the internal bool variable, does not fire the .Changed event
function Button:SetState(bool)
    self.bool = bool
    if self.changeFunction ~= nil then
        self.changeFunction(self.button, self.bool)
    end
end

-- class level Destructor, cleans up all listeners and destroys the class
function Button:Destroy()
    self.janitor:Destroy()
    setmetatable(self, nil)
end

return Button