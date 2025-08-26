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

export type ReadOnlySignal<T...> = {
    Connect: (self: ReadOnlySignal<T...>, callback: (T...) -> ()) -> Connection,
    ConnectAsync: (self: ReadOnlySignal<T...>, callback: (T...) -> ()) -> Connection,
    Wait: (self: ReadOnlySignal<T...>, timeout: number?) -> (T...),
}

export type Encode_Service = {
    JsonEncode:(Data:any, Pretty:boolean) -> string;

    JsonDecode:(Str:string) -> any;

    TomlEncode:(Data:any) -> string;

    TomlDecode:(Str:string) -> any
}

export type RunService = {
    RenderStep: ReadOnlySignal<number>;
    Heartbeat:ReadOnlySignal<>
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
    TouchStarted:ReadOnlySignal<UI_2D>;
    TouchEnded:ReadOnlySignal<UI_2D>;
    Size:UDim2;
    Position:UDim2;
    Position:UDim2;
    Anchorpoint:UDim2;
    Color:Color4;
    Rotation:number;
    ZIndex:number;
    CanQuery:boolean;
    SinkInputs:boolean;
    HoverBegan:ReadOnlySignal<>;
    HoverEnded:ReadOnlySignal<>;
    MouseClick:ReadOnlySignal<string>;
    MouseClickRelease:ReadOnlySignal<string>;
    Modifiers:{};

    GetAbsolute:(self:UI_2D) -> UDim2;
    GetAbsoluteSize:(self:UI_2D) -> (number, number);
    IsDescendantOf:(self:UI_2D, Target:Instance?) -> boolean;
    GetAncestors:(self:UI_2D) -> {UI_2D?};
    GetChildren:(self:UI_2D) -> {UI_2D?};
    GetDescendants:(self:UI_2D) -> {UI_2D?};
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
    SetVisible: (self: Mouse, Visible:boolean) -> nil
}

export type UserInputService = {
    InputBegan: ReadOnlySignal<string, number>,
    InputEnded: ReadOnlySignal<string, number>,
    MouseMoved: ReadOnlySignal<number,  number>,
    InputTick:ReadOnlySignal<{string}>,
    IsKeyDown: (self: UserInputService, Keycode: KeyCode) -> boolean,
    GetMouse: (self: UserInputService) -> Mouse,
    GetKeyCode:(self: UserInputService, ScanCode:number) -> KeyCode
}

export type Property = {
    Property: string,
    Type: string | {string},
    Value: any,
    WriteTransform: ((self: any, OldValue: any) -> any)?,
    ReadTransform: ((self: any, OldValue: any) -> ...any)?,
}

export type Method = {
    Method: string,
    Code: (self: any, ...any) -> ...any,
}

export type WindowOptions = {
    width: number?,
    height: number?,
    fullscreen: boolean?,
    borderless: boolean?,
    resizable: boolean?,
    vsync: boolean?,
    msaa: number?,
    title: string?,
}

export type CurrentMode = {
    width: number,
    height: number,
    fullscreen: boolean,
    borderless: boolean,
    resizable: boolean,
    vsync: boolean,
    msaa: number,
    title: string,
}

export type DesktopService = {
    CurrentMode: CurrentMode,

    Resized: ReadOnlySignal<number,  number>?,

    SetWindow: (self: DesktopService, options: WindowOptions?) -> (),
    HandleResize: (self: DesktopService, w: number, h: number) -> (),
    FullScreen: (self: DesktopService, Active: boolean) -> (),
    GetWindowSize: (self: DesktopService) -> (number, number),
    SetWindowName: (self: DesktopService, Name: string) -> (),
    SetIcon: (self: DesktopService, Icon: any) -> (),
}