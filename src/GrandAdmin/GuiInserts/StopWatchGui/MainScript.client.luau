local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Gui = script.Parent
local MainFrame = Gui:WaitForChild("MainFrame")
local SegmentDisplayFrame = MainFrame:WaitForChild("SegmentDisplayFrame")

local StartStopButton = MainFrame:WaitForChild("StartStopButton")
local ResetButton = MainFrame:WaitForChild("ResetButton")

local SevenSegment = require(Gui:WaitForChild("SevenSegment"))

local DisplaySettings = {
	Italics = true
}

local IsTiming = false
local HasStopped = false
local HeartbeatConnection

local StopwatchElapsedTime = 0
local StartTime

local HourDisplay = SevenSegment.new(SegmentDisplayFrame.HourDisplay, 2, DisplaySettings)
local MinuteDisplay = SevenSegment.new(SegmentDisplayFrame.MinuteDisplay, 2, DisplaySettings)
local SecondDisplay = SevenSegment.new(SegmentDisplayFrame.SecondDisplay, 2, DisplaySettings)
local MilisecondDisplay = SevenSegment.new(SegmentDisplayFrame.MilisecondDisplay, 2, DisplaySettings)

-- Functions

local function ToggleButtonTransparency(Button, Fade)
	if Fade then
		Button.TextTransparency = 0.5
		Button.BackgroundTransparency = 0.65
	else
		Button.TextTransparency = 0
		Button.BackgroundTransparency = 0
	end
end

function Format(Int)
	return string.format("%02i", Int)
end

function convertToHMS(Seconds)
	local Minutes = (Seconds - Seconds%60)/60
	Seconds = Seconds - Minutes*60
	local Hours = (Minutes - Minutes%60)/60
	Minutes = Minutes - Hours*60
	
	return Format(Hours), Format(Minutes), Format(Seconds)
end

-- Main

StartStopButton.MouseButton1Click:Connect(function()
	if not IsTiming then -- Start the timer
		IsTiming = true
		
		if not StartTime then
			StartTime = os.clock()
		end

		HeartbeatConnection = RunService.Heartbeat:Connect(function()
			StopwatchElapsedTime = os.clock() - StartTime

			local Hours, Minutes, Seconds = convertToHMS(StopwatchElapsedTime)
			local Miliseconds = math.floor((StopwatchElapsedTime % 1) * 100) / 100 * 100

			HourDisplay:SetText(Hours)
			MinuteDisplay:SetText(Minutes)
			SecondDisplay:SetText(Seconds)
			MilisecondDisplay:SetText(Miliseconds)
		end)
		
		StartStopButton.Text = "STOP"
	else -- Stop the timer
		HasStopped = true
		if HeartbeatConnection then
			HeartbeatConnection:Disconnect()
		end
		
		ToggleButtonTransparency(ResetButton, false)
		ToggleButtonTransparency(StartStopButton, true)
	end
end)

ResetButton.MouseButton1Click:Connect(function()
	if not HasStopped then return end
	
	IsTiming = false
	HasStopped = false
	
	if HeartbeatConnection then
		HeartbeatConnection:Disconnect()
	end
	
	StartTime = nil
	StopwatchElapsedTime = 0
	
	HourDisplay:SetText("00")
	MinuteDisplay:SetText("00")
	SecondDisplay:SetText("00")
	MilisecondDisplay:SetText("00")
	
	ToggleButtonTransparency(ResetButton, true)
	ToggleButtonTransparency(StartStopButton, false)
	
	StartStopButton.Text = "START"
end)

ToggleButtonTransparency(ResetButton, true)

HourDisplay:SetText("00")
MinuteDisplay:SetText("00")
SecondDisplay:SetText("00")
MilisecondDisplay:SetText("00")