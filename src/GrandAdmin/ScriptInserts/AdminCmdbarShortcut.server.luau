local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Events = ReplicatedStorage:WaitForChild("AdminRemoteEvents")
local Functions = ReplicatedStorage:WaitForChild("AdminRemoteFunctions")

local SendCommandEvent = Events:WaitForChild("SendAdminCommand")

local Keybind = Functions:WaitForChild("GetCmdbarShortcut"):InvokeServer()

if not Keybind then return end

local Debounce = false

local function FocusCmdbarTextbox()
	local PlrGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
	if PlrGui and PlrGui:FindFirstChild("AdminGUIs") then
		local CmdBar = PlrGui.AdminGUIs:FindFirstChild("CommandBarGui")
		if CmdBar and CmdBar.Enabled then
			task.wait(0.03) -- Delay due to a weird issue of typing ';' into the chat
			CmdBar.MainFrame.MainTextBox:CaptureFocus()
			return true
		end
	end
end

UserInputService.InputBegan:Connect(function(Input, Processed)
	if not Processed and Input.KeyCode == Keybind and not Debounce then
		Debounce = true
		
		if not FocusCmdbarTextbox() then
			SendCommandEvent:FireServer("commandbar")
		end
		
		-- Spamming might put a little bit of stress on the server
		task.wait(1)
		Debounce = false
	end
end)