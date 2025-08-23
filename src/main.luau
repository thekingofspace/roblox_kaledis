local game = require("./game")
local Color4, Enum, UDim, UDim2, task, Instance = game:GetCommonElements()

local Frame:Frame = Instance.new("Frame")

task.spawn(function()
    Frame:SetAttribute("Test", true)
    print(Frame:GetAttribute("Test"))
end)
