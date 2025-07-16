local TextService = game:GetService("TextService")

local LogsCountLimit = 10000

local Module = {
	ServerMessages = {}
}

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
	
	table.insert(Module.ServerMessages, Log)
end

function Module.Log(Plr, Message)
	local Log = {
		Username = Plr.Name,
		Time = os.time()
	}

	Log.Message = FilterString(Message, Plr.UserId, 200)

	AddChatLog(Log)
end

return Module
