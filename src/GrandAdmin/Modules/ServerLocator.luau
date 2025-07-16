--[[

	Server Locator - v1.1.0
	Module created by @Ethanthegrand14
	
	base code originally written by @lolbiIlyyy
	https://devforum.roblox.com/t/2831191

]]

local HttpService = game:GetService("HttpService")

local Locator = {}

local RetryCountMax = 5 -- Attempts before giving up on trying to fetch the server location

local function GetDataContent()
	local suc, getIp = pcall(function()
		return HttpService:GetAsync("https://api.ipify.org/?format=json")
	end)

	local serverIP

	if suc and getIp then
		local ipData = HttpService:JSONDecode(getIp)
		serverIP = ipData["ip"]
	elseif not suc then
		error("Failed to fetch ip data: " .. tostring(getIp))
	end

	-- now that we have the serverip, we can parse it and get the rest of the data
	local Success, ServerData = pcall(function()
		return HttpService:GetAsync("https://api.iplocation.net/?ip=" .. serverIP) 
	end)

	if Success and ServerData then
		local DecodedData = HttpService:JSONDecode(ServerData)
		_G.ServerRegionCache = DecodedData
		
		return DecodedData
	elseif not Success then
		error("Failed to fetch data: " .. tostring(ServerData))
	end
end

local function GetData()
	if not HttpService.HttpEnabled then
		return false, "N/A"
	end
	
	if _G.ServerRegionCache then
		return true, _G.ServerRegionCache
	end
	
	local Success, Data
	
	for i = 1, RetryCountMax do
		Success, Data = pcall(GetDataContent)
		if Success then break end
		
		warn("Failed to fetch server region. Retrying... (" .. i .. "/" .. RetryCountMax .. ") Error:", Data)
		
		task.wait(10)
	end
	
	if not Success or not Data then
		return false, Data
	end

	return Success, Data
end

function Locator.GetServerData()
	local Success, Data = GetData()

	if Success then
		return Data
	end
end


function Locator.GetRegion() : string
	local Success, Data = GetData()
	
	if Success then
		return Data["country_name"] --.. ", " .. Data["region"]
	else
		warn("Failed to fetch server region:", Data)
		return "Unavailable"
	end
end


return Locator