local game = require("./game")
local RunService:RunService = game:GetService("RunService")
local DataStore:DatastoreService = game:GetService("Datastore")
local Section:Datastore = DataStore:GetDataStore("Test")

local Color4, Enum, UDim, UDim2, task = game.GetCommonElements()

Section:SetAsync("Test", {
    Test = true
})

print(Section:GetAsync("Test"))