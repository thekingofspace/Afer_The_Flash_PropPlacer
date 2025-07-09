local module = {}

local DS_Handler = require(script.Parent.Parent.Parent:WaitForChild("HelperModules"):WaitForChild("DS_Handler"))

local Data_Segment = DS_Handler.New("Prop_Data_V7")

_G.PlayerData = _G.PlayerData or {}

local CachedPropFolders = {}

local CachedStreamFolders = {}

local function BuildPlayerData(Value:{})
	if Value.OwnedPacks == nil then
		Value.OwnedPacks = {["Free Item"] = true}
	end
	
	if Value.MaxProps == nil then
		Value.MaxProps = 300
	end
	
	if Value.Saves == nil then
		Value.Saves = {}
		
		for I = 1,10 do
			Value.Saves[I] = {
				Name = "No Name";
				
				PropCount = 0;
				
				PropData = {}
			}
		end
	end
	
	return Value
end

function module:LoadPlayerData(PL:Player)
	if _G.PlayerData[PL] ~= nil then return end
	
	if CachedPropFolders[PL] == nil then
		CachedPropFolders[PL] = Instance.new("Folder")

		CachedPropFolders[PL].Name = PL.Name .. "_Props"

		CachedPropFolders[PL].Parent = game.Workspace
	end
	
	PL:SetAttribute("Max_Props")
	
	local PL_Data = Data_Segment:GetEntry(PL.UserId)
	
	PL_Data.Value = BuildPlayerData(PL_Data.Value)

	_G.PlayerData[PL]  = PL_Data
	
	local StreamedFolder = Instance.new("Folder")
	
	StreamedFolder.Name = "StreamedAssets"
	
	StreamedFolder.Parent = PL
end

function module:GetStreamFolder(PL:Player)
	CachedStreamFolders[PL] = CachedStreamFolders[PL] or PL:WaitForChild("StreamedAssets", 300)
	
	return CachedStreamFolders[PL]
end

function module:GetPlayerPropFolder(PL:Player)
	if CachedPropFolders[PL] == nil then
		CachedPropFolders[PL] = Instance.new("Folder")
		
		CachedPropFolders[PL].Name = PL.Name .. "_Props"
		
		CachedPropFolders[PL].Parent = game.Workspace
	end

	return CachedPropFolders[PL]
end

function module:GetMaxProps(PL:Player)
	if _G.PlayerData[PL] == nil then return end

	return _G.PlayerData[PL].Value.MaxProps + (PL:GetAttribute("Max_Props") or 0)
end

function module:SetMaxProps(PL:Player, Count:number)
	if _G.PlayerData[PL] == nil then return end

	_G.PlayerData[PL].Value.MaxProps = Count
end

function module:SetMaxPropsTemp(PL:Player, Count:number)
	if _G.PlayerData[PL] == nil then return end

	PL:SetAttribute("Max_Props", Count)
end

function module:GrantPack(PL:Player, Pack:string)
	if _G.PlayerData[PL] == nil then return end
	
	_G.PlayerData[PL].Value.OwnedPacks[Pack] = true
end

function module:GetSave(PL:Player, Save:number)
	if _G.PlayerData[PL] == nil then return end
	if Save then
		return _G.PlayerData[PL].Value.Saves[Save]
	else

		return _G.PlayerData[PL].Value.Saves
	end
end

function module:WriteSave(PL:Player, Save:number, Data)
	if _G.PlayerData[PL] == nil then return end
	_G.PlayerData[PL].Value.Saves[Save] = Data
end

function module:OwnsPack(PL:Player, Pack:string)
	if _G.PlayerData[PL] == nil then return end
	
	return _G.PlayerData[PL].Value.OwnedPacks[Pack] or false
end

function module:GetPacks(PL:Player)
	if _G.PlayerData[PL] == nil then return end

	return _G.PlayerData[PL].Value.OwnedPacks
end


function module:UnbindPlayerData(PL:Player)
	if _G.PlayerData[PL] == nil then return end
	
	local Data:DS_Handler.DataEntry = _G.PlayerData[PL]
	
	game.Workspace:WaitForChild(PL.Name .. "_Props"):Destroy()
	
	_G.PlayerData[PL] = nil
	
	Data:Publish()
	
	Data = nil
end


return module
