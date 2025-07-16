local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayersService = game:GetService("Players")

local FunctionsFolder = ReplicatedStorage:WaitForChild("AdminRemoteFunctions")

local GetAdminsFunction = FunctionsFolder:WaitForChild("GetAdminList")

local Gui = script.Parent
local MainFrame = Gui:WaitForChild("MainFrame")
local ListFrame = MainFrame:WaitForChild("ObjectsList")
local NavigatorFrame = MainFrame:WaitForChild("NavigatorFrame")

local CanRefresh = true
local RefreshCooldown = 0

local FastWaitCount = 0

local PageSize = 15

-- Main

local MaxPages = 1
local CurrentPage = 1

local LoggedCommandTemplateFrame = ListFrame:WaitForChild("TemplateFrame"):Clone()

local function SetupList(SearchTerm: string?)
	if CanRefresh then
		CanRefresh = false

		-- Just in case
		for i, OldFrame in ipairs(MainFrame.ObjectsList:GetChildren()) do
			if OldFrame:IsA("Frame") then
				OldFrame:Destroy()
			end
		end

		--MainFrame.RefreshButton.TextTransparency = 0.5

		-- Get the ban list data
		local AdminList, Roles = GetAdminsFunction:InvokeServer()
		
		local FormattedRoles = {}

		if AdminList then
			for RoleName, RoleValue in pairs(Roles) do
				FormattedRoles[RoleValue] = RoleName
			end
			
			MaxPages = math.max(1, math.ceil(#AdminList / PageSize))
			NavigatorFrame.PageCount.Text = CurrentPage .. " / " .. MaxPages

			-- Create a list in the gui and set the text from the commands list
			for i = 1, PageSize do
				local AdminInfo = AdminList[i + ((CurrentPage - 1) * PageSize)]

				if not AdminInfo then break end -- We've ran out of logs
				
				local UserId = AdminInfo[1]
				local AdminRoleValue = AdminInfo[2]
				
				if UserId < 1 then
					continue
				end

				local Success, ErrMessage = pcall(function()
					-- Create the command info frame
					local NewFrame = LoggedCommandTemplateFrame:Clone()
					
					local Username = PlayersService:GetNameFromUserIdAsync(UserId)
					local RankName = FormattedRoles[AdminRoleValue]

					NewFrame.UsernameText.Text = Username
					NewFrame.UserIdText.Text = UserId
					NewFrame.RankText.Text = RankName

					NewFrame.Name = Username .. " " .. RankName

					NewFrame.Visible = not SearchTerm or string.match(NewFrame.Name:lower(), SearchTerm:lower())

					NewFrame.Parent = ListFrame
				end)
				
				if not Success then
					warn(ErrMessage)
				end
			end
		end

		task.wait(RefreshCooldown)

		--MainFrame.RefreshButton.TextTransparency = 0

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

--MainFrame.RefreshButton.MouseButton1Click:Connect(function()
--	CurrentPage = 1
--	SetupList(MainFrame.SearchBox.Text)
--end)

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