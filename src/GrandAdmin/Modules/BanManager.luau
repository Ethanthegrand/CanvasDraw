--[[
	Made by Katrist. Edited by Ethanthegrand14 to use roblox's ban API
]]

--//Services
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

--//Variables
local BanDataStore = DataStoreService:GetDataStore("BanData")
local BansLogStore = DataStoreService:GetDataStore("BansLog")

local BansLogKey = "BannedPlayers"

--//Tables
local BanManager = {}

--//Functions
local function LoadBanData(userId)
	local success, banData = pcall(function()
		return BanDataStore:GetAsync(userId)
	end)
	
	if success then
		return banData
	end
	
	return {}
end

local function SetBanDataStore(userId, data)
	local success, errorMessage = pcall(function()
		BanDataStore:SetAsync(userId, data)
		
		-- Add player ban data to the log
		BansLogStore:UpdateAsync(BansLogKey, function(OldData)
			if OldData then
				-- Overwrite ban data
				for i, PlrData in pairs(OldData) do
					if PlrData.ExtraData.UserID == userId then
						OldData[i] = data
						return OldData
					end
				end
				
				-- Create new ban data
				table.insert(OldData, data)
				return OldData
			else
				-- Create new log
				return {data}
			end
		end)
		
	end)
	
	if not success then
		warn(errorMessage)
	end
end

local function RemoveBanData(userId)
	local success, errorMessage = pcall(function()
		BanDataStore:RemoveAsync(userId)
		
		local LogData = BansLogStore:GetAsync(BansLogKey)
		
		for i, PlrData in pairs(LogData) do
			if PlrData.ExtraData.UserID == userId then
				table.remove(LogData, i)
				BansLogStore:SetAsync(BansLogKey, LogData)
				break
			end
		end
	end)
	
	if not success then
		warn(errorMessage)
	end
end

local function PlayerAdded(player)
	local playerData = LoadBanData(player.UserId) or {}

	if playerData.IsBanned then
		if playerData.UnbanDate and os.time() >= playerData.UnbanDate then
			RemoveBanData(player)
			
			return
		end
		
		-- Manually kick. Player was probably banned with the old BanManager
		local TimeRemaing = playerData.UnbanDate - os.time()

		local TimeRemainingText

		if TimeRemaing < 86400 then
			TimeRemainingText = math.ceil(TimeRemaing / 3600) .. " hours"
		else
			TimeRemainingText = math.ceil(TimeRemaing / 86400) .. " days"
		end

		player:Kick(playerData.BanMessage .. " | You will be unbanned in " .. TimeRemainingText)
	end
end

Players.PlayerAdded:Connect(function(player)
	PlayerAdded(player)
end)

for i, player in ipairs(Players:GetPlayers()) do
	task.spawn(PlayerAdded, player)
end

function BanManager.Ban(userId: number, message: string, banLength: number, extraData)
	assert(userId and typeof(userId) == "number", "UserId is not applicable")
	
	if message then
		assert(typeof(message) == "string", "Message must be a string")
	else
		message = "You have been banned."
	end
		
	if banLength then
		assert(typeof(banLength) == "number", "Ban Length must be a number")
		
		SetBanDataStore(userId, {
			IsBanned = true,
			BanMessage = message,
			ExtraData = extraData or {},
			UnbanDate = os.time() + banLength
		})
	else
		SetBanDataStore(userId, {
			IsBanned = true,
			BanMessage = message,
			ExtraData = extraData or {},
		})
	end
	
	local BanConfig: BanConfigType = {
		UserIds = {userId},
		Duration = banLength,
		DisplayReason = message,
		PrivateReason = message,
		ExcludeAltAccounts = false,
		ApplyToUniverse = true
	}

	Players:BanAsync(BanConfig)
end

function BanManager.Unban(userId)
	assert(userId and typeof(userId) == "number", "UserId is not applicable")
	
	local BanConfig: BanConfigType = {
		UserIds = {userId},
		ApplyToUniverse = true
	}
	
	Players:UnbanAsync(BanConfig)
	
	RemoveBanData(userId)
end

function BanManager.GetBanData(userId)
	assert(userId and typeof(userId) == "number", "UserId is not applicable")

	return LoadBanData(userId)
end

--//Deprecated, please switch to .GetBanDataStore when you can
function BanManager:IsBanned(userId)
	assert(userId and typeof(userId) == "number", "UserId is not applicable")

	return LoadBanData(userId).IsBanned
end

return BanManager