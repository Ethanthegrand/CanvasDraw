local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local FunctionsFolder = ReplicatedStorage:WaitForChild("AdminRemoteFunctions")

local GetCommandsLogFunction = FunctionsFolder:WaitForChild("GetCommandsLog")

local Gui = script.Parent
local MainFrame = Gui:WaitForChild("MainFrame")
local ListFrame = MainFrame:WaitForChild("ObjectsList")
local NavigatorFrame = MainFrame:WaitForChild("NavigatorFrame")

local CanRefresh = true
local RefreshCooldown = 0

local FastWaitCount = 0

local PageSize = 100

-- Main

local MaxPages = 1
local CurrentPage = 1

local LoggedCommandTemplateFrame = ListFrame:WaitForChild("TemplateFrame"):Clone()

local function FastWait(Amount)
	if FastWaitCount >= Amount then
		FastWaitCount = 0
		RunService.Heartbeat:Wait()
	else
		FastWaitCount += 1
	end
end

local function FormatAge(Age)
	local AgeThresholds = {
		{Threshold = 60, Unit = "second"},
		{Threshold = 3600, Unit = "minute"},
		{Threshold = 86400, Unit = "hour"},
		{Threshold = 604800, Unit = "day"},
		{Threshold = 2.628e+6, Unit = "week"},
		{Threshold = 3.154e+7, Unit = "month"},
		{Threshold = math.huge, Unit = "year"}
	}

	for i, v in ipairs(AgeThresholds) do
		if Age < v.Threshold then
			local Divisor = AgeThresholds[i - 1] and AgeThresholds[i - 1].Threshold or 1
			local Value = Age // Divisor
			return string.format("%d %ss", Value, v.Unit)
		end
	end

	return Age
end

local function SetupList(SearchTerm: string?)
	if CanRefresh then
		CanRefresh = false

		-- Just in case
		for i, OldFrame in ipairs(MainFrame.ObjectsList:GetChildren()) do
			if OldFrame:IsA("Frame") then
				OldFrame:Destroy()
			end
		end

		MainFrame.RefreshButton.TextTransparency = 0.5

		-- Get the ban list data
		local ChatList = GetCommandsLogFunction:InvokeServer()

		if ChatList then
			MaxPages = math.max(1, math.ceil(#ChatList / PageSize))
			NavigatorFrame.PageCount.Text = CurrentPage .. " / " .. MaxPages

			-- Create a list in the gui and set the text from the commands list
			for i = 1, PageSize do
				local Log = ChatList[i + ((CurrentPage - 1) * PageSize)]

				if not Log then break end -- We've ran out of logs

				-- Create the command info frame
				local NewFrame = LoggedCommandTemplateFrame:Clone()			

				NewFrame.UsernameText.Text = Log.Username
				NewFrame.CommandText.Text = Log.Message
				NewFrame.TimeText.Text = FormatAge(os.time() - Log.Date) .. " ago"

				NewFrame.Name = Log.Username .. " " .. Log.Message

				NewFrame.Visible = not SearchTerm or string.match(NewFrame.Name:lower(), SearchTerm:lower())

				NewFrame.Parent = ListFrame

				FastWait(10)
			end
		end

		task.wait(RefreshCooldown)

		MainFrame.RefreshButton.TextTransparency = 0

		CanRefresh = true
	end
end

local function AdvancePage(Amount)
	CurrentPage = math.clamp(CurrentPage + Amount, 1, MaxPages)
	SetupList(MainFrame.SearchBox.Text)
end

MainFrame.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
	local SearchTerm = MainFrame.SearchBox.Text

	for i, Item in pairs(ListFrame:GetChildren()) do
		if Item:IsA("Frame") then
			Item.Visible = not SearchTerm or string.match(Item.Name:lower(), SearchTerm:lower())
		end
	end
end)

Gui:GetPropertyChangedSignal("Enabled"):Connect(function()
	if Gui.Enabled then
		MainFrame.SearchBox.Text = ""
		SetupList()
	else
		for i, OldFrame in ipairs(MainFrame.ObjectsList:GetChildren()) do
			if OldFrame:IsA("Frame") then
				OldFrame:Destroy()
			end
		end
	end
end)

MainFrame.RefreshButton.MouseButton1Click:Connect(function()
	CurrentPage = 1
	SetupList(MainFrame.SearchBox.Text)
end)

NavigatorFrame.RightButton.MouseButton1Click:Connect(function()
	AdvancePage(1)
end)

NavigatorFrame.LeftButton.MouseButton1Click:Connect(function()
	AdvancePage(-1)
end)

NavigatorFrame.FirstPageButton.MouseButton1Click:Connect(function()
	AdvancePage(-MaxPages)
end)

NavigatorFrame.LastPageButton.MouseButton1Click:Connect(function()
	AdvancePage(MaxPages)
end)

ListFrame.TemplateFrame:Destroy()

SetupList()