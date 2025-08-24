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
    MouseMoved = Signal.CreateSignal()
}

local Services = {
    ["HTTP_Service"] = HTTP;
    ["RunService"] = RunService,
    ["Datastore"] = Datastore,
    ["Settings"] = Settings,
    ["UserInputService"] = UInput
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

function love.keypressed(key, scancode, isrepeat)
    InitData.InputBegan:Fire(key)
end

function love.keyreleased(key, scancode)
    InitData.InputEnded:Fire(key)
end

function love.mousepressed(x, y, button, istouch, presses)
    local name = MouseButtonNames[button] or tostring(button)
    InitData.InputBegan:Fire(name)
end

function love.mousereleased(x, y, button, istouch, presses)
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

function love.mousemoved(x, y, dx, dy, istouch)
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
        if item.ZIndex ~= nil then
            table.insert(layered, item)
        else
            table.insert(normal, item)
        end
    end

    table.sort(layered, function(a, b)
        return a.ZIndex < b.ZIndex
    end)

    for _, item in ipairs(layered) do
        if item.Draw then
            item:Draw()
        end
    end

    for _, item in ipairs(normal) do
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

            if Drawables[ID] then
                Drawables[ID] = nil
            end
            Stop()
        end;

        ["Create"] = function(Stop, Roll, Push, Pop, Stack, ID:string, Instance)
            if Instance.Draw ~= nil then
                Drawables[ID] = Instance
            else
                Instances[ID] = nil
            end
            Stop()
        end;
    }, {ID, Instance}, Type)
end)

return module
