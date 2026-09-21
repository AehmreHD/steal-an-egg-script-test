-- // WALKSPEED POS1 SYSTEM //
-- MADE BY: Emre_31er

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local FHeld = false
local GHeld = false

local HoldDelay = 1
local RapidDelay = 0.02

local TargetWalkSpeed = 16

local Pos1Part = nil
local Teleporting = false
local WalkSpeedChangedConnection = nil

local PlayerGui = player:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WalkSpeedPos1Gui"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.fromOffset(210, 55)
MainFrame.Position = UDim2.new(0.5, -105, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = MainFrame

local Stroke = Instance.new("UIStroke")
Stroke.Thickness = 1
Stroke.Color = Color3.fromRGB(255, 255, 255)
Stroke.Transparency = 0.35
Stroke.Parent = MainFrame

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Name = "SpeedLabel"
SpeedLabel.Size = UDim2.fromScale(1, 1)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "WalkSpeed: " .. math.floor(TargetWalkSpeed)
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.TextSize = 18
SpeedLabel.Font = Enum.Font.GothamBold
SpeedLabel.Parent = MainFrame

local Dragging = false
local DragStart = nil
local StartPosition = nil
local DragInput = nil

local function UpdateSpeedLabel()
	SpeedLabel.Text = "WalkSpeed: " .. math.floor(TargetWalkSpeed)
end

MainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		Dragging = true
		DragStart = input.Position
		StartPosition = MainFrame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				Dragging = false
			end
		end)
	end
end)

MainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		DragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == DragInput and Dragging then
		local delta = input.Position - DragStart

		MainFrame.Position = UDim2.new(
			StartPosition.X.Scale,
			StartPosition.X.Offset + delta.X,
			StartPosition.Y.Scale,
			StartPosition.Y.Offset + delta.Y
		)
	end
end)

local function GetCharacter()
	return player.Character
end

local function GetHumanoid()
	local character = GetCharacter()

	if not character then
		return nil
	end

	return character:FindFirstChildOfClass("Humanoid")
end

local function GetRootPart()
	local character = GetCharacter()

	if not character then
		return nil
	end

	return character:FindFirstChild("HumanoidRootPart")
end

local function BindWalkSpeed(humanoid)
	if WalkSpeedChangedConnection then
		WalkSpeedChangedConnection:Disconnect()
		WalkSpeedChangedConnection = nil
	end

	if not humanoid then
		return
	end

	WalkSpeedChangedConnection = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
		if humanoid.WalkSpeed ~= TargetWalkSpeed then
			humanoid.WalkSpeed = TargetWalkSpeed
		end
	end)
end

local function ChangeWalkSpeed(amount)
	TargetWalkSpeed = math.max(0, TargetWalkSpeed + amount)

	local humanoid = GetHumanoid()

	if humanoid then
		humanoid.WalkSpeed = TargetWalkSpeed
	end

	UpdateSpeedLabel()

	print("Speed:", math.floor(TargetWalkSpeed))
end

local function StartF()
	if FHeld then
		return
	end

	GHeld = false
	FHeld = true

	ChangeWalkSpeed(1)

	task.spawn(function()
		task.wait(HoldDelay)

		while FHeld do
			ChangeWalkSpeed(1)
			task.wait(RapidDelay)
		end
	end)
end

local function StartG()
	if GHeld then
		return
	end

	FHeld = false
	GHeld = true

	ChangeWalkSpeed(-1)

	task.spawn(function()
		task.wait(HoldDelay)

		while GHeld do
			ChangeWalkSpeed(-1)
			task.wait(RapidDelay)
		end
	end)
end

local function CreatePos1()
	local root = GetRootPart()

	if not root then
		return
	end

	if Pos1Part then
		Pos1Part:Destroy()
		Pos1Part = nil
	end

	local part = Instance.new("Part")
	part.Name = "Pos1"
	part.Size = Vector3.new(1, 1, 1)
	part.CFrame = root.CFrame
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Transparency = 0
	part.Parent = workspace

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "Pos1Billboard"
	billboard.Size = UDim2.fromOffset(100, 40)
	billboard.StudsOffset = Vector3.new(0, 2, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = part

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = "pos1"
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextStrokeTransparency = 0
	label.TextSize = 18
	label.Font = Enum.Font.GothamBold
	label.Parent = billboard

	Pos1Part = part

	print("Pos1 created:", part.Position)
end

local function DeletePos1()
	if Pos1Part then
		Pos1Part:Destroy()
		Pos1Part = nil

		print("Pos1 deleted")
	end
end

local function TeleportToPos1()
	if Teleporting then
		return
	end

	if not Pos1Part or not Pos1Part.Parent then
		print("Pos1 does not exist")
		return
	end

	local character = GetCharacter()
	local root = GetRootPart()

	if not character or not root then
		return
	end

	local targetCFrame = Pos1Part.CFrame
	local oldPos = root.CFrame

	Teleporting = true

	print("Old position saved:", oldPos.Position)

	root.CFrame = targetCFrame

	print("Teleported to Pos1")

	task.wait(1)

	if player.Character == character then
		root = GetRootPart()

		if root then
			root.CFrame = oldPos
			print("Returned to old position:", oldPos.Position)
		end
	end

	Teleporting = false
end

local humanoid = GetHumanoid()

if humanoid then
	TargetWalkSpeed = humanoid.WalkSpeed
	BindWalkSpeed(humanoid)
end

UpdateSpeedLabel()

print("Speed:", math.floor(TargetWalkSpeed))

RunService.RenderStepped:Connect(function()
	local currentHumanoid = GetHumanoid()

	if currentHumanoid and currentHumanoid.WalkSpeed ~= TargetWalkSpeed then
		currentHumanoid.WalkSpeed = TargetWalkSpeed
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.F then
		StartF()
	elseif input.KeyCode == Enum.KeyCode.G then
		StartG()
	elseif input.KeyCode == Enum.KeyCode.Z then
		CreatePos1()
	elseif input.KeyCode == Enum.KeyCode.J then
		task.spawn(TeleportToPos1)
	elseif input.KeyCode == Enum.KeyCode.V then
		DeletePos1()
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.F then
		FHeld = false
	elseif input.KeyCode == Enum.KeyCode.G then
		GHeld = false
	end
end)

player.CharacterAdded:Connect(function(character)
	local newHumanoid = character:WaitForChild("Humanoid")

	newHumanoid.WalkSpeed = TargetWalkSpeed

	BindWalkSpeed(newHumanoid)
	UpdateSpeedLabel()

	print("Speed:", math.floor(TargetWalkSpeed))
end)
