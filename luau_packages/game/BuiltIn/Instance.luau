
local InitModule = {}
local InstanceSignal:Signal = nil
local GetID = nil
local module = {}

local InstanceTypes = {
    ["Frame"] = require("@game/Instances/Frame");
    ["Sound"] = require("@game/Instances/Sound")
}

function InitModule.Build(Aray:{RenderStep:Signal, Heartbeat:Signal, InstanceUpdate:Signal}, Function)
    InstanceSignal = Aray.InstanceUpdate
    GetID = Function
end

function module.new(Instance:Instances)
    if InstanceTypes[Instance] then
        return InstanceTypes[Instance].new(InstanceSignal, GetID)
    end
end

return {module = module, Init = InitModule}