local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlr = Players.LocalPlayer

local EventsFolder = ReplicatedStorage:WaitForChild("AdminRemoteEvents")
local SendCommandEvent = EventsFolder:WaitForChild("SendAdminCommand")

local Gui = script.Parent
local MainFrame = Gui:WaitForChild("MainFrame")

local OriginalWidth = MainFrame.Size.X.Offset

local SpectateInterface = MainFrame:WaitForChild("SpectateInterface")

local FreecamController = require(script:WaitForChild("FreecamModule")) -- Made by @elite_hunter11

local NextButton = SpectateInterface:WaitForChild("NextButton")
local PrevButton = SpectateInterface:WaitForChild("PrevButton")
local FreeCamButton = MainFrame:WaitForChild("FreeCamButton")

local CanTp = true
local TpCooldown = 1

local CurrentPlayer = Gui:WaitForChild("CurrentPlayer")
local CurrentIndex = 1

local PlayersList = Players:GetPlayers()

local HealthConnection

local IsUsingFreecam = false

local function UpdateSpectating(Player, Humanoid)
	if HealthConnection then
		HealthConnection:Disconnect()
	end
	
	local function SetHealthbar()
		local HealthPercentage = Humanoid.Health / Humanoid.MaxHealth
		
		local Colour
		
		if HealthPercentage > 0.75 then
			Colour = Color3.new(0, 1)
		elseif HealthPercentage > 0.5 then
			Colour = Color3.new(0.5, 1)
		elseif HealthPercentage > 0.25 then
			Colour = Color3.new(1, 1)
		else
			Colour = Color3.new(1, 0)
		end
		
		SpectateInterface.Healthbar.Bar.Size = UDim2.fromScale(HealthPercentage, 1)
		SpectateInterface.Healthbar.Bar.BackgroundColor3 = Colour
		SpectateInterface.HealthText.Text = "Health: " .. math.ceil(Humanoid.Health) .. " / " .. math.ceil(Humanoid.MaxHealth)
	end
	
	SpectateInterface.UsernameText.Text = Player.Name
	
	if Player.Team then
		SpectateInterface.UsernameText.TextColor3 = Player.TeamColor.Color
	end
	
	if Humanoid then
		SetHealthbar()
		HealthConnection = Humanoid:GetPropertyChangedSignal("Health"):Connect(SetHealthbar)
	end
	
	workspace.CurrentCamera.CameraSubject = Humanoid
end

local function ChangeToPlayer(Direction)
	CurrentIndex += Direction
	
	-- Ensure we never go outside the list
	if CurrentIndex > #PlayersList then
		CurrentIndex = 1
	elseif CurrentIndex < 1 then
		CurrentIndex = #PlayersList
	end
	
	if Direction ~= 0 then
		CurrentPlayer.Value = PlayersList[CurrentIndex]
	end
	
	local SelectPlayer = CurrentPlayer.Value
	
	if SelectPlayer then
		local Character = SelectPlayer.Character
		if Character then
			local Humanoid = Character:FindFirstChild("Humanoid")
			if Humanoid then
				UpdateSpectating(SelectPlayer, Humanoid)
			elseif LocalPlr.Character then
				local LocalHum = LocalPlr.Character:FindFirstChild("Humanoid")
				UpdateSpectating(LocalPlr, LocalHum)
			end
		end
	end
end

local function ToggleFreecam()
	IsUsingFreecam = not IsUsingFreecam
	
	if IsUsingFreecam then
		FreecamController:EnableFreecam()
		MainFrame.Size = UDim2.fromOffset(OriginalWidth, 55)
		FreeCamButton.Text = "Exit Freecam"
	else
		FreecamController:StopFreecam()
		MainFrame.Size = UDim2.fromOffset(OriginalWidth, 125)
		FreeCamButton.Text = "Enter Freecam"
	end
	
	SpectateInterface.Visible = not IsUsingFreecam
end

local function MenuClosed()
	local LocalHum = LocalPlr.Character:FindFirstChild("Humanoid")
	UpdateSpectating(LocalPlr, LocalHum)

	if HealthConnection then
		HealthConnection:Disconnect()
	end

	if IsUsingFreecam then
		ToggleFreecam()
	end
end

NextButton.MouseButton1Click:Connect(function()
	ChangeToPlayer(1)
end)

PrevButton.MouseButton1Click:Connect(function()
	ChangeToPlayer(-1)
end)

-- Exit
MainFrame.CloseButton.MouseButton1Click:Connect(MenuClosed)

MainFrame.FreeCamButton.MouseButton1Click:Connect(ToggleFreecam)

Players.PlayerAdded:Connect(function(Plr)
	table.insert(PlayersList, Plr)
end)

Players.PlayerRemoving:Connect(function(Plr)
	local Index = table.find(PlayersList, Plr)
	if Index then
		table.remove(PlayersList, Index)
	end
end)

ChangeToPlayer(0)

Gui:GetPropertyChangedSignal("Enabled"):Connect(function()
	if Gui.Enabled then
		ChangeToPlayer(0)
	end
end)