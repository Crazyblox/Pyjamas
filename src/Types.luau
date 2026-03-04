--[[
	Pajamas: Types
	This module contains types that can be used in a Pajamas runtime.
]]

export type PajamasSrc = {
	schema: string,
	project: {
		name: string,
		author: string,
		version: string,
		launch_note: string,
	},
	runtime: {
		default: { run: boolean },
		roblox: { run_server: boolean, run_client: boolean }
	},
	libraries: {
		[string]: { include: boolean }
	},
	main: any
}

export type PajamasRuntime = {
	init: (self: PajamasRuntime, projectLocation: any, ...any) -> boolean
}

export type RuntimeProvider = "Roblox" | string

return nil
