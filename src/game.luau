local module = {}

function module.GetCommonElements()
    return require("./Modules/PropertyTypes/Color4"), require("./Modules/Enum"), require("./Modules/PropertyTypes/Udim")
end

return module