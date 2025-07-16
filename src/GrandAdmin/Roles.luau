-----------------------------------------------------------------------------------------------------------------
-- Ranks/permission levels --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

-- Adjust or add onto these variables for your needs. 
-- Can be useful if you want to use a group with custom roles and values.

local PermissionLevels = {
	None = 1, -- No admin/default permission value
	Mod = 2,
	Admin = 3,
	Developer = 4,
	CoOwner = 254,
	Owner = 255, -- Max value
}

return PermissionLevels