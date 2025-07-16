--[[
	================== SevenSegment ===================
	
	Created by: Ethanthegrand (@Ethanthegrand14)
	
	Last updated: 14/08/2023
	Version: 1.0.0
	
	Learn how to use the module here: https://devforum.roblox.com/t/2526209
	
	
	====================== API ========================
	
	> SevenSegment Module Functions
	
		SevenSegment.new(Frame : GuiObject, Digits : number?, DisplayInfo : table?)
			- Creates and returns a new Display object with an optional amount of digits and a DisplayInfo
			  to affect appearance.
	
	
	> Display Object Methods
	
		Display:Set(Character : number | string, DigitPosition: number?)
			- Changes the selected digit/character in the row.
			- If DigitPosition is empty, it will default to the first 
			  digit in your display.
		
		Display:SetText(Text : string | number)
			- Changes the entire row of characters from a given string or number.
		
		Display:SetColours(OnColour : Color3, OffColour : Color3?, DigitPosition: number?)
			- Changes the selected digit segment colours.
			- If OffColour is left empty or set to nil, it will use visibility instead of a colour.
			- If DigitPosition is left empty, then all digits will be affected
			
		Display:SetVisibility(Visible : boolean, DigitPosition: number?)
			- Changes the selected digit segment colours.
			- If OffColour is left empty or set to nil, it will use visibility instead of a colour.
			- If DigitPosition is left empty, then all digits will be affected
		
		Display:Destroy()
			- Destroys the Display object and all related instances and frames
			  that were created.
		
	
	=============== DisplayInfo ================
	
	Here are all the valid parameters of a DisplayInfo table which you can feed into the
	SevenSegment.new() function to customise your display:
	
	DisplayInfo = {
		OnColour : Color3,
		OffColour : Color3,
		Thickness : number,
		SeamSize : number,
		Italics : boolean,
		HorizontalAlignment : Enum.HorizontalAlignment,
		LayoutSpacing : UDim
	}
	
]]

local MainModule = {}

local CharacterSheet = require(script:WaitForChild("CharacterSheet"))
local SegmentDisplayTemplate = script:WaitForChild("SegmentDisplayTemplate")
local SegmentDisplayItalicsTemplate = script:WaitForChild("SegmentDisplayItalicsTemplate")

function MainModule.new(Frame: GuiObject, Digits: number?, DisplayInfo: {}?)
	assert(Frame and Frame:IsA("GuiObject"), "Module Error - Argument 1. Please provide a valid GuiObject")
	
	local RowContainer = Instance.new("Frame")
	RowContainer.AutomaticSize = Enum.AutomaticSize.X
	RowContainer.BackgroundTransparency = 1
	RowContainer.Size = UDim2.fromScale(1, 1)
	RowContainer.Name = "SegmentDisplayRow"
	RowContainer.Parent = Frame
	RowContainer.Visible = true
	
	-- Set up main display properties
	local Thickness = math.ceil(RowContainer.AbsoluteSize.Y / 12)
	local ItalicsEnabled = false
	local SeamSize = 1.5
	local SegmentOnColour = Color3.new(1, 1, 1)
	local SegmentOffColour
	local HorizontalAlignment = Enum.HorizontalAlignment.Left
	local LayoutSpacing = UDim.new(0, 15)
	
	local AutomaticScaling = not DisplayInfo or not DisplayInfo.Thickness
	
	if DisplayInfo then
		-- Segment colouring
		SegmentOnColour = DisplayInfo.OnColour or SegmentOnColour
		SegmentOffColour = DisplayInfo.OffColour or SegmentOffColour
		
		-- Segment sizing and offset
		Thickness = DisplayInfo.Thickness or Thickness
		SeamSize = DisplayInfo.SeamSize or SeamSize
		
		ItalicsEnabled = DisplayInfo.Italics or ItalicsEnabled
		
		HorizontalAlignment = DisplayInfo.HorizontalAlignment or HorizontalAlignment
		LayoutSpacing = DisplayInfo.LayoutSpacing or LayoutSpacing
	end
	
	-- Create display(s)
	local SegmentDisplay = {
		Frame = Frame,
		DigitCount = Digits or 1,
		
		-- Properties
		OnColour = SegmentOnColour,
		OffColour = SegmentOffColour,
		
		-- Internal variables
		CurrentDisplays = {}
	}

	local ListLayout = Instance.new("UIListLayout")
	ListLayout.FillDirection = Enum.FillDirection.Horizontal
	ListLayout.HorizontalAlignment = HorizontalAlignment or Enum.HorizontalAlignment.Left
	ListLayout.Padding = LayoutSpacing
	ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	ListLayout.Parent = RowContainer
	
	local TemplateToUse
	
	if ItalicsEnabled then
		TemplateToUse = SegmentDisplayItalicsTemplate
	else
		TemplateToUse = SegmentDisplayTemplate
	end
	
	local function AdjustSegmentFrames(FramesTable)
		local AbsoluteThickness = Thickness
		local PixelSeamSize = (AbsoluteThickness / 2) * SeamSize
		
		for i, Segment in ipairs(FramesTable) do
			if i == 1 or i == 4 or i == 7 then 
				-- Horizontal segments
				Segment.Size = UDim2.new(1, -AbsoluteThickness, 0, AbsoluteThickness)
			else
				Segment.Size = UDim2.new(1, -PixelSeamSize, 0, AbsoluteThickness)
			end
		end

		-- Adjust vertical segment proportions
		FramesTable[2].Position = UDim2.new(1, -AbsoluteThickness / 2, 0.25, AbsoluteThickness / 4)
		FramesTable[6].Position = UDim2.new(0, AbsoluteThickness / 2, 0.25, AbsoluteThickness / 4)

		FramesTable[3].Position = UDim2.new(1, -AbsoluteThickness / 2, 0.75, -AbsoluteThickness / 4)
		FramesTable[5].Position = UDim2.new(0, AbsoluteThickness / 2, 0.75, -AbsoluteThickness / 4)
	end
	
	if AutomaticScaling then
		Thickness = math.ceil(RowContainer.AbsoluteSize.Y / 12)
	end
	
	for i = 1, SegmentDisplay.DigitCount do
		local DisplayFrame = TemplateToUse:Clone()
		DisplayFrame.Name = "SegmentDisplay" .. i
		DisplayFrame.Parent = RowContainer
		DisplayFrame.LayoutOrder = i
		DisplayFrame.Visible = true

		local SegmentFrames = {
			DisplayFrame.TopSegment,
			DisplayFrame.TopRightSegment,
			DisplayFrame.BottomRightSegment,
			DisplayFrame.BottomSegment,
			DisplayFrame.BottomLeftSegment,
			DisplayFrame.TopLeftSegment,
			DisplayFrame.MiddleSegment,
		}
		
		local DisplayProperties = { -- Individual seven segment display
			EnabledSegments = {false, false, false, false, false, false, false},
			OnColour = SegmentOnColour,
			OffColour = SegmentOffColour,
			SegmentFrames = SegmentFrames,
			IsVisible = true
		}
		
		for i, Segment in ipairs(SegmentFrames) do
			if SegmentOffColour then
				Segment.ImageColor3 = SegmentOffColour
			else
				Segment.Visible = false
			end
		end

		AdjustSegmentFrames(SegmentFrames)

		table.insert(SegmentDisplay.CurrentDisplays, DisplayProperties)	
	end
	
	local AutoScaleConnection
	
	-- Automatically rescale the segments
	if AutomaticScaling then
		AutoScaleConnection = RowContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			Thickness = math.ceil(RowContainer.AbsoluteSize.Y / 12)
			
			for i = 1, SegmentDisplay.DigitCount do
				AdjustSegmentFrames(SegmentDisplay.CurrentDisplays[i].SegmentFrames)
			end
		end)
	end
	
	-- Methods
	function SegmentDisplay:Set(Character: number | string, DigitPosition: number?)
		DigitPosition = DigitPosition or 1
		
		if DigitPosition > #self.CurrentDisplays then return end
		
		assert(Character and tostring(Character), "Module Error - Arugment 1. Invalid number/string")
		assert(
			DigitPosition and tonumber(DigitPosition) and math.floor(DigitPosition) == DigitPosition, 
			"Module Error - Argument 2. Invalid value. DisplayPosition must be an interger"
		)
		
		local Display = self.CurrentDisplays[DigitPosition]
		
		if not Display.IsVisible then return end

		local SegmentData = CharacterSheet[tostring(Character)] -- Number, symbol, letter

		if not SegmentData then
			SegmentData = CharacterSheet[tostring(Character):lower()] -- lowercase letter
		end
		
		if not SegmentData then
			-- Invalid character
			for i, Segment in ipairs(Display.SegmentFrames) do
				if self.OffColour then
					Segment.ImageColor3 = self.OffColour
				else
					Segment.Visible = false
				end
			end
			return
		end
		
		-- Set the segments
		for i, Segment in ipairs(Display.SegmentFrames) do
			local Lit = SegmentData[i] and SegmentData[i] == 1
			
			Display.EnabledSegments[i] = Lit

			if Lit then
				Segment.Visible = true
				Segment.ImageColor3 = self.OnColour
			elseif self.OffColour then
				Segment.ImageColor3 = self.OffColour
			else
				Segment.Visible = false
			end
		end
	end

	function SegmentDisplay:SetText(Text: string | number)	
		assert(Text and tostring(Text), "Module Error - Argument 1. Please provide a valid string or number")
		
		local Characters = string.split(tostring(Text), "")

		for i = 1, #self.CurrentDisplays do
			if Characters[i] then
				self:Set(Characters[i], i)
			else
				self:Set("", i)
			end
		end
	end
	
	function SegmentDisplay:SetColours(OnColour: Color3, OffColour: Color3?, DigitPosition: number?)	
		assert(OnColour and typeof(OnColour) == "Color3", "Module Error - Argument 1. Please provide a valid Color3 value")
		assert(not OnColour or typeof(OnColour) == "Color3", "Module Error - Argument 2. Please provide a valid Color3 value")
		
		local function AdjustDisplay(Display)
			self.OnColour = OnColour
			
			if OffColour then
				self.OffColour = OffColour
			end
			
			if Display.IsVisible then
				for i, SegmentFrame in ipairs(Display.SegmentFrames) do
					if Display.EnabledSegments[i] then
						SegmentFrame.ImageColor3 = OnColour
					elseif OffColour then
						SegmentFrame.ImageColor3 = OffColour
						SegmentFrame.Visible = true
					end
				end
			end
		end
		
		if DigitPosition then	
			AdjustDisplay(self.CurrentDisplays[DigitPosition])
		else
			for i, Display in ipairs(self.CurrentDisplays) do
				AdjustDisplay(self.CurrentDisplays[i])
			end
		end
	end
	
	function SegmentDisplay:SetVisibility(Visible: boolean, DigitPosition: number?)	
		local function SetDisplay(Display)
			for i, Segment in ipairs(Display.SegmentFrames) do
				
				if Display.EnabledSegments[i] and Visible then
					Segment.ImageColor3 = self.OnColour
					Segment.Visible = true
				elseif self.OffColour and Visible then
					Segment.ImageColor3 = self.OffColour
					Segment.Visible = true
				else
					Segment.Visible = false
					Segment.ImageColor3 = self.OnColour
				end
				
			end
			
			Display.IsVisible = Visible
		end
		
		if DigitPosition then	-- Selected display
			SetDisplay(self.CurrentDisplays[DigitPosition])
		else -- Whole row
			for i, Display in ipairs(self.CurrentDisplays) do
				SetDisplay(self.CurrentDisplays[i])
			end
		end
	end
	
	function SegmentDisplay:Destroy()
		if AutoScaleConnection then
			AutoScaleConnection:Disconnect()
		end
		
		RowContainer:Destroy()
		
		table.clear(SegmentDisplay.CurrentDisplays)
		table.clear(SegmentDisplay)
	end
	
	return SegmentDisplay
end

return MainModule
