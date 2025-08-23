local Json = require("@game/Vendors/Json")
local TOML = require("@game/Vendors/toml")

local InitModule = {}

local module = {}

function module.JsonEncode(Data:any, Pretty:boolean):string
    return Json.encode(Data, Pretty)
end

function module.JsonDecode(Str:string):any
    return Json.decode(Str)
end

function module.TomlEncode(Data:any):string
    return TOML.encode(Data)
end

function module.TomlDecode(Str:string):any
    return TOML.decode(Str)
end

return {module = module, Init = InitModule}