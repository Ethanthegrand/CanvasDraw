--[[

	Grand Admin | Admin Script
	v1.15.0
	
	Created by @Ethanthegrand14
	
	Last Updated: 11/07/2025
	
	
	Edit the 'Settings' module to give users permission.
	
	Edit the 'Commands' module to edit command permissions.
	
	Edit the 'CustomCommands' module to create your own commands.
	
	Edit the 'Roles' module to add on or adjust types of admin roles. 
	If you are using a group, you may want to edit this.
	
	Edit the 'Settings' module for settings and to enable 
	datastore access for banning and logging.
	
]]



-- Services
local PlayersService = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ServerStorage = game:GetService("ServerStorage")
local DataStoreService = game:GetService("DataStoreService")
local TextChatService = game:GetService("TextChatService")

-- Datastores
local BansLogDataStore = DataStoreService:GetDataStore("BansLog")
local BansLogKey = "BannedPlayers"

-- Modues
local Modules = script:WaitForChild("Modules")

local Settings = require(script.Settings)
local InternalCommands = require(script.Commands)
local CustomCommands = require(script.CustomCommands)
local Roles = require(script.Roles)


local PresetFunctions = require(Modules.PresetFunctions)
local CommandHelper = require(Modules.CommandHelper)
local ChatLogs = require(Modules.ChatLogs)
local CommandsLogs = require(Modules.CommandLogs)
local ServerLocator = require(Modules.ServerLocator)

local CommandPrefixes = Settings.CommandPrefixes

local BindableModuleEventsFolder = script.ModuleEvents

-- Folders
local RemoteFunctionsFolder = Instance.new("Folder", ReplicatedStorage)
local RemoteEventsFolder = Instance.new("Folder", ReplicatedStorage)

-- Remote functions
local GetCommandsListFunction = Instance.new("RemoteFunction", RemoteFunctionsFolder)
local GetAdminObjectsFunction = Instance.new("RemoteFunction", RemoteFunctionsFolder)
local GetBannedPlayersFunction = Instance.new("RemoteFunction", RemoteFunctionsFolder)
local GetCommandsLogFunction = Instance.new("RemoteFunction", RemoteFunctionsFolder)
local GetChatLogFunction = Instance.new("RemoteFunction", RemoteFunctionsFolder)
local GetCmdbarShortcutFunction = Instance.new("RemoteFunction", RemoteFunctionsFolder)
local GetAdminListFunction = Instance.new("RemoteFunction", RemoteFunctionsFolder)
local ClientPingFunction = Instance.new("RemoteFunction", RemoteFunctionsFolder)
local PingFunction = Instance.new("RemoteFunction", RemoteFunctionsFolder)
local ServerAgeFunction = Instance.new("RemoteFunction", RemoteFunctionsFolder)
local ServerLocationFunction = Instance.new("RemoteFunction", RemoteFunctionsFolder)

-- Remote events
local OpenPlrGuiEvent = Instance.new("RemoteEvent", RemoteEventsFolder)
local SendBannedPlayerDataEvent = Instance.new("RemoteEvent", RemoteEventsFolder)
local SendCommandEvent = Instance.new("RemoteEvent", RemoteEventsFolder)

-- Bindable events
local SendEventToClientListener = BindableModuleEventsFolder:WaitForChild("RequestEventToClient")

-- Timers
local CommandsLogCooldownTime = 0

-- Main
local StartTime = os.time()

local RankNames = {}

local CommandsList = {}
local ServerChatLogs = {}

local function FireEventToClient(Player, EventName, Parameter)
	local Event = RemoteEventsFolder:FindFirstChild(EventName)

	if Event then
		Event:FireClient(Player, Parameter)
	end 
end

local function MessageInputted(GivenMessage, MainPlr)
	local UserId = MainPlr.UserId
	
	local GivenPrefix
	
	for i, Prefix in pairs(CommandPrefixes) do
		local Start, End = string.find(GivenMessage, Prefix)
		if Start and Start == 1 then
			GivenPrefix = Prefix
			break
		end
	end

	-- Find the prefix inputted
	if not table.find(CommandPrefixes, GivenPrefix) then
		return -- Not a valid prefix
	end
	
	local PlrRank = PresetFunctions.GetPlayerRank(MainPlr)

	local GivenCommand = string.split(GivenMessage, " ")[1]:lower()

	for i, CommandInfo in pairs(CommandsList) do
		
		if not CommandInfo.RankRequired then -- Check if the command is enabled
			continue
		end
		
		-- Check if the player is ranked high enough, or is the owner of the game
		if PlrRank >= CommandInfo.RankRequired then
			-- Check for command from message
			for i, CommandName in ipairs(CommandInfo.Names) do
				
				-- Find the command
				if GivenPrefix .. CommandName:lower() == GivenCommand then

					-- Get the selected parameters from the message
					local GivenParameters = string.sub(GivenMessage, #GivenPrefix + #CommandName + 2)
					local ParametersArray = string.split(GivenParameters, " ")

					if #ParametersArray == 0 then 
						-- No specified user was given. Assume the user was meant to be himself.
						ParametersArray = {"me"}
					end

					-- Execute the command
					CommandInfo.Function(ParametersArray, MainPlr, PresetFunctions.GetPlayerRank(MainPlr))
					
					-- Log the command
					if Settings.DatastoreAccess then
						local Success, ErrorMessage = pcall(function()
							local CommandString = CommandPrefixes[1] .. string.sub(GivenMessage, #GivenPrefix + 1, #GivenMessage)
							CommandsLogs.Log(MainPlr, CommandString)
						end)
						
						if not Success then
							warn("Failed to log command: " .. ErrorMessage)
						end
					end
					
					-- Webhook log the command
					if CommandInfo.WebhookLog then
						CommandHelper.SendCommandWebhookLog(MainPlr, CommandName, string.sub(GivenMessage, #GivenPrefix + 1, #GivenMessage))
					end

					break -- Command has been found. Break loop
				end
			end
		end
	end
end

local function UserHasPerms(Player) -- Anti-exploiter check
	return PresetFunctions.GetPlayerRank(Player) > 1
end

local function RequestCommandsList(Player)
	local PlrRank = PresetFunctions.GetPlayerRank(Player)
	
	if not UserHasPerms(Player) then return {} end -- Check if user is an admin

	local AlphabetisedCommands = {}

	for i, Command in pairs(CommandsList) do
		if not Command.RankRequired then -- Check if the command is enabled
			continue
		end
		
		if Command.RankRequired <= PlrRank then
			Command.IsRankedHighEnough = "yes"
		else
			Command.IsRankedHighEnough = RankNames[Command.RankRequired]
		end
		
		local CommandCopy = table.clone(Command)
		CommandCopy.MouseHoverText = CommandCopy.Names[1]
		CommandCopy.Function = nil -- We don't want the client to view such code
		
		if CommandCopy.ParameterTypes then
			for i, ParamType in ipairs(CommandCopy.ParameterTypes) do
				CommandCopy.MouseHoverText = CommandCopy.MouseHoverText .. " [" .. ParamType .. "]"
			end
		end
		table.insert(AlphabetisedCommands, CommandCopy)
	end

	table.sort(AlphabetisedCommands, function(a,b)
		return a.Names[1] < b.Names[1]
	end)

	return AlphabetisedCommands
end

local function RequestBansList(Player)	
	local BannedPlayersList

	local Success, ErrorMessage = pcall(function()
		if UserHasPerms(Player) then -- Ensure user is an admin
			BannedPlayersList = BansLogDataStore:GetAsync(BansLogKey)
		end
	end)

	if not Success then
		warn(ErrorMessage)
		return
	end

	if BannedPlayersList then
		table.sort(BannedPlayersList, function(a,b)
			return a.UnbanDate < b.UnbanDate
		end)

		return BannedPlayersList
	else
		return {}
	end
end

local function RequestCommandLogs(Player)	
	local LoggedCommandsList

	local Success, ErrorMessage = pcall(function()
		if UserHasPerms(Player) then
			local FreshLogsCount = #CommandsLogs.NewServerMessages
			LoggedCommandsList = table.clone(CommandsLogs.GlobalMessages)
			
			for i = 1, FreshLogsCount do
				table.remove(LoggedCommandsList, i)
			end
			
			table.sort(CommandsLogs.NewServerMessages, function(a,b)
				return a.Date > b.Date
			end)
			
			for i, Log in ipairs(CommandsLogs.NewServerMessages) do
				table.insert(LoggedCommandsList, Log)
			end
		end
	end)

	if not Success then
		warn(ErrorMessage)
		return
	end

	if LoggedCommandsList then
		table.sort(LoggedCommandsList, function(a,b)
			return a.Date > b.Date
		end)

		return LoggedCommandsList
	else
		return {}
	end
end

local function RequestChatLogs(Player)
	if not UserHasPerms(Player) then return {} end
	
	local LoggedChatList = ChatLogs.ServerMessages

	table.sort(LoggedChatList, function(a,b)
		return a.Time > b.Time
	end)

	return LoggedChatList
end


local function RequestAdminList(Player)
	if not UserHasPerms(Player) then return {} end
	
	local List = table.clone(Settings.Admins)
	
	local CreatorId = game.CreatorId
	
	-- Studio test
	if CreatorId == 0 then CreatorId = Player.UserId end
	
	table.insert(List, {CreatorId, 255}) -- The owner

	return List, Roles
end

local function RequestCmdbarShortcut(Player)	
	local Keycode

	local Success, ErrorMessage = pcall(function()
		if UserHasPerms(Player) then
			Keycode = Settings.CommandbarShortcutKey
		end
	end)

	if not Success then
		warn(ErrorMessage)
		return
	end

	return Keycode
end

local function RequestServerLocation(Player)
	if not UserHasPerms(Player) then return "N/A" end
	
	return ServerLocator.GetRegion()
end

local function RequestServerStartTime(Player)
	return StartTime
end

local function RequestAdminObjectsContent(Player)
	if not UserHasPerms(Player) then return "N/A" end
	
	local ObjectsStorage = ServerStorage:FindFirstChild("AdminObjects")
	
	if ObjectsStorage then
		local ObjectNames = {}

		for i, Object in pairs(ObjectsStorage:GetChildren()) do
			if Object:IsA("Model") or Object:IsA("BasePart") then
				table.insert(ObjectNames, Object.Name)
			end
		end

		table.sort(ObjectNames, function(a,b)
			return a < b
		end)

		if ObjectsStorage and #ObjectNames > 0 then
			return ObjectNames
		else
			return nil
		end
	else
		return nil
	end
end

local function PlayerAdded(Plr)
	Plr.Chatted:Connect(function(Message)
		MessageInputted(Message, Plr)
		ChatLogs.Log(Plr, Message)
	end)
end

for Name, PermissionLevel in pairs(Roles) do
	RankNames[PermissionLevel] = Name
end

PlayersService.PlayerAdded:Connect(PlayerAdded)

-- Do this, because sometimes the player joins before this script loads
for i, Player in ipairs(PlayersService:GetPlayers()) do
	PlayerAdded(Player)
end

-- Get both internal and custom commands
for i, Command in ipairs(CustomCommands) do
	table.insert(CommandsList, Command)
end
for i, Command in ipairs(InternalCommands) do
	table.insert(CommandsList, Command)
end

-- Enable shortcut for command bar
if Settings.CommandbarShortcutKey then
	local Script = script.ScriptInserts.AdminCmdbarShortcut:Clone()
	Script.Parent = ReplicatedFirst
	Script.Enabled = true
end

-- Connect remote events and functions
SendEventToClientListener.Event:Connect(FireEventToClient)

GetCommandsListFunction.OnServerInvoke = RequestCommandsList
GetAdminObjectsFunction.OnServerInvoke = RequestAdminObjectsContent
GetBannedPlayersFunction.OnServerInvoke = RequestBansList
GetCommandsLogFunction.OnServerInvoke = RequestCommandLogs
GetChatLogFunction.OnServerInvoke = RequestChatLogs
GetCmdbarShortcutFunction.OnServerInvoke = RequestCmdbarShortcut
GetAdminListFunction.OnServerInvoke = RequestAdminList
ServerLocationFunction.OnServerInvoke = RequestServerLocation
ServerAgeFunction.OnServerInvoke = RequestServerStartTime

ClientPingFunction.OnServerInvoke = function(Plr) 
	return Plr:GetNetworkPing()
end

PingFunction.OnServerInvoke = function() end


SendCommandEvent.OnServerEvent:Connect(function(Player, Command)
	MessageInputted(CommandPrefixes[1] .. Command, Player)
end)



-- Name the remote events/functions

RemoteFunctionsFolder.Name = "AdminRemoteFunctions"
RemoteEventsFolder.Name = "AdminRemoteEvents"

GetCommandsListFunction.Name = "GetCommandsList"
GetAdminObjectsFunction.Name = "GetAdminObjects"
GetBannedPlayersFunction.Name = "GetBannedPlrsList"
GetCommandsLogFunction.Name = "GetCommandsLog"
GetChatLogFunction.Name = "GetChatLog"
GetCmdbarShortcutFunction.Name = "GetCmdbarShortcut"
GetAdminListFunction.Name = "GetAdminList"

OpenPlrGuiEvent.Name = "OpenPlrAdminGui"
SendBannedPlayerDataEvent.Name = "SendBannedPlrData"
SendCommandEvent.Name = "SendAdminCommand"
ClientPingFunction.Name = "ClientPing"
PingFunction.Name = "Ping"
ServerLocationFunction.Name = "GetServerLocation"
ServerAgeFunction.Name = "GetServerStartTime"