local game = require("./game")
local Color4, Enum, _UDim, UDim2, task, Instance = game:GetCommonElements()

local Settings:SettingsService = game:GetService("Settings")
local UserInput:UserInputService = game:GetService("UserInputService")
local TweenSerive:TweenService = game:GetService("TweenService")

local DataStoreService:DatastoreService = game:GetService("Datastore")

local DesktopService:DesktopService  = game:GetService("DesktopService")

local _ExtendedLove = require("@packages/ExtendedLove")

local Section = DataStoreService:GetDataStore("Position")

UserInput.InputBegan:Connect(function(Keycode:KeyCode)
    if UserInput:IsKeyDown(Enum.KeyCodes.w) and UserInput:IsKeyDown(Enum.KeyCodes.s) then
        print("Ran")
    end
end)

local Config = Settings.new("Main")

local Values = {
    ["Volume"] = {
        ["Music Level"] = 50;
        ["Ambient"] = 50;
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

local Sound:Sound  = Instance.new("Sound")

Sound.Sound = "sounds/On.wav"


local function createWall(name, size, position, color)
    local wall:Frame = Instance.new("Frame")
    wall.Size = size
    wall.Position = position
    wall.Anchorpoint = UDim2.new(0,0,0,0)
    wall.Color = color
    wall.Name = name
    wall.Parent = game.Workspace
    wall.Visible = true

    return wall
end

local wallColor = Color4.new("#885be3")

createWall("TopWall", UDim2.new(1, 0, 0.05, 0), UDim2.new(0, 0, 0, 0), wallColor)
createWall("BottomWall", UDim2.new(1, 0, 0.05, 0), UDim2.new(0, 0, 0.95, 0), wallColor)
createWall("LeftWall", UDim2.new(0.05, 0, 1, 0), UDim2.new(0, 0, 0, 0), wallColor)
createWall("RightWall", UDim2.new(0.05, 0, 1, 0), UDim2.new(0.95, 0, 0, 0), wallColor):SetAttribute("Passthrough", true)

local OldData:{X:number, Y:number, YS:number, XS:number}? = Section:GetAsync("PositionData")
local TruePos:UDim2 = nil
local TrueSize:UDim2 = nil

if OldData ~= nil then
    TruePos = UDim2.new(OldData.X, 0, OldData.Y, 0)
    TrueSize = UDim2.new(OldData.XS, 0, OldData.YS, 0)
else
    TruePos = UDim2.new(0.5, 0, 0.5, 0)
    TrueSize = UDim2.new(0.1, 0, 0.1, 0)
end

local NewFrame:Frame = Instance.new("Frame")
NewFrame.Color = Color4.new("#e81818")
NewFrame.Name = "Player"
NewFrame.Size = TrueSize
NewFrame.Anchorpoint = UDim2.new(0.5, 0, 0.5, 0)
NewFrame.Position = TruePos
NewFrame.ZIndex = 1
NewFrame.Parent = game.Workspace
NewFrame.Visible = true

NewFrame.TouchStarted:Connect(function(B:UI_2D?)
    NewFrame.Color = Color4.new("3fb335")
end)

NewFrame.TouchEnded:Connect(function(B:UI_2D?)
    NewFrame.Color = Color4.new("#e81818")
end)
local Mouse = UserInput:GetMouse()

NewFrame.MouseClick:Connect(function(Key)
    if Enum.KeyCodes[Key] == Enum.KeyCodes.mouse_right then
        print("Ran Right")
        Sound:Play()
    end
end)

NewFrame.MouseClickRelease:Connect(function(Key)
    if Enum.KeyCodes[Key] == Enum.KeyCodes.mouse_left then
        print("Ran Left")
        Sound:Stop()
    end
end)

NewFrame.HoverBegan:Connect(function()
    Mouse:SetIcon(Enum.CursorTypes.Hand)
     NewFrame.Color = NewFrame.Color:darken(0.2)
end)

NewFrame.HoverEnded:Connect(function()
    Mouse:SetIcon(Enum.CursorTypes.Arrow)
    NewFrame.Color = Color4.new("#e81818")
end)

local TestFrame:Frame = NewFrame:Clone()

TestFrame.Size = UDim2.new(0.9, 0, 0.9, 0)

TestFrame.Parent = NewFrame

TestFrame.Position = UDim2.new(0.5, 0, 0.5, 0)

TestFrame.Color = wallColor

TestFrame.Name = "TestFrame"

local moveSpeed = 0.005

UserInput.InputTick:Connect(function(Keys)
    local deltaX, deltaY = 0, 0

    if UserInput:IsKeyDown(Config:Get("Keybinds", "Forward")) then deltaY -= 1 end
    if UserInput:IsKeyDown(Config:Get("Keybinds", "Back")) then deltaY += 1 end
    if UserInput:IsKeyDown(Config:Get("Keybinds", "Left")) then deltaX -= 1 end
    if UserInput:IsKeyDown(Config:Get("Keybinds", "Right")) then deltaX += 1 end

    if deltaX ~= 0 or deltaY ~= 0 then
        local length = math.sqrt(deltaX^2 + deltaY^2)
        deltaX = (deltaX / length) * moveSpeed
        deltaY = (deltaY / length) * moveSpeed
    end

    local pos = NewFrame.Position
    local newX = math.clamp(pos.X.Scale + deltaX, 0, 1)
    local newY = math.clamp(pos.Y.Scale + deltaY, 0, 1)

    local moved = false

    local testXPos = UDim2.new(newX, 0, pos.Y.Scale, 0)
    local hitX = game:GetItemsInBound(NewFrame:GetAbsolute() + UDim2.new(deltaX, 0, 0, 0), NewFrame.Size, {NewFrame, TestFrame})
    local blockedX = false
    for _, item in ipairs(hitX) do
        if not item:GetAttribute("Passthrough") then
            blockedX = true
            break
        end
    end
    if not blockedX then
        NewFrame.Position = testXPos
        moved = true
    end

    local testYPos = UDim2.new(NewFrame.Position.X.Scale, 0, newY, 0)
    local hitY = game:GetItemsInBound(NewFrame:GetAbsolute() + UDim2.new(0, 0, deltaY, 0), NewFrame.Size, {NewFrame, TestFrame})
    local blockedY = false
    for _, item in ipairs(hitY) do
        if not item:GetAttribute("Passthrough") then
            blockedY = true
            break
        end
    end
    if not blockedY then
        NewFrame.Position = testYPos
        moved = true
    end

    if not moved then
        print("Blocked in all directions!")
    end
end)

UserInput.InputBegan:Connect(function(KeyCode:KeyCode, ScanCode:number)
    if KeyCode == Enum.KeyCodes.q then
        NewFrame.Size += UDim2.new(0.05, 0, 0.05, 0)
    elseif KeyCode == Enum.KeyCodes.e then
        NewFrame.Size -= UDim2.new(0.05, 0, 0.05, 0)
    end
end)

game:BindToClose(function()
    Section:SetAsync("PositionData", {X = NewFrame.Position.X.Scale, Y = NewFrame.Position.Y.Scale, XS = NewFrame.Size.X.Scale, YS = NewFrame.Size.Y.Scale })
end)

task.spawn(function()
    task.wait(5)
    while true do
        local Tween  =  TweenSerive:Create(NewFrame, 6, Enum.EasingStyles.Elastic, Enum.EasingDirections.In, {Color = Color4.new("#7d74fa"), Rotation =  360})
        Tween:Play()
        Tween.Completed:Wait()
        NewFrame.Rotation = 0
    end
end)


DesktopService:SetWindowName("Guh")