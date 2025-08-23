local UDim = {}
UDim.__index = UDim

function UDim.new(scale, offset)
    local self = setmetatable({}, UDim)
    self.Scale = scale or 0
    self.Offset = offset or 0
    return self
end

function UDim:__tostring()
    return string.format("UDim(Scale = %.2f, Offset = %d)", self.Scale, self.Offset)
end

function UDim.__add(a, b)
    return UDim.new(a.Scale + (b.Scale or 0), a.Offset + (b.Offset or 0))
end

function UDim.__sub(a, b)
    return UDim.new(a.Scale - (b.Scale or 0), a.Offset - (b.Offset or 0))
end

local UDim2 = {}
UDim2.__index = UDim2

function UDim2.new(xScale, xOffset, yScale, yOffset)
    local self = setmetatable({}, UDim2)
    self.X = UDim.new(xScale, xOffset)
    self.Y = UDim.new(yScale, yOffset)
    return self
end

function UDim2:__tostring()
    return string.format("UDim2(X = %s, Y = %s)", tostring(self.X), tostring(self.Y))
end

function UDim2:ToAbsolute(parentWidth, parentHeight)
    local absX = (self.X.Scale * parentWidth) + self.X.Offset
    local absY = (self.Y.Scale * parentHeight) + self.Y.Offset
    return absX, absY
end

function UDim2.__add(a, b)
    return UDim2.new(
        a.X.Scale + b.X.Scale, a.X.Offset + b.X.Offset,
        a.Y.Scale + b.Y.Scale, a.Y.Offset + b.Y.Offset
    )
end

function UDim2.__sub(a, b)
    return UDim2.new(
        a.X.Scale - b.X.Scale, a.X.Offset - b.X.Offset,
        a.Y.Scale - b.Y.Scale, a.Y.Offset - b.Y.Offset
    )
end

return {UDim = UDim, UDim2 = UDim2}
