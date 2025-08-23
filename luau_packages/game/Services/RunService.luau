local InitModule = {}
local module = {}
local Signal = require("@game/signal")

function InitModule.Build(RenderStep:Signal, Heartbeat:Signal)
    module.RenderStep = Signal.CreateReadOnlySignal(RenderStep)
    module.Heartbeat = Signal.CreateReadOnlySignal(Heartbeat)
end

return {module = module, Init = InitModule}