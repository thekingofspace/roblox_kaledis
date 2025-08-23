local module = {
    Workspace = "Workspace";
}

local Workspace = {}


type Services = "HTTP_Service" | "RunService" | "Datastore"

local Enum = require("@game/Enum")
local Signal = require("@game/signal")
local Color4 = require("@game/PropertyTypes/Color4")
local Udim = require("@game/PropertyTypes/Udim")

local Task = require("@game/BuiltIn/Task")

local HTTP = require("@game/Services./EncodeService")
local RunService = require("@game/Services/RunService")
local Datastore = require("@game/Services/DataStore")

local InitData = {
    RenderStep = Signal.CreateSignal();
    Heartbeat = Signal.CreateSignal();
    InstanceUpdate = Signal.CreateSignal()
}

local Services = {
    ["HTTP_Service"] = HTTP;
    ["RunService"] = RunService,
    ["Datastore"] = Datastore
}

for I, item in pairs(Services) do
    if item.Init.Build then
        item.Init.Build(InitData)
    end
end

function module:GetCommonElements()
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
