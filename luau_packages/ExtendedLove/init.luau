local Types = require("@self/Types")

return {
    Socket = require("@self/Packages/Socket")::Types.SocketModule;
    Enet = require("@self/Packages/Enet")::Types.Enet;
}