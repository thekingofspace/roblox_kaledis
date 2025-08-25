local module = {
    Workspace = "Workspace";
}

type Services = "EncoderService" | "RunService" | "Datastore" | "Settings" | "UserInputService"

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
    InputTick = Signal.CreateSignal();
}

local Services = {
    EncoderService = HTTP;
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

local MouseButtonNames = {
    [1] = "leftclick",
    [2] = "rightclick",
    [3] = "middleclick",
}

local keysDown = {}

function love.keypressed(key)
    keysDown[key] = true
    InitData.InputBegan:Fire(key)
end

function love.keyreleased(key)
    keysDown[key] = nil
    InitData.InputEnded:Fire(key)
end

function love.mousepressed(x, y, button)
    local name = MouseButtonNames[button] or tostring(button)
    keysDown[name] = true
    InitData.InputBegan:Fire(name)
end

function love.mousereleased(x, y, button)
    local name = MouseButtonNames[button] or tostring(button)
    keysDown[name] = nil
    InitData.InputEnded:Fire(name)
end

local QuitCode = nil

function module:BindToClose(Callback)
    QuitCode = Callback
end

function love.quit()
    if QuitCode then
        QuitCode()
    end
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


 local Data:{string}? = {}

function love.update(dt)
    InitData.Heartbeat:Fire()
    Task.Init.heartbeat(dt)

    if Data then
        for I, item in pairs(keysDown) do
            table.insert(Data, I)
        end

        if #Data ~= 0 then
            InitData.InputTick:Fire(Data)

            table.clear(Data)
        end
    end
end

local function GetTruePosition(Instance)

    if not Instance.Position or not Instance.Size or not Instance.Anchorpoint then
        return Udim.UDim2.new(0,0,0,0)
    end

    local px, py = Instance.Position:ToAbsolute(love.graphics.getWidth(), love.graphics.getHeight())

    local sx, sy = Instance.Size:ToAbsolute(love.graphics.getWidth(), love.graphics.getHeight())

    local ax, ay = Instance.Anchorpoint:ToAbsolute(sx, sy)

    return px - ax, py - ay, sx, sy
end

local function RectOverlap(x1, y1, w1, h1, x2, y2, w2, h2)
    return not (x1 + w1 < x2 or x2 + w2 < x1 or y1 + h1 < y2 or y2 + h2 < y1)
end

function module:GetItemsInBound(Position:UDim2, Size:UDim2, IgnoreList:{Instance?})
    local results = {}
    IgnoreList = IgnoreList or {}

    local bx, by = Position:ToAbsolute(love.graphics.getWidth(), love.graphics.getHeight())
    local bw, bh = Size:ToAbsolute(love.graphics.getWidth(), love.graphics.getHeight())

    for _, inst in pairs(Drawables) do
        if inst.Visible ~= false and not table.find(IgnoreList, inst) and inst.Parent ~= nil and inst.CanQuery ==  true then
            local ix, iy, iw, ih = GetTruePosition(inst)

            if RectOverlap(bx, by, bw, bh, ix, iy, iw, ih) then
                table.insert(results, inst)
            end
        end
    end

    for _, inst in pairs(Instances) do
        if inst.Visible ~= false and not table.find(IgnoreList, inst) then
            local ix, iy, iw, ih = GetTruePosition(inst)

            if RectOverlap(bx, by, bw, bh, ix, iy, iw, ih) then
                table.insert(results, inst)
            end
        end
    end

    return results
end

local function CheckCollisions(drawables)
    for i = 1, #drawables do
        local a = drawables[i]
        local ax, ay, aw, ah = GetTruePosition(a)

        if a.Visible ~= true or a.CanQuery == false then
            continue
        end

        for j = i + 1, #drawables do
            local b = drawables[j]

            if b.Visible ~= true or b.CanQuery == false then
                continue
            end

            if not b:IsDescendantOf(a) and not a:IsDescendantOf(b) then
                local bx, by, bw, bh = GetTruePosition(b)

                if RectOverlap(ax, ay, aw, ah, bx, by, bw, bh) then
                    a.TouchedPrivate:Fire(b)
                    b.TouchedPrivate:Fire(a)
                end
            end
        end
    end
end

function love.draw()
    local currentTime = love.timer.getTime()
    local dt = currentTime - lastTime
    lastTime = currentTime

    InitData.RenderStep:Fire(dt)

    local drawList = {}

    local function getAbsoluteZ(item)
        local z = item.ZIndex or 0
        local parent = item.Parent
        if type(parent) == "table" and parent.ZIndex then
            return getAbsoluteZ(parent) + z
        end
        return z
    end

    for _, item in pairs(Drawables) do
        table.insert(drawList, {obj = item, z = getAbsoluteZ(item)})
    end

    table.sort(drawList, function(a, b)
        return a.z < b.z
    end)

    local onlyObjects = {}
    for _, entry in ipairs(drawList) do
        table.insert(onlyObjects, entry.obj)
    end
    CheckCollisions(onlyObjects)

    for _, entry in ipairs(drawList) do
        entry.obj:Draw()
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
