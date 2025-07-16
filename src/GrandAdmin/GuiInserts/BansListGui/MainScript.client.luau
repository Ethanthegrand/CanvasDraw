local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local FunctionsFolder = ReplicatedStorage:WaitForChild("AdminRemoteFunctions")
local EventsFolder = ReplicatedStorage:WaitForChild("AdminRemoteEvents")

local GetBansListFunction = FunctionsFolder:WaitForChild("GetBannedPlrsList")
local SendCommandEvent = EventsFolder:WaitForChild("SendAdminCommand")

local Gui = script.Parent
local MainFrame = Gui:WaitForChild("MainFrame")
local ListFrame = MainFrame:WaitForChild("ObjectsList")
local NavigatorFrame = MainFrame:WaitForChild("NavigatorFrame")

local PageSize = 64

-- Main

local CanRefresh = true
local RefreshCooldown = 2

local CanUnban = true
local UnbanCooldown = 5

local CanView = true
local ViewCooldown = 1

local MaxPages = 1
local CurrentPage = 1

local FastWaitCount = 0

local BannedPlrTemplateFrame = ListFrame:WaitForChild("TemplateFrame"):Clone()

local function FastWait(Amount)
	if FastWaitCount >= Amount then
		FastWaitCount = 0
		RunService.Heartbeat:Wait()
	else
		FastWaitCount += 1
	end
end

local function ToggleButtonsFade(ButtonName, Fade)
	for i, Frame in pairs(ListFrame:GetChildren()) do
		if Frame:IsA("Frame") then
			local Button = Frame:FindFirstChild(ButtonName)
			
			if Button then
				if Fade then
					Button.TextTransparency = 0.5
				else
					Button.TextTransparency = 0
				end
			end
		end
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
			return string.format("%d %ss", Value + 1, v.Unit)
		end
	end

	return Age
end

local function SetupList(SearchTerm: string?)
	if CanRefresh then
		CanRefresh = false

		MainFrame.RefreshButton.TextTransparency = 0.5

		for i, OldFrame in pairs(ListFrame:GetChildren()) do
			if OldFrame:IsA("Frame") then
				OldFrame:Destroy()
			end
		end

		-- Get the ban list data
		local BansList = GetBansListFunction:InvokeServer()

		if BansList then
			local FilteredBansList = {}

			for i, BanData in pairs(BansList) do
				if BanData and BanData.IsBanned and (BanData.ExtraData.Duration == -1 or os.time() < BanData.UnbanDate) then
					table.insert(FilteredBansList, BanData)
				end
			end
			
			MaxPages = math.max(1, math.ceil(#FilteredBansList / PageSize))
			NavigatorFrame.PageCount.Text = CurrentPage .. " / " .. MaxPages

			-- Create a list in the gui and set the text from the commands list
			for i = 1, PageSize do
				local PlrData = FilteredBansList[i + ((CurrentPage - 1) * PageSize)]
				
				if PlrData and PlrData.ExtraData then -- Check if everything is there
					-- Search term checking
					local TimeRemaing = PlrData.UnbanDate - os.time()
					
					local IsPermBan = PlrData.ExtraData.Duration == -1

					if TimeRemaing > 0 or IsPermBan then -- Ensure we aren't creating useless ban tabs
						local Username = PlrData.ExtraData.Username

						local NewFrame = BannedPlrTemplateFrame:Clone()

						local TimeRemainingText

						-- Create appropriate units for time remaining text
						if TimeRemaing > 10000000000 or IsPermBan then
							TimeRemainingText = "permanently"
						else
							TimeRemainingText = FormatAge(TimeRemaing)
						end

						NewFrame.UsernameText.Text = Username
						NewFrame.BanTimeText.Text = TimeRemainingText

						-- Connect commands to buttons
						NewFrame.ViewButton.MouseButton1Click:Connect(function()
							if CanView then
								CanView = false

								ToggleButtonsFade("ViewButton", true)
								SendCommandEvent:FireServer("banprofile " .. PlrData.ExtraData.UserID)

								task.wait(ViewCooldown)

								ToggleButtonsFade("ViewButton", false)
								CanView = true
							end
						end)

						NewFrame.UnbanButton.MouseButton1Click:Connect(function()
							if CanUnban then
								CanUnban = false

								ToggleButtonsFade("UnbanButton", true)
								SendCommandEvent:FireServer("unban " .. PlrData.ExtraData.UserID)

								task.wait(UnbanCooldown)

								NewFrame.Visible = false

								ToggleButtonsFade("UnbanButton", false)

								CanUnban = true
							end
						end)

						NewFrame.Name = Username
						NewFrame.Visible = not SearchTerm or string.match(Username:lower(), SearchTerm:lower())
						NewFrame.Parent = ListFrame
					end
					FastWait(10)
				end
			end
		end

		task.wait(RefreshCooldown)

		MainFrame.RefreshButton.TextTransparency = 0

		CanRefresh = true
	end
end

local function AdvancePage(Amount)
	if CanRefresh then
		CurrentPage = math.clamp(CurrentPage + Amount, 1, MaxPages)
	end
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