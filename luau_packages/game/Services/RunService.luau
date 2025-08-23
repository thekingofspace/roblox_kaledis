local InitModule = {}
local module = {}
local Signal = require("@game/signal")

function InitModule.Build(RenderStep:Signal)
    module.RenderStep = Signal.CreateReadOnlySignal(RenderStep)
end

return {module = module, Init = InitModule}