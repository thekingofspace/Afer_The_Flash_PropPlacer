local module = {}

local EventFolder = nil

local RS = game:GetService("RunService")

EventFolder = game.ReplicatedStorage:FindFirstChild("Zone_Events") or (function()
	
	if RS:IsClient() == true then
		for I=1,5 do
			if game.ReplicatedStorage:FindFirstChild("Zone_Events") then
				return game.ReplicatedStorage:FindFirstChild("Zone_Events")
			else
				task.wait(1)
			end
		end
	end
	
	local Folder = Instance.new("Folder")
	
	Folder.Name = "Zone_Events"
	
	Folder.Parent = game.ReplicatedStorage
	
	return Folder
end)()

function module:GetEvent(ID:string):RemoteFunction
	local Event:RemoteFunction = EventFolder:FindFirstChild(ID)
	if Event then
		return Event
	else
		if RS:IsServer() == true then
			Event = Instance.new("RemoteFunction")
			
			Event.Name = ID
			
			Event.Parent = EventFolder
			
			return Event
		end
	end
end

function module:GetGlobal(ID:string):RemoteEvent
	local Event:RemoteEvent = EventFolder:FindFirstChild(ID)
	if Event then
		return Event
	else
		if RS:IsServer() == true then
			Event = Instance.new("RemoteEvent")

			Event.Name = ID

			Event.Parent = EventFolder

			return Event
		end
	end
end

return module
