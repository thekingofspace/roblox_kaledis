local game = require("./game")
local RunService:RunService = game:GetService("RunService")
local Color4, Enum, _UDim, UDim2, _task, Instance = game:GetCommonElements()

local Settings:SettingsService = game:GetService("Settings")

local UserInput:UserInputService = game:GetService("UserInputService")

UserInput.InputBegan:Connect(function(Keycode:KeyCode)
    if UserInput:IsKeyDown(Enum.KeyCodes.w) and UserInput:IsKeyDown(Enum.KeyCodes.s) then
        print("Ran")
    end
end)

local Config = Settings.new()


local Values = {
    ["Volume"] = {
        ["Music Level"] = 50;
        
        ["Ambient"] = 50
    };

    ["Keybinds"] = {
        ["Forward"] = Enum.KeyCodes.w;
        
        ["Back"] = Enum.KeyCodes.s;

        ["Left"] = Enum.KeyCodes.a;

        ["Right"] = Enum.KeyCodes.d;
    };
}

for I, item in pairs(Values) do
    for E, Value in pairs(item) do
        Config:Set(I, E, Config:Get(I, E) or Value)
    end
end


local Frame:Frame = Instance.new("Frame")

Frame.Size = UDim2.new(0.5, 0, 0.5, 0)

Frame.Anchorpoint = UDim2.new(0.5, 0, 0.5, 0)

Frame.Parent = game.Workspace

Frame.Visible = true

Frame.Position = UDim2.new(0.5, 0, 0.5, 0)

Frame.Color = Color4.new("#885be3")

local NewFrame:Frame = Frame:Clone()

local Color = Color4.new("#e81818")

Color.a = 0.2

NewFrame.Color = Color

NewFrame.Size = UDim2.new(0.3, 0, 0.3, 0)

NewFrame.ZIndex = 1

local direction = 1
local speed = 5


RunService.RenderStep:Connect(function(DT)
    local newX = NewFrame.Size.X.Scale + speed * direction * DT
    local newY = NewFrame.Size.Y.Scale + speed * direction * DT

    if newX >= 1 then
        newX = 1
        direction = -1
    elseif newX <= 0 then
        newX = 0
        direction = 1
    end

    NewFrame.Size = UDim2.new(newX, 0, newY, 0)
end)
