local game = require("./game")
local RunService:RunService = game:GetService("RunService")
local DataStore:DatastoreService = game:GetService("Datastore")
local HTTP:HTTP_Service = game:GetService("HTTP_Service")
local Section:Datastore = DataStore:GetDataStore("Test")

local Color4, Enum, UDim, UDim2, task = game:GetCommonElements()

task.spawn(function()
    task.wait(1)
    print("ran")
end)

RunService.Heartbeat:Connect(function()
    print("Ran")
end)

HTTP.JsonEncode({Test = true}, true)

Section:SetAsync("Test", {
    Test = true
})

print(Section:GetAsync("Test"))