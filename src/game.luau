local module = {
    Workspace = "Workspace";
}

type Services = "EncoderService" | "RunService" | "Datastore" | "Settings" | "UserInputService" | "DesktopService"

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
local Desktop = require("@game/Services/DesktopService")

local InitData = {
    RenderStep = Signal.CreateSignal();
    Heartbeat = Signal.CreateSignal();
    InstanceUpdate = Signal.CreateSignal();
    InputBegan = Signal.CreateSignal();
    InputEnded = Signal.CreateSignal();
    MouseMoved = Signal.CreateSignal();
    InputTick = Signal.CreateSignal();
    Window_Resize = Signal.CreateSignal();
}

local Services = {
    EncoderService = HTTP;
    RunService = RunService;
    Datastore = Datastore;
    Settings = Settings;
    UserInputService = UInput;
    DesktopService = Desktop
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

Instance.Init.Build(InitData, generateNumericId)

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
    [1] = "mouse_left",
    [2] = "mouse_right",
    [3] = "mouse_middle",
}

local keysDown = {}

function love.keypressed(key, ScanCode)
    keysDown[key] = true
    InitData.InputBegan:Fire(key, ScanCode)
end

function love.keyreleased(key, ScanCode)
    keysDown[key] = nil
    InitData.InputEnded:Fire(key, ScanCode)
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

local lastTime = love.timer.getTime()

local Data:{string}? = {}
local pressedInstances = {}

local function GetTruePosition(Instance)
    if not Instance.Position or not Instance.Size or not Instance.Anchorpoint then
        return 0, 0, 0, 0, 0
    end

    local px, py = Instance.Position:ToAbsolute(love.graphics.getWidth(), love.graphics.getHeight())
    local sx, sy = Instance.Size:ToAbsolute(love.graphics.getWidth(), love.graphics.getHeight())
    local ax, ay = Instance.Anchorpoint:ToAbsolute(sx, sy)
    local rotation = Instance.Rotation or 0

    return px - ax, py - ay, sx, sy, rotation
end

local function RotatePoint(px, py, cx, cy, angle)
    if angle == 0 then
        return px, py
    end
    
    local cos_a = math.cos(angle)
    local sin_a = math.sin(angle)
    local dx = px - cx
    local dy = py - cy
    
    return cx + dx * cos_a - dy * sin_a, cy + dx * sin_a + dy * cos_a
end

local function GetRotatedCorners(x, y, w, h, rotation)
    local cx, cy = x + w/2, y + h/2
    
    local corners = {
        {x, y},
        {x + w, y},
        {x + w, y + h},
        {x, y + h}
    }
    
    if rotation ~= 0 then
        for i = 1, 4 do
            corners[i][1], corners[i][2] = RotatePoint(corners[i][1], corners[i][2], cx, cy, rotation)
        end
    end
    
    return corners
end

local function PointInRotatedRect(px, py, x, y, w, h, rotation)
    if rotation == 0 then
        return px >= x and px <= x + w and py >= y and py <= y + h
    end
    
    local corners = GetRotatedCorners(x, y, w, h, rotation)
    
    local function IsLeft(p0x, p0y, p1x, p1y, p2x, p2y)
        return (p1x - p0x) * (p2y - p0y) - (p2x - p0x) * (p1y - p0y)
    end
    
    local wn = 0
    for i = 1, 4 do
        local j = (i % 4) + 1
        local c1 = corners[i]
        local c2 = corners[j]
        
        if c1[2] <= py then
            if c2[2] > py then
                if IsLeft(c1[1], c1[2], c2[1], c2[2], px, py) > 0 then
                    wn = wn + 1
                end
            end
        else
            if c2[2] <= py then
                if IsLeft(c1[1], c1[2], c2[1], c2[2], px, py) < 0 then
                    wn = wn - 1
                end
            end
        end
    end
    
    return wn ~= 0
end

local function RotatedRectOverlap(x1, y1, w1, h1, rot1, x2, y2, w2, h2, rot2)
    if rot1 == 0 and rot2 == 0 then
        return not (x1 + w1 < x2 or x2 + w2 < x1 or y1 + h1 < y2 or y2 + h2 < y1)
    end
    
    local corners1 = GetRotatedCorners(x1, y1, w1, h1, rot1)
    local corners2 = GetRotatedCorners(x2, y2, w2, h2, rot2)
    
    local axes = {}
    
    for i = 1, 4 do
        local j = (i % 4) + 1
        local dx = corners1[j][1] - corners1[i][1]
        local dy = corners1[j][2] - corners1[i][2]
        local length = math.sqrt(dx*dx + dy*dy)
        if length > 0 then
            table.insert(axes, {-dy/length, dx/length})
        end
    end
    
    for i = 1, 4 do
        local j = (i % 4) + 1
        local dx = corners2[j][1] - corners2[i][1]
        local dy = corners2[j][2] - corners2[i][2]
        local length = math.sqrt(dx*dx + dy*dy)
        if length > 0 then
            table.insert(axes, {-dy/length, dx/length})
        end
    end
    
    for _, axis in ipairs(axes) do
        local min1, max1 = math.huge, -math.huge
        local min2, max2 = math.huge, -math.huge
        
        for _, corner in ipairs(corners1) do
            local projection = corner[1] * axis[1] + corner[2] * axis[2]
            min1 = math.min(min1, projection)
            max1 = math.max(max1, projection)
        end
        
        for _, corner in ipairs(corners2) do
            local projection = corner[1] * axis[1] + corner[2] * axis[2]
            min2 = math.min(min2, projection)
            max2 = math.max(max2, projection)
        end
        
        if max1 < min2 or max2 < min1 then
            return false
        end
    end
    
    return true
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
        if inst.Visible ~= false and not table.find(IgnoreList, inst) and inst.Parent ~= nil and inst.CanQuery == true then
            local ix, iy, iw, ih, irot = GetTruePosition(inst)

            local overlaps
            if irot and irot ~= 0 then
                overlaps = RotatedRectOverlap(bx, by, bw, bh, 0, ix, iy, iw, ih, irot)
            else
                overlaps = RectOverlap(bx, by, bw, bh, ix, iy, iw, ih)
            end

            if overlaps then
                table.insert(results, inst)
            end
        end
    end

    for _, inst in pairs(Instances) do
        if inst.Visible ~= false and not table.find(IgnoreList, inst) then
            local ix, iy, iw, ih, irot = GetTruePosition(inst)

            local overlaps
            if irot and irot ~= 0 then
                overlaps = RotatedRectOverlap(bx, by, bw, bh, 0, ix, iy, iw, ih, irot)
            else
                overlaps = RectOverlap(bx, by, bw, bh, ix, iy, iw, ih)
            end

            if overlaps then
                table.insert(results, inst)
            end
        end
    end

    return results
end

local activeCollisions = {}

local function CheckCollisions(drawables)
    local newCollisions = {}

    for i = 1, #drawables do
        local a = drawables[i]
        local ax, ay, aw, ah, arot = GetTruePosition(a)

        if a.Visible ~= true or a.CanQuery == false or a.SinkInputs == false then
            continue
        end

        for j = i + 1, #drawables do
            local b = drawables[j]

            if b.Visible ~= true or b.CanQuery == false or a.SinkInputs == false then
                continue
            end

            if not b:IsDescendantOf(a) and not a:IsDescendantOf(b) then
                local bx, by, bw, bh, brot = GetTruePosition(b)

                local overlaps
                if (arot and arot ~= 0) or (brot and brot ~= 0) then
                    overlaps = RotatedRectOverlap(ax, ay, aw, ah, arot or 0, bx, by, bw, bh, brot or 0)
                else
                    overlaps = RectOverlap(ax, ay, aw, ah, bx, by, bw, bh)
                end

                if overlaps then
                    local key = tostring(a) .. "_" .. tostring(b)
                    newCollisions[key] = {a, b}

                    if not activeCollisions[key] then
                        a.TouchedStartedPrivate:Fire(b)
                        b.TouchedStartedPrivate:Fire(a)
                    end
                end
            end
        end
    end

    for key, pair in pairs(activeCollisions) do
        if not newCollisions[key] then
            local a, b = pair[1], pair[2]
            if a.TouchedPrivate then
                a.TouchedPrivate:Fire(b)
            end
            if b.TouchedPrivate then
                b.TouchedPrivate:Fire(a)
            end
        end
    end

    activeCollisions = newCollisions
end

local hoveredInstances = {}

local function CheckMouseHover(drawables)
    local mx, my = love.mouse.getPosition()
    local newHovered = {}

    for _, inst in ipairs(drawables) do
        if inst.Visible ~= false and inst.CanQuery == true and inst.SinkInputs == true then
            local x, y, w, h, rotation = GetTruePosition(inst)

            local isInside
            if rotation and rotation ~= 0 then
                isInside = PointInRotatedRect(mx, my, x, y, w, h, rotation)
            else
                isInside = mx >= x and mx <= x + w and my >= y and my <= y + h
            end

            if isInside then
                newHovered[inst] = true

                if not hoveredInstances[inst] then
                    if inst.HoverBegan_Private then
                        inst.HoverBegan_Private:Fire()
                    end
                end
            end
        end
    end

    for inst, _ in pairs(hoveredInstances) do
        if not newHovered[inst] then
            if inst.HoverEnded_Private and inst.SinkInputs == true then
                inst.HoverEnded_Private:Fire()
            end

            if pressedInstances[inst] then
                if inst.MouseClickRelease_Private then
                    inst.MouseClickRelease_Private:Fire()
                end
                pressedInstances[inst] = nil
            end
        end
    end

    hoveredInstances = newHovered
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
    CheckMouseHover(onlyObjects)

    for _, entry in ipairs(drawList) do
        entry.obj:Draw()
    end
end

function love.mousepressed(x, y, button)
    local name = MouseButtonNames[button] or tostring(button)
    keysDown[name] = true
    InitData.InputBegan:Fire(name)

    for inst, _ in pairs(hoveredInstances) do
        if inst.SinkInputs ~= true then
            continue
        end
        inst.MouseClick_Private:Fire(name)
        pressedInstances[inst] = true
    end
end

function love.mousereleased(x, y, button)
    local name = MouseButtonNames[button] or tostring(button)
    keysDown[name] = nil
    InitData.InputEnded:Fire(name)

    for inst, _ in pairs(pressedInstances) do
        if inst.MouseClickRelease_Private then
            inst.MouseClickRelease_Private:Fire(name)
        end
    end

    pressedInstances = {}
end

function love.mousemoved(x, y, dx, dy)
    InitData.MouseMoved:Fire(x, y, dx, dy)
    local drawList = {}
    for _, item in pairs(Drawables) do table.insert(drawList, item) end
    for _, item in pairs(Instances) do table.insert(drawList, item) end
    CheckMouseHover(drawList)
end


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


function module:GetType(I:Instance?)
    if typeof(I) == "table" and I.ClassName then
        return I.ClassName
    else
        return typeof(I)
    end
end

function RayRectIntersect(rayX, rayY, dirX, dirY, rectX, rectY, rectW, rectH, rotation, maxDist)
    if rotation == 0 then
        return RayAABBIntersect(rayX, rayY, dirX, dirY, rectX, rectY, rectW, rectH, maxDist)
    else
        return RayOBBIntersect(rayX, rayY, dirX, dirY, rectX, rectY, rectW, rectH, rotation, maxDist)
    end
end

function RayAABBIntersect(rayX, rayY, dirX, dirY, rectX, rectY, rectW, rectH, maxDist)
    local minX, maxX = rectX, rectX + rectW
    local minY, maxY = rectY, rectY + rectH
    
    local tMinX = (minX - rayX) / dirX
    local tMaxX = (maxX - rayX) / dirX
    
    if tMinX > tMaxX then
        tMinX, tMaxX = tMaxX, tMinX
    end
    
    local tMinY = (minY - rayY) / dirY
    local tMaxY = (maxY - rayY) / dirY
    
    if tMinY > tMaxY then
        tMinY, tMaxY = tMaxY, tMinY
    end
    
    local tMin = math.max(tMinX, tMinY)
    local tMax = math.min(tMaxX, tMaxY)
    
    if tMax < 0 or tMin > tMax or tMin > maxDist then
        return nil
    end
    
    local t = tMin >= 0 and tMin or tMax
    if t > maxDist then
        return nil
    end
    
    local hitX = rayX + dirX * t
    local hitY = rayY + dirY * t
    
    local normal = {x = 0, y = 0}
    local centerX, centerY = rectX + rectW/2, rectY + rectH/2
    local relX, relY = hitX - centerX, hitY - centerY
    
    if math.abs(relX) > math.abs(relY) then
        normal.x = relX > 0 and 1 or -1
    else
        normal.y = relY > 0 and 1 or -1
    end
    
    return {x = hitX, y = hitY, normal = normal}, t
end

function RayOBBIntersect(rayX, rayY, dirX, dirY, rectX, rectY, rectW, rectH, rotation, maxDist)
    local centerX, centerY = rectX + rectW/2, rectY + rectH/2
    local halfW, halfH = rectW/2, rectH/2
    
    local cos_r = math.cos(-rotation)
    local sin_r = math.sin(-rotation)
    
    local localRayX = rayX - centerX
    local localRayY = rayY - centerY
    
    local transformedRayX = localRayX * cos_r - localRayY * sin_r
    local transformedRayY = localRayX * sin_r + localRayY * cos_r
    
    local transformedDirX = dirX * cos_r - dirY * sin_r
    local transformedDirY = dirX * sin_r + dirY * cos_r
    
    local result, distance = RayAABBIntersect(
        transformedRayX, transformedRayY,
        transformedDirX, transformedDirY,
        -halfW, -halfH, rectW, rectH,
        maxDist
    )
    
    if not result then
        return nil
    end
    
    local localHitX, localHitY = result.x, result.y
    local worldHitX = localHitX * cos_r - localHitY * sin_r + centerX
    local worldHitY = localHitX * sin_r + localHitY * cos_r + centerY
    
    local localNormalX, localNormalY = result.normal.x, result.normal.y
    local worldNormalX = localNormalX * cos_r - localNormalY * sin_r
    local worldNormalY = localNormalX * sin_r + localNormalY * cos_r
    
    return {
        x = worldHitX, 
        y = worldHitY, 
        normal = {x = worldNormalX, y = worldNormalY}
    }, distance
end

function module:Raycast(Origin: UDim2, Direction: UDim2, MaxDistance: number?, IgnoreList: {Instance?}?)
    MaxDistance = MaxDistance or 1000
    IgnoreList = IgnoreList or {}
    
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    
    local startX, startY = Origin:ToAbsolute(screenWidth, screenHeight)
    local dirX, dirY = Direction:ToAbsolute(screenWidth, screenHeight)
    
    local dirLength = math.sqrt(dirX * dirX + dirY * dirY)
    if dirLength == 0 then
        return nil, startX, startY
    end
    
    dirX = dirX / dirLength
    dirY = dirY / dirLength
    
    local results = {}
    
    local allObjects = {}
        for _, obj in pairs(Drawables) do
            table.insert(allObjects, obj)
        end
        for _, obj in pairs(Instances) do
            table.insert(allObjects, obj)
        end
        
        for _, inst in pairs(allObjects) do
        if IgnoreList then
            if inst.Visible == false
            or table.find(IgnoreList, inst)
            or inst.Parent == nil
            or (inst.CanQuery ~= nil and inst.CanQuery == false) then
                continue
            end
        end

        local x, y, w, h, rotation = GetTruePosition(inst)

        local hitPoint, distance = RayRectIntersect(
            startX, startY, dirX, dirY,
            x, y, w, h, rotation or 0,
            MaxDistance
        )

        if hitPoint then
            table.insert(results, {
                Instance = inst,
                Position = Udim.UDim2.new(0, hitPoint.x, 0, hitPoint.y),
                Distance = distance,
                Normal = hitPoint.normal
            })
        end
    end
    
    table.sort(results, function(a, b)
        return a.Distance < b.Distance
    end)
    
    if #results > 0 then
        local closest = results[1]
        return closest.Instance, closest.Position.X.Offset, closest.Position.Y.Offset, closest.Distance, closest.Normal
    end
    
    local endX = startX + dirX * MaxDistance
    local endY = startY + dirY * MaxDistance
    return nil, endX, endY, MaxDistance, nil
end

function module:Quit()
    love.event.quit(1)
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
