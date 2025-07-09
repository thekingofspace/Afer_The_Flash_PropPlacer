local module = {}

print(`[Prop_Placer_V7] - Thank you for choosing prop placer V7 by Raikin_145ps!`)

local PlayerController = require(script:WaitForChild("PlayerControllers"))

local EventBuilder = require(script:WaitForChild("EventBuilder"))

local PlacedProps = {}

local StreamedAssets = {}

local Types = require(script.Parent.Parent:WaitForChild("Type_Definitions"))

local PropList:Types.PropFolder = require(script:WaitForChild('Prop_List'))

for I, item in pairs(PropList) do
	PropList[I].ID = I
end

local PlacedProp = EventBuilder:GetEvent("PlacedProp")

local HTTP = game:GetService("HttpService")

local RemovedProp = EventBuilder:GetEvent("RemovedProp")

local LoadNear = EventBuilder:GetEvent("LoadNear")

local PropHolders = {}

local PlayerSpecificProps = {}

-- A simplified integration system.
function module:EasyInit()
	EventBuilder:GetEvent("StreamIn").OnServerInvoke = function(PL:Player, ID:number, Key:string)
		StreamedAssets[PL] = StreamedAssets[PL] or {}
		if PropList[ID] then
			if StreamedAssets[PL][Key] == nil  then
				local NewProp = PropList[ID].Model:Clone()
				
				NewProp.Name = Key
				
				NewProp.Parent = PlayerController:GetStreamFolder(PL)
				
				StreamedAssets[PL][Key] = NewProp
			else
				return StreamedAssets[PL][Key]
			end
		end
	end
	
	EventBuilder:GetEvent("StreamOut").OnServerInvoke = function(PL:Player, Key:string)
		if StreamedAssets[PL][Key] ~= nil then
			
			StreamedAssets[PL][Key]:Destroy()
			
			StreamedAssets[PL][Key] = nil
		end
	end
	
	EventBuilder:GetEvent("PlaceProp").OnServerInvoke = function(PL:Player, ID:number, Position:CFrame)
		local PropInfo = PropList[ID]
		
		PlayerSpecificProps[PL] = PlayerSpecificProps[PL] or {}
		
		if PropInfo.MaxCount ~= 0 then
			local Count = 0
			for I, item in pairs(PropHolders) do
				if item.ID == ID then
					Count+=1
				end
			end
			
			if Count > PropInfo.MaxCount then
				return
			end
		end
		
		if #PlayerController:GetPlayerPropFolder(PL):GetChildren() > PlayerController:GetMaxProps(PL) then
			return
		end
		
		
		if PlayerController:OwnsPack(PL, PropInfo.Pack) then
			local Prop = PropInfo.Model:Clone()
			
				
			for I, item in ipairs(Prop:GetDescendants()) do
				if item:IsA("BasePart") and item.CanCollide == true then
					item.CollisionGroup = "Prop_Meta_Place"
				end
			end
			
			Prop:AddTag("Prop")

			Prop:SetAttribute("OwningPlayer", tostring(PL.UserId))

			Prop.Parent = PlayerController:GetPlayerPropFolder(PL)

			Prop:PivotTo(Position)
			
			local Key  = HTTP:GenerateGUID()
			
			Prop.Name  = Key
			
			PlayerSpecificProps[PL][Key] = Prop
			
			PlacedProp:InvokeClient(PL, Key, ID)
			
			local PropTable = {ID = ID}
			
			if PropInfo.InteractPart and PropInfo.OnInteract then
				local ClickDet = Instance.new("ClickDetector")
				
				ClickDet.Parent = Prop:WaitForChild(PropInfo.InteractPart.Name)
				
				PropTable.Event = ClickDet.MouseClick:Connect(function(Inter_Player)
					PropInfo.OnInteract(Prop, Inter_Player)
				end)
			end
			
			if PropInfo.OnPlace then
				PropInfo.OnPlace(Prop)
			end
			
			PropHolders[Prop] = PropTable
		end
	end
	
	
	EventBuilder:GetEvent("DestroyProp").OnServerInvoke = function(PL:Player, PropName:string)
		PlayerSpecificProps[PL] = PlayerSpecificProps[PL] or {}
		local Prop = PlayerController:GetPlayerPropFolder(PL):WaitForChild(PropName)
		if Prop:HasTag("Prop") and Prop:GetAttribute("OwningPlayer") == tostring(PL.UserId) then
			RemovedProp:InvokeClient(PL, Prop)

			PlayerSpecificProps[PL][PropName] = nil

			local ID = PropHolders[Prop].ID
			
			if PropHolders[Prop].Event then
				PropHolders[Prop].Event:Disconnect()
			end

			PropHolders[Prop] = nil

			if PropList[ID].OnDelete then
				PropList[ID].OnDelete(Prop)
			end

			Prop:Destroy()
		end
	end
	
	EventBuilder:GetEvent("GetInfo").OnServerInvoke = function(PL)
		return {MaxProps = PlayerController:GetMaxProps(PL), Props = PlayerController:GetSave(PL), OwnerPacks = PlayerController:GetPacks(PL)}
	end
	
	EventBuilder:GetEvent("GetInfoLite").OnServerInvoke = function(PL)
		return {MaxProps = PlayerController:GetMaxProps(PL), OwnerPacks = PlayerController:GetPacks(PL)}
	end
	
	EventBuilder:GetEvent("GetProps").OnServerInvoke = function(PL)
		return PropList
	end
	
	EventBuilder:GetEvent("GetSave").OnServerInvoke = function(PL, ID:number)
		return PlayerController:GetSave(PL, ID)
	end

	
	EventBuilder:GetEvent("EditProps").OnServerInvoke = function(PL:Player, Props:{[string]:CFrame})
		local PropContainer = PlayerController:GetPlayerPropFolder(PL)
		for I, item in pairs(Props) do
			local Prop:Model = PropContainer:WaitForChild(I)
			
			if Prop:HasTag("Prop") and Prop:GetAttribute("OwningPlayer") == tostring(PL.UserId) then
				Prop:PivotTo(item)
			end
		end
	end
	
	local PlayerDebounce = {}
	
	EventBuilder:GetEvent("SaveProps").OnServerInvoke = function(PL, SaveID:number, Name:string)
		if PlayerDebounce[PL] == true then
			return "Failed"
		end
		
		PlayerDebounce[PL] = true
		task.delay(5, function()
			PlayerDebounce[PL] = false
		end)
		
		
		PlayerSpecificProps[PL] = PlayerSpecificProps[PL] or {}
		local Save:Types.PropSave = {}
		local Count = 0
		Save.Name = Name
		Save.PropData = {}
		for I, item:Model in pairs(PlayerSpecificProps[PL]) do
			Count+=1
			local PropCache = PropHolders[item]
			
			local PropInfo:Types.PropEntry = PropList[PropCache.ID]
			
			local Pivot = item:GetPivot()

			local x, y, z = Pivot:ToEulerAnglesXYZ()

			local PropUpdate = nil

			if PropInfo.OnSave then
				PropUpdate = PropInfo.OnSave(item)
			end

			table.insert(Save.PropData, {
				ID = PropCache.ID,

				Position = {
					X = Pivot.Position.X,
					Y = Pivot.Position.Y,
					Z = Pivot.Position.Z,
					RX = x,
					RY = y,
					RZ = z,
				},

				PropData = PropUpdate or {}
			})
		end
		
		Save.PropCount = Count
		
		PlayerController:WriteSave(PL, SaveID, Save)
	end
	
	EventBuilder:GetEvent("DontCollde").OnServerInvoke = function(PL)
		if PL.Character then
			if PL.Character:GetAttribute("CollideProp") == nil then
				PL.Character:GetAttribute("CollideProp", true)
			end
			
			if PL.Character:GetAttribute("CollideProp") == false then
				PL.Character:SetAttribute("CollideProp", true)
				for I, item in ipairs(PL.Character:GetDescendants()) do
					if item:IsA("BasePart") then
						item.CollisionGroup = "Default"
					end
				end
				
			else
				PL.Character:SetAttribute("CollideProp", false)
				for I, item in ipairs(PL.Character:GetDescendants()) do
					if item:IsA("BasePart") then
						item.CollisionGroup = "PlayerProp"
					end
				end
			end
		end
	end
	
	EventBuilder:GetEvent("LoadProps").OnServerInvoke = function(PL:Player, SaveData:Types.PropSave)
		if PlayerDebounce[PL] == true then
			return "Failed"
		end

		PlayerDebounce[PL] = true
		task.delay(5, function()
			PlayerDebounce[PL] = false
		end)

		local Save:Types.PropSave = SaveData

		local SendBack = {}

		local PropFolder = PlayerController:GetPlayerPropFolder(PL)

		local CurrentCount = #PropFolder:GetChildren()
		local MaxProps = PlayerController:GetMaxProps(PL)

		local ActualCount = 0

		local PendingCount = 0

		local Threads = {}

		for I, item in ipairs(Save.PropData) do
			if CurrentCount + PendingCount >= MaxProps then
				break
			end

			PendingCount += 1
			ActualCount += 1

			table.insert(Threads, task.spawn(function()
				local PropInfo = PropList[item.ID]

				PlayerSpecificProps[PL] = PlayerSpecificProps[PL] or {}

				local Position = CFrame.new(item.Position.X, item.Position.Y, item.Position.Z) * CFrame.Angles(item.Position.RX, item.Position.RY, item.Position.RZ)

				local Prop = PropInfo.Model:Clone()
				for _, part in ipairs(Prop:GetDescendants()) do
					if part:IsA("BasePart") and part.CanCollide == true then
						part.CollisionGroup = "Prop_Meta_Place"
					end
				end

				Prop:AddTag("Prop")

				Prop:SetAttribute("OwningPlayer", tostring(PL.UserId))

				Prop.Parent = PropFolder

				Prop:PivotTo(Position)

				table.insert(SendBack, Prop)

				local Key = HTTP:GenerateGUID()

				Prop.Name = Key

				PlayerSpecificProps[PL][Key] = Prop

				PlacedProp:InvokeClient(PL, Key, item.ID)

				local PropTable = {ID = item.ID}

				if PropInfo.InteractPart and PropInfo.OnInteract then
					local ClickDet = Instance.new("ClickDetector")
					ClickDet.Parent = Prop:WaitForChild(PropInfo.InteractPart.Name)
					PropTable.Event = ClickDet.MouseClick:Connect(function()
						PropInfo.OnInteract(Prop)
					end)
				end

				if PropInfo.OnPlace then
					PropInfo.OnPlace(Prop)
				end

				if PropInfo.OnLoad then
					PropInfo.OnLoad(Prop, item.PropData)
				end

				PropHolders[Prop] = PropTable
			end))
		end

		while #SendBack ~= ActualCount do
			task.wait()
		end
	end

	
	for I, item in ipairs(game.Players:GetPlayers()) do
		PlayerController:LoadPlayerData(item)
	end
	
	game.Players.PlayerAdded:Connect(function(PL)
		PlayerController:LoadPlayerData(PL)
	end)
	
	game.Players.PlayerRemoving:Connect(function(PL)
		if PlayerSpecificProps[PL] then
			local Folder = PlayerController:GetPlayerPropFolder(PL)
			for I, item in pairs(PlayerSpecificProps[PL]) do
				if PropHolders[Folder:FindFirstChild(item.Name)] then
					if PropHolders[Folder:FindFirstChild(item.Name)].Event then
						PropHolders[Folder:FindFirstChild(item.Name)].Event:Disconnect()
					end
				end

				PropHolders[Folder:FindFirstChild(item.Name)] = nil
			end
			PlayerSpecificProps[PL] = nil
		end
		
		PlayerController:UnbindPlayerData(PL)
	end)
end


return module
