local Module = {
	GlobalMessages = {}, -- Global datastore messages
	ServerMessages = {}, -- Data for this server only
	NewServerMessages = {} -- Newly chatted cache for this server to be added to the data
}

local TextService = game:GetService("TextService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local AdminSettings = require(script.Parent.Parent:WaitForChild("Settings"))

local LogsStore = DataStoreService:GetDataStore("CommandsLogDataStore")
local LogsKey = "CommandsLog"

local LogsCountLimit = 5000 -- Averages at about at a maximum of 0.6 MB of data
local MaxMessageLength = 64 -- Helps reduce data size

local function FilterString(Text, UserId, MaxLength)
	local function getTextObject(message, fromPlayerId)
		local textObject

		local success, errorMessage = pcall(function()
			textObject = TextService:FilterStringAsync(message, fromPlayerId)
		end)

		if success then
			return textObject
		elseif errorMessage then
			warn("Error generating TextFilterResult:", errorMessage)
		end

		return false
	end

	local function getFilteredMessage(textObject)
		local filteredMessage

		local success, errorMessage = pcall(function()
			filteredMessage = textObject:GetNonChatStringForBroadcastAsync()
		end)

		if success then
			return filteredMessage
		elseif errorMessage then
			warn("Error filtering message:", errorMessage)
			return "<filter error>"
		end
	end

	if #Text > MaxLength then return "" end --Check that their chat is appropriate length

	local TextObject = getTextObject(Text, UserId)
	return getFilteredMessage(TextObject)
end

local function AddChatLog(Log)
	if #Module.ServerMessages >= LogsCountLimit then
		table.remove(Module.ServerMessages, 1)
	end
	if #Module.NewServerMessages >= LogsCountLimit then
		table.remove(Module.NewServerMessages, 1)
	end

	table.insert(Module.ServerMessages, Log)
	table.insert(Module.NewServerMessages, Log)
end

function Module.Log(Plr, Message)
	local Log = {
		Username = Plr.Name,
		Date = os.time()
	}
	
	-- Don't filter the first word as that is the command itself
	local Split = string.split(Message, " ")
	
	local Command = Split[1]
	local Content = ""
	
	for i = 2, #Split do
		Content = Content .. " " .. Split[i]
	end

	Log.Message = Command .. FilterString(Content, Plr.UserId, 200)
	
	if Log.Message and #Log.Message > MaxMessageLength then
		Log.Message = string.sub(Log.Message, 1, MaxMessageLength - 3) .. "..."
	end

	AddChatLog(Log)
end

local function SaveLog()
	LogsStore:UpdateAsync(LogsKey, function(PastData)
		if not PastData then 
			-- Initiate data for first time
			return Module.ServerMessages
		else
			-- Add new chats to datastore
			for i, Log in pairs(Module.NewServerMessages) do
				-- Dont go beyond the limit
				if #PastData >= LogsCountLimit then
					table.remove(PastData, 1)
				end

				table.insert(PastData, Log)
			end
			table.clear(Module.NewServerMessages)

			Module.GlobalMessages = PastData

			--print("Logs count:", #PastData)
			--print("Data size:", #game.HttpService:JSONEncode(PastData) / 1e+6, " MB")

			return PastData
		end
	end)
end

coroutine.wrap(function()
	if not AdminSettings.DatastoreAccess then return end
	
	local HasLoaded = false
	local LoadedData
	
	repeat -- Attempt/retry to load the data
		local Success, ErrorMsg = pcall(function()
			LoadedData = LogsStore:GetAsync(LogsKey)
		end)

		HasLoaded = Success

		if not Success then
			warn("Failed to load CommandLogs data:", ErrorMsg, "(Retrying in 5 seconds...)")
			task.wait(5)
		else
			Module.GlobalMessages = LoadedData
		end
	until HasLoaded
	
	local AutoSaveIncrement = 60
	
	while true do -- Auto save loop for datastore
		task.wait(AutoSaveIncrement)
		
		local SaveSuccess, ErrorMsg = pcall(SaveLog)

		if not SaveSuccess then
			warn("Failed to save command logs data:", ErrorMsg)
		end
		
		local Budget = DataStoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.GetAsync)
		AutoSaveIncrement = math.max((1 / Budget) * 9000, 60)
	end
end)()

return Module