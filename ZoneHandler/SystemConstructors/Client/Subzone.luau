local module = {}

local Que = {}
local Folder = game.Workspace:FindFirstChild("Zones") or (function()
	local Folder = Instance.new("Folder")
	
	Folder.Name = "Zones"
	
	Folder.Parent = game.Workspace
	
	return Folder
end)()

local Shared = script.Parent.Parent.Parent:WaitForChild("Shared")
local Zone = require(Shared:WaitForChild("Zone"))
local Signal = require(Shared:WaitForChild("Signal"))
local UpdateEvent_Enter = Signal:CreateSignal()
local UpdateEvent_Exit = Signal:CreateSignal()

local Enumerator = require(Shared.Parent:WaitForChild("Enumerator"))

local Busy = false

game:GetService("RunService").RenderStepped:Connect(function()
	if Busy == true or #Que == 0 then
		return
	end
	Busy = true
	local Item:{Action:Enumerator.Custom_Enum, Sub_ID:string} = Que[1]
	
	if Item.Action == Enumerator.ActionType.Enter then
		UpdateEvent_Enter:Fire(Item.Action, Item.Sub_ID)
	else
		UpdateEvent_Exit:Fire(Item.Action, Item.Sub_ID)
	end
	
	table.remove(Que, 1)
	
	Busy = false
end)

function module:CreateZone(ZoneID:string, Parts:{BasePart})
	local NewZone = Instance.new("Folder")
	
	NewZone.Name = ZoneID
	
	for I, item in ipairs(Parts) do
		item.Transparency = 1
		
		item.Anchored = true
		
		item.CanCollide = false
		
		item.CanQuery = true
		
		item.CanTouch = true
		item.Parent = NewZone
	end
	NewZone.Parent = Folder
	
	local Zone_Object = Zone.new(NewZone)
	
	Zone_Object.localPlayerEntered:Connect(function()
		table.insert(Que, {Action = Enumerator.ActionType.Enter, Sub_ID = ZoneID})
	end)
	
	Zone_Object.localPlayerExited:Connect(function()
		table.insert(Que, {Action = Enumerator.ActionType.Leave, Sub_ID = ZoneID})
	end)
end

module.OnEnter = Signal:CreateReadOnlySignal(UpdateEvent_Enter)
module.OnExit = Signal:CreateReadOnlySignal(UpdateEvent_Exit)

return module
