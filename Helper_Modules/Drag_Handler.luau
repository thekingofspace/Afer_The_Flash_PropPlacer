local module = {}

export type EditorController = {
	Events: {any},
	Pivot: CFrame,
	Mode: "Move" | "Rotate",
	SnapLevel: number,
	RotSnap: number,
	OriginalPivot: CFrame,
	Manual: boolean,
	Orientation:"Local" | "Global";

	-- Methods
	SwitchMode: (self: EditorController, Manual:boolean) -> (),
	SwitchType: (self: EditorController, Mode:"Move" |"Rotate") -> (),
	Set_ROT_Snap: (self: EditorController, Snap_Level: number) -> (),
	Set_Move_Snap: (self: EditorController, Snap_Level: number) -> (),
	Cancel: (self: EditorController) -> (),
	Destroy: (self: EditorController) -> any,

	__index: any
}

local ArrowUI = Instance.new("ScreenGui")

ArrowUI.ResetOnSpawn = false

ArrowUI.Parent = game.Players.LocalPlayer.PlayerGui

ArrowUI.Name = "DragArrows"

local CS = game:GetService("CollectionService")

local mouse = game.Players.LocalPlayer:GetMouse()

local function AdjustLocal(self, Model: Model, TargetPart: Part)
	local centerCFrame, _ = Model:GetBoundingBox()
	if self.Orientation == "Local" then
		TargetPart.CFrame = centerCFrame
	else
		TargetPart.CFrame = CFrame.new(centerCFrame.Position) 
	end
end


local Colors = {
	[Enum.NormalId.Top] = Color3.new(0.223529, 1, 0.0470588);

	[Enum.NormalId.Bottom] = Color3.new(0.223529, 1, 0.0470588);

	[Enum.NormalId.Right] = Color3.new(0.239216, 0.352941, 1);

	[Enum.NormalId.Left] = Color3.new(0.239216, 0.352941, 1);

	[Enum.NormalId.Front] = Color3.new(1, 0.215686, 0.227451);

	[Enum.NormalId.Back] = Color3.new(1, 0.215686, 0.227451);
}

local function SnapCFrame(cf: CFrame, SnapSize: number): CFrame
	if SnapSize <= 0 then
		return cf
	end

	local pos = cf.Position
	local snappedPos = Vector3.new(
		math.round(pos.X / SnapSize) * SnapSize,
		math.round(pos.Y / SnapSize) * SnapSize,
		math.round(pos.Z / SnapSize) * SnapSize
	)

	return CFrame.new(snappedPos) * CFrame.new(cf.Position):ToObjectSpace(cf)
end

local function SnapAngle(angle: number, snapIncrement: number): number
	if snapIncrement <= 0 then return angle end
	return math.floor((angle + snapIncrement / 2) / snapIncrement) * snapIncrement
end

local function SnapRotation(cf: CFrame, snapIncrement: number): CFrame
	local _, _, _, r00, r01, r02, r10, r11, r12, r20, r21, r22 = cf:components()

	local sx, sy, sz = cf:ToOrientation()

	local x = math.deg(sx)
	local y = math.deg(sy)
	local z = math.deg(sz)

	x = SnapAngle(x, snapIncrement)
	y = SnapAngle(y, snapIncrement)
	z = SnapAngle(z, snapIncrement)

	return CFrame.new(cf.Position) * CFrame.Angles(math.rad(x), math.rad(y), math.rad(z))
end

local function MakeArrow(Part:BasePart)
	local HandleThings = {}


	for I, item in ipairs(Enum.NormalId:GetEnumItems()) do
		local Handle = Instance.new("Handles")

		Handle.Color3 = Colors[item] or Color3.new(1, 1, 1)

		Handle.Faces = Faces.new(item)

		Handle.Adornee = Part

		Handle.Style = Enum.HandlesStyle.Movement

		Handle.Parent = ArrowUI

		HandleThings[item] = Handle

		Handle:AddTag("P_PLacer_Handle")
	end

	return HandleThings
end

local function GetAllCharacterModels()
	local ignoreList = {}
	for _, plr in ipairs(game.Players:GetPlayers()) do
		if plr.Character then
			table.insert(ignoreList, plr.Character)
		end
	end
	return ignoreList
end

local function HandeMove(self, Model:Model, TargetPart:Part)
	local MAX_MOVE_DISTANCE = 60

	local function HandleMove(FaceID: Enum.NormalId, Distance: number)
		Distance = math.clamp(Distance, -MAX_MOVE_DISTANCE, MAX_MOVE_DISTANCE)

		local MoveVectors = {
			[Enum.NormalId.Top] = Vector3.new(0, Distance, 0),
			[Enum.NormalId.Bottom] = Vector3.new(0, -Distance, 0),
			[Enum.NormalId.Left] = Vector3.new(-Distance, 0, 0),
			[Enum.NormalId.Right] = Vector3.new(Distance, 0, 0),
			[Enum.NormalId.Back] = Vector3.new(0, 0, Distance),
			[Enum.NormalId.Front] = Vector3.new(0, 0, -Distance),
		}

		local currentPivot = self.Pivot

		if MoveVectors[FaceID] then
			local moveVector = MoveVectors[FaceID]

			if self.Orientation == "Local" then
				-- Move relative to current rotation
				Model:PivotTo(SnapCFrame(currentPivot * CFrame.new(moveVector), self.SnapLevel))
			else
				-- Move relative to world axes WITHOUT changing rotation
				local newPosition = currentPivot.Position + moveVector
				local newCFrame = CFrame.fromMatrix(
					newPosition,
					currentPivot.RightVector,
					currentPivot.UpVector
				)
				Model:PivotTo(SnapCFrame(newCFrame, self.SnapLevel))
			end
		end
	end

	local function TogglePivot()
		AdjustLocal(self, Model, TargetPart)
		self.Pivot = Model:GetPivot()
	end

	for I, item in pairs(MakeArrow(TargetPart)) do
		table.insert(self.Events, item.MouseButton1Up:Connect(TogglePivot))
		table.insert(self.Events, item.MouseButton1Down:Connect(TogglePivot))
		table.insert(self.Events, item.MouseDrag:Connect(HandleMove))
	end
end


local function BeginFollowRotateY(self, Model: Model)
	local UserInputService = game:GetService("UserInputService")
	local RunService = game:GetService("RunService")

	local lastMouseX
	local currentAngle = 0

	table.insert(self.Events, RunService.RenderStepped:Connect(function()
		local mouseX = UserInputService:GetMouseLocation().X

		if lastMouseX then
			local deltaX = mouseX - lastMouseX
			currentAngle = currentAngle - math.rad(deltaX * 0.2) 

			local newCFrame = self.Pivot * CFrame.Angles(0, -currentAngle, 0)
			Model:PivotTo(SnapRotation(newCFrame, self.RotSnap))
		end

		lastMouseX = mouseX
	end))
end

local function RaycastFromMouse(maxDistance, Model)
	local camera = workspace.CurrentCamera
	local unitRay = camera:ScreenPointToRay(mouse.X, mouse.Y)

	local origin = unitRay.Origin
	local direction = unitRay.Direction * (maxDistance or 1000)

	local List = GetAllCharacterModels()

	table.insert(List, Model)

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = List
	raycastParams.IgnoreWater = true
	raycastParams.RespectCanCollide = true

	local result = workspace:Raycast(origin, direction, raycastParams)
	return result
end

local function BeginFollow(self, Model: Model)
	table.insert(self.Events, game:GetService("RunService").RenderStepped:Connect(function()
		local Ray: RaycastResult = RaycastFromMouse(1000, Model)
		if Ray then
			local currentRotation = Model:GetPivot() - Model:GetPivot().Position

			local newCFrame = CFrame.new(Ray.Position) * currentRotation

			Model:PivotTo(SnapCFrame(newCFrame, self.SnapLevel))
		end
	end))
end

local function ClearOverrides(self)
	for I, item:RBXScriptConnection in ipairs(self.Events) do
		item:Disconnect()
	end
	
	for I, item in ipairs(CS:GetTagged("P_PLacer_Handle")) do
		item:Destroy()
	end
end

local function BindRotation(self, Model:Model, TargetPart)
	local function HandleMove(Axis: Enum.Axis, RelativeAngle: number, DeltaRadius: number)
		local angleDegrees = math.deg(RelativeAngle)
		local snappedDegrees = SnapAngle(angleDegrees, self.RotSnap)
		local snappedRadians = math.rad(snappedDegrees)

		local pos = self.Pivot.Position

		if self.Orientation == "Local" then
			if Axis == Enum.Axis.X then
				Model:PivotTo(self.Pivot * CFrame.Angles(snappedRadians, 0, 0))
			elseif Axis == Enum.Axis.Y then
				Model:PivotTo(self.Pivot * CFrame.Angles(0, snappedRadians, 0))
			elseif Axis == Enum.Axis.Z then
				Model:PivotTo(self.Pivot * CFrame.Angles(0, 0, snappedRadians))
			end
		else
			local pivotNoRotation = CFrame.new(pos)

			local rotation
			if Axis == Enum.Axis.X then
				rotation = CFrame.Angles(snappedRadians, 0, 0)
			elseif Axis == Enum.Axis.Y then
				rotation = CFrame.Angles(0, snappedRadians, 0)
			elseif Axis == Enum.Axis.Z then
				rotation = CFrame.Angles(0, 0, snappedRadians)
			end

			local currentRotation = self.Pivot - pos
			local newCFrame = pivotNoRotation * rotation * currentRotation
			Model:PivotTo(newCFrame)
		end
	end

	for _, item in ipairs(CS:GetTagged("P_PLacer_Handle")) do
		item:Destroy()
	end

	local function TogglePivot()
		AdjustLocal(self, Model, TargetPart)
		self.Pivot = Model:GetPivot()
	end

	local Rot = Instance.new("ArcHandles")
	Rot.Adornee = TargetPart
	Rot.Parent = ArrowUI
	CS:AddTag(Rot, "P_PLacer_Handle")

	table.insert(self.Events, Rot.MouseButton1Up:Connect(TogglePivot))
	table.insert(self.Events, Rot.MouseButton1Down:Connect(TogglePivot))
	table.insert(self.Events, Rot.MouseDrag:Connect(HandleMove))
end


function module.New(Model: Model, ForceManual:boolean, ForceMode:string)
	local self = setmetatable({}, {})

	self.Events = {}
	self.Pivot = Model:GetPivot()
	self.Mode = ForceMode or "Move"
	self.SnapLevel = 0
	self.RotSnap = 0
	self.OriginalPivot = Model:GetPivot()
	self.Orientation = "Local"
	self.Manual = false
	
	if ForceManual == true then
		self.Manual = true
	end

	local cf = Model:GetBoundingBox()

	local Hitbox = Instance.new("Part")
	Hitbox.Name = "HitBox"
	Hitbox.Anchored = true
	Hitbox.CanCollide = false
	Hitbox.Transparency = 1
	Hitbox.Size = Model:GetExtentsSize()
	Hitbox.CFrame = cf
	Hitbox.Parent = Model
	
	local function StartMove()
		ClearOverrides(self)
		self.Pivot = Model:GetPivot()
		if self.Manual == true then
			HandeMove(self, Model, Hitbox)
		else
			BeginFollow(self, Model)
		end
	end

	local function StartRot()
		ClearOverrides(self)
		self.Pivot = Model:GetPivot()
		if self.Manual == true then
			BindRotation(self, Model, Hitbox)
		else
			BeginFollowRotateY(self, Model)
		end
	end
	
	function self:SwitchMode(Manual:boolean)
		if Manual == nil then
			self.Manual = not self.Manual
		else
			self.Manual = Manual
		end
		
		if self.Mode == "Move" then
			StartMove()
		else
			StartRot()
		end
	end
	
	function self:SetMovement(Type:"Global" | "Local")
		self.Orientation = Type
		
		AdjustLocal(self, Model, Hitbox)
	end
	
	function self:SwitchType(Mode:"Move" |"Rotate")
		if Mode ==  nil then
			if self.Mode == "Move" then
				self.Mode = "Rotate"
				StartRot()
			else
				self.Mode = "Move"
				StartMove()
			end
			
		else
			self.Mode = Mode
			
			if self.Mode == "Move" then
				StartMove()
			else
				StartRot()
			end
		end
	end
	
	function self:Set_ROT_Snap(Snap_Level:number)
		self.RotSnap = Snap_Level
	end
	
	function self:Set_Move_Snap(Snap_Level:number)
		self.SnapLevel = Snap_Level
	end
	
	function self:Cancel()
		Model:PivotTo(self.OriginalPivot)
		
		self:Destroy()
	end
	
	function self:Destroy()
		ClearOverrides(self)
		
		self = nil
		
		Hitbox:Destroy()
		
		Hitbox = nil
		
		cf = nil
		
		return self
	end

	StartMove()

	self.__index = self
	return self
end


return module
