--!strict
--!native

--[[
	Pajamas plugin - input:
	
	A simple keyboard input module providing an agnostic interface
	for a pajamas project to react to keyboard user intent.
]]

local Input = {
	Provided = {
		InputBegan = {} :: Signal<InputObject>,
		InputEnded = {} :: Signal<InputObject>,
		InputChanged = {} :: Signal<InputObject>,
	},
	Connections = {} :: {Connection}
}

-- Types

export type Connection = {
	Disconnect: (self: Connection) -> (),
	Destroy: (self: Connection) -> (),
	Connected: boolean,
}

export type Signal<T...> = {
	Fire: (self: Signal<T...>, T...) -> (),
	Connect: (self: Signal<T...>, fn: (T...) -> ()) -> Connection,
	Destroy: (self: Signal<T...>) -> (),
	Wait: (self: Signal<T...>) -> T...,
}

export type InputObject = {
	KeyCode: string,
	[string]: any
}

-- Input Library Functions

function Input.registerSignals(inputBegan: (Signal<InputObject> | any), inputEnded: (Signal<InputObject> | any), inputChanged: (Signal<InputObject> | any)?)
	Input.Provided.InputBegan = inputBegan
	Input.Provided.InputEnded = inputEnded
	
	if not inputChanged then return end
	Input.Provided.InputChanged = inputChanged
end

function Input.InputBegan(targetKeyCode: string | any, callback: (InputObject, ...any) -> ())
	assert(Input.Provided.InputBegan.Connect, "Input signals have not been registered yet!")
	table.insert(Input.Connections, Input.Provided.InputBegan:Connect(function(input: InputObject, ...) 
		if targetKeyCode == input.KeyCode or (string.split(tostring(input.KeyCode), `.`)[3] or ``) == targetKeyCode then
			callback(input, ...)
		end
	end))
end

function Input.InputEnded(targetKeyCode: string | any, callback: (InputObject, ...any) -> ())
	assert(Input.Provided.InputEnded.Connect, "Input signals have not been registered yet!")
	table.insert(Input.Connections, Input.Provided.InputEnded:Connect(function(input: InputObject, ...) 
		if targetKeyCode == input.KeyCode or (string.split(tostring(input.KeyCode), `.`)[3] or ``) == targetKeyCode then
			callback(input, ...)
		end
	end))
end

function Input.InputChanged(targetKeyCode: string | any, callback: (InputObject, ...any) -> ())
	assert(Input.Provided.InputChanged.Connect, "InputChanged signal has not been registered yet!")
	table.insert(Input.Connections, Input.Provided.InputChanged:Connect(function(input: InputObject, ...) 
		if targetKeyCode == input.KeyCode or (string.split(tostring(input.KeyCode), `.`)[3] or ``) == targetKeyCode then
			callback(input, ...)
		end
	end))
end

function Input.ClearConnections()
	for _, connection in Input.Connections do
		connection:Disconnect()
		connection:Destroy()
	end
	table.clear(Input.Connections)
end

return Input
