local InitModule = {}

local module = {}

local RunService = require("@game/Services/RunService").module
local Task = require("@game/BuiltIn/Task").module
local Color = require("@game/PropertyTypes/Color4")
local UDimModule = require("@game/PropertyTypes/Udim")
local Signal = require("@game/signal")

local UDim = UDimModule.UDim
local UDim2 = UDimModule.UDim2

local BaseEasing = {
    Linear = function(t) return t end,
    Exponential = function(t) return t * t end,
    Cubic = function(t) return t^3 end,
    Quart = function(t) return t^4 end,
    Quint = function(t) return t^5 end,
    Sine = function(t) return 1 - math.cos(t * math.pi/2) end,
    Bounce = function(t)
        local n1, d1 = 7.5625, 2.75
        if t < 1/d1 then
            return n1*t*t
        elseif t < 2/d1 then
            t = t - 1.5/d1
            return n1*t*t + 0.75
        elseif t < 2.5/d1 then
            t = t - 2.25/d1
            return n1*t*t + 0.9375
        else
            t = t - 2.625/d1
            return n1*t*t + 0.984375
        end
    end,
    Back = function(t)
        local c1 = 1.70158
        local c3 = c1 + 1
        return 1 + c3 * (t - 1)^3 + c1 * (t - 1)^2
    end,
    Elastic = function(t)
        if t == 0 or t == 1 then return t end
        return -2^(10 * t - 10) * math.sin((t * 10 - 10.75) * (2*math.pi/3))
    end
}
local function EasingWrapper(base, direction)
    if direction == "In" then
        return base
    elseif direction == "Out" then
        return function(t) return 1 - base(1 - t) end
    elseif direction == "InOut" then
        return function(t)
            if t < 0.5 then
                return base(t*2)/2
            else
                return 1 - base((1-t)*2)/2
            end
        end
    else
        return base
    end
end

local Tween = {}
Tween.__index = Tween

local function InterpolateValue(startValue, endValue, alpha)
    local mt = getmetatable(startValue)
    if mt == Color then
        return startValue:mix(endValue, alpha)
    elseif mt == UDim then
        return UDim.new(
            startValue.Scale + (endValue.Scale - startValue.Scale) * alpha,
            startValue.Offset + (endValue.Offset - startValue.Offset) * alpha
        )
    elseif mt == UDim2 then
        return UDim2.new(
            startValue.X.Scale + (endValue.X.Scale - startValue.X.Scale) * alpha,
            startValue.X.Offset + (endValue.X.Offset - startValue.X.Offset) * alpha,
            startValue.Y.Scale + (endValue.Y.Scale - startValue.Y.Scale) * alpha,
            startValue.Y.Offset + (endValue.Y.Offset - startValue.Y.Offset) * alpha
        )
    elseif type(startValue) == "number" then
        return startValue + (endValue - startValue) * alpha
    else
        error("Unsupported tween type: "..tostring(startValue))
    end
end

function Tween.new(instance, time, easingStyle, easingDirection, properties)
    assert(typeof(instance) == "table" and instance.ClassName, "Invalid instance")
    local self = setmetatable({}, Tween)
    self.Instance = instance
    self.Time = time
    self.Properties = properties
    self.Easing = EasingWrapper(BaseEasing[easingStyle] or BaseEasing.Linear, easingDirection or "In")
    self.StartValues = {}
    self.EndValues = {}
    self.PrivateCompleted = Signal.CreateSignal()
    self.Completed = Signal.CreateReadOnlySignal(self.PrivateCompleted)

    for key, value in pairs(properties) do
        local current = instance[key]

        if current == nil then
            local mt = getmetatable(value)
            if mt == Color then
                current = Color.new(0, 0, 0, 255)
            elseif mt == UDim then
                current = UDim.new(0,0)
            elseif mt == UDim2 then
                current = UDim2.new(0,0,0,0)
            elseif type(value) == "number" then
                current = 0
            else
                error("Unsupported tween property: "..tostring(key))
            end
        end

        self.StartValues[key] = current
        self.EndValues[key] = value
    end

    self.Playing = false
    return self
end

function Tween:Play()
    if self.Playing then return end
    self.Playing = true

    Task.spawn(function()
        local elapsed = 0
        while elapsed < self.Time do
            local dt = RunService.RenderStep:Wait()
            elapsed = elapsed + dt
            local alpha = math.clamp(elapsed / self.Time, 0, 1)
            local easedAlpha = self.Easing(alpha)

            for key, startValue in pairs(self.StartValues) do
                local endValue = self.EndValues[key]
                self.Instance[key] = InterpolateValue(startValue, endValue, easedAlpha)
            end
        end

        for key, endValue in pairs(self.EndValues) do
            self.Instance[key] = endValue
        end

        self.Playing = false
        self.PrivateCompleted:Fire()
    end)
end

function module:Create(instance:Instance?, time:number, easingStyle:EasingStyle, easingDirection:EasingDirection, properties:{[string]:any})
    return Tween.new(instance, time, easingStyle, easingDirection, properties)
end

return {module = module, Init = InitModule}
