local Socket = require("socket")
local http = require("socket.http")
local ftp = require("socket.ftp")
local smtp = require("socket.smtp")
local url = require("socket.url")
local mime = require("mime")
local ltn12 = require("ltn12")

local SocketModule = {
	socket = Socket,
	dns = Socket.dns,
	tcp = Socket.tcp,
	udp = Socket.udp,
	unix = Socket.unix,
	connect = Socket.connect,
	bind = Socket.bind,
	select = Socket.select,
	sleep = Socket.sleep,
	gettime = Socket.gettime,
	protect = Socket.protect,
	newtry = Socket.newtry,
	sink = Socket.sink,
	source = Socket.source,
	skip = Socket.skip,
	choose = Socket.choose,
	http = http,
	ftp = ftp,
	smtp = smtp,
	url = url,
	mime = mime,
	ltn12 = ltn12,
}

return SocketModule
