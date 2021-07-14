local services = {}

-- load each service one by one
for _, service in ipairs(script.Services:GetChildren()) do
    local s = require(service)
    if s.Init ~= nil then
        s:Init()
    end
    services[service.Name] = s
end

-- run each service:Start() method, passing in all the services into the service
for _, service in pairs(services) do
    if service.Start ~= nil then
        coroutine.wrap(function()
            service:Start(services)
        end)()
    end
end