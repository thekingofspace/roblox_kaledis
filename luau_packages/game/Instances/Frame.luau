local module = {}
local Inherited = require("@game/Instances/Inherited")
local Signal = require("@game/signal")
local Udim = require("@game/PropertyTypes/Udim")
local Color4 = require("@game/PropertyTypes/Color4")

local function CheckType(ID: string, Value, Properties)
    if Properties[ID] == "frozen" then
        return false
    end
    if typeof(Properties[ID]) == "string" then
        return typeof(Value) == Properties[ID]
    else
        for _, item in ipairs(Properties[ID]) do
            if typeof(Value) == item then
                return true
            end
        end
        return false
    end
end

local PropertyTypes = {
    Name = "string",
    ClassName = "frozen",
    Changed = "frozen",
    Touched = "frozen",
    TouchedPrivate = "frozen",
    ID = "frozen",
    attributes = "table",
    Parent = {"nil", "string", "table"},
    Visible = "boolean",
    Size = "table";
    Position = "table";
    Anchorpoint = "table";
    Color = "table";
    Rotation = "number";
    ZIndex = "number";
    Destroyed = "frozen";
    CanQuery = "boolean";
}

local PropertyTransform = {
    Parent = function(_, Value)
            if typeof(Value) == "table" and Value.Draw ~= nil then
                return Value
            else
                if Value == "Workspace" or Value == nil then
                return Value or "nil"
            end

            return
        end
    end
}

local ReadTransform = {
    Parent = function(_, Value)
        if Value == "nil" then
            return nil
        else
            return Value
        end
    end
}

function module.new(InstanceUpdate: Signal, GetID: () -> string, UserInput:UserInputService)
    local Changed = Signal.CreateSignal()
    local Touched = Signal.CreateSignal()
    local UID = GetID()

    local RawProperties = {
        Name = "Frame",
        ClassName = "Frame",
        Changed = Signal.CreateReadOnlySignal(Changed),
        Touched = Signal.CreateReadOnlySignal(Touched),
        TouchedPrivate = Touched,
        ID = UID,
        attributes = {},
        Parent = "nil",
        Visible = true;
        Size = Udim.UDim2.new(0, 100, 0, 100);
        Position = Udim.UDim2.new(0, 0, 0, 0);
        Anchorpoint = Udim.UDim2.new(0.5, 0, 0.5, 0);
        Color = Color4.new("#ffffff");
        Rotation = 0;
        ZIndex = 0;
        Destroyed = false;
        CanQuery = true;
    }

    local RawMethods = {}
    for k, v in pairs(Inherited) do
        RawMethods[k] = v
    end

    RawMethods.GetAbsolute = function(self)
        local parent = RawProperties.Parent
        local parentW, parentH = love.graphics.getWidth(), love.graphics.getHeight()
        local parentX, parentY = 0, 0

        if type(parent) == "table" and parent.GetAbsolute and parent.GetAbsoluteSize then
            parentW, parentH = parent:GetAbsoluteSize()
            local parentAbs = parent:GetAbsolute()
            parentX, parentY = parentAbs.X.Offset or 0, parentAbs.Y.Offset or 0
        end

        local px, py = self.Position:ToAbsolute(parentW, parentH)
        local sx, sy = self.Size:ToAbsolute(parentW, parentH)
        local ax, ay = self.Anchorpoint:ToAbsolute(sx, sy)

        local absX, absY = px - ax + parentX, py - ay + parentY
        return Udim.UDim2.new(absX / love.graphics.getWidth(), 0, absY / love.graphics.getHeight(), 0)
    end

    RawMethods.GetAbsoluteSize = function(self)
        local parent = RawProperties.Parent
        local parentW, parentH = love.graphics.getWidth(), love.graphics.getHeight()
        
        if type(parent) == "table" and parent.GetAbsoluteSize then
            parentW, parentH = parent:GetAbsoluteSize()
        end
        
        return self.Size:ToAbsolute(parentW, parentH)
    end

    RawMethods.Draw = function(self)
        if RawProperties.Visible ~= true and self.Parent ~= nil then return end

        local parent = RawProperties.Parent
        local parentW, parentH = love.graphics.getWidth(), love.graphics.getHeight()
        local parentX, parentY = 0, 0

        if type(parent) == "table" and parent.GetAbsolute and parent.GetAbsoluteSize then
            parentW, parentH = parent:GetAbsoluteSize()
            local parentAbs = parent:GetAbsolute()
            parentX = parentAbs.X.Scale * love.graphics.getWidth() + parentAbs.X.Offset
            parentY = parentAbs.Y.Scale * love.graphics.getHeight() + parentAbs.Y.Offset
        end

        local px, py = RawProperties.Position:ToAbsolute(parentW, parentH)
        local sx, sy = RawProperties.Size:ToAbsolute(parentW, parentH)
        local ax, ay = RawProperties.Anchorpoint:ToAbsolute(sx, sy)

        local r, g, b, a = RawProperties.Color:toLove()

        love.graphics.push()
        love.graphics.translate(px + parentX, py + parentY)
        love.graphics.rotate(math.rad(RawProperties.Rotation))
        love.graphics.setColor(r, g, b, a)
        love.graphics.rectangle("fill", -ax, -ay, sx, sy)
        love.graphics.pop()
    end

    RawMethods.Destroy = function(self)
        InstanceUpdate:Fire(UID, "Destroy", self)
        table.clear(RawProperties)
        table.clear(RawMethods)
        Changed = nil
        UID = nil
        RawProperties.Destroyed = true
    end

    RawMethods.IsDescendantOf = function(self, Target:Frame)
        local CurrentParent = self.Parent
        while CurrentParent do
            if CurrentParent == Target then
                return true
            end
            CurrentParent = CurrentParent.Parent
        end
        return false
    end

    RawMethods.Clone = function(self)
        local clone = module.new(InstanceUpdate, GetID, UserInput)

        for k, v in pairs(RawProperties) do
            if PropertyTypes[k] ~= "frozen" then
                clone[k] = v
            end
        end

        return clone
    end

    local self = {}
    local mt = {}

    mt.__index = function(_, index)
        if RawProperties[index] then
            if ReadTransform[index] then
                return ReadTransform[index](self, RawProperties[index])
            else
                return RawProperties[index]
            end
        elseif RawMethods[index] then
            return RawMethods[index]
        end

        return
    end

    mt.__newindex = function(_, index, value)
        if RawProperties[index] then
            if CheckType(index, value, PropertyTypes) then
                if PropertyTransform[index] then
                    RawProperties[index] = PropertyTransform[index](self, value)
                else
                    RawProperties[index] = value
                end

                Changed:Fire()
            else
                if PropertyTypes[index] == "frozen" then
                    error(index .. " cannot be changed")
                else
                    error(string.format(
                        "%s must be a %s",
                        index,
                        type(PropertyTypes[index]) == "table" and table.concat(PropertyTypes[index], " ") or type(RawProperties[index])
                    ))
                end
            end
        else
            error(index .. " is not a property of " .. RawProperties.ClassName)
        end
    end

    mt.__eq = function(a, b)
        if typeof(b) == "table" and b.ClassName ~= nil then
            return a.ID == b.ID
        else
            return false
        end
    end

    setmetatable(self, mt)
    InstanceUpdate:Fire(UID, "Create", self)

    return self
end

return module
