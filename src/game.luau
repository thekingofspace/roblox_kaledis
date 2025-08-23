local module = {}

_G.Signals = _G.UpdateSignals or {}

-- Dependencies
local Enum = require("@game/Enum")
local Color4 = require("@game/PropertyTypes/Color4")
local Udim = require("@game/PropertyTypes/Udim")

-- Methods
function module.GetCommonElements()
    return Color4, Enum, Udim.UDim, Udim.UDim2
end

-- Love2D callbacks
function love.load()
   
end

function love.update()
    
end

function love.draw(dt)
    
end

return module
