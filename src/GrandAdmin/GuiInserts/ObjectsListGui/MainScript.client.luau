local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FunctionsFolder = ReplicatedStorage:WaitForChild("AdminRemoteFunctions")
local EventsFolder = ReplicatedStorage:WaitForChild("AdminRemoteEvents")

local GetObjectsFunction = FunctionsFolder:WaitForChild("GetAdminObjects")
local SendCommandEvent = EventsFolder:WaitForChild("SendAdminCommand")

local Gui = script.Parent
local MainFrame = Gui:WaitForChild("MainFrame")
local ListFrame = MainFrame:WaitForChild("ObjectsList")

local SummonCooldown = 0.5

local CanSummon = true

-- Main

local ObjectTemplateFrame = ListFrame:WaitForChild("TemplateFrame"):Clone()

local ObjectsList = GetObjectsFunction:InvokeServer()

if ObjectsList then
	for i, ObjectName in pairs(ObjectsList) do
		local NewObjectFrame = ObjectTemplateFrame:Clone()
		
		-- Set command title/names
		NewObjectFrame.Title.Text = ObjectName
		NewObjectFrame.Parent = ListFrame
		
		NewObjectFrame.SummonButton.MouseButton1Click:Connect(function()
			if CanSummon then
				CanSummon = false
				SendCommandEvent:FireServer("summon " .. ObjectName)
				task.wait(SummonCooldown)
				CanSummon = true
			end
			
		end)
	end
else
	local NewObjectFrame = ObjectTemplateFrame:Clone()
	NewObjectFrame.Title.Text = "No objects found"
	NewObjectFrame.SummonButton.Visible = false
	NewObjectFrame.Title.TextColor3 = Color3.new(0.5, 0.5, 0.5)
	NewObjectFrame.Parent = ListFrame
end

ListFrame.TemplateFrame:Destroy()