local Module = {}

local PlayersService = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")

local Main = script.Parent.Parent

local BindableModuleEventsFolder = Main:WaitForChild("ModuleEvents")

local AdminSettings = require(Main:WaitForChild("Settings"))

local BanManager = require(Main.Modules:WaitForChild("BanManager"))
local WebhookService = require(Main.Modules.WebhookService)

-- Module variables
Module.RequestEventToClient = BindableModuleEventsFolder:WaitForChild("RequestEventToClient")

Module.ScriptInsertsFolder = Main:WaitForChild("ScriptInserts")
Module.GuiInsertsFolder = Main:WaitForChild("GuiInserts")

Module.InsertedFolderName = "InsertedAdminObjects_"

-- Sub modules
Module.PresetFunctions = require(Main.Modules:WaitForChild("PresetFunctions"))

Module.SyntaxTypes = {
	PlayerTarget = "Target?",
	MultiPlayerTargets = "Target(s)...",
	Number = "Number",
	Text = "Text",
	UsernameOrUserID = "Username/UserID",
}

local function FormatAge(Age)
	if Age == -1 then
		return "permanently"
	end
	
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

local function SendBanWebhookLog(Type, Admin, Username, Reason, Duration)
	-- Discord webhook message
	if AdminSettings.BanLogWebhookURL and string.match(AdminSettings.BanLogWebhookURL, "%S") then
		if not HttpService.HttpEnabled then
			warn("Failed to send webhook message (Http requests not enabled!)")
			return
		end
		
		local Request = WebhookService:new()
		local Fields

		if Type == "ban" then
			local DisplayBanTime
			
			if Duration == -1 then
				DisplayBanTime = "Permanently"
				Request.Title = "'" .. Username .. "' has been permanently banned!"
			else
				DisplayBanTime = FormatAge(Duration * 86400)
				Request.Title = "'" .. Username .. "' has been temporarily banned!"
			end
			Request.Color = WebhookService.colors.red

			Fields = {
				{
					["name"] = "Reason:",
					["value"] = Reason,
					["inline"] = false,
				},
				{
					["name"] = "Duration:",
					["value"] = DisplayBanTime,
					["inline"] = false,
				},
				{
					["name"] = "Banned by:",
					["value"] = Admin.Name,
					["inline"] = false,
				},
			}

		else
			Request.Title = "'" .. Username .. "' has been unbanned!"
			Request.Color = WebhookService.colors.green			
			
			Fields = {
				{
					["name"] = "Unbanned by:",
					["value"] = Admin.Name,
					["inline"] = false,
				},
			}
		end
		
		table.insert(Fields,{
			["name"] = "Place:",
			["value"] = MarketplaceService:GetProductInfo(game.PlaceId).Name,
			["inline"] = false,
		})

		Request.Fields = Fields
		Request.Footer = "Grand Admin [Ban Log]"
		Request.TimeStamp = DateTime.now():ToIsoDate()

		Request:sendEmbed(AdminSettings.BanLogWebhookURL)
	end
end

local function SendCommandWebhookLog(Admin, CommandName, FullMessage)
	-- Discord webhook message
	if AdminSettings.CommandLogWebhookURL and string.match(AdminSettings.CommandLogWebhookURL, "%S") then
		if not HttpService.HttpEnabled then
			warn("Failed to send webhook message (Http requests not enabled!)")
			return
		end

		local Request = WebhookService:new()

		Request.Title = "'" .. Admin.Name .. "' executed " .. AdminSettings.CommandPrefixes[1] .. CommandName
		Request.Color = WebhookService.colors.green			

		local Fields = {
			{
				["name"] = "Admin:",
				["value"] = Admin.Name .. " (" .. Admin.UserId .. ")",
				["inline"] = false,
			},
			{
				["name"] = "Executed Line:",
				["value"] = FullMessage,
				["inline"] = false,
			},
			{
				["name"] = "Place:",
				["value"] = MarketplaceService:GetProductInfo(game.PlaceId).Name,
				["inline"] = false,
			}
		}

		Request.Fields = Fields
		Request.Footer = "Grand Admin [Command Log]"
		Request.TimeStamp = DateTime.now():ToIsoDate()

		Request:sendEmbed(AdminSettings.CommandLogWebhookURL)
	end
end

-- Module functions
function Module.RunFunctionOnTarget(TargetParameter: string, Admin: Player, PlayerFunction, IgnoreHigherRanks: boolean?)
	local function CanExecuteOnPlr(Plr)
		return Plr == Admin or Module.PresetFunctions.GetPlayerRank(Plr) < Module.PresetFunctions.GetPlayerRank(Admin) or IgnoreHigherRanks
	end
	
	if TargetParameter:lower() == "all" then
		-- All players
		for i, Plr in pairs(PlayersService:GetPlayers()) do
			if CanExecuteOnPlr(Plr) then
				PlayerFunction(Plr)
			end
		end
		
	elseif TargetParameter:lower() == "others" then
		-- All players except for the admin
		for i, Plr in pairs(PlayersService:GetPlayers()) do
			if Plr ~= Admin and CanExecuteOnPlr(Plr) then
				PlayerFunction(Plr)
			end
		end
			
	elseif TargetParameter and #TargetParameter > 0 and (TargetParameter:lower() ~= "me" and TargetParameter:lower() ~= "self") then
		-- Specified player
		local ChosenPlr = Module.PresetFunctions.GetPlayerFromShortName(TargetParameter, Admin, IgnoreHigherRanks)
		if ChosenPlr and CanExecuteOnPlr(ChosenPlr) then
			PlayerFunction(ChosenPlr)
		end
	else
		-- Self (Admin)
		PlayerFunction(Admin)
	end
end

function Module.ParentAdminObject(Object: Instance)
	local InsertedObjectsFolder = workspace:FindFirstChild(Module.InsertedFolderName)

	if not InsertedObjectsFolder then
		InsertedObjectsFolder = Instance.new("Folder", workspace)
		InsertedObjectsFolder.Name = Module.InsertedFolderName
	end

	Object.Parent = InsertedObjectsFolder
end

function Module.SetHumanoidProperty(Parameters, Admin: Player, Property: string)
	local Value = Parameters[2]
	local DoSelf = false

	local function SetHumanoid(Plr)
		local Humanoid = Module.PresetFunctions.GetPlayerHumanoid(Plr)
		if Humanoid then
			Humanoid[Property] = Value
		end
	end

	if not Value then
		Value = Parameters[1]
		DoSelf = true
	end

	if not tonumber(Value) then
		return
	end
	
	if not DoSelf then
		Module.RunFunctionOnTarget(Parameters[1], Admin, SetHumanoid)
	else
		Module.RunFunctionOnTarget("me", Admin, SetHumanoid)
	end
end

function Module.InsertGui(Plr, Gui)
	local PlayerGui = Plr:FindFirstChild("PlayerGui")
	
	-- Create a folder for the Admin UIs
	local AdminUiFolder = PlayerGui:FindFirstChild("AdminGUIs")
	if not AdminUiFolder then
		AdminUiFolder = Instance.new("BillboardGui", PlayerGui)
		AdminUiFolder.ResetOnSpawn = false
		AdminUiFolder.Name = "AdminGUIs"
	end
	
	local OldGui = AdminUiFolder:FindFirstChild(Gui.Name)

	if not OldGui then
		local NewGui = Gui:Clone()

		local UiScript = Module.ScriptInsertsFolder.UIScript:Clone()
		UiScript.Parent = NewGui
		UiScript.Enabled = true
		
		local MainFrame = NewGui:FindFirstChild("MainFrame")
		if MainFrame then
			if AdminSettings.WidgetTransparency then
				MainFrame.BackgroundTransparency = AdminSettings.WidgetTransparency
			end
			
			if AdminSettings.WidgetBackgroundColour then
				MainFrame.BackgroundColor3 = AdminSettings.WidgetBackgroundColour
			end

			if AdminSettings.WidgetUIBlur then
				local BlurScript = Module.ScriptInsertsFolder.BlurController:Clone()
				BlurScript.Parent = MainFrame
				BlurScript.Enabled = true
			end
		end

		NewGui.Parent = AdminUiFolder
		
		return NewGui
	elseif OldGui then
		Module.RequestEventToClient:Fire(Plr, "OpenPlrAdminGui", Gui.Name)
		return OldGui
	end
end

function Module.InsertPopUp(Plr, Title: string, Message: string)
	if not Plr.PlayerGui then return end -- Just in case?
	
	local UIsFolder = Plr.PlayerGui:FindFirstChild("AdminGUIs")
	
	if not UIsFolder then
		UIsFolder = Instance.new("Folder", Plr.PlayerGui)
		UIsFolder.Name = "AdminGUIs"
	end
	
	local OldGui = UIsFolder:FindFirstChild("AdminPopupMessageGui")
	
	if OldGui then
		OldGui.MainFrame.Title.Text = Title
		OldGui.MainFrame.MessageText.Text = Message
		Module.InsertGui(Plr, OldGui)
	else
		local MsgGUI = Module.InsertGui(Plr, Module.GuiInsertsFolder.PopupMessageGui)
		MsgGUI.MainFrame.Title.Text = Title
		MsgGUI.MainFrame.MessageText.Text = Message
	end
end

function Module.BanUser(Admin, Parameters, BanType)
	local AdminRank = Module.PresetFunctions.GetPlayerRank(Admin)

	local DayLength = 86400 -- In seconds

	local BanReason = "Not specified"
	local BanMessage = "You've been banned for: "
	local BanDuration = 1 -- In days
	
	local BanTimeSeconds

	-- Get the ban duration (in days)
	if BanType == "perm" then
		BanTimeSeconds = -1
		BanDuration = -1
		
		-- Get ban reason
		if #Parameters >= 2 then
			BanReason = Module.PresetFunctions.CreateMessageFromParameters(Parameters, 2)
		end
	else
		if #Parameters > 1 and tonumber(Parameters[2]) then
			BanDuration = tonumber(Parameters[2])
		end
		
		BanTimeSeconds = BanDuration * DayLength
		
		-- Get the ban reason
		if #Parameters >= 3 then
			BanReason = Module.PresetFunctions.CreateMessageFromParameters(Parameters, 3)
		end
	end

	-- Make the kick message
	BanMessage = BanMessage .. BanReason

	local function BanPlayer(Plr, ExtraBanData)
		ExtraBanData.Username = Plr.Name
		ExtraBanData.UserID = Plr.UserId

		-- Check if the user is ranked low enough to be banned
		if Module.PresetFunctions.GetPlayerRank(Plr) < Module.PresetFunctions.GetPlayerRank(Admin) then
			-- Ban user
			local BanManagerSuc, BanManagerErrMsg = pcall(function()
				BanManager.Ban(Plr.UserId, BanMessage, BanTimeSeconds, ExtraBanData, AdminSettings.DatastoreAccess)
				SendBanWebhookLog("ban", Admin, Plr.Name, BanReason, BanDuration)
			end)
			
			if not BanManagerSuc and BanManagerErrMsg then
				Module.InsertPopUp(Admin, "Ban error - " .. Plr.Name, "BAN ERROR: " .. BanManagerErrMsg)
				error(BanManagerErrMsg)
				return
			end
			
			if BanType == "perm" then
				Module.InsertPopUp(Admin, "Ban - " .. Plr.Name, "Successfully perm banned '" .. Plr.Name .. "'")
			else
				Module.InsertPopUp(Admin, "Ban - " .. Plr.Name, "Successfully banned '" .. Plr.Name .. "' for " .. BanDuration .. " days")
			end
		else
			-- Ban fail (rank difference)
			Module.InsertPopUp(Admin, "Ban - " .. Plr.Name, "Ban failed. '" .. Plr.Name .. "' is an admin and is ranked too high compared to you")
			--print("Ban failed - Attempt to ban a higher or equal ranked admin")
		end
	end

	local ExtraBanData = {
		Moderator = Admin.Name, 
		Duration = BanDuration,
		Reason = BanReason,
		Username = "?",
		UserID = 0,
	}

	-- Ban all
	if Parameters[1] == "all" then
		for i, Plr in pairs(PlayersService:GetPlayers()) do
			BanPlayer(Plr, ExtraBanData)
		end

		-- Ban specified player
	else
		local ChosenPlr = Module.PresetFunctions.GetPlayerFromShortName(Parameters[1], Admin, false)

		if ChosenPlr then -- In server
			BanPlayer(ChosenPlr, ExtraBanData)
		else -- Out of server / UserID
			local Name = Parameters[1]
			local UserID

			if tonumber(Name) then -- ID
				UserID = tonumber(Name)
			else -- Username
				local Success, ErrorMessage = pcall(function()
					UserID = PlayersService:GetUserIdFromNameAsync(Name)
				end)

				if not Success then
					Module.InsertPopUp(Admin, "BAN ERROR", ErrorMessage)
					warn("BAN ERROR", ErrorMessage .. ": " .. Name)
					return
				end
			end

			-- Prevent a higher rank from getting banned
			if not Module.PresetFunctions.CompareRanksToUserID(Admin, UserID) then
				Module.InsertPopUp(Admin, "Ban - " .. Name, "Ban failed. '" .. Name .. "' is an admin and is ranked too high compared to you")
				print("Ban failed - Attempt to ban a higher or equal ranked admin")
				return
			end

			if UserID then
				local Success, ErrorMessage = pcall(function()
					ExtraBanData.Username = PlayersService:GetNameFromUserIdAsync(UserID)
					ExtraBanData.UserID = UserID

					BanManager.Ban(UserID, BanMessage, BanTimeSeconds, ExtraBanData, AdminSettings.DatastoreAccess)
					
					if BanType == "perm" then
						Module.InsertPopUp(Admin, "Ban - " .. ExtraBanData.Username, "Successfully perm banned '" .. ExtraBanData.Username .. "'")
					else
						Module.InsertPopUp(Admin, "Ban - " .. ExtraBanData.Username, "Successfully banned '" .. ExtraBanData.Username .. "' for " .. BanDuration .. " days")
					end
					
					SendBanWebhookLog("ban", Admin, ExtraBanData.Username, BanReason, BanDuration)
				end)

				if not Success then
					Module.InsertPopUp(Admin, "BAN ERROR", ErrorMessage)
				end
			end
		end
	end
end

function Module.SendUnbanWebhookLog(Admin, TargetUsername)
	SendBanWebhookLog("unban", Admin, TargetUsername)
end

function Module.SendCommandWebhookLog(Admin, CommandName, FullMessage)
	SendCommandWebhookLog(Admin, CommandName, FullMessage)
end

return Module