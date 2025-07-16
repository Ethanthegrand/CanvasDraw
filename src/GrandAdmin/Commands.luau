--!nonstrict

local Main = script.Parent

-- Services
local TeleportService = game:GetService("TeleportService")
local DebrisService = game:GetService("Debris")
local PlayersService = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local TeamsService = game:GetService("Teams")

-- Modules
local BanManager = require(Main.Modules:WaitForChild("BanManager"))
local BuildFunctions = require(Main.Modules:WaitForChild("Build"))
local CommandHelper = require(Main.Modules:WaitForChild("CommandHelper"))
local AdminSettings = require(Main:WaitForChild("Settings"))
local Roles = require(Main:WaitForChild("Roles"))

local PresetFunctions = CommandHelper.PresetFunctions

-- Misc
local SyntaxTypes = CommandHelper.SyntaxTypes
local InsertedAdminObjName = CommandHelper.InsertedFolderName


--[[ 

Tips:
  - By default, if RankRequired is set to Roles.None, then that means anyone can use the command as that is
    the default permission level for all non-admin players
    
  - Set RankRequred to nil to disable the command
  
  - Some commands are disabled by default. Set a rank to enabled
]]



-----------------------------------------------------------------------------------------------------------------
-- Main commands ------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

local Commands = {

	-- UI Commands
	{
		Names = {"commands", "cmds"},
		Description = "Gives the user a list of all admin commands",
		WebhookLog = false,
		
		RankRequired = Roles.Mod,
		
		Function = function(Parameters, Admin, Rank)
			local Gui = CommandHelper.InsertGui(Admin, CommandHelper.GuiInsertsFolder.CommandsListGui)
			
			-- Get the rank name
			for RankName, PermLevel in pairs(Roles) do
				if PermLevel == Rank then
					Gui.MainFrame.RankText.Text = "YOUR RANK: <b>" .. RankName .. "</b>"
					break
				end
			end
		end,
		
		ParameterTypes = nil,
	},
	{
		Names = {"admins", "mods", "adminlist"},
		Description = "Gives the user a list of all current admins",
		WebhookLog = false,

		RankRequired = Roles.Mod,

		Function = function(Parameters, Admin)
			CommandHelper.InsertGui(Admin, CommandHelper.GuiInsertsFolder.AdminListGui)
		end,

		ParameterTypes = nil,
	},
	{
		Names = {"logs", "cmdlogs"},
		Description = "Gives the user a global list of all executed commands and when they were called",
		WebhookLog = false,
		
		RankRequired = Roles.Mod,
		
		Function = function(Parameters, Admin)
			if not AdminSettings.DatastoreAccess then
				CommandHelper.InsertPopUp(Admin, "Logs", "This command cannot be used as datastore access is disabled in the settings")
				return
			end
			
			CommandHelper.InsertGui(Admin, CommandHelper.GuiInsertsFolder.LogsGui)
		end,
		
		ParameterTypes = nil,
	},
	{
		Names = {"chatlogs", "clogs"},
		Description = "Gives the user a list of all chat messages from the current server",
		WebhookLog = false,

		RankRequired = Roles.Mod,

		Function = function(Parameters, Admin)
			CommandHelper.InsertGui(Admin, CommandHelper.GuiInsertsFolder.ChatLogsGui)
		end,

		ParameterTypes = nil,
	},
	{
		Names = {"commandbar", "cmdbar"},
		Description = "Gives the user a command bar to execute commands privately",
		WebhookLog = false,
		
		RankRequired = Roles.Mod,

		Function = function(Parameters, Admin, Rank)
			CommandHelper.InsertGui(Admin, CommandHelper.GuiInsertsFolder.CommandBarGui)
		end,
		
		ParameterTypes = nil,
	},
	{
		Names = {"notes", "notepad"},
		Description = "Gives the user a notepad",
		WebhookLog = false,
		
		RankRequired = Roles.Mod,
		
		Function = function(Parameters, Admin)
			CommandHelper.InsertGui(Admin, CommandHelper.GuiInsertsFolder.NotesGui)
		end,
		
		ParameterTypes = nil,
	},
	{
		Names = {"performance", "stats", "fps", "ping"},
		Description = "Gives the user a widget to view FPS, ping and server age/stats",
		WebhookLog = false,

		RankRequired = Roles.Mod,

		Function = function(Parameters, Admin)
			CommandHelper.InsertGui(Admin, CommandHelper.GuiInsertsFolder.PerformanceGui)
		end,

		ParameterTypes = nil,
	},
	{
		Names = {"stopwatch"},
		Description = "Gives the user a stopwatch",
		WebhookLog = false,
		
		RankRequired = Roles.Mod,
		
		Function = function(Parameters, Admin)
			CommandHelper.InsertGui(Admin, CommandHelper.GuiInsertsFolder.StopWatchGui)
		end,
		
		ParameterTypes = nil,
	},
	{
		Names = {"spectate", "watch", "view", "freecam"},
		Description = "Spectates the selected target and gives the user a spectating widget with free cam",
		WebhookLog = false,
		
		RankRequired = Roles.Mod,

		Function = function(Parameters, Admin)
			local ChosenPlayer = PresetFunctions.GetPlayerFromShortName(Parameters[1], Admin)
			
			local function SetSpectator(Plr)
				if Admin.PlayerGui:FindFirstChild("AdminGUIs") then
					local Gui = Admin.PlayerGui.AdminGUIs:FindFirstChild("SpectateGui")
					if Gui then
						Gui.CurrentPlayer.Value = Plr
						return
					end
				end
				CommandHelper.GuiInsertsFolder.SpectateGui.CurrentPlayer.Value = Plr
			end

			if ChosenPlayer then
				SetSpectator(ChosenPlayer)
			else
				SetSpectator(Admin)
			end
			
			CommandHelper.InsertGui(Admin, CommandHelper.GuiInsertsFolder.SpectateGui)
		end,
		
		ParameterTypes = {SyntaxTypes.PlayerTarget},
	},
	{
		Names = {"track"},
		Description = "Locally tracks the selected targets with highlights and lines that only you can see",
		WebhookLog = false,

		RankRequired = Roles.Mod,

		Function = function(Parameters, Admin)
			if not Admin.Character then return end

			local function TrackUser(Plr)
				local ScriptId = "AdminTrack_" .. Plr.Name
				
				if not Admin.Character:FindFirstChild(ScriptId) then
					local TrackScript = CommandHelper.ScriptInsertsFolder.TrackTarget:Clone()
					TrackScript.CurrentPlayer.Value = Plr
					TrackScript.Parent = Admin.Character
					TrackScript.Name = ScriptId
					TrackScript.Enabled = true
				end
			end

			for i, Target in pairs(Parameters) do
				CommandHelper.RunFunctionOnTarget(Target, Admin, TrackUser, true)
			end
		end,

		ParameterTypes = {SyntaxTypes.MultiPlayerTargets},
	},
	{
		Names = {"untrack"},
		Description = "Stops tracking the selected targets",
		WebhookLog = false,

		RankRequired = Roles.Mod,

		Function = function(Parameters, Admin)
			if not Admin.Character then return end

			local function TrackUser(Plr)
				local TrackScript = Admin.Character:FindFirstChild("AdminTrack_" .. Plr.Name)
				if TrackScript then
					TrackScript:Destroy()
				end
			end
			
			if #Parameters == 0 or Parameters[1] == "" then
				CommandHelper.RunFunctionOnTarget("all", Admin, TrackUser, true)
				return
			end

			for i, Target in pairs(Parameters) do
				CommandHelper.RunFunctionOnTarget(Target, Admin, TrackUser, true)
			end
		end,

		ParameterTypes = {SyntaxTypes.MultiPlayerTargets},
	},
	{
		Names = {"objects", "obj"},
		Description = "Gives the user a list of all objects that can be summoned",
		WebhookLog = false,
		
		RankRequired = nil, -- Disabled. Set a role to enable
		
		Function = function(Parameters, Admin)
			CommandHelper.InsertGui(Admin, CommandHelper.GuiInsertsFolder.ObjectsListGui)
		end,
		
		ParameterTypes = nil,
	},
	{
		Names = {"bans", "viewbans", "banlist"},
		Description = "Gives the user a list of currently banned users",
		WebhookLog = false,
		
		RankRequired = Roles.Mod,
		
		Function = function(Parameters, Admin)
			if AdminSettings.DatastoreAccess then
				CommandHelper.InsertGui(Admin, CommandHelper.GuiInsertsFolder.BansListGui)
			else
				CommandHelper.InsertPopUp(Admin, "Bans", "This command cannot be used as datastore access is disabled in the settings")
			end
		end,
		
		ParameterTypes = nil,
	},
	{
		Names = {"message", "msg"},
		Description = "Creates a temporary message on everyones screen from a given text",
		WebhookLog = true,
		
		RankRequired = Roles.Admin,
		
		Function = function(Parameters, Admin)
			-- Create the message
			if #Parameters > 0 then
				local MessageText = PresetFunctions.CreateMessageFromParameters(Parameters, 1)

				local FilteredMessage = PresetFunctions.GetFilteredString(Admin, MessageText, 200)

				local DisplayDuration = math.clamp(#FilteredMessage / 6, 3, 12)

				for i, Plr in pairs(PlayersService:GetPlayers()) do
					local PlayerGui = Plr:FindFirstChild("PlayerGui")

					if PlayerGui then
						local MessageGui = CommandHelper.GuiInsertsFolder.AdminMessageGui:Clone()
						MessageGui.MainFrame.Title.Text = "A message from " .. Admin.DisplayName
						MessageGui.MainFrame.Messsage.MainLabel.Text = FilteredMessage

						MessageGui.DisplayTime.Value = DisplayDuration

						MessageGui.Parent = PlayerGui

						DebrisService:AddItem(MessageGui, 15)
					end
				end

			end
		end,
		
		ParameterTypes = {SyntaxTypes.Text},
	},
	{
		Names = {"sign", "createsign", "placesign"},
		Description = "Creates a sign with text",
		WebhookLog = false,
		
		RankRequired = Roles.Admin,
		
		Function = function(Parameters, Admin)
			-- Create the message
			if #Parameters > 0 and Admin.Character then
				local MessageText = PresetFunctions.CreateMessageFromParameters(Parameters, 1)

				local FilteredMessage = PresetFunctions.GetFilteredString(Admin, MessageText, 200)

				-- Create the sign
				local YOffset = -1.4 -- R6
				local Humanoid = PresetFunctions.GetPlayerHumanoid(Admin)
	
				if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then -- R15
					YOffset = -0.1
				end
				
				local Sign = BuildFunctions.Sign(Admin.Character:GetPivot() * CFrame.new(0, YOffset, -3), FilteredMessage)

				-- Parent the sign	
				CommandHelper.ParentAdminObject(Sign)
				
			end
		end,
		
		ParameterTypes = {SyntaxTypes.Text},
	},

	{
		Names = {"respawn", "re", "refresh"},
		Description = "Instantly respawns the selected target(s)'s character",
		WebhookLog = false,
		
		RankRequired = Roles.Mod,
		
		Function = function(Parameters, Admin)
			local function RefreshCharacter(Plr)
				local Tests = 0
				
				coroutine.wrap(function()
					local PrevPos

					if Plr.Character then
						PrevPos = Plr.Character:GetPivot()
					end

					if PrevPos then
						-- Teleport the player to their original position
						Plr.CharacterAdded:Once(function()
							repeat task.wait() Tests += 1 until Plr.Character:FindFirstChild("HumanoidRootPart") or Tests > 500

							Plr.Character:PivotTo(PrevPos)
						end)
						
						Plr:LoadCharacter()
						
					end
				end)()
			end
			
			for i, Name in pairs(Parameters) do
				CommandHelper.RunFunctionOnTarget(Name, Admin, RefreshCharacter)
			end 
		end,
		
		ParameterTypes = {SyntaxTypes.MultiPlayerTargets},
	},

	-- Humanoid commands
	{
		Names = {"kill"},
		Description = "Kills the selected target(s)'s humanoid",
		WebhookLog = true,
		
		RankRequired = Roles.Mod,
		
		Function = function(Parameters, Admin)
			local function KillHumanoid(Plr)
				local Humanoid = PresetFunctions.GetPlayerHumanoid(Plr)
				if Humanoid then
					Humanoid.Health = 0
				end
			end

			for i, Name in pairs(Parameters) do
				CommandHelper.RunFunctionOnTarget(Name, Admin, KillHumanoid)
			end 
		end,
		
		ParameterTypes = {SyntaxTypes.MultiPlayerTargets},
	},
	{
		Names = {"speed", "walkspeed"},
		Description = "Set the selected target's WalkSpeed",
		WebhookLog = false,
		
		RankRequired = Roles.Admin,
		
		Function = function(Parameters, Admin)
			CommandHelper.SetHumanoidProperty(Parameters, Admin, "WalkSpeed")
		end,
		
		ParameterTypes = {SyntaxTypes.PlayerTarget, SyntaxTypes.Number},
	},
	{
		Names = {"jump", "jumppower"},
		Description = "Set the selected target's JumpPower",
		WebhookLog = false,
		
		RankRequired = Roles.Admin,
		
		Function = function(Parameters, Admin)
			CommandHelper.SetHumanoidProperty(Parameters, Admin, "JumpPower")
		end,
		
		ParameterTypes = {SyntaxTypes.PlayerTarget, SyntaxTypes.Number},
	},
	{
		Names = {"health", "hp"},
		Description = "Set the selected target's Health",
		RankRequired = Roles.Admin,
		WebhookLog = false,
		
		Function = function(Parameters, Admin)
			CommandHelper.SetHumanoidProperty(Parameters, Admin, "MaxHealth")
			CommandHelper.SetHumanoidProperty(Parameters, Admin, "Health")
		end,
		
		ParameterTypes = {SyntaxTypes.PlayerTarget, SyntaxTypes.Number},
	},
	{
		Names = {"heal"},
		Description = "heal the target by a specified amount of health",
		WebhookLog = false,
		
		RankRequired = Roles.Admin,
		
		Function = function(Parameters, Admin)
			local Value = Parameters[2]
			local DoSelf = false

			local function HealHumanoid(Plr)
				local Humanoid = PresetFunctions.GetPlayerHumanoid(Plr)
				if Humanoid then
					Humanoid.Health = math.clamp(Humanoid.Health + Value, 0, Humanoid.MaxHealth)
				end
			end

			if not Value then
				if not tonumber(Parameters[1]) then
					Value = math.huge
				else
					Value = Parameters[1]
				end
				DoSelf = true
			end

			if not tonumber(Value) then
				return
			end

			-- All
			if not DoSelf then
				CommandHelper.RunFunctionOnTarget(Parameters[1], Admin, HealHumanoid)
			else
				CommandHelper.RunFunctionOnTarget("me", Admin, HealHumanoid)
			end
		end,
		
		ParameterTypes = {SyntaxTypes.PlayerTarget, SyntaxTypes.Number .. "?"},
	},
	{
		Names = {"damage"},
		Description = "damage the target by a specified amount",
		WebhookLog = false,
		
		RankRequired = Roles.Admin,
		
		Function = function(Parameters, Admin)
			local Value = Parameters[2]
			local DoSelf = false

			local function HealHumanoid(Plr)
				local Humanoid = PresetFunctions.GetPlayerHumanoid(Plr)
				if Humanoid then
					Humanoid:TakeDamage(Value)
				end
			end
			
			if not Value then
				if not tonumber(Parameters[1]) then
					Value = math.huge
				else
					Value = Parameters[1]
				end
				DoSelf = true
			end

			if not tonumber(Value) then
				return
			end
			
			-- All
			if not DoSelf then
				CommandHelper.RunFunctionOnTarget(Parameters[1], Admin, HealHumanoid)
			else
				CommandHelper.RunFunctionOnTarget("me", Admin, HealHumanoid)
			end
		end,
		
		ParameterTypes = {SyntaxTypes.PlayerTarget, SyntaxTypes.Number .. "?"},
	},
	{
		Names = {"sit"},
		Description = "Sits the selected target(s)",
		WebhookLog = false,
		
		RankRequired = Roles.Admin,
		
		Function = function(Parameters, Admin)

			local function SetHumanoid(Plr)
				local Humanoid = PresetFunctions.GetPlayerHumanoid(Plr)
				if Humanoid then
					Humanoid.Sit = true
				end
			end

			for i, Name in pairs(Parameters) do
				CommandHelper.RunFunctionOnTarget(Name, Admin, SetHumanoid)
			end 
		end,
		
		ParameterTypes = {SyntaxTypes.MultiPlayerTargets},
	},
	{
		Names = {"trip", "platformstand"},
		Description = "Trips the selected target(s)",
		WebhookLog = false,
		
		RankRequired = Roles.Admin,
		
		Function = function(Parameters, Admin)

			local function SetHumanoid(Plr)
				local Humanoid = PresetFunctions.GetPlayerHumanoid(Plr)
				if Humanoid then
					Humanoid.PlatformStand = true
				end
			end

			for i, Name in pairs(Parameters) do
				CommandHelper.RunFunctionOnTarget(Name, Admin, SetHumanoid)
			end 
		end,
		
		ParameterTypes = {SyntaxTypes.MultiPlayerTargets},
	},
	{
		Names = {"untrip", "unplatformstand", "getup", "unsit"},
		Description = "Untrips/unsits the selected target(s)",
		WebhookLog = false,
		
		RankRequired = Roles.Admin,
		
		Function = function(Parameters, Admin)

			local function SetHumanoid(Plr)
				local Humanoid = PresetFunctions.GetPlayerHumanoid(Plr)
				if Humanoid then
					Humanoid.PlatformStand = false
					Humanoid.Sit = false
				end
			end

			for i, Name in pairs(Parameters) do
				CommandHelper.RunFunctionOnTarget(Name, Admin, SetHumanoid)
			end 
		end,
		
		ParameterTypes = {SyntaxTypes.MultiPlayerTargets},
	},

	-- Player based command
	{
		Names = {"kick"},
		Description = "Kicks the targeted player from the game with an optional kick message",
		WebhookLog = true,
		
		RankRequired = Roles.Mod,
		
		Function = function(Parameters, Admin)
			local KickMessage

			-- Create the kick message
			if #Parameters >= 2 then
				KickMessage = PresetFunctions.CreateMessageFromParameters(Parameters, 2)
			end

			CommandHelper.RunFunctionOnTarget(Parameters[1], Admin, function(Player)
				Player:Kick(KickMessage)
			end)
		end,
		
		ParameterTypes = {SyntaxTypes.PlayerTarget, SyntaxTypes.Text .. " (reason)?"},
	},
	{
		Names = {"ban"},
		Description = "Bans the selected player from any server on the game for a specified amount of days with a ban reason message\nNOTE: To ban users that aren't in your server, type their full username or UserID",
		WebhookLog = false,
		
		RankRequired = Roles.Mod,
		
		Function = function(Parameters, Admin)
			CommandHelper.BanUser(Admin, Parameters, "regular")
		end,
		
		ParameterTypes = {SyntaxTypes.PlayerTarget .. "/Username/UserID", SyntaxTypes.Number .. " (days)?", SyntaxTypes.Text},
	},
	{
		Names = {"permban", "pban"},
		Description = "Permanently bans the selected player from any server on the game with a ban reason message\nNOTE: To ban users that aren't in your server, type their full username or UserID",
		WebhookLog = false,
		
		RankRequired = Roles.Mod,

		Function = function(Parameters, Admin)
			CommandHelper.BanUser(Admin, Parameters, "perm")
		end,

		ParameterTypes = {SyntaxTypes.PlayerTarget .. "/Username/UserID", SyntaxTypes.Text},
	},
	{
		Names = {"unban"},
		Description = "Unbans the selected player(s) if they are banned.\nNOTE: Parameters must be either full Usernames or UserIDs",
		WebhookLog = false,
		
		RankRequired = Roles.Mod,
		
		Function = function(Parameters, Admin)
			for i, Name in pairs(Parameters) do
				local UserID
				local Username
				
				local Success, ErrorMessage = pcall(function()
					if tonumber(Name) then -- ID
						UserID = tonumber(Name)
						Username = PlayersService:GetNameFromUserIdAsync(UserID)
					else -- Username
						UserID = PlayersService:GetUserIdFromNameAsync(Name)
						Username = Name
					end	
				end)
				
				if Success and UserID then
					local AdminRank = PresetFunctions.GetPlayerRank(Admin)
					
					-- Prevent a higher rank from getting banned
					if not PresetFunctions.CompareRanksToUserID(Admin, UserID) then
						CommandHelper.InsertPopUp(Admin, "Unban - " .. Username, "Unban failed. '" .. Username .. "' is an admin and is ranked too high compared to you.")
						--print("Unban failed - Attempt to unban a higher or equal ranked admin")
						return
					end
					
					local BanManagerSuc, BanManagerErrMsg = pcall(function()
						BanManager.Unban(UserID)
						CommandHelper.SendUnbanWebhookLog(Admin, Username)
					end)
					
					if BanManagerSuc then
						CommandHelper.InsertPopUp(Admin, "Unban - " .. Username, "Successfully unbanned user")
					elseif BanManagerErrMsg then
						CommandHelper.InsertPopUp(Admin, "Unban error - " .. Username, "UNBAN ERROR: " .. BanManagerErrMsg)
					end
					--print("Unbanned " .. Name)
				elseif ErrorMessage then
					CommandHelper.InsertPopUp(Admin, "UNBAN ERROR", ErrorMessage)
					warn("Unban error: " .. ErrorMessage)
				end

			end
		end,
		
		ParameterTypes = {SyntaxTypes.UsernameOrUserID},
	},
	{
		Names = {"viewban", "banprofile"},
		Description = "Views the selected player's ban data if they are banned.\nNOTE: Parameters must be either full usernames or UserIDs",
		WebhookLog = false,
		
		RankRequired = Roles.Mod,
		
		Function = function(Parameters, Admin)
			if not AdminSettings.DatastoreAccess then
				CommandHelper.InsertPopUp(Admin, "viewban", "This command cannot be used as datastore access is disabled in the settings")
				return
			end
			
			local Name = Parameters[1]
			local UserID

			if tonumber(Name) then -- ID
				UserID = tonumber(Name)
			else -- Username
				local Success, ErrorMessage = pcall(function()
					UserID = PlayersService:GetUserIdFromNameAsync(Name)
				end)
				
				if not Success then
					warn(ErrorMessage)
					CommandHelper.InsertPopUp(Admin, "ERROR", ErrorMessage)
					return
				end
			end	

			if UserID then
				local BanData = BanManager.GetBanData(UserID)
				
				if BanData then
					CommandHelper.InsertGui(Admin, CommandHelper.GuiInsertsFolder.BannedUserGui)
					CommandHelper.RequestEventToClient:Fire(Admin, "SendBannedPlrData", BanData)
					--print(BanData)
				else
					CommandHelper.InsertPopUp(Admin, Name, "User is currently not banned")
					--print("User is not banned")
				end
			else
				CommandHelper.InsertPopUp(Admin, Name, "Invalid username/user id")
				--print("Invalid user")
			end 
		end,
		
		ParameterTypes = {SyntaxTypes.UsernameOrUserID},
	},
	{
		Names = {"rejoin"},
		Description = "Automatically rejoin the current place",
		
		RankRequired = Roles.None,
		
		Function = function(Parameters, Admin)
			TeleportService:Teleport(game.PlaceId, Admin)
		end,
		
		ParameterTypes = nil,
	},

	-- Visual commands
	{
		Names = {"highlight"},
		Description = "Inserts a highlight that everyone can see to the target player(s)",
		WebhookLog = false,
		
		RankRequired = Roles.Developer,
		
		Function = function(Parameters, Admin)

			local function CreateHighlight(SelectedPlr)
				local Char = SelectedPlr.Character

				if Char then
					local Highlight = Instance.new("Highlight", Char)
					Highlight.Name = "AdminHighlight_"
					Highlight.OutlineColor = Color3.new(1, 1, 1)
					Highlight.FillColor = Color3.new(1, 1, 1)
					Highlight.OutlineTransparency = 0
					Highlight.FillTransparency = 0.5
				end
			end

			for i, Name in pairs(Parameters) do
				CommandHelper.RunFunctionOnTarget(Name, Admin, CreateHighlight, true)
			end
		end,
		
		ParameterTypes = {SyntaxTypes.MultiPlayerTargets},
	},
	{
		Names = {"unhighlight", "removehighlight"},
		Description = "Removes any inserted highlight effects from the selected player(s)",
		WebhookLog = false,
		
		RankRequired = Roles.Developer,
		
		Function = function(Parameters, Admin)

			local function RemoveEffect(SelectedPlr)
				local Char = SelectedPlr.Character

				if Char then
					for i, Effect in pairs(Char:GetChildren()) do
						if Effect.Name == "AdminHighlight_" then
							Effect:Destroy()
						end
					end
				end
			end

			for i, Name in pairs(Parameters) do
				CommandHelper.RunFunctionOnTarget(Name, Admin, RemoveEffect, true)
			end 
		end,
		
		ParameterTypes = {SyntaxTypes.MultiPlayerTargets},
	},
	{
		Names = {"forcefield", "ff"},
		Description = "Inserts a forcefield to the target player(s)",
		WebhookLog = false,
		
		RankRequired = Roles.Developer,
		
		Function = function(Parameters, Admin)

			local function CreateForcefield(SelectedPlr)
				local Char = SelectedPlr.Character

				if Char then
					local Forcefield = Instance.new("ForceField", Char)
					Forcefield.Name = "AdminForcefield_"
				end
			end

			for i, Name in pairs(Parameters) do
				CommandHelper.RunFunctionOnTarget(Name, Admin, CreateForcefield)
			end 
		end,
		
		ParameterTypes = {SyntaxTypes.MultiPlayerTargets},
	},
	{
		Names = {"unforcefield", "unff", "removeff"},
		Description = "Removes any inserted forcefields from the selected player(s)",
		WebhookLog = false,
		
		RankRequired = Roles.Developer,
		
		Function = function(Parameters, Admin)

			local function RemoveForcefield(SelectedPlr)
				local Char = SelectedPlr.Character

				if Char then
					for i, ForceField in pairs(Char:GetChildren()) do
						if ForceField.Name == "AdminForcefield_" and ForceField:IsA("ForceField") then
							ForceField:Destroy()
						end
					end
				end
			end

			for i, Name in pairs(Parameters) do
				CommandHelper.RunFunctionOnTarget(Name, Admin, RemoveForcefield)
			end 
		end,
		
		ParameterTypes = {SyntaxTypes.MultiPlayerTargets},
	},
	{
		Names = {"summon", "spawn"}, -- NOTE: Requires a folder called "AdminObjects" in the ServerStorage to work
		Description = "Summon in specified props/objects from a given name",
		WebhookLog = false,
		
		RankRequired = nil, -- Disabled. Set a role to enable (e.g. Roles.Admin)
		
		Function = function(Parameters, Admin)	
			local AdminObjectsStorage = ServerStorage:FindFirstChild("AdminObjects")

			local GivenObjectName = PresetFunctions.CreateMessageFromParameters(Parameters, 1)
			
			if not AdminObjectsStorage then
				CommandHelper.InsertPopUp(Admin, "SUMMON FAILED", "This command is unavailable")
				warn("No 'AdminObjects' folder in ServerStorage. Please insert one to use this command")
				return
			elseif #AdminObjectsStorage:GetChildren() == 0 then
				CommandHelper.InsertPopUp(Admin, "SUMMON FAILED", "No objects available")
				print("There is nothing in the 'AdminObjects' folder to summon")
				return
			end

			-- Check for the storage folder and if our character is loaded
			if GivenObjectName and Admin.Character then	
				local ChosenObject = PresetFunctions.GetObjectFromShortName(GivenObjectName, AdminObjectsStorage:GetChildren())

				-- Ensure we have a valid object
				if ChosenObject and (ChosenObject:IsA("Model") or ChosenObject:IsA("BasePart")) then
					
					-- Get the Y offset value for the object
					local YOffset = -1.4 -- R6
					local Humanoid = PresetFunctions.GetPlayerHumanoid(Admin)

					if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then -- R15
						YOffset = -0.1
					end
					
					-- Create and insert the object
					local ClonedObject = ChosenObject:Clone()
					ClonedObject:PivotTo(Admin.Character:GetPivot() * CFrame.new(0, YOffset, -6))
					
					-- Parent the object
					CommandHelper.ParentAdminObject(ClonedObject)
				else
					--print("Invalid object")
				end
			end
		end,
		
		ParameterTypes = {SyntaxTypes.Text .. " (object)"},
	},
	{
		Names = {"clear", "clean", "remove"},
		Description = "Removes all inserted objects from commands",
		WebhookLog = false,
		
		RankRequired = Roles.Admin,
		
		Function = function(Parameters, Admin)
			local InsertedObjectsFolder = workspace:FindFirstChild(InsertedAdminObjName)
			
			if not InsertedObjectsFolder then return end
			
			if #Parameters > 0 and Parameters[1]:lower() ~= "all" then -- Specified or random object
				local Objects = InsertedObjectsFolder:GetChildren()
				
				if Parameters[1]:lower() == "random" then
					-- Random object
					Objects[math.random(1, #Objects)]:Destroy()
				else
					-- Specified object
					local SpecifiedObjName = CommandHelper.PresetFunctions.CreateMessageFromParameters(Parameters, 1)

					for i, Obj in ipairs(Objects) do
						if string.find(Obj.Name:lower(), SpecifiedObjName:lower()) then
							Obj:Destroy()
						end
					end
				end	
			else 
				-- All objects
				InsertedObjectsFolder:Destroy()
			end
			
		end,
		
		ParameterTypes = {SyntaxTypes.Text .. " (objects?)"},
	},
	{
		Names = {"teleport", "tp"},
		Description = "Teleports target A to target B\nExample: tp ethan noah",
		WebhookLog = false,
		
		RankRequired = Roles.Admin,
		
		Function = function(Parameters, Admin)
			local SelectedTarget1 = PresetFunctions.GetPlayerFromShortName(Parameters[1], Admin, true)
			local SelectedTarget2 = PresetFunctions.GetPlayerFromShortName(Parameters[2], Admin, true)

			local function TeleportPlayer(TargetA, TargetB)
				local SelectedChar = TargetA.Character
				local TargetChar = TargetB.Character

				if SelectedChar and TargetChar then
					SelectedChar:PivotTo(TargetChar:GetPivot())
					--print("Teleported " .. SelectedChar.Name .. " to " .. TargetChar.Name)
				end
			end

			if SelectedTarget1 and SelectedTarget2 then
				TeleportPlayer(SelectedTarget1, SelectedTarget2)
			elseif SelectedTarget1 then
				TeleportPlayer(Admin, SelectedTarget1)
			end
		end,
		
		ParameterTypes = {SyntaxTypes.PlayerTarget, SyntaxTypes.PlayerTarget},
	},
	{
		Names = {"goto", "to"},
		Description = "Teleports the user to a specified player",
		WebhookLog = false,
		
		RankRequired = Roles.Admin,
		
		Function = function(Parameters, Admin)
			local GivenName = Parameters[1]

			local function TeleportToPlayer(Target)
				local SelectedChar = Admin.Character
				local TargetChar = Target.Character

				if SelectedChar and TargetChar then
					SelectedChar:PivotTo(TargetChar:GetPivot())
					--print("Teleported " .. SelectedChar.Name .. " to " .. TargetChar.Name)
				end
			end
		
			local ChosenPlr = PresetFunctions.GetPlayerFromShortName(GivenName, Admin, true)

			if ChosenPlr then
				TeleportToPlayer(ChosenPlr)
			end
		end,
		
		ParameterTypes = {SyntaxTypes.PlayerTarget},
	},
	{
		Names = {"bring"},
		Description = "Teleports target players to you",
		WebhookLog = false,
		
		RankRequired = Roles.Admin,
		
		Function = function(Parameters, Admin)

			local function TeleportPlayer(Target)
				local SelectedChar = Target.Character
				local TargetChar = Admin.Character

				if SelectedChar and TargetChar then
					SelectedChar:PivotTo(TargetChar:GetPivot())
					--print("Teleported " .. SelectedChar.Name .. " to " .. TargetChar.Name)
				end
			end

			for i, Name in pairs(Parameters) do
				CommandHelper.RunFunctionOnTarget(Name, Admin, TeleportPlayer)
			end 
		end,
		
		ParameterTypes = {SyntaxTypes.MultiPlayerTargets},
	},
	{
		Names = {"team", "changeteam", "cteam", "setteam"},
		Description = "change team of target player(s)",
		WebhookLog = false,
		
		RankRequired = Roles.Admin,
		
		Function = function(Parameters, Admin)
			local CurrentTeams = TeamsService:GetTeams()

			local TeamToNeutral = false

			local TeamParameterNumber = 2

			if Parameters[2] == "neutral" or Parameters[2] == "nil" or Parameters[2] == "none" 
				or Parameters[1] == "neutral" or Parameters[1] == "nil" or Parameters[1] == "none" then
				TeamToNeutral = true
			end
			
			local function SetTeamNeutral(Player)
				Player.Team = nil
			end

			-- Get the team
			if not TeamToNeutral then
				local MsgFromParams = Parameters[2] and PresetFunctions.CreateMessageFromParameters(Parameters, 2)
				local ChosenTeam = PresetFunctions.GetObjectFromShortName(MsgFromParams, CurrentTeams)

				if not ChosenTeam then
					MsgFromParams = Parameters[1] and PresetFunctions.CreateMessageFromParameters(Parameters, 2)
					ChosenTeam = PresetFunctions.GetObjectFromShortName(MsgFromParams, CurrentTeams)

					if ChosenTeam then
						TeamParameterNumber = 1 -- user was too lazy to put 'me' in the command
					end
				end

				if not ChosenTeam then
					return
				end

				-- Team the player
				if Parameters[1] == "all" and TeamParameterNumber == 2 then
					for i, Plr in pairs(PlayersService:GetPlayers()) do
						Plr.Team = ChosenTeam
					end
				elseif TeamParameterNumber == 2 then
					local ChosenPlr = PresetFunctions.GetPlayerFromShortName(Parameters[1], Admin, true)
					if ChosenPlr then
						ChosenPlr.Team = ChosenTeam
					end
				else
					Admin.Team = ChosenTeam
				end
			else
				CommandHelper.RunFunctionOnTarget(Parameters[1], Admin, SetTeamNeutral)
			end
		end,
		
		ParameterTypes = {SyntaxTypes.PlayerTarget, SyntaxTypes.Text  .. " (team)"},
	},

	-- Leaderstat management
	{
		Names = {"set", "change"},
		Description = "Set a given value of a leaderstat on a specified player\nExample: set player money 1000",
		WebhookLog = false,
		
		RankRequired = Roles.Admin,
		
		Function = function(Parameters, Admin)
			local SelectedPlayers = {}

			-- Get the specified value amount from either paramter 3 or 2
			local SpecifiedValue = Parameters[3]
			local SpecifiedLeaderstat = Parameters[2]

			-- Find player(s)
			CommandHelper.RunFunctionOnTarget(Parameters[1], Admin, function(Plr)
				table.insert(SelectedPlayers, Plr)
			end)
			
			if #SelectedPlayers == 0 then
				CommandHelper.InsertPopUp(Admin, "ERROR", "Invalid target player. Please try again.\nExample: set player money 500")
				return
			end

			-- Give money
			for i, Player in pairs(SelectedPlayers) do
				-- Find leaderstats
				local Leaderstats = Player:FindFirstChild("leaderstats")

				if Leaderstats then
					local SelectedLeaderstat = PresetFunctions.GetObjectFromShortName(SpecifiedLeaderstat, Leaderstats:GetChildren())

					if SelectedLeaderstat and (SelectedLeaderstat:IsA("NumberValue") or SelectedLeaderstat:IsA("IntValue")) then
						SelectedLeaderstat.Value = SpecifiedValue
					else
						CommandHelper.InsertPopUp(Admin, "ERROR", "Invalid leaderstat object. Please try again.\nExample: set player money 500")
					end
				else
					CommandHelper.InsertPopUp(Admin, "ERROR", "This command is unavailable to use as there are no leaderstats")
				end
			end

		end,
		
		ParameterTypes = {SyntaxTypes.PlayerTarget, SyntaxTypes.Text .. " (leaderstat)", SyntaxTypes.Number},
	},
	{
		Names = {"give", "add"},
		Description = "Add a given value to a leaderstat on a specified player\nExample: give player money 100",
		WebhookLog = false,
		
		RankRequired = Roles.Admin,
		
		Function = function(Parameters, Admin)
			local SelectedPlayers = {}

			-- Get the specified value amount from either paramter 3 or 2
			local SpecifiedValue = Parameters[3]
			local SpecifiedLeaderstat = Parameters[2]

			-- Find player(s)
			CommandHelper.RunFunctionOnTarget(Parameters[1], Admin, function(Plr)
				table.insert(SelectedPlayers, Plr)
			end)

			if #SelectedPlayers == 0 then
				CommandHelper.InsertPopUp(Admin, "ERROR", "Invalid target player. Please try again.\nExample: give player money 500")
				return
			end

			-- Give money
			for i, Player in pairs(SelectedPlayers) do
				-- Find leaderstats
				local Leaderstats = Player:FindFirstChild("leaderstats")

				if Leaderstats then
					local SelectedLeaderstat = PresetFunctions.GetObjectFromShortName(SpecifiedLeaderstat, Leaderstats:GetChildren())

					if SelectedLeaderstat and (SelectedLeaderstat:IsA("NumberValue") or SelectedLeaderstat:IsA("IntValue")) then
						SelectedLeaderstat.Value += SpecifiedValue
					else
						CommandHelper.InsertPopUp(Admin, "ERROR", "Invalid leaderstat object. Please try again.\nExample: give player money 500")
					end
				else
					CommandHelper.InsertPopUp(Admin, "ERROR", "This command is unavailable to use as there are no leaderstats")
				end
			end

		end,
		
		ParameterTypes = {SyntaxTypes.PlayerTarget, SyntaxTypes.Text .. " (leaderstat)", SyntaxTypes.Number},
	},
}

return Commands