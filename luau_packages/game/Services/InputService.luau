--!nocheck
local InitModule = {}

local module = {}

local Signal = require("@game/signal")
local Enum = require("@game/Enum")

local Mouse = {
    X = 0,
    Y = 0,
    Type = ""
}

local MouseMethods = {
    SetIcon = function(self, Icon:CursorTypes)
        love.mouse.setCursor(love.mouse.getSystemCursor(Icon))
        Mouse.Type = Icon
    end,

    SetVisible = function(self, isVisible:boolean)
        love.mouse.setVisible(isVisible)
    end
}

function InitModule.Build(Aray:{InputBegan:Signal, InputEnded:Signal, MouseMoved:Signal, InputTick:Signal})
    module.InputBegan = Signal.CreateReadOnlySignal(Aray.InputBegan)

    module.InputEnded = Signal.CreateReadOnlySignal(Aray.InputEnded)

    module.MouseMoved = Signal.CreateReadOnlySignal(Aray.MouseMoved)

    module.InputTick = Signal.CreateReadOnlySignal(Aray.InputTick)

    module.MouseMoved:Connect(function(X, Y)
        Mouse.X = X
        Mouse.Y = Y
    end)
end


function module:IsKeyDown(Keycode:KeyCode):boolean
    return love.keyboard.isDown(Keycode)
end

local KeyCodes = {
    ["-"] = "Minus",
    ["="] = "Equals",
    ["["] = "LeftBracket",
    ["]"] = "RightBracket",
    ["\\"] = "Backslash",
    [";"] = "Semicolon",
    ["'"] = "Apostrophe",
    [","] = "Comma",
    ["."] = "Period",
    ["/"] = "Slash",
    ["`"] = "Backtick"
}

function module:GetKeyCode(ScanCode:number)
    if Enum.KeyCodes[love.keyboard.getKeyFromScancode(ScanCode)] then
        return Enum.KeyCodes[love.keyboard.getKeyFromScancode(ScanCode)]
    else
        return Enum.KeyCodes[KeyCodes[love.keyboard.getKeyFromScancode(ScanCode)]]
    end
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