local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEventsFolder = ReplicatedStorage:WaitForChild("AdminRemoteEvents")

local OpenUIEvent = RemoteEventsFolder:WaitForChild("OpenPlrAdminGui")

local DragModule = require(script:WaitForChild("DragModule"))

local Gui = script.Parent
local MainFrame = Gui:WaitForChild("MainFrame")

local GuiContainer = Gui.Parent

local CloseButton = MainFrame:WaitForChild("CloseButton")

local IgnoreObjects = {}

local CurrentDraggable
local DragConnection

local function SendGuiToFront()
	for i, OtherGui in ipairs(GuiContainer:GetChildren()) do
		if OtherGui:IsA("ScreenGui") and OtherGui ~= Gui then
			OtherGui.DisplayOrder = 10
		else
			Gui.DisplayOrder = 11
		end
	end		
end

local function OpenUI()
	Gui.Enabled = true
	
	local OriginalParent = Gui.Parent
	
	if not CurrentDraggable then
		CurrentDraggable = DragModule.new(MainFrame)
		
		-- Send GUI to front
		CurrentDraggable.DragStarted = SendGuiToFront
		MainFrame.InputBegan:Connect(function(Input, GPE)
			if not GPE and Input.UserInputType == Enum.UserInputType.MouseButton1 or 
				Input.UserInputType == Enum.UserInputType.Touch then
				SendGuiToFront()
			end
		end)
		
	end
	
	CurrentDraggable:Enable()
	
	SendGuiToFront()
end

-- Main

-- Set ignored objects for UI
for i, Object in pairs(MainFrame:GetDescendants()) do
	if Object:IsA("TextBox") or Object:IsA("GuiButton") or Object:IsA("ScrollingFrame") then
		table.insert(IgnoreObjects, Object)
	end
end

-- Close
CloseButton.MouseButton1Click:Connect(function()
	Gui.Enabled = false
	CurrentDraggable:Disable()
	
	-- Remove DepthOfField effect if all widgets are closed
	for i, OtherGui in pairs(GuiContainer:GetChildren()) do
		if OtherGui.Enabled then
			return
		end
	end
	
	local AdminUIBlur = workspace.CurrentCamera:FindFirstChild("_AdminUIBlur")
	if AdminUIBlur then
		AdminUIBlur.Enabled = false
	end
end)

OpenUI()

OpenUIEvent.OnClientEvent:Connect(function(GuiName)
	if Gui.Name == GuiName then
		OpenUI()
	end
end)
