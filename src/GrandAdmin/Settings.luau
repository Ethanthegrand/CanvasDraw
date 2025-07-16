-----------------------------------------------------------------------------------------------------------------
-- Main Settings ------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

-- To create, edit or add onto the 'Roles' list, edit the Roles module
local Roles = require(script.Parent:WaitForChild("Roles"))

local Settings = {
	Admins = { -- Manual ranking (over-rides anyone in the group if GroupId is set)	
		-- Format: {UserId, Rank},
		{0000000, Roles.Mod}, -- Template, Rank 2 (Mod)

		-- Studio only
		{-1, Roles.Owner}, -- Player1 (owner perms)
		{-2, Roles.Mod}, -- Player2 (mod)
	},
	
	GroupId = nil, -- Give admin permissions to group members depending on rank (set to nil to disable)
	
	DefaultPermissionLevel = Roles.None, -- The permision level/rank for users who aren't in the 'Admins' list or in the group.
	
	CommandPrefixes = {"/", "!", ":", ";"}, -- The character(s) you type before a command's name (e.g. "/kill" or ":kill")
	
	-- DataStore settings
	DatastoreAccess = true, -- Allows for datastore based commands and funtions to work (ban listing, command logging, etc)
	
	-- Discord webhook logging
	BanLogWebhookURL = "", -- Sends an alert when a user gets banned or unbanned
	CommandLogWebhookURL = "", -- Sends an alert when an admin uses certain commands (You can edit which commands are affected in the 'Commands' module)
	
	-- Widget/UI appearance and accessibility
	WidgetTransparency = nil, -- Set to a number value to overwrite the widget background transparency
	WidgetBackgroundColour = nil, -- Set to a Color3 value to overwrite the widget back colour
	WidgetUIBlur = false, -- [EXPERIMENTAL] Gives all widgets a background blur/glass effect. Keep disabled if your game uses DepthOfField effect
	
	-- Shortcuts
	CommandbarShortcutKey = Enum.KeyCode.Semicolon, -- Set to 'nil' to disable
}

return Settings
