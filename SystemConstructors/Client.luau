local module = {}

module.OnPlace = nil

module.OnDelete = nil

module.OnInteract = nil

module.OnSelect = nil

local Modules = script.Parent.Parent:WaitForChild("HelperModules")

local DragHandler = require(Modules:WaitForChild("DragHandler"))

local ControlHandler = require(Modules:WaitForChild("ControlHandler"))

local EventInteract = require(script:WaitForChild("EventInteract"))

local Placed_Event = EventInteract:GetEvent("PlacedProp")

local RemovedProp = EventInteract:GetEvent("RemovedProp")

local LoadNear = EventInteract:GetEvent("LoadNear")

local CS = game:GetService("CollectionService")

local ChangedEvent = Instance.new("BindableEvent")

local UInput = game:GetService("UserInputService")

local EditingLoad = false

local Selecting = false

local InteractionUI = Instance.new("ScreenGui")

InteractionUI.Parent = game.Players.LocalPlayer.PlayerGui

local RemovedSelected = false

local Template = script:WaitForChild("Template")

local RotSnap = 0

local MoveSnap = 0

InteractionUI.ResetOnSpawn = false

local EditingContainer = false

local EditMode = false

local Props = {}

local ReferenceModel:Model = nil

local DragDetector = require(script:WaitForChild("Drag"))

local SelectionMeta = {}

local Selected = {}

local BlockInteract = false

local BlockMouse = false

local PropID = nil

local ClicksToReturn = {}

local CurrentDrag:DragHandler.EditorController = nil

local function ReturnClick()
	for I:Model, item:ClickDetector in pairs(ClicksToReturn) do
		item.Parent = I
	end
	
	ClicksToReturn = {}
end

local function UnTouchModel()
	for I, item in ipairs(ReferenceModel:GetDescendants()) do
		if item:IsA("BasePart") and item.CanCollide == true then
			item:AddTag("Collidable")
			item.CanCollide = false
		end
	end
end

local function TouchModel()
	for I, item in ipairs(ReferenceModel:GetDescendants()) do
		if item:HasTag("Collidable") then
			item.CanCollide = true
			item:RemoveTag("Collidable")
		end
	end
end

local Props = {}

Placed_Event.OnClientInvoke = function(PropName:string, ID:number)
	local Prop:Model = EventInteract:GetPlayerPropFolder():WaitForChild(PropName)
	
	local ClickDet = Instance.new("ClickDetector")
	
	ClickDet.Parent = Prop
	
	Prop:AddTag("Selectable")
	
	Props[Prop] = {Dec = ClickDet, Event = ClickDet.MouseClick:Connect(function()
		if BlockMouse == false then
			if BlockInteract ~= true then
				if EditMode == true then
					if UInput:IsKeyDown(Enum.KeyCode.E) then
						if module.OnInteract then
							module.OnInteract()
						end
						if not CurrentDrag then
							local Container:Model = module:MakePropContainer({Prop})
							Container.WorldPivot = Prop:GetPivot()
							module:EditContainer(Container)

							ClickDet.Parent = script

							ClicksToReturn[Prop] = ClickDet
						end

					elseif UInput:IsKeyDown(Enum.KeyCode.X) then
						if CurrentDrag == nil then
							EventInteract:GetEvent("DestroyProp"):InvokeServer(Prop.Name)
							if module.OnDelete then
								module.OnDelete()
							end
						end
						
					elseif UInput:IsKeyDown(Enum.KeyCode.LeftShift) and ReferenceModel ~= nil and CurrentDrag ~= nil then
						CurrentDrag:SwitchMode(true)
						ReferenceModel:PivotTo(Prop:GetPivot())
						
					end
				else
					if UInput:IsKeyDown(Enum.KeyCode.LeftShift) and ReferenceModel ~= nil and CurrentDrag ~= nil then
						CurrentDrag:SwitchMode(true)
						ReferenceModel:PivotTo(Prop:GetPivot())
						
					elseif UInput:IsKeyDown(Enum.KeyCode.LeftShift) then
						module:PlaceProp(ID)
						
						while not ReferenceModel do
							task.wait()
						end
						
						ReferenceModel:PivotTo(Prop:GetPivot())
						
						CurrentDrag:SwitchMode(true)
					end
				end
			end
		end
	end)}
end

RemovedProp.OnClientInvoke  = function(Prop:Model)
	if Props[Prop] then
		Props[Prop].Event:Disconnect()
		
		Props[Prop] = nil
		
		if table.find(Selected, Prop) then
			table.remove(Selected, table.find(Selected, Prop))
		end
	end
end

function module:GetContainerContents(Container:Model)
	local Aray = {}
	for I, item in ipairs(Container:GetChildren()) do
		if not item:IsA("Highlight") then
			Aray[item.Name] = item:GetPivot()
		end
	end
	
	return Aray
end

function module:MakePropContainer(Props:{Model})
	local Container = Instance.new("Model")


	Container.Parent = game.Workspace

	Container.Name = "Prop_Container"

	local Highlight = Instance.new("Highlight")

	Highlight.FillColor = Color3.new(0.196078, 0.196078, 0.196078)

	Highlight.OutlineColor = Color3.new(0.101961, 0.101961, 0.101961)
	task.delay(0.1, function()
		Highlight.Adornee = Container

		Highlight.Parent = Container
	end)

	for I, item in ipairs(Props) do
		local SoftCopy = item:Clone()

		SoftCopy.Parent = EventInteract:GetPlayerPropFolder()

		SoftCopy:AddTag("Soft_Copies")

		for I, item in ipairs(SoftCopy:GetDescendants()) do
			if item:IsA("BasePart") then
				item.Transparency = 0.85

				item.Color = Color3.new(0.72549, 1, 0.607843)

				item.Material = Enum.Material.SmoothPlastic

				item.CanCollide = false
			end
		end

		item.Parent = Container
	end

	local cf, size = Container:GetBoundingBox()
	local bottomY = cf.Position.Y - (size.Y / 2)
	local newPivot = CFrame.new(Vector3.new(cf.Position.X, bottomY, cf.Position.Z))
	Container.WorldPivot = newPivot

	return Container
end


function module:UnMakeContainer(Container:Model)
	for I, item in ipairs(CS:GetTagged("Soft_Copies")) do
		item:Destroy()
	end
	
	Container:WaitForChild("Highlight"):Destroy()
	
	for I, item in ipairs(Container:GetChildren()) do
		if item:IsA("Highlight") then
			item:Destroy()
		else
			item.Parent = EventInteract:GetPlayerPropFolder()
		end
	end
	
	Container:Destroy()
end

function module:BindStandardControls()
	local RanSelect = false
	
	local INDeb = false
	ControlHandler:AssignAction("INPUT", "SwitchInput", function()
		if CurrentDrag ~= nil then
			CurrentDrag:SwitchMode()
		end
	end)
	
	ControlHandler:AssignAction("INPUT", "Rotate", function()
		if CurrentDrag ~= nil then
			CurrentDrag:SwitchType("Rotate")
		end
	end)
	
	ControlHandler:AssignAction("INPUT", "Move", function()
		if CurrentDrag ~= nil then
			CurrentDrag:SwitchType("Move")
		end
	end)
	
	ControlHandler:AssignAction("INPUT", "ClearPlace", function()
		if EditingLoad == true then
			if #Selected > 0 then
				if module.OnDelete then
					module.OnDelete()
				end

				CurrentDrag:Destroy()

				ReturnClick()

				local ModelsToBreak = {}

				for I, item in ipairs(ReferenceModel:GetChildren()) do
					if item:IsA("Model") then
						table.insert(ModelsToBreak, item.Name)
					end
				end

				module:UnMakeContainer(ReferenceModel)

				for I, item in ipairs(ModelsToBreak) do
					task.spawn(function()
						EventInteract:GetEvent("DestroyProp"):InvokeServer(item)
					end)
				end
			end
			
			EditingContainer = false
			
			CurrentDrag = nil
			
			ReferenceModel = nil
			
			EditingLoad = false
			
			BlockInteract = false

			RemovedSelected = false
			
			Selected = {}
			
			RanSelect = false
		else
			if BlockInteract == true then
				if module.OnDelete then
					module.OnDelete()
				end
				RemovedSelected = true
				for I, item in ipairs(Selected) do
					task.spawn(function()
						EventInteract:GetEvent("DestroyProp"):InvokeServer(item.Name)
					end)
				end
				Selected = {}

				ReturnClick()

				for I, item in pairs(SelectionMeta) do
					item.Event:Disconnect()

					item.UI:Destroy()
				end
				EditingContainer = false

				BlockInteract = false

				RemovedSelected = false
			else
				if CurrentDrag then
					TouchModel()
					if EditingContainer == true then
						CurrentDrag:Cancel()

						if ReferenceModel then
							module:UnMakeContainer(ReferenceModel)

							ReferenceModel = nil
						end

						EditingContainer = false

						ReturnClick()
					else
						CurrentDrag:Destroy()

						if ReferenceModel then
							ReferenceModel:Destroy()

							ReferenceModel = nil
						end
					end

					CurrentDrag = nil
				end
			end
		end
	end)
	
	ControlHandler:AssignAction("INPUT", "FinalizeProp", function()
		EditingLoad = false
		if CurrentDrag then
			TouchModel()
			if module.OnPlace then
				module.OnPlace()
			end
			if EditingContainer == true then
				CurrentDrag:Destroy()
				
				local ContainerContents = module:GetContainerContents(ReferenceModel)
				
				module:UnMakeContainer(ReferenceModel)
				
				ReferenceModel = nil
				
				EventInteract:GetEvent("EditProps"):InvokeServer(ContainerContents)
				
				EditingContainer = false
				
				CurrentDrag = nil
				
				ReturnClick()
				
			else
				CurrentDrag:Destroy()
				
				EventInteract:GetEvent("PlaceProp"):InvokeServer(PropID, ReferenceModel:GetPivot())
				
				ReferenceModel:Destroy()
				
				ReferenceModel = nil
				
				CurrentDrag = nil
			end
		end
	end)
	
	ControlHandler:AssignAction("INPUT", "EditProp", function()
		if EditMode == true then
			while Selecting == true do
				task.wait()
			end

			if RemovedSelected == true then
				return
			end

			if #Selected > 0 then
				local NewClick = {}
				for I, item in pairs(SelectionMeta) do
					NewClick[I] = ClicksToReturn[I]

					ClicksToReturn[I] = nil

					item.Event:Disconnect()
					item.UI:Destroy()
				end

				ReturnClick()

				ClicksToReturn = NewClick

				local Container = module:MakePropContainer(Selected)

				local cframe, size = Container:GetBoundingBox()
				local bottomCFrame = CFrame.new(
					cframe.Position.X,
					cframe.Position.Y - size.Y / 2,
					cframe.Position.Z
				)

				Container.WorldPivot = bottomCFrame

				Selected = {}

				BlockInteract = false

				module:EditContainer(Container)
				
				RanSelect = false
			end
		end
	end)

	
	
	
	ControlHandler:AssignAction("INPUT", "Selection", function()
		if EditMode  then
			if RanSelect == true then
				ReturnClick()
				if #Selected > 0 then
					local NewClick = {}
					for I, item in pairs(SelectionMeta) do
						NewClick[I] = ClicksToReturn[I]

						ClicksToReturn[I] = nil

						item.Event:Disconnect()

						item.UI:Destroy()
					end

					ClicksToReturn = NewClick

					Selected = {}

					BlockInteract = false

				else
					for I, item in pairs(SelectionMeta) do

						ClicksToReturn[I] = nil

						item.Event:Disconnect()

						item.UI:Destroy()

						BlockInteract = false
					end
				end
			else
				if BlockMouse == true then return end
				if INDeb == true then return end

				INDeb = true
				if CurrentDrag == nil and #EventInteract:GetPlayerPropFolder():GetChildren() >0 then
					BlockInteract = true
					Selected = {}
					SelectionMeta = {}
					for I, item in pairs(Props) do
						local NewINteract = Template:Clone()

						NewINteract.Adornee = I

						NewINteract.Parent = InteractionUI

						Props[I].Dec.Parent = script

						ClicksToReturn[I] = Props[I].Dec

						SelectionMeta[I] = {
							UI = NewINteract;

							Event = NewINteract:WaitForChild("TextButton").Activated:Connect(function()
								local Index = table.find(Selected, I)

								if module.OnSelect then
									module.OnSelect()
								end

								if Index ~= nil then
									NewINteract.TextButton.BackgroundColor3 = Color3.new(1, 1, 1)
									table.remove(Selected, Index)
								else
									table.insert(Selected, I)
									NewINteract.TextButton.BackgroundColor3 = Color3.new(0, 0, 0)
								end
							end)
						}
					end
				end

				task.wait(0.2)

				INDeb = false
			end
			RanSelect = not RanSelect
		else
			for I, item in pairs(SelectionMeta) do

				ClicksToReturn[I] = nil

				item.Event:Disconnect()

				item.UI:Destroy()

				BlockInteract = false
			end
		end
	end)
	
	ControlHandler:AssignAction("INPUT", "SelectAll", function()
		Selecting = true
		if BlockInteract == true then
			if #Selected ~= #EventInteract:GetPlayerPropFolder():GetChildren() then
				Selected = {}
				for I, item in pairs(SelectionMeta) do
					table.insert(Selected, I)

					item.UI.TextButton.BackgroundColor3 = Color3.new(0, 0, 0)
				end
			else
				Selected = {}
				for I, item in pairs(SelectionMeta) do
					item.UI.TextButton.BackgroundColor3 = Color3.new(1, 1, 1)
				end
			end
		end
		
		Selecting = false
	end)
	
	DragDetector.Start(function(CurrentSelect)
		Selected = {}
		for I, item in pairs(SelectionMeta) do
			if table.find(CurrentSelect, I) then
				item.UI.TextButton.BackgroundColor3 = Color3.new(0, 0, 0)
				table.insert(Selected, I)
			else
				item.UI.TextButton.BackgroundColor3 = Color3.new(1, 1, 1)
			end
			
		end
	end, function()
		return EditMode == true and BlockMouse == false and BlockInteract == true
	end)
	
	ControlHandler:BindKeybind(Enum.KeyCode.V, "SwitchInput")
	
	ControlHandler:BindKeybind(Enum.KeyCode.R, "Rotate")
	
	ControlHandler:BindKeybind(Enum.KeyCode.T, "Move")

	ControlHandler:BindKeybind(Enum.KeyCode.X, "ClearPlace")
	
	ControlHandler:BindKeybind(Enum.KeyCode.F, "FinalizeProp")
	
	ControlHandler:BindKeybind(Enum.KeyCode.LeftAlt, "Selection")
	
	ControlHandler:BindKeybind(Enum.KeyCode.E, "EditProp")
	
	ControlHandler:BindKeybind(Enum.KeyCode.Q, "SelectAll")
	
	
	ControlHandler:BindInput()
	
	ControlHandler:BindRelease()
end

local Debounce = false

EventInteract:GetEvent("LoadNear").OnClientInvoke = function(Data:{string})
	local Models = {}
	EditingLoad = true
	local Folder = EventInteract:GetPlayerPropFolder()
	
	for I, item in ipairs(Data) do
		table.insert(Models, Folder:WaitForChild(item))
	end
	
	module:EditContainer(module:MakePropContainer(Models))
end


function module:EditContainer(Container:Model)
	if Debounce == true then return end
	if BlockInteract ~= true then
		ChangedEvent:Fire()
		Debounce = true
		if CurrentDrag == nil then
			EditingContainer = true
			ReferenceModel = Container
			UnTouchModel()
			CurrentDrag = DragHandler.New(Container, true, "Move")
			
			CurrentDrag:Set_ROT_Snap(RotSnap)

			CurrentDrag:Set_Move_Snap(MoveSnap)
		end
		
		task.wait(0.2)
		Debounce = false
	end
end


function module:PlaceProp(ID:number)
	if EditMode == false then
		if Debounce == true then return end
		if BlockInteract ~= true then
			Debounce = true
			if CurrentDrag == nil then
				ChangedEvent:Fire()
				PropID = ID
				local Model = EventInteract:StreamModel("PropPlacer_Main", ID)

				Model.Parent = game.Workspace

				ReferenceModel = Model

				UnTouchModel()

				CurrentDrag = DragHandler.New(Model)
				
				CurrentDrag:Set_ROT_Snap(RotSnap)
				
				CurrentDrag:Set_Move_Snap(MoveSnap)

			end

			task.wait(0.2)

			Debounce = false
		end
	end
end

function module:GetInfo()
	return EventInteract:GetEvent("GetInfo"):InvokeServer()
end


function module:GetInfoLight()
	return EventInteract:GetEvent("GetInfoLite"):InvokeServer()
end


function module:GetProps()
	return EventInteract:GetEvent("GetProps"):InvokeServer()
end

function module:LoadSave(Save:number, Near:boolean)
	if CurrentDrag == nil then
		return EventInteract:GetEvent("LoadProps"):InvokeServer(Save, Near)
	end
end

function module:Save(Save:number, SaveName:string)
	if CurrentDrag == nil then
		return EventInteract:GetEvent("SaveProps"):InvokeServer(Save, SaveName)
	end
end

function module:SwitchEdit()
	EditMode = not EditMode
	
	if EditMode == false then
		ControlHandler:SimulateInput(Enum.KeyCode.LeftAlt)
	end
	
	if CurrentDrag then
		ControlHandler:SimulateInput(Enum.KeyCode.X)
	end
	
	return EditMode
end

function module:RemoveAllProps()
	for I, item in pairs(Props) do
		task.spawn(function()
			EventInteract:GetEvent("DestroyProp"):InvokeServer(I.Name)
		end)
	end
end

function module:GetPropCount()
	return #EventInteract:GetPlayerPropFolder():GetChildren()
end


function module:GetFolder()
	return EventInteract:GetPlayerPropFolder()
end

function module:SetRotSnap(Level:number)
	RotSnap = Level
	
	if CurrentDrag then
		CurrentDrag:Set_ROT_Snap(RotSnap)
	end
end

function module:SetMoveSnap(Level:number)
	MoveSnap = Level

	if CurrentDrag then
		CurrentDrag:Set_Move_Snap(MoveSnap)
	end
end

function module:GetAngle()
	if CurrentDrag then
		return CurrentDrag.Orientation
	end
end

function module:SetAngle(Type:string)
	if CurrentDrag then
		ChangedEvent:Fire()
		CurrentDrag:SetMovement(Type)
	end
end


function module:SwitchBlock(Value:boolean)
	BlockMouse = Value
	if BlockMouse == true and CurrentDrag ~= nil then
		for I, item in pairs(SelectionMeta) do

			ClicksToReturn[I] = nil

			item.Event:Disconnect()

			item.UI:Destroy()

			BlockInteract = false
		end
		Selected = nil
		ControlHandler:SimulateInput(Enum.KeyCode.X)
	end
end

function module:GetPropModel(ID:number, Key:string):Model
	return EventInteract:StreamModel(Key,  ID)
end

module.Changed = ChangedEvent.Event


return module
