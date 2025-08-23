local module = {
    Workspace = "Workspace";
}

type Services = "HTTP_Service" | "RunService" | "Datastore"

local Enum = require("@game/Enum")
local Signal = require("@game/signal")
local Color4 = require("@game/PropertyTypes/Color4")
local Udim = require("@game/PropertyTypes/Udim")

local Task = require("@game/BuiltIn/Task")
local Instance = require("@game/BuiltIn/Instance")

local HTTP = require("@game/Services./EncodeService")
local RunService = require("@game/Services/RunService")
local Datastore = require("@game/Services/DataStore")
local Switch = require("@game/Vendors/Switch")

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

math.randomseed(os.time() + math.random())

local usedIds = {}

local function generateNumericId()
    local length = 55
    local id

    repeat
        id = ""
        local timePart = tostring(os.time())
        id = id .. timePart

        for i = #timePart + 1, length do
            id = id .. tostring(math.random(0, 9))
        end
    until not usedIds[id]

    usedIds[id] = true
    return id
end

Instance.Init.Build(InitData, generateNumericId)


function module:GetCommonElements()
    return Color4, Enum, Udim.UDim, Udim.UDim2, Task.module, Instance.module
end

function module:GetService(Service:Services)
    if Services[Service] then
        return Services[Service].module
    else
        error("No service found under this name")
    end
end

local Instances = {}

function love.load()
    
end


function love.update(dt)
    InitData.Heartbeat:Fire()
    Task.Init.heartbeat(dt)
end

function love.draw(dt)
    InitData.RenderStep:Fire(dt)
    for I, item in pairs(Instances) do
        if item.Draw then
            item:Draw()
        end
    end
end

InitData.InstanceUpdate:Connect(function(ID:string, Type:string, Instance)
    Switch({
        ["Destroy"] = function(Stop, Roll, Push, Pop, Stack, ID:string, Instance)
            if Instances[ID] then
                Instances[ID] = nil
            end
            Stop()
        end;

        ["Create"] = function(Stop, Roll, Push, Pop, Stack, ID:string, Instance)
            Instances[ID] = Instance
            Stop()
        end;
    }, {ID, Instance}, Type)
end)

return module
