local controllers = {}

-- load all controllers one after another
for _, controller in ipairs(script.Controllers:GetChildren()) do
    local s = require(controller)
    if s.Init ~= nil then
        s:Init()
    end
    controllers[controller.Name] = s
end

-- run their start methods all at once, if they have one, pass the controller list to them
for _, controller in pairs(controllers) do
    if controller.Start ~= nil then
        coroutine.wrap(function()
            controller:Start(controllers)
        end)()
    end
end