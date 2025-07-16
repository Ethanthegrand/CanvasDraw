local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local GroupService = game:GetService("GroupService")

local Main = script.Parent.Parent
local Settings = require(Main:WaitForChild("Settings"))

local function GetPlayerRank(Player)
	if Player.UserId == game.CreatorId then
		return 255
	end
	
	for i, PlrInfo in pairs(Settings.Admins) do
		if PlrInfo[1] == Player.UserId then
			return PlrInfo[2]
		end
	end
	
	-- Check for group
	local GroupId = Settings.GroupId
	
	if GroupId then
		local GroupRank = Player:GetRankInGroup(GroupId)
		if GroupRank < 1 then
			GroupRank = 1
		end
		return GroupRank
	end

	return 1
end

local function CompareRanks(Admin, TargetPlayer)
	return GetPlayerRank(Admin) >= GetPlayerRank(TargetPlayer)
end

local function GetGroupRankFromUserId(UserID)
	local Groups = GroupService:GetGroupsAsync(UserID)

	for i, Group in ipairs(Groups) do
		if Group.Id == Settings.GroupId then
			return Group.Rank
		end
	end

	return Settings.DefaultPermissionLevel
end

-- Main preset functions
local Functions = {
	GetPlayerRank = GetPlayerRank,
	
	CompareRanksToUserID = function(Admin, TargetUserID)
		local AdminRank = GetPlayerRank(Admin)
		
		for i, AdminInfo in pairs(Settings.Admins) do -- Admins list
			if AdminInfo[1] == TargetUserID and AdminInfo[2] >= AdminRank then
				return false -- Target is higher
			end
		end

		if GetGroupRankFromUserId(TargetUserID) >= AdminRank then -- Group rank
			return false -- Target is higher
		end
		
		return true -- Admin is higher
	end,
	
	GetGroupRankFromUserId = GetGroupRankFromUserId,
	
	GetPlayerFromShortName = function(GivenName, Admin, IgnoreHigherRanks: boolean)
		if not GivenName then
			return
		end
		
		if GivenName == "me" or GivenName == "self" or GivenName == "" then -- self
			return Admin
		elseif GivenName == "random" then -- random
			local Players = Players:GetPlayers()
			
			for i, Plr in pairs(Players) do
				if not CompareRanks(Admin, Plr) and not IgnoreHigherRanks then
					table.remove(Players, i)
				end
			end
			
			return Players[math.random(1, #Players)]
		else -- specified player
			for i, Plr in pairs(Players:GetPlayers()) do
				if string.sub(Plr.Name, 1, #GivenName):lower() == GivenName:lower() or 
					string.sub(Plr.DisplayName, 1, #GivenName):lower() == GivenName:lower() then
					if CompareRanks(Admin, Plr) or IgnoreHigherRanks then
						return Plr
					end
				end 
			end
		end
	end,
	
	GetObjectFromShortName = function(GivenName, ObjectsTable)
		if not GivenName then
			return
		end
		
		if GivenName == "random" then
			return ObjectsTable[math.random(1, #ObjectsTable)]
		else
			for i, Object in pairs(ObjectsTable) do
				if string.sub(Object.Name, 1, #GivenName):lower() == GivenName:lower() then
					return Object
				end 
			end
		end
	end,
	
	GetPlayerHumanoid = function(Player)
		if Player.Character then
			if Player.Character:FindFirstChild("Humanoid") then
				return Player.Character.Humanoid
			end
		end
	end,
	
	CreateMessageFromParameters = function(Parameters, StartIndex: number?)
		local MessageText = ""
		
		local StartI = StartIndex or 1

		for i = StartI, #Parameters do
			MessageText = MessageText .. Parameters[i]

			if i < #Parameters then
				MessageText = MessageText .. " "
			end
		end
		
		return MessageText
	end,
	
	GetFilteredString = function(Admin, Text: string, MaxLength: number)
		local function getTextObject(message, fromPlayerId)
			local textObject

			local success, errorMessage = pcall(function()
				textObject = TextService:FilterStringAsync(message, fromPlayerId)
			end)

			if success then
				return textObject
			elseif errorMessage then
				print("Error generating TextFilterResult:", errorMessage)
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
				print("Error filtering message:", errorMessage)
			end

			return false
		end
		
		if typeof(Text) ~= "string" then return end --Check they actually sent a string
		if #Text > MaxLength then return end --Check that their chat is appropriate length

		local TextObject = getTextObject(Text, Admin.UserId)
		return getFilteredMessage(TextObject)
	end,
}

return Functions