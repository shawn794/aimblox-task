local Janitor = require(game.ReplicatedStorage.Shared.Janitor)

local Button = {}
Button.__index = Button

function Button.new(buttonFrame: ImageButton, bool: boolean)
    local self = setmetatable({}, Button)
    self:constructor(buttonFrame, bool)
    return self
end

function Button:constructor(buttonFrame: ImageButton, bool: boolean)
    self.janitor = Janitor.new()
    self.bool = bool

    self.changedEvent = Instance.new("BindableEvent")
    self.Changed = self.changedEvent.Event

    self.janitor:Add(buttonFrame.MouseButton1Click:Connect(function()
        self.bool = not self.bool
        self.changedEvent:Fire(self.bool)
    end))
end

function Button:SetState(bool)
    self.bool = bool
end

function Button:Destroy()
    self.janitor:Destroy()
    setmetatable(self, nil)
end

return Button