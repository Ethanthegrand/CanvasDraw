local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FunctionsFolder = ReplicatedStorage:WaitForChild("AdminRemoteFunctions")

local SPingFunction = FunctionsFolder:WaitForChild("Ping")
local CPingFunction = FunctionsFolder:WaitForChild("ClientPing")
local GetLocationFunction = FunctionsFolder:WaitForChild("GetServerLocation")
local GetServerAgeFunction = FunctionsFolder:WaitForChild("GetServerStartTime")

local Gui = script.Parent
local MainFrame = Gui:WaitForChild("MainFrame")
local StatsFrame = MainFrame:WaitForChild("Content")

local LastFrame = os.clock()

local FramesRendered = 0

local ServerStartTime = GetServerAgeFunction:InvokeServer()

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
			return string.format("%d %ss", Value, v.Unit)
		end
	end

	return Age
end

local function GetPing(Type)
	if Type == "server" then
		local Start = os.clock()
		SPingFunction:InvokeServer()
		local Ping = os.clock() - Start

		return math.round(Ping * 1000)
	else
		return math.round(CPingFunction:InvokeServer() * 1000)
	end
end

local function GetServerAge()
	return FormatAge(os.time() - ServerStartTime)
end

RunService.RenderStepped:Connect(function()
	if not Gui.Enabled then return end

	if os.clock() - LastFrame >= 1 then
		StatsFrame.FPS.Label.Text = math.round(FramesRendered)

		FramesRendered = 0
		LastFrame = os.clock()
	else
		FramesRendered += 1
	end
end)

task.spawn(function()
	while true do
		task.wait(1)
		if Gui.Enabled then
			StatsFrame.ClientPing.Label.Text = GetPing("client") .. " ms"
			StatsFrame.ServerPing.Label.Text = GetPing("server") .. " ms"
			StatsFrame.ServerAge.Label.Text = GetServerAge()
		end
	end
end)

StatsFrame.ServerLocation.Label.Text = GetLocationFunction:InvokeServer()