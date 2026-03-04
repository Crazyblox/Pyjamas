--!strict
--!native

-- Wrapper

-- Initializes shared libraries. This is done here to support Parallel Luau.
local function initializeSharedLibraries(libraries: {[string]: {include: boolean}})
	if not libraries then return warn("Pajamas - Roblox: The project does not define a library tree, so you must manually initialize shared libraries.") end
	
	local UserInputService = game:GetService("UserInputService")

	local EntryPoint = script:FindFirstAncestor("Pajamas")
	if not EntryPoint then return warn("Pajamas - Roblox: The project has not been initialized under Pajamas/Projects, so you must manually initialize shared libraries.") end
	
	if libraries.task and libraries.task.include then
		local Task = require(EntryPoint.SharedLibraries.Task)
		Task.registerAPI(task.cancel, task.defer, task.wait, task.synchronize, task.desynchronize)
	end
	
	if libraries.input and libraries.input.include then
		local Input = require(EntryPoint.SharedLibraries.Input)
		Input.registerSignals(UserInputService.InputBegan, UserInputService.InputEnded, UserInputService.InputChanged)
	end
end

local Actor = script:FindFirstAncestorWhichIsA("Actor")
if not Actor then return end

local Connection: RBXScriptConnection
Connection = Actor:BindToMessage("InitializeWrapper", function(pajamaSrc: {[string]: any}, ...)
	if not script:GetAttribute("CanRun") then return end
	assert(pajamaSrc.main, "Pajamas - Roblox: Main module has not been provided!");

	task.synchronize()

	Connection:Disconnect()
	Connection = nil :: any

	initializeSharedLibraries(pajamaSrc.libraries);

	(require(pajamaSrc.main) :: any)(...)
end)
