--!strict
--!native

--[[
	Pajamas Runtime: Roblox
	
	This module is responsible for handling the Pajamas runtime on Roblox.
]]

-- Init assertions
assert(game, "Pajamas - Roblox: Cannot find the DataModel singleton.")
assert(script:FindFirstChild("WrapperServer"), "Pajamas - Roblox: Can't initialise, missing 'WrapperServer' Module")
assert(script:FindFirstChild("WrapperClient"), "Pajamas - Roblox: Can't initialise, missing 'WrapperClient' Module")

-- Types

local Types = require("../Types")
type PajamasSrc = Types.PajamasSrc

-- Init
warn("Pajamas - Roblox: Initializing Pajamas Runtime...")

local RunService = game:GetService("RunService")
local IsClient: boolean = RunService:IsClient()

-- Keeps track of running projects in the given runcontext
local RunningProjects = {}

-- Function that is called after ValidateProject() has confirmed we are good to launch.
local function StartProject(Project: Folder, pajamasrc: PajamasSrc, LaunchParams: {string}): boolean
	-- Insert project directory to list of running projects so duplicates can't be made accidentally.
	table.insert(RunningProjects, Project)

	-- Let the user know we are starting up a project...
	print(`Pajamas - Roblox: Init - { pajamasrc.project.name } by { pajamasrc.project.author } [Version { pajamasrc.project.version }]`)

	-- Create a copy of the host wrapper script that will begin running the project.
	local Wrapper = if IsClient then script.WrapperClient:Clone() else script.WrapperServer:Clone()
	Wrapper.Enabled = false

	-- Create Actor instance and insert wrapper as child to enable serial/parallel capabilities.
	local Process = Instance.new("Actor")
	Process.Name = "Process_Main"
	Wrapper.Parent = Process
	Process.Parent = Project

	-- Output project name and launch note before running.
	print(`Pajamas - Roblox: { pajamasrc.project.name } - { pajamasrc.project.launch_note }`)

	-- Run the project!
	Wrapper:SetAttribute("CanRun", true)
	Wrapper.Enabled = true
	
	-- Wait until Wrapper initializes the binding.
	RunService.Heartbeat:Wait()
	
	Process:SendMessage("InitializeWrapper", pajamasrc, LaunchParams)

	-- Success!
	return true
end

-- Performs checks if project is valid and can be initialised in the given runcontext.
local function ValidateProject(Project: Folder, LaunchParams: {[number]: any}): boolean
	-- Check if the provided project contains a '.pajamasrc' module
	local pajamasrcModule = Project:FindFirstChild(".pajamasrc")
	if not (pajamasrcModule and pajamasrcModule:IsA("ModuleScript")) then
		warn(`Pajamas - Roblox: '{Project:GetFullName()}' doesn't contain the .pajamasrc module, cancelling...`)
		return false
	end

	-- Require the .pajamasrc module
	local pajamasrc = require(pajamasrcModule) :: PajamasSrc

	-- Check if the project is already running in this runcontext.
	if table.find(RunningProjects, Project) then
		warn(`Pajamas - Roblox: '{Project:GetFullName()}' is already initialised, cancelling...`)
		return false
	end

	-- Check if the .pajamasrc is configured to allow the project to run in this runcontext.
	local Server_On: boolean = pajamasrc.runtime.roblox.run_server
	local Client_On: boolean = pajamasrc.runtime.roblox.run_client
	if (IsClient and Client_On ~= true) or ((not IsClient) and Server_On ~= true) then
		warn(`Pajamas - Roblox: '{Project:GetFullName()}' .pajamasrc has current runcontext disabled, cancelling...` )
		return false
	end

	-- Checks passed; begin starting up the project and return the success bool result.
	return StartProject(Project, pajamasrc, LaunchParams)
end

-- Initialization Success
warn("Pajamas - Roblox: Initialization success!")

-- The Roblox runtime for Pajamas.
return function(ProjectLocation: Folder, Params: {string}): boolean
	assert(typeof(ProjectLocation) == "Instance", `Pajamas - Roblox: Project location has not been provided.`)
	assert(ProjectLocation:IsA("Folder"), `Pajamas - Roblox: Project location is not a folder.`)
	
	return ValidateProject(ProjectLocation, Params)
end