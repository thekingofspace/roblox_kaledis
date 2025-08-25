
local InitModule = {}
local InstanceSignal:Signal = nil
local GetID = nil
local UInput:UserInputService = nil

local module = {}

local InstanceTypes = {
    ["Frame"] = require("@game/Instances/Frame")
}

function InitModule.Build(Aray:{RenderStep:Signal, Heartbeat:Signal, InstanceUpdate:Signal}, Function, Input:UserInputService)
    InstanceSignal = Aray.InstanceUpdate
    GetID = Function
    UInput = Input
end

function module.new(Instance:Instances)
    if InstanceTypes[Instance] then
        return InstanceTypes[Instance].new(InstanceSignal, GetID, UInput)
    end
end

return {module = module, Init = InitModule}