local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EventsFolder = ReplicatedStorage:WaitForChild("AdminRemoteEvents")

local SendCommandEvent = EventsFolder:WaitForChild("SendAdminCommand")

local Gui = script.Parent
local MainFrame = Gui:WaitForChild("MainFrame")

local Textbox = MainFrame:WaitForChild("MainTextBox")
local SendButton = MainFrame:WaitForChild("ExecuteButton")

local CharacterLimit = 128 -- Should be equal or less than the roblox chat limit


-- Main

local function SendCommand()
	local Text = Textbox.Text
	local Command
	
	if not string.match(string.sub(Text, 1, 1), "%w") then -- Remove any prefixes
		Command = string.sub(Text, 2, #Text)
	else
		Command = Text
	end

	SendCommandEvent:FireServer(Command)
end

-- Connections
SendButton.MouseButton1Click:Connect(SendCommand)

Gui:GetPropertyChangedSignal("Enabled"):Connect(function()
	if Gui.Enabled then
		Textbox:CaptureFocus()
	end
end)

Textbox.FocusLost:Connect(function(EnterPressed)
	if EnterPressed then
		SendCommand()
	end
end)

Textbox:GetPropertyChangedSignal("Text"):Connect(function()
	local Text = Textbox.Text
	
	if #Text > CharacterLimit then
		Textbox.Text = string.sub(Text, 1, CharacterLimit)
	end
end)