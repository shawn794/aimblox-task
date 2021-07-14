local Janitor = require(game.ReplicatedStorage.Shared.Janitor)

--[[
    PascalCase methods and variables are public, camelCase methods and variables are private (except for new)
]]

local Button = {}
Button.__index = Button

-- Creates a new button wrapper
function Button.new(buttonFrame: ImageButton, bool: boolean)
    local self = setmetatable({}, Button)
    self:constructor(buttonFrame, bool)
    return self
end

-- internal constructor, should not be called externally
function Button:constructor(buttonFrame: ImageButton, bool: boolean)
    self.janitor = Janitor.new()
    self.bool = bool

    self.changedEvent = Instance.new("BindableEvent")
    -- expose the BindableEvent Event for bool state updates
    self.Changed = self.changedEvent.Event

    self.janitor:Add(buttonFrame.MouseButton1Click:Connect(function()
        self.bool = not self.bool
        self.changedEvent:Fire(self.bool)
    end))
end

-- external class method to change the internal bool variable, does not fire the .Changed event
function Button:SetState(bool)
    self.bool = bool
end

-- class level Destructor, cleans up all listeners and destroys the class
function Button:Destroy()
    self.janitor:Destroy()
    setmetatable(self, nil)
end

return Button