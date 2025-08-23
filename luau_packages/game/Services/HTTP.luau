local Json = require("@game/Vendors/Json")

local InitModule = {}

local module = {}

function module.JsonEncode(Data:any, Pretty:boolean):string
    return Json.encode(Data, Pretty)
end

function module.JsonDecode(Str:string):any
    return Json.decode(Str)
end

return {module = module, Init = InitModule}