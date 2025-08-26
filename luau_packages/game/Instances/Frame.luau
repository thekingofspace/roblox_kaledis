local D2 = require("@game/Instances/D2")

local module = {}

export type Property = {
    Property: string,
    Type: string | {string},
    Value: any,
    WriteTransform: ((self: any, OldValue: any) -> ...any)?,
    ReadTransform: ((self: any, OldValue: any) -> any)?,
}

export type Method = {
    Method: string,
    Code: (self: any, ...any) -> ...any,
}

function module.new(InstanceUpdate: Signal, GetID: () -> string, UserInput)
    return D2.new(InstanceUpdate, GetID, UserInput, function()
        local RawProperty: {Property} = {}
        local Methods: {Method} = {}
        local ExtendedMethods: {Method} = {}

        
        table.insert(RawProperty, {
            Property = "Name";
            Type = "string";
            Value = "Frame"
        })

        
        table.insert(RawProperty, {
            Property = "ClassName";
            Type = "string";
            Value = "Frame"
        })

        return RawProperty, Methods, ExtendedMethods
    end)
end

return module
