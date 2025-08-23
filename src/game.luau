local module = {}

type Services = "HTTP_Service" | "RunService"

local Enum = require("@game/Enum")
local Signal = require("@game/signal")
local Color4 = require("@game/PropertyTypes/Color4")
local Udim = require("@game/PropertyTypes/Udim")

local Task = require("@game/BuiltIn/Task")

local HTTP = require("@game/Services/HTTP")
local RunService = require("@game/Services/RunService")

local InitData = {
    RenderStep = Signal.CreateSignal();
    Heartbeat = Signal.CreateSignal();
}

RunService.Init.Build(InitData.RenderStep, InitData.Heartbeat)

local Services = {
    ["HTTP_Service"] = HTTP;
    ["RunService"] = RunService
}

function module.GetCommonElements()
    return Color4, Enum, Udim.UDim, Udim.UDim2, Task.module
end

function module:GetService(Service:Services)
    if Services[Service] then
        return Services[Service].module
    else
        error("No service found under this name")
    end
end

function love.load()
   
end

function love.update(dt)
    InitData.Heartbeat:Fire()
    Task.Init.heartbeat(dt)
end

function love.draw(dt)
    InitData.RenderStep:Fire(dt)
end

return module
