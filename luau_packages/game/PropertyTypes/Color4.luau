local Color = {}
Color.__index = Color

function Color.new(r, g, b, a):Color4
    local self = setmetatable({}, Color)

    if type(r) == "string" then
        local hex = r:gsub("#","")
        assert(#hex == 6 or #hex == 8, "Hex must be 6 or 8 characters")

        r = tonumber(hex:sub(1,2), 16)
        g = tonumber(hex:sub(3,4), 16)
        b = tonumber(hex:sub(5,6), 16)
        a = #hex == 8 and tonumber(hex:sub(7,8), 16) or 255
    else
        a = a or 255
    end

    self.r = math.max(0, math.min(1, r/255))
    self.g = math.max(0, math.min(1, g/255))
    self.b = math.max(0, math.min(1, b/255))
    self.a = math.max(0, math.min(1, a/255))

    return self
end

function Color:toLove()
    return self.r, self.g, self.b, self.a
end

function Color:mix(other, t):Color4
    t = t or 0.5
    local r = self.r*(1-t) + other.r*t
    local g = self.g*(1-t) + other.g*t
    local b = self.b*(1-t) + other.b*t
    local a = self.a*(1-t) + other.a*t
    return Color.new(r*255, g*255, b*255, a*255)
end

function Color:darken(factor):Color4
    factor = factor or 0.2
    return Color.new(
        (self.r*(1-factor))*255,
        (self.g*(1-factor))*255,
        (self.b*(1-factor))*255,
        self.a*255
    )
end

function Color:lighten(factor):Color4
    factor = factor or 0.2
    return Color.new(
        math.min(self.r + factor, 1)*255,
        math.min(self.g + factor, 1)*255,
        math.min(self.b + factor, 1)*255,
        self.a*255
    )
end

return Color
