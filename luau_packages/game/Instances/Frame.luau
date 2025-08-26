local D2 = require("@game/Instances/D2")

local module = {}

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
            Code = function(self:Frame)
                if not self.Visible or self.Parent == nil then
                    return
                end
                    
                local parent = self.Parent
                local parentW, parentH = love.graphics.getWidth(), love.graphics.getHeight()
                local parentX, parentY = 0, 0
                local totalRotation = self.Rotation
                
                if type(parent) == "table" and parent.GetAbsolute and parent.GetAbsoluteSize then
                    parentW, parentH = parent:GetAbsoluteSize()
                    local parentAbs = parent:GetAbsolute()
                    parentX = parentAbs.X.Scale * love.graphics.getWidth() + parentAbs.X.Offset
                    parentY = parentAbs.Y.Scale * love.graphics.getHeight() + parentAbs.Y.Offset
                    
                    local ancestors = self:GetAncestors()
                    for i = 1, #ancestors do
                        if ancestors[i].Rotation then
                            totalRotation = totalRotation + ancestors[i].Rotation
                        end
                    end
                end
                
                local px, py = self.Position:ToAbsolute(parentW, parentH)
                local sx, sy = self.Size:ToAbsolute(parentW, parentH)
                local ax, ay = self.Anchorpoint:ToAbsolute(sx, sy)
                local r, g, b, a = self.Color:toLove()
                
                love.graphics.push()
                love.graphics.translate(px + parentX, py + parentY)
                love.graphics.rotate(math.rad(totalRotation))
                love.graphics.setColor(r, g, b, a)
                love.graphics.rectangle("fill", -ax, -ay, sx, sy)
                love.graphics.pop()
            end
        })

        return RawProperty, Methods, ExtendedMethods
    end)
end

return module
