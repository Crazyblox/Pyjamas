A lightweight project spec that enables Luau projects to be created in a platform-agnostic manner.

By reducing the dependency of a project into a set of Luau plugin modules, the burden of porting Luau code to be compatible from one environment to the next is massively reduced in scope, as only the plugin modules would need to be ported, rather than a given codebase.

The primary example of this being applied in practice is the 'penumbra' Luau graphics rendering pipeline.

Link: https://github.com/Crazyblox/Penumbra

-----

# Setting up a Pajamas Project

Setting up a pajamas project may differ platform to platform, but the main project layout should be the same:

**ProjectFolder**:

	 ┣━ .pajamasrc.luau
	 ┗━ init.luau

## Explained:

### `.pajamasrc.luau`:

A Pajamas runtime provider starts validating a Pajamas project by looking for this file.
It contains project details, launch parameter options, and specific runtime configuration.
To ensure consistency, this file must exist on all runtime providers and its schema must not change.

```luau
return {
	schema = "0.0.2", -- Schema version
	project = { -- Your project details
		name = "Penumbra",
		author = "Crazyblox",
		version = "26.04.0",
		launch_note = "Thanks for using Penumbra! Contributions & reports are welcome at https://github.com/Crazyblox/Penumbra"
	},
	runtime = { -- Runtime provider configuration
		roblox = { run_server = false, run_client = true } -- Each runtime provider may present different options here.
	},
	libraries = { -- Built-in shared libraries
		["input"] = { include = false }, -- If include is set to false, then Pajamas will not initialize the said library automatically.
		["task"] = { include = true }
	},
	main = "path/to/penumbra_init" -- The location of the init.luau file, or similar. This file will be ran when the project starts.
}
```

### `init.luau`:

This is the entry point of your pajamas project. While the location of this file can be changed, it is required that you define the location of this file in your `.pajamasrc.luau` file, otherwise your project will not run. This file must also return a function.

It is heavily recommended that you place your project folder as a child under the `Pajamas/Projects` directory, as you'll be able to easily access the main Pajamas API. It also gives your project more consistency across platforms.

-----

# Running a pajamas project:

## Runtime Providers

Like it has been mentioned above, Pajamas allows you to run your Luau projects in a platform-agnostic manner, which is done through runtime providers.

A runtime provider is the middleman between the runtime and your project. It setups your project, and initializes the libraries that you included within your project. It handles everything related to the runtime for your project, so you don't need to interact with the runtime directly yourself.

This way, your Luau project can be ported to different platforms with ease, and you only need to initialize the provider for a runtime you wish to port your project to.

## Runtime Objects

After setting up your project, to run it, you must first create a runtime object with a runtime provider. A runtime object is used to initialize and run projects per runtime. In the examples below, you can see how this is done.

## Setting up a project on Roblox

```luau
local Pajamas = require("@Pajamas")
local RobloxProvider = require("@Pajamas/RuntimeProviders/Roblox")
Pajamas.registerRuntimeProvider("Roblox", RobloxProvider)

local Runtime = Pajamas.runtime("Roblox")
Runtime:init(script.Parent, "Test!")
```

## Setting up a project on another platform

```luau
local Pajamas = require("@Pajamas")
local TestProvider = require("@Pajamas/RuntimeProviders/Test")
Pajamas.registerRuntimeProvider("Test", TestProvider)

local Runtime = Pajamas.runtime("Test")
Runtime:init("path/to/project/folder", "Test!")
```

Using the `Pajamas.registerRuntimeProvider(runtimeName: string, provider: (...any) -> ())` API, you first register a runtime provider to Pajamas. This stores the provider internally, and makes it ready to be used in runtime objects.

To create a runtime object, you use the `Pajamas.runtime(runtimeName: string)` API. This returns a runtime object from the provider that you have registered on the same name. Runtime objects are cached, meaning, if you use this function with the same runtime name multiple times, it will just return the already existing runtime object.

After creating a runtime object, you must then initialize a project on this runtime. Using the `Runtime:init(projectLocation: any, ...)` method, you initialize and run a project on this runtime. The first parameter of this function tells the provider where your project is. This can change depending on the platform you wish to use Pajamas on. Any parameters after the location will be directly given to your project.

It is also possible to initialize multiple projects on the same runtime with runtime objects.

-----

# Shared Libraries

Pajamas comes with a set of shared libraries that are intended to handle interfacing with the Luau runtime the project is running on. This enables a Pajamas project to not depend on runtime specific APIs and functions.

The goal is that, by deferring requirements for running on different platforms down to a specific set of shared libraries, developers would find themselves writing code where their logic is wholly separate from the environment they developed it in, allowing for more portability and giving Luau more opportunity for growth.

To access these libraries, Pajamas provides the `Pajamas.getLibrary(libraryName: string)` function. Using this, you can access all available shared libraries that Pajamas provides. Do note that if a library has not been included within the `.pajamasrc.luau` file, it will not come initialized for your runtime. This is done so developers can select which libraries that their project needs, removing accidental bloat.
