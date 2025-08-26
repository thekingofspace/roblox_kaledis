export type StartupRatios = {X:number, Y:number}

export type KeyCode = string

export type CursorTypes =
    | "arrow"
    | "ibeam"
    | "wait"
    | "crosshair"
    | "hand"
    | "sizewe"
    | "sizens"
    | "sizenwse"
    | "sizenesw"
    | "sizeall"
    | "no"
    | "waitarrow"
    | "hresize"
    | "vresize";

export type Instances = "Frame"

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
    Destroy: (self:Signal) -> nil
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
    Clone:(self:Instance) -> any,
    SetAttribute:(self:Instance, Name:string, Value:any) -> nil,
    GetAttribute:(self:Instance, Name:string) -> any
}

export type UI_2D = Instance & {
    Parent: string | Instance? | nil,
    Visible:boolean;
    TouchStarted:ReadOnlySignal;
    TouchEnded:ReadOnlySignal;
    Size:UDim2;
    Position:UDim2;
    Position:UDim2;
    Anchorpoint:UDim2;
    Color:Color4;
    Rotation:number;
    ZIndex:number;
    CanQuery:boolean;
    SinkInputs:boolean;
    HoverBegan:ReadOnlySignal;
    HoverEnded:ReadOnlySignal;
    MouseClick:ReadOnlySignal;
    MouseClickRelease:ReadOnlySignal;

    GetAbsolute:(self:Frame) -> UDim2;
    GetAbsoluteSize:(self:Frame) -> UDim2;
    IsDescendantOf:(self:Frame, Target:Instance?) -> boolean
}

export type Frame = UI_2D

export type Setting = {
    Save: (self: Setting) -> nil,
    Load: (self: Setting) -> nil,
    Set: (self: Setting, section: string, key: string, value: any) -> nil,
    Get: (self: Setting, section: string, key: string) -> any,
}

export type SettingsService = {
    new: (Name:string) -> Setting,
}

export type Mouse = {
    X: number,
    Y: number,
    Type: string,
    SetIcon: (self: Mouse, Icon: CursorTypes) -> (),
}

export type UserInputService = {
    InputBegan: ReadOnlySignal,
    InputEnded: ReadOnlySignal,
    MouseMoved: ReadOnlySignal,
    InputTick:ReadOnlySignal,
    IsKeyDown: (self: UserInputService, Keycode: KeyCode) -> boolean,
    GetMouse: (self: UserInputService) -> Mouse,
}