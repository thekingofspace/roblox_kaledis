local InitModule = {}
local Signal = require("@game/signal")
local module = {}

function InitModule.Build(Aray:{Window_Resize:Signal})
    module.Resized = Signal.CreateReadOnlySignal(Aray.Window_Resize)
end


return {module = module, Init = InitModule}