local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Janitor = require(game.ReplicatedStorage.Shared.Janitor)

local Slider = {}
Slider.__index = Slider

function Slider.new(bar: Frame, defaultPosition: number)
    local self = setmetatable({}, Slider)
    self:constructor(bar, defaultPosition)
    return self
end

function Slider:constructor(bar: Frame, defaultPosition: number)
    self.janitor = Janitor.new()

    self.bar = bar
    self.barAbsoluteSize = Vector2.new(self.bar.AbsoluteSize.X, self.bar.AbsoluteSize.Y)
    self.barAbsolutePosition = Vector2.new(self.bar.AbsolutePosition.X, self.bar.AbsolutePosition.Y)

    self.mouseDown = false

    self.dragger = bar:FindFirstChild("Dragger")
    self.fill = bar:FindFirstChild("Fill")
    assert(self.dragger ~= nil and self.dragger:IsA("ImageButton"), "Dragger missing or incorrect type")
    assert(self.fill ~= nil, "Fill missing")

    self.fill.Size = UDim2.new(defaultPosition, 0, 1, 0)
    self.dragger.Position = UDim2.new(defaultPosition, 0, .5, 0)

    self.changedEvent = Instance.new("BindableEvent")
    self.Changed = self.changedEvent.Event

    self.finishedEvent = Instance.new("BindableEvent")
    self.Finished = self.finishedEvent.Event

    self.janitor:Add(self.dragger.MouseButton1Down:Connect(function()
        local mousePosition = UserInputService:GetMouseLocation()
        self.fill.Size = UDim2.new(0, mousePosition.X - self.barAbsolutePosition.X, 1, 0)
        self.dragger.Position = UDim2.new(0, mousePosition.X - self.barAbsolutePosition.X, .5, 0)
        self.mouseDown = true
    end))

    self.janitor:Add(UserInputService.InputEnded:Connect(function(input, _)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if self.mouseDown then
                self.mouseDown = false
                self.finishedEvent:Fire(self.fill.AbsoluteSize.X / self.barAbsoluteSize.X)
            end
        end
    end))

    self.janitor:Add(RunService.RenderStepped:Connect(function()
        if self.mouseDown then
            local mousePosition = UserInputService:GetMouseLocation()
            -- check if lower
            if mousePosition.X < self.barAbsolutePosition.X then
                self.fill.Size = UDim2.new(0, 0, 1, 0)
                self.dragger.Position = UDim2.new(0, 0, .5, 0)
            -- check if higher
            elseif mousePosition.X > (self.barAbsolutePosition.X + self.barAbsoluteSize.X) then
                self.fill.Size = UDim2.new(1, 0, 1, 0)
                self.dragger.Position = UDim2.new(1, 0, .5, 0)
            else
                self.fill.Size = UDim2.new(0, mousePosition.X - self.barAbsolutePosition.X, 1, 0)
                self.dragger.Position = UDim2.new(0, mousePosition.X - self.barAbsolutePosition.X, .5, 0)
            end

            self.changedEvent:Fire(self.fill.AbsoluteSize.X / self.barAbsoluteSize.X)
        end
    end))
end

function Slider:Destroy()
    self.janitor:Destroy()
    setmetatable(self, nil)
end

return Slider