local InitModule = {}
local module = {}

local HeartbeatTasks = {}
local WaitTasks = {}
local DeferredTasks = {}
local DelayedTasks = {}

local Task = {}
Task.__index = Task

function Task.new(func)
    local self = setmetatable({}, Task)
    self.Function = func
    self.IsCancelled = false
    return self
end

function Task:cancel()
    self.IsCancelled = true
end

function module.wait(T:number)
    local co = coroutine.running()
    if co then
        local timer = 0
        table.insert(WaitTasks, {
            Function = function(dt)
                timer = timer + dt
                if timer >= T then
                    coroutine.resume(co)
                    return true
                end
                return false
            end,
            IsCancelled = false
        })
        return coroutine.yield()
    else
        error("task.wait Must be used within a thread")
    end
end

function module.spawn(func)
    local taskObj = Task.new(func)
    table.insert(HeartbeatTasks, taskObj)
    return taskObj
end

function module.defer(func)
    local taskObj = Task.new(func)
    table.insert(DeferredTasks, taskObj)
    return taskObj
end

function module.delay(T, func)
    local taskObj = Task.new(func)
    table.insert(DelayedTasks, {
        Task = taskObj,
        Timer = 0,
        Delay = T
    })
    return taskObj
end

function module.cancel(taskObj)
    if taskObj and taskObj.cancel then
        taskObj:cancel()
    end
end

InitModule.heartbeat = function(dt)
    local tasks = HeartbeatTasks
    HeartbeatTasks = {}
    for _, t in ipairs(tasks) do
        if not t.IsCancelled then
            coroutine.wrap(t.Function)()
        end
    end

    local deferred = DeferredTasks
    DeferredTasks = {}
    for _, t in ipairs(deferred) do
        if not t.IsCancelled then
            coroutine.wrap(t.Function)()
        end
    end
    local remainingWaits = {}
    for _, t in ipairs(WaitTasks) do
        if not t.IsCancelled then
            local finished = t.Function(dt)
            if not finished then
                table.insert(remainingWaits, t)
            end
        end
    end
    WaitTasks = remainingWaits

    local remainingDelays = {}
    for _, t in ipairs(DelayedTasks) do
        if not t.Task.IsCancelled then
            t.Timer = t.Timer + dt
            if t.Timer >= t.Delay then
                coroutine.wrap(t.Task.Function)()
            else
                table.insert(remainingDelays, t)
            end
        end
    end
    DelayedTasks = remainingDelays
end

return {module = module, Init = InitModule}
