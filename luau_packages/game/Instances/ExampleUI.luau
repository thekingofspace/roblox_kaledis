local D2 = require("@game/Instances/D2")

local module = {}

function module.new(InstanceUpdate: Signal, GetID: () -> string)
    return D2.new(InstanceUpdate, GetID, function()
        local RawProperty: {Property} = {}
        local Methods: {Method} = {}
        local ExtendedMethods: {Method} = {}

        table.insert(RawProperty, { -- New Property
            Property = "test";
            Type = "boolean";
            Value = true
        })

        table.insert(RawProperty, { -- Writing over old property
            Property = "Visible";
            Type = "boolean";
            Value = false
        })

        table.insert(Methods, { -- Writing over old  method
            Method = "Draw";

            Code = function(self)
                print("ran")
            end
        })

        table.insert(Methods, { -- new method
            Method = "Test";

            Code = function(self)
                print("ran")
            end
        })

        table.insert(ExtendedMethods, { -- Injects a new function to be run before destroy.
            Method = "Destroy";

            Code = function(self)
                print("ran")
            end
        })

        return RawProperty, Methods, ExtendedMethods
    end)
end

return module
