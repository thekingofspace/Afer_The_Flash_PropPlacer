local module = {}

local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

export type DataEntry = {
	Created: number,
	Updated: number?,
	Value: any,
	Key: string,
	KeyHistory: { string },
	Refresh: (self: DataEntry) -> nil,
	Destroy: (self: DataEntry) -> nil,
	ChangeKey: (self: DataEntry, newKey: string) -> nil,
	Publish: (self: DataEntry) -> nil,
}

export type DataStoreWrapper = {
	DataStore: DataStore,
	StoreKey: string,
	GetEntry: (self: DataStoreWrapper, entryKey: string) -> DataEntry,
}

local function RemoveEntry(dataStore: DataStore, key: string)
	local attempts = 0
	local isStudio = RunService:IsStudio()

	while true do
		local success = pcall(function()
			return dataStore:RemoveAsync(key)
		end)

		if success then
			return
		elseif isStudio and attempts == 5 then
			warn("[OOP_DS] - Could not remove, please check if DataStore is enabled.")
			return
		else
			attempts += 1
			task.wait(1)
		end
	end
end

local function UpdateEntry(dataStore: DataStore, key: string, newValue: any)
	local attempts = 0
	local isStudio = RunService:IsStudio()

	while true do
		local success, result = pcall(function()
			return dataStore:UpdateAsync(key, function(oldData)
				oldData.MetaData.LastUpdate = os.time()
				oldData.Data = newValue
				return oldData
			end)
		end)

		if success then
			return result
		elseif isStudio and attempts == 5 then
			warn("[OOP_DS] - Could not update, please check if DataStore is enabled.")
			return
		else
			attempts += 1
			task.wait(1)
		end
	end
end

local function SetEntry(dataStore: DataStore, key: string, value: any)
	local attempts = 0
	local isStudio = RunService:IsStudio()

	while true do
		local success = pcall(function()
			return dataStore:SetAsync(key, value)
		end)

		if success then
			return
		elseif isStudio and attempts == 5 then
			warn("[OOP_DS] - Could not set value, please check if DataStore is enabled.")
			return
		else
			attempts += 1
			task.wait(1)
		end
	end
end

local function EnsureEntryExists(dataStore: DataStore, key: string)
	local attempts = 0
	local isStudio = RunService:IsStudio()

	while true do
		local success, data = pcall(function()
			return dataStore:GetAsync(key)
		end)

		if success then
			if data == nil then
				data = {
					MetaData = { Creation = os.time() },
					Keys = {},
					Data = {}
				}
				SetEntry(dataStore, key, data)
			end

			return data
		elseif isStudio and attempts == 5 then
			warn("[OOP_DS] - Could not get data, please check if DataStore is enabled.")
			return
		else
			attempts += 1
			task.wait(1)
		end
	end
end

function module.New(storeKey: string)
	local self = setmetatable({}, {})
	self.DataStore = DataStoreService:GetDataStore(storeKey)
	self.StoreKey = storeKey

	function self:GetEntry(entryKey: string)
		local dataStore = self.DataStore
		local entryData = EnsureEntryExists(dataStore, entryKey)

		local rawEntry = {
			Created = entryData.MetaData.Creation,
			Updated = entryData.MetaData.LastUpdate,
			Value = entryData.Data,
			Key = entryKey,
			KeyHistory = entryData.Keys
		}

		local entryMeta = {}

		function rawEntry:Refresh()
			entryData = EnsureEntryExists(dataStore, entryKey)
			rawEntry.Created = entryData.MetaData.Creation
			rawEntry.Updated = entryData.MetaData.LastUpdate
			rawEntry.Value = entryData.Data
			rawEntry.KeyHistory = entryData.Keys
		end

		function rawEntry:Destroy()
			RemoveEntry(dataStore, entryKey)
		end

		function rawEntry:ChangeKey(newKey: string)
			RemoveEntry(dataStore, entryKey)

			table.insert(rawEntry.KeyHistory, entryKey)

			local newData = {
				MetaData = entryData.MetaData,
				Data = entryData.Data,
				Keys = rawEntry.KeyHistory
			}

			SetEntry(dataStore, newKey, newData)
			entryKey = newKey
			rawEntry.Key = newKey
		end

		function rawEntry:Publish()
			UpdateEntry(dataStore, entryKey, rawEntry.Value)
		end

		entryMeta.__index = rawEntry

		entryMeta.__newindex = function(_, key, value)
			if key == "Value" then
				rawEntry[key] = value
			else
				error("Attempt to modify protected key: " .. tostring(key))
			end
		end

		return setmetatable({}, entryMeta)
	end

	self.__index = self
	return self
end
return module
