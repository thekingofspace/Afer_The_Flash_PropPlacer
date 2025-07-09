local DragSelector = {}

local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DragSelectorGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local selected = {}

local function clearHighlights()
	selected = {}
end

function DragSelector.Start(Callback:(Selected:{Model}) -> nil, CheckCode:() -> boolean)
	local function startDrag()
		if not UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then return end
		if CheckCode() == false then  return end

		clearHighlights()

		local frame = Instance.new("Frame")
		local uiStroke = Instance.new("UIStroke")

		frame.Parent = screenGui
		frame.BackgroundTransparency = 0.6
		frame.BackgroundColor3  = Color3.new(0.156863, 0.156863, 0.156863)
		frame.BorderSizePixel = 0
		frame.Position = UDim2.new(0, mouse.X, 0, mouse.Y)
		frame.Size = UDim2.new(0, 0, 0, 0)

		uiStroke.Parent = frame
		uiStroke.Thickness = 2
		uiStroke.Transparency = 0.2
		uiStroke.Color = Color3.fromRGB(36, 36, 36)
		uiStroke.LineJoinMode = Enum.LineJoinMode.Miter

		local startX, startY = mouse.X, mouse.Y

		local function update()
			selected = {}

			local currentX, currentY = mouse.X, mouse.Y
			local width = math.abs(currentX - startX)
			local height = math.abs(currentY - startY)
			local posX = math.min(startX, currentX)
			local posY = math.min(startY, currentY)

			frame.Position = UDim2.new(0, posX, 0, posY)
			frame.Size = UDim2.new(0, width, 0, height)

			clearHighlights()
			for _, model in pairs(CollectionService:GetTagged("Selectable")) do
				if model:IsA("Model") and model.PrimaryPart then
					local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(model.PrimaryPart.Position)
					if onScreen and
						screenPos.X >= posX and screenPos.X <= posX + width and
						screenPos.Y >= posY and screenPos.Y <= posY + height
					then
						table.insert(selected, model)
					end
				end
			end
			Callback(selected)
		end

		local moveConnection
		moveConnection = UserInputService.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				update()
			end
		end)

		local releaseConnection
		releaseConnection = UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				moveConnection:Disconnect()
				releaseConnection:Disconnect()
				frame:Destroy()
			end
		end)
	end

	mouse.Button1Down:Connect(startDrag)

	UserInputService.InputBegan:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
			clearHighlights()
		end
	end)
end

return DragSelector
