local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local Janitor = require(game.ReplicatedStorage.Shared.Janitor)

--[[
    PascalCase methods and variables are public, camelCase methods and variables are private (except for new)
]]

local Slider = {}
Slider.__index = Slider

-- Creates a new slider wrapper
function Slider.new(bar: Frame, defaultPosition: number)
    local self = setmetatable({}, Slider)
    self:constructor(bar, defaultPosition)
    return self
end

-- internal constructor, should not be called externally
function Slider:constructor(bar: Frame, defaultPosition: number)
    -- create a janitor for event handling
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
    -- expose the BindableEvent Event for slider changes, sending the current value of the slider every frame it updates
    self.Changed = self.changedEvent.Event

    self.finishedEvent = Instance.new("BindableEvent")
    -- expose the BindableEvent Event for when the slider is released, sending the final value that should be sent to the server
    self.Finished = self.finishedEvent.Event

    self.janitor:Add(self.dragger.MouseButton1Down:Connect(function()
        local mousePosition = UserInputService:GetMouseLocation()
        self.fill.Size = UDim2.new(0, mousePosition.X - self.barAbsolutePosition.X, 1, 0)
        self.dragger.Position = UDim2.new(0, mousePosition.X - self.barAbsolutePosition.X, .5, 0)
        self.dragger.Detail.ImageColor3 = Color3.fromRGB(125, 125, 125)
        self.mouseDown = true
    end))

    self.janitor:Add(UserInputService.InputEnded:Connect(function(input, _)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if self.mouseDown then
                self.mouseDown = false
                self.dragger.Detail.ImageColor3 = Color3.new(1, 1, 1)
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

            SoundService.Tick:Play()
            self.changedEvent:Fire(self.fill.AbsoluteSize.X / self.barAbsoluteSize.X)
        end
    end))
end

-- class level Destructor, cleans up all listeners and destroys the class
function Slider:Destroy()
    self.janitor:Destroy()
    setmetatable(self, nil)
end

return Slider