local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local EventsFolder = ReplicatedStorage:WaitForChild("AdminRemoteEvents")

local GetBannedDataEvent = EventsFolder:WaitForChild("SendBannedPlrData")

local Gui = script.Parent
local MainFrame = Gui:WaitForChild("MainFrame")
local ListFrame = MainFrame:WaitForChild("ObjectsList")

-- Main

GetBannedDataEvent.OnClientEvent:Connect(function(BanData)
	if BanData and BanData.ExtraData then
		local Username = BanData.ExtraData.Username
		local UserID = BanData.ExtraData.UserID
		local UserWhoBanned = BanData.ExtraData.Moderator
		local BanDuration = BanData.ExtraData.Duration
		local BanReason = BanData.ExtraData.Reason
		
		local IsPermBanned = BanDuration > 10000000000 or BanDuration == -1
		
		local BanTimeRemaining = (BanData.UnbanDate - os.time())
		
		local BanDaysRemaining = math.max(0, math.ceil(BanTimeRemaining / 86400))
		local BanHoursRemaining = math.max(0, math.ceil(BanTimeRemaining / 3600))
		
		if UserWhoBanned then
			MainFrame.ObjectsList.ModeratorText.Text = "<b>BANNED BY:</b> " .. UserWhoBanned
		end
		
		if BanDuration then
			if IsPermBanned then
				MainFrame.ObjectsList.BanLengthText.Text = "<b>BAN TIME:</b> Forever"
			else
				MainFrame.ObjectsList.BanLengthText.Text = "<b>BAN TIME:</b> " .. BanDuration .. " days"
			end
		end
		
		if BanReason then
			MainFrame.ObjectsList.ReasonText.Text = "<b>REASON:</b> " .. BanReason
		end
		
		local BanState
		
		if BanDaysRemaining == 0 then
			BanState = [[<font color="rgb(0,255,0)">ENDED</font>]]
		elseif IsPermBanned then
			BanState = [[<font color="rgb(255,0,0)">P BANNED</font>]]
		else
			BanState = [[<font color="rgb(255,0,0)">BANNED</font>]]
		end
		
		if BanDaysRemaining <= 1 then
			MainFrame.ObjectsList.BanTimeLeftText.Text = "<b>UNBANNED IN:</b> " .. BanHoursRemaining .. " hours"
		elseif IsPermBanned then
			MainFrame.ObjectsList.BanTimeLeftText.Text = "<b>UNBANNED IN:</b> N/A"
		else
			MainFrame.ObjectsList.BanTimeLeftText.Text = "<b>UNBANNED IN:</b> " .. BanDaysRemaining .. " days"
		end
		
		MainFrame.ObjectsList.BanStateText.Text = "<b>BAN STATE:</b> " .. BanState
		
		if UserID then
			MainFrame.UserIDTextBox.Text = BanData.ExtraData.UserID
			
			-- Profile image
			local ThumbType = Enum.ThumbnailType.AvatarThumbnail
			local ThumbSize = Enum.ThumbnailSize.Size420x420
			local ImageID, IsReady = Players:GetUserThumbnailAsync(BanData.ExtraData.UserID, ThumbType, ThumbSize)
			
			MainFrame.UserProfileImage.Image = ImageID
		end
		
		if Username then
			MainFrame.UsernameTextBox.Text = Username
		end
	end
end)