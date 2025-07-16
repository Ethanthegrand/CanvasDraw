local Players = game:GetService("Players")

local CurrentPlayer = script:WaitForChild("CurrentPlayer")

local TrackHighlight = script:WaitForChild("TrackHighlight")
local TrackBeam = script:WaitForChild("TrackBeam")

local LocalPlr = Players.LocalPlayer
local TargetPlr : Player = CurrentPlayer.Value

if not TargetPlr then
	script.Enabled = false
	return
end

local TrackBeamAttach0
local TrackBeamAttach1

local function ToggleBeam(Enabled, Part0, Part1)
	if Enabled then
		TrackBeamAttach0 = Part0:FindFirstChild("_TrackAttachment0")
		TrackBeamAttach1 = Part1:FindFirstChild("_TrackAttachment1")
		
		if not TrackBeamAttach0 then
			TrackBeamAttach0 = Instance.new("Attachment", Part0)
			TrackBeamAttach0.Name = "_TrackAttachment0"
		end
		
		if not TrackBeamAttach1 then
			TrackBeamAttach1 = Instance.new("Attachment", Part1)
			TrackBeamAttach1.Name = "_TrackAttachment1"
		end
		
		TrackBeam.Attachment0 = TrackBeamAttach0
		TrackBeam.Attachment1 = TrackBeamAttach1
	end
	
	TrackBeam.Enabled = Enabled
	TrackHighlight.Enabled = Enabled
end

	
local AdminChar = LocalPlr.Character
local TargetChar = TargetPlr.Character

if AdminChar and TargetChar then
	TrackHighlight.Adornee = TargetChar
	local AdminHRP = AdminChar:FindFirstChild("HumanoidRootPart")
	local TargetHRP = TargetChar:FindFirstChild("HumanoidRootPart")
	
	if AdminHRP and TargetHRP then
		ToggleBeam(true, AdminHRP, TargetHRP)
	else
		script.Enabled = false
		return
	end
else
	script.Enabled = false
	return
end

TargetPlr.CharacterAdded:Connect(function(Character)
	ToggleBeam(false)
	
	local TargetHRP
	local AdminHRP
	
	repeat
		TargetHRP = Character:FindFirstChild("HumanoidRootPart")
		AdminHRP = AdminChar:FindFirstChild("HumanoidRootPart")
		task.wait(0.1)
	until TargetHRP and AdminHRP
	
	TrackHighlight.Adornee = Character
	ToggleBeam(true, AdminHRP, TargetHRP)
end)