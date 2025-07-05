local module = {}

local UserInputService = game:GetService("UserInputService")

local CS = game:GetService("CollectionService")

_G.StoredActionsInput = _G.StoredActionsInput or {}

_G.StoredActionsRelease = _G.StoredActionsRelease or {}

_G.KeyAssignments = _G.KeyAssignments or {}

if game:GetService("RunService"):IsClient() ~= true then
	warn("This is meant for client please do not run on server")
end

for I, item in ipairs(Enum.KeyCode:GetEnumItems()) do
	_G.KeyAssignments[item.Name] = "None"
end

function module:BindInput()
	UserInputService.InputBegan:Connect(function(Input, Proc)
		if _G.StoredActionsInput[_G.KeyAssignments[Input.KeyCode.Name]] and not Proc then
			_G.StoredActionsInput[_G.KeyAssignments[Input.KeyCode.Name]](Input.KeyCode)
		end
	end)

	local InputEvent = nil

	if CS:GetTagged("InputEvent")[1] == nil then
		InputEvent = Instance.new("BindableEvent")

		InputEvent.Name = "InputEvent"

		InputEvent:AddTag("InputEvent")

		InputEvent.Parent = script

	else
		InputEvent = CS:GetTagged("InputEvent")[1]
	end

	InputEvent.Event:Connect(function(Input:Enum.KeyCode)
		if _G.StoredActionsInput[_G.KeyAssignments[Input.Name]] then
			_G.StoredActionsInput[_G.KeyAssignments[Input.Name]](Input)
		end
	end)
end

function module:BindRelease()
	UserInputService.InputEnded:Connect(function(Input, Proc)
		if _G.StoredActionsRelease[_G.KeyAssignments[Input.KeyCode.Name]] and not Proc then
			_G.StoredActionsRelease[_G.KeyAssignments[Input.KeyCode.Name]](Input.KeyCode)
		end
	end)

	local Release = nil

	if CS:GetTagged("ReleaseEvent")[1] == nil then
		Release = Instance.new("BindableEvent")

		Release.Name = "ReleaseEvent"

		Release:AddTag("ReleaseEvent")

		Release.Parent = script

	else
		Release = CS:GetTagged("ReleaseEvent")[1]
	end

	Release.Event:Connect(function(Input:Enum.KeyCode)
		if _G.StoredActionsRelease[_G.KeyAssignments[Input.Name]] then
			_G.StoredActionsRelease[_G.KeyAssignments[Input.Name]](Input)
		end
	end)
end

function module:SimulateInput(KeyCode:Enum.KeyCode)
	if CS:GetTagged("InputEvent")[1] then
		CS:GetTagged("InputEvent")[1]:Fire(KeyCode)
	end
end

function module:SimulateRelease(KeyCode:Enum.KeyCode)
	if CS:GetTagged("ReleaseEvent")[1] then
		CS:GetTagged("ReleaseEvent")[1]:Fire(KeyCode)
	end
end


function module:AssignAction(Type:|"INPUT"|"RELEASE", ActionID:string, Function)
	if Type == "INPUT" then
		_G.StoredActionsInput[ActionID] = Function
	else
		_G.StoredActionsRelease[ActionID] = Function
	end
end

function module:AwaitBind(CheckCode, Function)
	local Event = nil

	Event = UserInputService.InputBegan:Connect(function(Input, Proc)
		local Var = CheckCode(Input)
		if not Proc and _G.KeyAssignments[Input.KeyCode.Name] and Input.KeyCode.Name ~= "Unknown" and Var == true then
			Event:Disconnect()

			Function(Input.KeyCode)
		end
	end)
end


function module:BindKeybind(KeyCode:Enum.KeyCode, ActionID:string)
	if KeyCode then
		if _G.KeyAssignments[KeyCode.Name] then
			_G.KeyAssignments[KeyCode.Name] = ActionID
		end
	end
end

function module:UnBindKeybind(KeyCode:Enum.KeyCode)
	if KeyCode then
		if _G.KeyAssignments[KeyCode.Name] then
			_G.KeyAssignments[KeyCode.Name] = "None"
		end
	end
end

function module:GetKeybind(ActionID:string)
	for I, item in pairs(_G.KeyAssignments) do
		if item == ActionID then
			return Enum.KeyCode[I]
		end
	end
end

function module:GetActionID(Keybind:Enum.KeyCode)
	if _G.KeyAssignments[Keybind.Name] then
		return _G.KeyAssignments[Keybind.Name]
	end
end


return module