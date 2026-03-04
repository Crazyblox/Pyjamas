--!strict
--!native

--[[
    Pajamas plugin - task:
    Consolidates task library functionality from various Luau
    runtimes such as Roblox, Lute & Lune.
    
    Conveniences for Roblox's Parallel Luau are also provided
    via Task.runSync() and Task.runDesync().
]]

local Task = {}

-- Types

type cancel = (thread: thread) -> ()
type defer<A..., R...> = (threadOrFunction: ((A...) -> (R...)) | thread, A...) -> thread
type wait = (duration: number?) -> number
type func = () -> ()

-- Local Functions

local function s_ret(s, ...) return ..., s() end
local function s_test(): boolean return true, Task.sync() end

-- Task Library Functions

-- Registers all necessary API methods for the library. Must be used first.
function Task.registerAPI<A..., R...>(cancel: cancel, defer: defer<A..., R...>, wait: wait, sync: func, desync: func)
	Task.cancel = cancel
	Task.defer = defer
	Task.wait = wait

	Task.synchronize = sync
	Task.sync = sync

	Task.desynchronize = desync
	Task.desync = desync
end

-- Calls/resumes a function/thread immediately. 
function Task.spawn<A..., R...>(f: (A...) -> (R...) | thread, ...: A...): thread
	local output: thread = if type(f) == "thread" then f else coroutine.create(f)
	coroutine.resume(output, ...)
	return output
end

-- Runs function in serial, switching back to calling sync state on return
function Task.runSync<A..., R...>(f: (A...) -> (R...), ...: A...): R...
	assert(Task.sync and Task.desync, "Task APIs have not been registered yet!")
	local s_f = coroutine.wrap(s_test)() and Task.sync or Task.desync
	Task.sync(); return s_ret(s_f, f(...))
end

-- Runs function in parallel, switching back to calling sync state on return
function Task.runDesync<A..., R...>(f: (A...) -> (R...), ...: A...): R...
	assert(Task.sync and Task.desync, "Task APIs have not been registered yet!")
	local s_f = coroutine.wrap(s_test)() and Task.sync or Task.desync
	Task.desync(); return s_ret(s_f, f(...))
end

return Task
