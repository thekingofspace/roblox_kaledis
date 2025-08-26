local module = {}

local Inherited = require("@game/Instances/Inherited")
local Signal = require("@game/signal")
local Udim = require("@game/PropertyTypes/Udim")
local Color4 = require("@game/PropertyTypes/Color4")

local RealProperties = {
    Name = "string",
    ClassName = "frozen",
    Changed = "frozen",
    TouchEnded = "frozen",
    TouchedPrivate = "frozen",
    TouchStarted = "frozen",
    TouchedStartedPrivate = "frozen",
    ID = "frozen",
    attributes = "table",
    Parent = {"nil", "string", "table"},
    Visible = "boolean",
    Size = "table",
    Position = "table",
    Anchorpoint = "table",
    Color = "table",
    Rotation = "number",
    ZIndex = "number",
    Destroyed = "frozen",
    CanQuery = "boolean",
    HoverBegan = "frozen",
    HoverEnded = "frozen",
    MouseClick = "frozen",
    HoverBegan_Private = "frozen",
    HoverEnded_Private = "frozen",
    MouseClick_Private = "frozen",
    MouseClickRelease_Private = "frozen";
    MouseClickRelease = "frozen";
    SinkInputs = "boolean";
    Modifiers = "table";
    Children = "table"
}

local function CheckType(id, value, properties)
    if properties[id] == "frozen" then
        return false
    end
    
    if typeof(properties[id]) == "string" then
        return typeof(value) == properties[id]
    else
        for _, item in ipairs(properties[id]) do
            if typeof(value) == item then
                return true
            end
        end
        return false
    end
end

export type Property = {
    Property: string,
    Type: string | {string},
    Value: any,
    WriteTransform: ((self: any, OldValue: any) -> ...any)?,
    ReadTransform: ((self: any, OldValue: any) -> any)?,
}

export type Method = {
    Method: string,
    Code: (self: any, ...any) -> ...any,
}

function module.new(InstanceUpdate, GetID, UserInput, SuperConstruct:(() -> ({Property}, {Method}, {Method}))?)
    local Changed = Signal.CreateSignal()
    local Touched = Signal.CreateSignal()
    local TouchedStarted = Signal.CreateSignal()
    local HoverBegan = Signal.CreateSignal()
    local HoverEnded = Signal.CreateSignal()
    local MouseClick = Signal.CreateSignal()
    local MouseClick_release = Signal.CreateSignal()
    local UID = GetID()
    local self = {}
    
    local PropertyTransform = {
        Parent = function(self, value)
            if typeof(value) == "table" and value.Draw ~= nil then
                table.insert(value.Children, self)
                return value
            elseif value == "Workspace" or value == nil then
                if typeof(self.Parent) == "table" then
                    for I, item in ipairs(self.Parent.Children) do
                        if item == self then
                            table.remove(self.Parent.Children, I)
                            break
                        end
                    end
                end
                
                return value or "nil"
            end
            return nil
        end
    }

    local ReadTransform = {
        Parent = function(_, value)
            if value == "nil" then
                return nil
            else
                return value
            end
        end
    }

    local ExtendMethod = {

    }
    
    local PropertyTypes = RealProperties

    local RawProperties = {
        Name = "CLASS NAME",
        ClassName = "CLASS NAME",
        Changed = Signal.CreateReadOnlySignal(Changed),
        TouchEnded = Signal.CreateReadOnlySignal(Touched),
        TouchStarted = Signal.CreateReadOnlySignal(TouchedStarted),
        TouchedStartedPrivate = TouchedStarted,
        TouchedPrivate = Touched,
        ID = UID,
        attributes = {},
        Parent = "nil",
        Visible = true,
        Size = Udim.UDim2.new(0, 100, 0, 100),
        Position = Udim.UDim2.new(0, 0, 0, 0),
        Anchorpoint = Udim.UDim2.new(0.5, 0, 0.5, 0),
        Color = Color4.new("#ffffff"),
        Rotation = 0,
        ZIndex = 0,
        Destroyed = false,
        CanQuery = true,
        SinkInputs = true;
        Modifiers = {}; 
        Children = {};

        HoverBegan = Signal.CreateReadOnlySignal(HoverBegan),
        HoverEnded = Signal.CreateReadOnlySignal(HoverEnded),
        MouseClick = Signal.CreateReadOnlySignal(MouseClick),
        MouseClickRelease = Signal.CreateReadOnlySignal(MouseClick_release),

        MouseClickRelease_Private = MouseClick_release,
        HoverBegan_Private = HoverBegan,
        HoverEnded_Private = HoverEnded,
        MouseClick_Private = MouseClick,
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
            parentX = parentAbs.X.Offset or 0
            parentY = parentAbs.Y.Offset or 0
        end
        
        local px, py = self.Position:ToAbsolute(parentW, parentH)
        local sx, sy = self.Size:ToAbsolute(parentW, parentH)
        local ax, ay = self.Anchorpoint:ToAbsolute(sx, sy)
        local absX, absY = px - ax + parentX, py - ay + parentY
        
        return Udim.UDim2.new(
            absX / love.graphics.getWidth(), 0,
            absY / love.graphics.getHeight(), 0
        )
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
        if ExtendMethod["Draw"] then
            ExtendMethod["Draw"](self)
        end
    end
    
    RawMethods.Destroy = function(self)
        if ExtendMethod["Destroy"] then
            ExtendMethod["Destroy"](self)
        end

        self.Parent = nil

        InstanceUpdate:Fire(UID, "Destroy", self)
        table.clear(RawProperties)
        table.clear(RawMethods)
        Changed:Destroy()
        Touched:Destroy()
        table.clear(PropertyTypes)
        PropertyTypes = nil
        TouchedStarted:Destroy()
        HoverBegan:Destroy()
        HoverEnded:Destroy()
        MouseClick:Destroy()
        MouseClick_release:Destroy()

        table.clear(ReadTransform)
        table.clear(PropertyTransform)
        table.clear(ExtendMethod)
        
        HoverBegan = nil
        HoverEnded = nil
        MouseClick = nil
        MouseClick = nil
        MouseClick_release = nil
        Changed = nil
        Touched = nil
        TouchedStarted = nil
        UID = nil
        RawProperties.Destroyed = true
        PropertyTypes.Destroyed = "Boolean"
    end
    
    RawMethods.IsDescendantOf = function(self, target)
        local currentParent = self.Parent
        while currentParent do
            if currentParent == target then
                return true
            end
            currentParent = currentParent.Parent
        end
        return false
    end

    RawMethods.GetAncestors = function(self)
        local Ancestors = {}
        local  LastAncestor = self.Parent
        while true do
            table.insert(Ancestors, LastAncestor)
            if typeof(LastAncestor)  ~= "table" then
                return Ancestors
            end

            LastAncestor = LastAncestor.Parent
        end
    end

    RawMethods.GetChildren = function(self)
        return self.Children
    end

    RawMethods.GetDescendants = function(self)
        local Descendants = {}

        local function recurse(children)
            for _, child in ipairs(children) do
                table.insert(Descendants, child)
                if child.GetChildren then
                    recurse(child:GetChildren())
                end
            end
        end

        recurse(self:GetChildren())
        return Descendants
    end
    
    RawMethods.Clone = function(self)
        if ExtendMethod["Clone"] then
            ExtendMethod["Clone"](self)
        end

        local clone = module.new(InstanceUpdate, GetID, UserInput, SuperConstruct)
        for k, v in pairs(RawProperties) do
            if PropertyTypes[k] ~= "frozen" then
                clone[k] = v
            end
        end
        return clone
    end

    if SuperConstruct then
        local Properties, Methods, Extended = SuperConstruct()

        for I, item in ipairs(Properties) do
            RawProperties[item.Property] = item.Value
            PropertyTypes[item.Property] = item.Type

            if item.ReadTransform then
                ReadTransform[item.Property] = item.ReadTransform
            end

            if item.WriteTransform then
                PropertyTransform[item.Property] = item.WriteTransform
            end
        end

        for I, item in ipairs(Methods) do
            RawMethods[item.Method] = function()
                if ExtendMethod[item.Method] then
                    ExtendMethod[item.Method](self)
                end

                item.Code(self)
            end
        end

        for I, item in ipairs(Extended) do
            ExtendMethod[item.Method] = item.Code
        end
    end

    local mt = {
        __index = function(_, index)
            if RawProperties[index] then
                if ReadTransform[index] then
                    return ReadTransform[index](self, RawProperties[index])
                else
                    return RawProperties[index]
                end
            elseif RawMethods[index] then
                return RawMethods[index]
            end
            return nil
        end,
        
        __newindex = function(_, index, value)
            if not RawProperties[index] then
                error(index .. " is not a property of " .. RawProperties.ClassName)
            end
            
            if not CheckType(index, value, PropertyTypes) then
                if PropertyTypes[index] == "frozen" then
                    error(index .. " cannot be changed")
                else
                    local expectedType = type(PropertyTypes[index]) == "table" 
                        and table.concat(PropertyTypes[index], " or ") 
                        or PropertyTypes[index]
                    error(string.format("%s must be a %s", index, expectedType))
                end
            end
            
            if PropertyTransform[index] then
                RawProperties[index] = PropertyTransform[index](self, value)
            else
                RawProperties[index] = value
            end
            
            Changed:Fire()
        end,
        
        __eq = function(a, b)
            return typeof(b) == "table" and b.ClassName ~= nil and a.ID == b.ID
        end
    }
    
    setmetatable(self, mt)
    InstanceUpdate:Fire(UID, "Create", self)
    
    return self
end

return module