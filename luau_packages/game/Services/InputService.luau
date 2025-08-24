--!nocheck
local InitModule = {}

local module = {}

local Signal = require("@game/signal")

local Mouse = {
    X = 0,
    Y = 0,
    Type = ""
}

local MouseMethods = {
    SetIcon = function(self, Icon:CursorTypes)
        love.mouse.setCursor(love.mouse.getSystemCursor(Icon))
        Mouse.Type = "arrow"
    end
}

function InitModule.Build(Aray:{InputBegan:Signal, InputEnded:Signal, MouseMoved:Signal})
    module.InputBegan = Signal.CreateReadOnlySignal(Aray.InputBegan)

    module.InputEnded = Signal.CreateReadOnlySignal(Aray.InputEnded)

    module.MouseMoved = Signal.CreateReadOnlySignal(Aray.MouseMoved)

    module.MouseMoved:Connect(function(X, Y)
        Mouse.X = X
        Mouse.Y = Y
    end)
end


function module:IsKeyDown(Keycode:KeyCode):boolean
    return love.keyboard.isDown(Keycode)
end

function module:GetMouse()
    local mouse = {}

    mouse = setmetatable(mouse, {
        __index = function(aray, Value)
            if Mouse[Value] then
                return Mouse[Value]
            elseif MouseMethods[Value] then
                return MouseMethods[Value]
            else
                return nil
            end
        end
    })

    return mouse
end

return {module = module, Init = InitModule}