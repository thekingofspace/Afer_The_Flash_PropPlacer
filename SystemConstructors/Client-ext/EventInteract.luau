local module = {}

local EventFolder:Folder = game.ReplicatedStorage:WaitForChild("PropPlacer_Events")

local CachedFolder:Folder = nil

local CachedFolderProp:Folder = nil

local function GetStreamFolder()
	CachedFolder = CachedFolder or game.Players.LocalPlayer:WaitForChild("StreamedAssets", 300)
	
	return CachedFolder
end

local function GetEvent(Name:string)
	local Event:RemoteFunction = EventFolder:WaitForChild(Name)
	
	return Event
end

function module:StreamModel(StreamID:string, ID:number)
	GetEvent("StreamIn"):InvokeServer(ID, StreamID .. ID)
	
	local NewModel = GetStreamFolder():WaitForChild(StreamID .. ID):Clone()
	
	GetEvent("StreamOut"):InvokeServer(StreamID .. ID)
	
	return NewModel
end

function module:GetPlayerPropFolder()
	CachedFolderProp = CachedFolderProp or game.Workspace:WaitForChild(game.Players.LocalPlayer.Name .. "_Props")

	return CachedFolderProp
end


function module:GetEvent(Name:string)
	return GetEvent(Name)
end

return module
