local InitModule = {}
local Signal = require("@game/signal")
local module = {}

module.CurrentMode = {
    width = love.graphics.getWidth(),
    height = love.graphics.getHeight(),
    fullscreen = false,
    borderless = false,
    resizable = false,
    vsync = true,
    msaa = 0,
    title = love.window.getTitle() or "Untitled"
}

function InitModule.Build(Aray:{Window_Resize:Signal})
    module.Resized = Signal.CreateReadOnlySignal(Aray.Window_Resize)
end

function module:SetWindow(options)
    options = options or {}

    module.CurrentMode.width = options.width or module.CurrentMode.width
    module.CurrentMode.height = options.height or module.CurrentMode.height
    module.CurrentMode.fullscreen = options.fullscreen or module.CurrentMode.fullscreen
    module.CurrentMode.borderless = options.borderless or module.CurrentMode.borderless
    module.CurrentMode.resizable = options.resizable or module.CurrentMode.resizable
    module.CurrentMode.vsync = options.vsync
        if options.vsync == nil then module.CurrentMode.vsync = true end
    module.CurrentMode.msaa = options.msaa or module.CurrentMode.msaa
    module.CurrentMode.title = options.title or module.CurrentMode.title

    love.window.setMode(
        module.CurrentMode.width,
        module.CurrentMode.height,
        {
            fullscreen = module.CurrentMode.fullscreen,
            borderless = module.CurrentMode.borderless,
            resizable = module.CurrentMode.resizable,
            vsync = module.CurrentMode.vsync,
            msaa = module.CurrentMode.msaa
        }
    )

    love.window.setTitle(module.CurrentMode.title)

    if module.Resized then
        module.Resized:Fire(module.CurrentMode.width, module.CurrentMode.height)
    end
end

function module:HandleResize(w, h)
    module.CurrentMode.width = w
    module.CurrentMode.height = h
    if module.Resized then
        module.Resized:Fire(w, h)
    end
end

function module:FullScreen(Active:boolean)
    love.window.setFullscreen(Active)
    module.CurrentMode.fullscreen = Active
end

function module:GetWindowSize():(number, number)
    return love.graphics.getDimensions()
end

function module:SetWindowName(Name:string)
    module.CurrentMode.title = Name
    love.window.setTitle(Name)
end

function module:SetIcon(Icon:unknown)
    error("No asset service yet")
end

return {module = module, Init = InitModule}
