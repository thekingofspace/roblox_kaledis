export type EnetEvent = {
    type:"receive" | "disconnect" | "connect",
    peer:Peer?,
    data:string | number,
    channel:number?
}

export type Peer = {
    disconnect:(self:Peer, data:number) -> nil;
    disconnect_now:(self:Peer, data:number) -> nil;
    disconnect_later:(self:Peer, data:number) -> nil;
    reset:(self:Peer) -> nil;
    ping:(self:Peer) -> nil;
    receive:(self:Peer) -> (string, number),
    send:(self:Peer, data:string, channel:number, flag:"reliable" | "unsequenced", "unreliable") -> nil,
    ping_interval:(self:Peer, interval:number) -> nil;
    timeout:(self:Peer, limit:number, minimum:number, maximum:number) -> nil;
    index:(self:Peer) -> number;
    state:(self:Peer) -> "disconnected" | "connecting" | "acknowledging_connect" | "connection_pending" | "connection_succeeded" | "connected" | "disconnect_later" | "disconnecting" | "acknowledging_disconnect" | "zombie" | "unknown";
    connect_id:(self:Peer) -> number;
    round_trip_time:(self:Peer) -> number;
    last_round_trip_time:(self:Peer) -> number
}

export type Enet_Host = {
    service:(self:Peer, timeout:number) -> EnetEvent,
    check_events:(self:Peer) -> {EnetEvent},
    connect:(self:Peer, address:string, channel_count:number, data:number) -> Peer,
    flush:(self:Peer) -> nil,
    broadcast:(self:Peer, data:string, channel:number, flag:"reliable" | "unsequenced", "unreliable") -> nil,
    channel_limit:(self:Peer, limit:number) -> nil,
    bandwidth_limit:(self:Peer, incoming:number, outgoing:number) -> nil,
    get_socket_address:(self:Peer) -> string,
    destroy:(self:Peer) -> nil,
    total_sent_data:(self:Peer) -> number,
    total_received_data:(self:Peer) -> number,
    peer_count:(self:Peer) -> number,
    get_peer:(self:Peer, index:number) -> Peer
}

export type Enet = {
	host_create:(bind_address:string, peer_count:number, channel_count:number, in_bandwidth:number, out_bandwidth:number) -> Enet_Host
}

export type SocketError = "closed" | "timeout" | "refused" | "Address already in use"

export type TimeoutValue = number | "b" | nil

export type Socket = {
	close: (self: Socket) -> (number | nil, SocketError?),
	getfd: (self: Socket) -> number,
	getstats: (self: Socket) -> (number, number, number),
	setstats: (self: Socket, received: number, sent: number, age: number) -> (number),
	settimeout: (self: Socket, value: TimeoutValue, mode: ("b" | "t")?) -> (),
	gettimeout: (self: Socket) -> TimeoutValue,
	dirty: (self: Socket) -> boolean,
}

export type TCPSocket = Socket & {
	accept: (self: TCPSocket) -> (TCPSocket?, SocketError?),
	bind: (self: TCPSocket, address: string, port: number) -> (number | nil, SocketError?),
	connect: (self: TCPSocket, address: string, port: number, locaddr: string?, locport: number?) -> (number | nil, SocketError?),
	getpeername: (self: TCPSocket) -> (string?, number?),
	getsockname: (self: TCPSocket) -> (string?, number?),
	listen: (self: TCPSocket, backlog: number?) -> (number | nil, SocketError?),
	receive: (self: TCPSocket, pattern: (number | "*a" | "*l" | "*L")?, prefix: string?) -> (string?, SocketError?, string?),
	send: (self: TCPSocket, data: string, i: number?, j: number?) -> (number | nil, SocketError?, number?),
	setoption: (self: TCPSocket, option: string, value: any) -> (number | nil, SocketError?),
	getoption: (self: TCPSocket, option: string) -> (any, SocketError?),
	shutdown: (self: TCPSocket, mode: ("both" | "send" | "receive")?) -> (number | nil, SocketError?),
}


export type UDPSocket = Socket & {
	receivefrom: (self: UDPSocket, size: number?) -> (string?, string?, number?, SocketError?),
	sendto: (self: UDPSocket, datagram: string, ip: string, port: number) -> (number | nil, SocketError?),
	setpeername: (self: UDPSocket, address: string, port: number) -> (number | nil, SocketError?),
	setsockname: (self: UDPSocket, address: string, port: number) -> (number | nil, SocketError?),
	getpeername: (self: UDPSocket) -> (string?, number?),
	getsockname: (self: UDPSocket) -> (string?, number?),
	setoption: (self: UDPSocket, option: string, value: any) -> (number | nil, SocketError?),
	getoption: (self: UDPSocket, option: string) -> (any, SocketError?),
}

export type UnixSocket = Socket & {
	accept: (self: UnixSocket) -> (UnixSocket?, SocketError?),
	bind: (self: UnixSocket, path: string) -> (number | nil, SocketError?),
	connect: (self: UnixSocket, path: string) -> (number | nil, SocketError?),
	listen: (self: UnixSocket, backlog: number?) -> (number | nil, SocketError?),
	receive: (self: UnixSocket, pattern: (number | "*a" | "*l" | "*L")?, prefix: string?) -> (string?, SocketError?, string?),
	send: (self: UnixSocket, data: string, i: number?, j: number?) -> (number | nil, SocketError?, number?),
	shutdown: (self: UnixSocket, mode: ("both" | "send" | "receive")?) -> (number | nil, SocketError?),
}

export type HTTPResult = {
	body: string,
	code: number,
	headers: {[string]: string},
	status: string,
}

export type HTTPRequest = {
	url: string,
	sink: any?,
	method: string?,
	headers: {[string]: string}?,
	source: any?,
	step: any?,
	proxy: string?,
	redirect: boolean?,
	create: () -> TCPSocket?,
}

export type FTPResult = {
	body: string?,
	code: number,
	message: string,
}

export type SMTPMessage = {
	headers: {[string]: string},
	body: string | {string},
}

export type SMTPSource = () -> (string?)

export type SMTPServer = {
	server: string,
	port: number?,
	domain: string?,
	user: string?,
	password: string?,
	create: (() -> TCPSocket)?,
}

export type URLComponents = {
	scheme: string?,
	authority: string?,
	userinfo: string?,
	user: string?,
	password: string?,
	host: string?,
	port: number?,
	path: string?,
	params: string?,
	query: string?,
	fragment: string?,
}

export type MimeSource = () -> (string?)
export type MimeSink = (chunk: string?, err: string?) -> ()

export type LTN12Source = () -> (string?, string?)
export type LTN12Sink = (chunk: string?, err: string?) -> (string?)
export type LTN12Filter = (chunk: string?) -> (string?)
export type LTN12Pump = {
	step: (src: LTN12Source, snk: LTN12Sink) -> (string?),
	all: (src: LTN12Source, snk: LTN12Sink) -> (number | nil, string?),
}

export type SocketModule = {
	_VERSION: string,
	_DEBUG: boolean,
	
	connect: (address: string, port: number, locaddr: string?, locport: number?) -> (TCPSocket | nil, SocketError?),
	bind: (host: string, port: number, backlog: number?) -> (TCPSocket | nil, SocketError?),
	tcp: () -> TCPSocket,
	udp: () -> UDPSocket,
	unix: () -> UnixSocket?,
	
	choose: (...any) -> (...any),
	gettime: () -> number,
	newtry: (finalizer: ((...any) -> ())?) -> ((...any) -> (...any)),
	protect: (func: (...any) -> (...any)) -> ((...any) -> (boolean, ...any)),
	select: (recvt: {Socket}, sendt: {Socket}?, timeout: number?) -> ({Socket}, {Socket}, SocketError?),
	sink: (mode: string, socket: Socket) -> LTN12Sink,
	skip: (d: number, ret: (...any) -> (...any)) -> (...any) -> (...any),
	sleep: (time: number) -> (),
	source: (mode: string, socket: Socket, length: number?) -> LTN12Source,
	
	dns: {
		toip: (address: string) -> (string | nil, string?),
		tohostname: (address: string) -> (string | nil, string?),
		gethostname: () -> (string | nil, string?),
	},
	
	http: {
		request: ((HTTPRequest | string), body: string?) -> (HTTPResult | string | nil, number?, {[string]: string}?, string?),
	},
	
	ftp: {
		get: (url: string | {url: string, sink: any, type: ("i" | "a")?}) -> (FTPResult | nil, string?),
		put: (url: string | {url: string, source: any, type: ("i" | "a")?}, body: string?) -> (FTPResult | nil, string?),
	},
	
	smtp: {
		message: (mesgt: SMTPMessage) -> SMTPSource,
		send: (mail: {
			from: string,
			rcpt: string | {string},
			source: SMTPSource,
			server: string?,
			port: number?,
			domain: string?,
			user: string?,
			password: string?,
		}) -> (number | nil, string?),
	},
	
	url: {
		build: (components: URLComponents) -> string,
		build_path: (segments: {string}, unsafe: boolean?) -> string,
		parse: (url: string, default: URLComponents?) -> URLComponents,
		parse_path: (path: string) -> {string},
		parse_query: (query: string, sep: string?) -> {[string]: string},
		absolute: (base: string, relative: string) -> string,
		escape: (s: string) -> string,
		unescape: (s: string) -> string,
	},
	
	mime: {
		b64: (data: string) -> string,
		unb64: (data: string) -> string,
		qp: (data: string, mode: ("text" | "binary")?) -> string,
		unqp: (data: string) -> string,
		wrp: (length: number, data: string, indent: number?) -> string,
		qpwrp: (data: string, length: number?, indent: number?) -> string,
		eol: (mode: number, data: string) -> string,
		dot: (mode: number, data: string) -> string,
	},
	
	ltn12: {
		BLOCKSIZE: number,
		
		source: {
			cat: (...LTN12Source) -> LTN12Source,
			chain: (src: LTN12Source, filter: LTN12Filter) -> LTN12Source,
			empty: () -> LTN12Source,
			error: (err: string) -> LTN12Source,
			file: (file: any, message: string?) -> LTN12Source,
			simplify: (src: LTN12Source) -> LTN12Source,
			string: (s: string) -> LTN12Source,
		},
		
		filter: {
			chain: (...LTN12Filter) -> LTN12Filter,
			cycle: (low: LTN12Filter, ctx: any, extra: any) -> LTN12Filter,
		},
		
		sink: {
			chain: (filter: LTN12Filter, sink: LTN12Sink) -> LTN12Sink,
			error: (err: string) -> LTN12Sink,
			file: (file: any, message: string?) -> LTN12Sink,
			null: () -> LTN12Sink,
			simplify: (sink: LTN12Sink) -> LTN12Sink,
			table: (t: {string}?) -> LTN12Sink,
		},
		
		pump: LTN12Pump,
	},
}

return nil