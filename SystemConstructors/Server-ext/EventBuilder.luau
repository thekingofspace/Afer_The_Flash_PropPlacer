local module = {}

local EventsFolder = Instance.new("Folder")

EventsFolder.Parent = game.ReplicatedStorage

EventsFolder.Name = "PropPlacer_Events"

function module:GetEvent(Name:string)
	local Event = Instance.new("RemoteFunction")
	
	Event.Name = Name
	
	Event.Parent = EventsFolder
	
	return Event
end

return module
