local PlayersService = game:GetService("Players")

local Main = script.Parent

local Roles = require(Main:WaitForChild("Roles"))

-- Some handy preset functions and variables that the internal commands use
local CommandHelper = require(Main.Modules:WaitForChild("CommandHelper"))
local SyntaxTypes = CommandHelper.SyntaxTypes

--[[ 

Write your own custom commands here!

Tips:

  - By default, if RankRequired is set to Roles.None, then that means anyone can use the command as that is
    the default permission level for all non-admin players
    
  - Set RankRequred to nil to disable the command
    
  - Use the CommandHelper module to access some very useful functions that the other internal
    commands use.
    
]]

-----------------------------------------------------------------------------------------------------------------
-- Custom Commands ----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

local Commands = {
	
	-- Example command (DISABLED BY DEFAULT)
	{
		Names = {"time"}, -- Command phrases/names
		Description = "Sets the time of day to a specified value",
		RankRequired = nil, -- SET A RANK TO ENABLE (such as Roles.Moderator)

		Function = function(Parameters, Admin) -- Parameters is a table containing an array of keywords
			local Time = tonumber(Parameters[1])
			
			game.Lighting.ClockTime = Time
		end,
		
		ParameterTypes = {SyntaxTypes.Number}, -- Used for the /commands gui
	},
}

return Commands