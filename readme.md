# Roblox x Kaleids

A Love2D wrapper to make it work like Roblox.  
Provides familiar Roblox-like services, signals, and instances for use inside a Love2D environment.  

## Features
- Roblox-style services (`RunService`, `Datastore`, `UserInputService`, etc.)
- Signal/event system (`Heartbeat`, `RenderStep`, `InputBegan`, `InputEnded`, etc.)
- Instance management with Roblox-like properties
- Basic input handling and window events

## Installation
Download from the **main** branch.  
Inside find src. Main will be your script you are editing.

## Example
```lua
local game = require("./game")

-- Access services
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Connect to Heartbeat
RunService.Heartbeat:Connect(function(DT:number)
    print("Heartbeat step")
end)

-- Handle in
```