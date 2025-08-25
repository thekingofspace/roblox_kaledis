local game = require("./game")
local Color4, Enum, _UDim, UDim2, task, Instance = game:GetCommonElements()

local Settings:SettingsService = game:GetService("Settings")
local UserInput:UserInputService = game:GetService("UserInputService")

local DataStoreService:DatastoreService = game:GetService("Datastore")

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

local OldData:{X:number, Y:number}? = Section:GetAsync("PositionData")
local TruePos:UDim2 = nil

if OldData ~= nil then
    TruePos = UDim2.new(OldData.X, 0, OldData.Y, 0)
else
    TruePos = UDim2.new(0.5, 0, 0.5, 0)
end


local NewFrame:Frame = Instance.new("Frame")
NewFrame.Color = Color4.new("#e81818")
NewFrame.Name = "Player"
NewFrame.Size = UDim2.new(0.1, 0, 0.1, 0)
NewFrame.Anchorpoint = UDim2.new(0.5, 0, 0.5, 0)
NewFrame.Position = TruePos
NewFrame.ZIndex = 1
NewFrame.Parent = game.Workspace
NewFrame.Visible = true

local Debounce = false

NewFrame.Touched:Connect(function(B:Instance?)

    if Debounce ~= true then
        Debounce = true

        task.defer(function()
           NewFrame.Color = Color4.new("3fb335")

            task.wait(0.2)

            NewFrame.Color = Color4.new("#e81818")

           Debounce = false
        end)
    end
end)

local TestFrame:Frame = NewFrame:Clone()

TestFrame.Size = UDim2.new(0.8, 0, 0.8, 0)

TestFrame.Parent = NewFrame

TestFrame.Position = UDim2.new(0.5, 0, 0.5, 0)

TestFrame.Color = wallColor

TestFrame.Name = "TestFrame"

local moveSpeed = 0.005

UserInput.InputTick:Connect(function(Keys)
    local deltaX, deltaY = 0, 0

    if UserInput:IsKeyDown(Enum.KeyCodes.w) then deltaY -= 1 end
    if UserInput:IsKeyDown(Enum.KeyCodes.s) then deltaY += 1 end
    if UserInput:IsKeyDown(Enum.KeyCodes.a) then deltaX -= 1 end
    if UserInput:IsKeyDown(Enum.KeyCodes.d) then deltaX += 1 end

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

game:BindToClose(function()
    Section:SetAsync("PositionData", {X = NewFrame.Position.X.Scale, Y = NewFrame.Position.Y.Scale})
end)
