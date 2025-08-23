local module = {}

type Services = "HTTP_Service"

local InitData = {
    
}

local HTTP = require("@game/Services/HTTP")

local Services = {
    ["HTTP_Service"] = HTTP
}

local Enum = require("@game/Enum")
local Color4 = require("@game/PropertyTypes/Color4")
local Udim = require("@game/PropertyTypes/Udim")

function module.GetCommonElements()
    return Color4, Enum, Udim.UDim, Udim.UDim2
end

function module:GetService(Service:Services)
    if Services[Service] then
        return Services[Service].module
    else
        error("No service found under this name")
    end
end

-- Love2D callbacks
function love.load()
   
end

function love.update()
    
end

function love.draw(dt)
    
end

return module
