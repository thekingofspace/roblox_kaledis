local module = {
    Workspace = "Workspace";
}

type Services = "HTTP_Service" | "RunService" | "Datastore" | "Settings" | "UserInputService"

local Enum = require("@game/Enum")
local Signal = require("@game/signal")
local Color4 = require("@game/PropertyTypes/Color4")
local Udim = require("@game/PropertyTypes/Udim")

local Task = require("@game/BuiltIn/Task")
local Instance = require("@game/BuiltIn/Instance")
local Switch = require("@game/Vendors/Switch")

local HTTP = require("@game/Services./EncodeService")
local RunService = require("@game/Services/RunService")
local Datastore = require("@game/Services/DataStore")
local Settings = require("@game/Services/Settings")
local UInput = require("@game/Services/InputService")

local InitData = {
    RenderStep = Signal.CreateSignal();
    Heartbeat = Signal.CreateSignal();
    InstanceUpdate = Signal.CreateSignal();
    InputBegan = Signal.CreateSignal();
    InputEnded = Signal.CreateSignal();
    MouseMoved = Signal.CreateSignal();
}

local Services = {
    HTTP_Service = HTTP;
    RunService = RunService;
    Datastore = Datastore;
    Settings = Settings;
    UserInputService = UInput;
}

for _, service in pairs(Services) do
    if service.Init.Build then
        service.Init.Build(InitData)
    end
end

math.randomseed(os.time() + math.random())

local usedIds = {}

local function generateNumericId()
    local length = 55
    local id

    repeat
        id = tostring(os.time())
        while #id < length do
            id = id .. tostring(math.random(0, 9))
        end
    until not usedIds[id]

    usedIds[id] = true
    return id
end

Instance.Init.Build(InitData, generateNumericId, UInput.module)

function module:GetCommonElements()
    return Color4, Enum, Udim.UDim, Udim.UDim2, Task.module, Instance.module
end

function module:GetService(Service: Services)
    local service = Services[Service]
    if service then
        return service.module
    else
        error("No service found under this name")
    end
end

local Instances = {}
local Drawables = {}

function love.load()
end

function love.update(dt)
    InitData.Heartbeat:Fire()
    Task.Init.heartbeat(dt)
end

local MouseButtonNames = {
    [1] = "leftclick",
    [2] = "rightclick",
    [3] = "middleclick",
}

function love.keypressed(key)
    InitData.InputBegan:Fire(key)
end

function love.keyreleased(key)
    InitData.InputEnded:Fire(key)
end

function love.mousepressed(x, y, button)
    local name = MouseButtonNames[button] or tostring(button)
    InitData.InputBegan:Fire(name)
end

function love.mousereleased(x, y, button)
    local name = MouseButtonNames[button] or tostring(button)
    InitData.InputEnded:Fire(name)
end

function love.wheelmoved(x, y)
    if y > 0 then
        InitData.InputBegan:Fire("wheel_up")
        InitData.InputEnded:Fire("wheel_up")
    elseif y < 0 then
        InitData.InputBegan:Fire("wheel_down")
        InitData.InputEnded:Fire("wheel_down")
    end
end

function love.mousemoved(x, y, dx, dy)
    InitData.MouseMoved:Fire(x, y, dx, dy)
end

local lastTime = love.timer.getTime()

function love.draw()
    local currentTime = love.timer.getTime()
    local dt = currentTime - lastTime
    lastTime = currentTime

    InitData.RenderStep:Fire(dt)

    local normal = {}
    local layered = {}
    for _, item in pairs(Drawables) do
        if item.ZIndex then
            table.insert(layered, item)
        else
            table.insert(normal, item)
        end
    end

    table.sort(layered, function(a, b)
        return a.ZIndex < b.ZIndex
    end)

    for _, item in ipairs(layered) do
        item:Draw()
    end

    for _, item in ipairs(normal) do
        item:Draw()
    end
end

InitData.InstanceUpdate:Connect(function(ID: string, Type: string, Instance)
    Switch({
        Destroy = function(Stop, _, _, _, _, ID: string)
            Instances[ID] = nil
            Drawables[ID] = nil
            Stop()
        end;
        Create = function(Stop, _, _, _, _, ID: string, Instance)
            if Instance.Draw then
                Drawables[ID] = Instance
            else
                Instances[ID] = Instance
            end
            Stop()
        end;
    }, {ID, Instance}, Type)
end)

return module
