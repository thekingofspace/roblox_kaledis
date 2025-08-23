local InitModule = {}
local module = {}
local Signal = require("@game/signal")

function InitModule.Build(Aray:{RenderStep:Signal, Heartbeat:Signal})
    module.RenderStep = Signal.CreateReadOnlySignal(Aray.RenderStep)
    module.Heartbeat = Signal.CreateReadOnlySignal(Aray.Heartbeat)
end

return {module = module, Init = InitModule}