export type StartupRatios = {X:number, Y:number}

export type Color4 = {
    r: number,
    g: number,
    b: number,
    a: number,

    toLove: (self: Color4) -> (number, number, number, number),
    mix: (self: Color4, other: Color4, t: number?) -> Color4,
    darken: (self: Color4, factor: number?) -> Color4,
    lighten: (self: Color4, factor: number?) -> Color4,
}

export type UDim = {
    Scale: number,
    Offset: number,
}
export type UDim2 = {
    X: UDim,
    Y: UDim,
    ToAbsolute: (self: UDim2, parentWidth: number, parentHeight: number) -> (number, number),
}

export type Connection = {
    Callback: (...any) -> (),
    IsConnected: boolean,
    Disconnect: (self: Connection) -> (),
}

export type Signal = {
    Connect: (self: Signal, Callback: (...any) -> ()) -> Connection,
    ConnectAsync: (self: Signal, Callback: (...any) -> ()) -> Connection,
    Wait: (self: Signal, timeout: number?) -> ...any,
    Fire: (self: Signal, ...any) -> (),
}

export type ReadOnlySignal = {
    Connect: (self: ReadOnlySignal, callback: (...any) -> ()) -> Connection,
    ConnectAsync: (self: ReadOnlySignal, callback: (...any) -> ()) -> Connection,
    Wait: (self: ReadOnlySignal, timeout: number?) -> (...any),
}

export type Encode_Service = {
    JsonEncode:(Data:any, Pretty:boolean) -> string;

    JsonDecode:(Str:string) -> any;

    TomlEncode:(Data:any) -> string;

    TomlDecode:(Str:string) -> any
}

export type RunService = {
    RenderStep: ReadOnlySignal;
    Heartbeat:ReadOnlySignal
}

export type DatastoreService = {
    GetDataStore: (self: DatastoreService, name: string) -> Datastore,
}

export type Datastore = {
    name: string,
    GetAsync: (self: Datastore, key: string) -> any?,
    SetAsync: (self: Datastore, key: string, value: any) -> (boolean, string?),
    UpdateAsync: (self: Datastore, key: string, updateFunc: (currentValue: any?) -> any) -> (boolean, string?),
    RemoveAsync: (self: Datastore, key: string) -> (boolean, string?),
    ListAsync: (self: Datastore) -> {[string]: any?},
}

export type Instance = {
    Name:string;
    ClassName:string;
    Changed:Signal;
    ID:string;

    Destroy:(self:Instance) -> nil;
    Draw:((self:Instance) -> nil)?,
    SetAttribute:(self:Instance, Name:string, Value:any) -> nil,
    GetAttribute:(self:Instance, Name:string) -> any
}

export type Frame = Instance & {
    Parent: string?,
    Visible:boolean
    
}