local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Mouse = Players.LocalPlayer:GetMouse()

local FunctionsFolder = ReplicatedStorage:WaitForChild("AdminRemoteFunctions")

local GetCommandsList = FunctionsFolder:WaitForChild("GetCommandsList")

local Gui = script.Parent
local MainFrame = Gui:WaitForChild("MainFrame")
local ListFrame = MainFrame:WaitForChild("CommandsList")

local HoverLabel = Gui:WaitForChild("MouseText")

local ToggleHiddenButton = MainFrame:WaitForChild("ToggleHiddenButton")

local ShowHidden = false

-- Main

local HidableCommandFrames = {}

local CommandTemplateFrame = ListFrame:WaitForChild("TemplateFrame"):Clone()

local CommandsList = GetCommandsList:InvokeServer()

local function HoverText()
	local GuiObjects = Players.LocalPlayer.PlayerGui:GetGuiObjectsAtPosition(Mouse.X, Mouse.Y)
	
	for i, Frame in pairs(GuiObjects) do
		if Frame.Name == "Title" and Frame.Parent.Parent == ListFrame then
			local HoverText = Frame.Parent:FindFirstChild("HoverText")
			if HoverText and HoverText.Value ~= "none" then
				HoverLabel.Text = HoverText.Value
				HoverLabel.Visible = true
				HoverLabel.Position = UDim2.fromOffset(Mouse.X + 12, Mouse.Y + 12)
				return
			end
		end
	end
	
	HoverLabel.Visible = false
end

local function PolulateList(SearchTerm: string?)
	for i, Command in pairs(CommandsList) do
		local CanShow = false
		-- Search name checking
		if SearchTerm then
			if string.match(Command.Description:lower(), SearchTerm:lower()) then
				CanShow = true
			end
			for i, Name in pairs(Command.Names) do
				if string.match(Name, SearchTerm:lower()) then
					CanShow = true
					break
				end
			end
		else
			CanShow = true
		end
		
		if not CanShow then continue end
		
		local NewCommandInfoFrame = CommandTemplateFrame:Clone()

		-- Set command title/names
		local Title = "> "

		for i, Name in pairs(Command.Names) do
			Title = Title .. Name
			if i ~= #Command.Names then
				Title = Title .. " / "
			end
		end

		if type(Command.IsRankedHighEnough) == "string" and Command.IsRankedHighEnough ~= "yes" then
			NewCommandInfoFrame.Title.TextColor3 = Color3.new(0.5, 0.5, 0.5)
			NewCommandInfoFrame.Description.TextColor3 = Color3.new(0.5, 0.5, 0.5)
			NewCommandInfoFrame.NotRankedText.Text = "Requires " .. Command.IsRankedHighEnough
			NewCommandInfoFrame.NotRankedText.Visible = true
			NewCommandInfoFrame.Visible = ShowHidden

			table.insert(HidableCommandFrames, NewCommandInfoFrame)
		end

		NewCommandInfoFrame.Title.Text = Title
		NewCommandInfoFrame.Description.Text = Command.Description
		
		NewCommandInfoFrame.HoverText.Value = Command.MouseHoverText

		NewCommandInfoFrame.Parent = ListFrame
	end
end

local function SearchBoxChanged()
	for i, OldFrame in ipairs(MainFrame.CommandsList:GetChildren()) do
		if OldFrame:IsA("Frame") then
			OldFrame:Destroy()
		end
	end
	
	PolulateList(MainFrame.SearchBox.Text)
end

ToggleHiddenButton.MouseButton1Click:Connect(function()
	ShowHidden = not ShowHidden
	
	if ShowHidden then
		ToggleHiddenButton.Text = "Hide unavailable"
	else
		ToggleHiddenButton.Text = "Show unavailable"
	end
	
	for i, Frame in pairs(HidableCommandFrames) do
		Frame.Visible = ShowHidden
	end
end)

local MouseConnection = Mouse.Move:Connect(HoverText)

Gui:GetPropertyChangedSignal("Enabled"):Connect(function()
	if Gui.Enabled then
		MainFrame.SearchBox.Text = ""
		PolulateList()
		MouseConnection = Mouse.Move:Connect(HoverText)
	else
		for i, OldFrame in ipairs(MainFrame.CommandsList:GetChildren()) do
			if OldFrame:IsA("Frame") then
				OldFrame:Destroy()
			end
		end
		
		if MouseConnection then
			MouseConnection:Disconnect()
		end
	end
end)

MainFrame.SearchBox:GetPropertyChangedSignal("Text"):Connect(SearchBoxChanged)

ListFrame.TemplateFrame:Destroy()

PolulateList()