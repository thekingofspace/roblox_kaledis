local module = {}

type Services = "HTTP_Service" | "RunService"

local Enum = require("@game/Enum")
local Signal = require("@game/signal")
local Color4 = require("@game/PropertyTypes/Color4")
local Udim = require("@game/PropertyTypes/Udim")

local HTTP = require("@game/Services/HTTP")
local RunService = require("@game/Services/RunService")

local InitData = {
    RenderStep = Signal.CreateSignal()
}

RunService.Init.Build(InitData.RenderStep)

local Services = {
    ["HTTP_Service"] = HTTP;
    ["RunService"] = RunService
}

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
    InitData.RenderStep:Fire(dt)
end

return module
