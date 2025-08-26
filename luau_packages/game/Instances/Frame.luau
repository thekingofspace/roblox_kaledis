local D2 = require("@game/Instances/D2")

local module = {}

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

function module.new(InstanceUpdate: Signal, GetID: () -> string, UserInput)
    return D2.new(InstanceUpdate, GetID, UserInput, function()
        local RawProperty: {Property} = {}
        local Methods: {Method} = {}
        local ExtendedMethods: {Method} = {}

        
        table.insert(RawProperty, {
            Property = "Name";
            Type = "string";
            Value = "Frame"
        })

        
        table.insert(RawProperty, {
            Property = "ClassName";
            Type = "string";
            Value = "Frame"
        })

        table.insert(ExtendedMethods, {
            Method = "Draw",
            Code = function(self)
                if not self.Visible or self.Parent == nil then
                    return
                end
                    
                local parent = self.Parent
                local parentW, parentH = love.graphics.getWidth(), love.graphics.getHeight()
                local parentX, parentY = 0, 0
                
                if type(parent) == "table" and parent.GetAbsolute and parent.GetAbsoluteSize then
                    parentW, parentH = parent:GetAbsoluteSize()
                    local parentAbs = parent:GetAbsolute()
                    parentX = parentAbs.X.Scale * love.graphics.getWidth() + parentAbs.X.Offset
                    parentY = parentAbs.Y.Scale * love.graphics.getHeight() + parentAbs.Y.Offset
                end
                
                local px, py = self.Position:ToAbsolute(parentW, parentH)
                local sx, sy = self.Size:ToAbsolute(parentW, parentH)
                local ax, ay = self.Anchorpoint:ToAbsolute(sx, sy)
                local r, g, b, a = self.Color:toLove()
                
                love.graphics.push()
                love.graphics.translate(px + parentX, py + parentY)
                love.graphics.rotate(math.rad(self.Rotation))
                love.graphics.setColor(r, g, b, a)
                love.graphics.rectangle("fill", -ax, -ay, sx, sy)
                love.graphics.pop()
            end
        })

        return RawProperty, Methods, ExtendedMethods
    end)
end

return module
