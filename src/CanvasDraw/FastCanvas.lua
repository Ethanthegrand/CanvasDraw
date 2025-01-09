--!native

--[[
	FastCanvas is a simple, but very fast and efficent 
	drawing canvas with per pixel methods via EditableImage.
	
	This module was designed to be intergrated with CanvasDraw. 
	A real-time roblox pixel graphics engine.
	
	This can be used on normal GUI Frames AND Decals, Textures, MeshParts, etc

	Written by @Ethanthegrand14
	
	Created: 9/11/2023
	Last Updated: 6/01/2024
]]

local AssetService = game:GetService("AssetService")

local FastCanvas = {}

type ParentType = GuiObject | MeshPart

local bit32bor = bit32.bor
local bit32lshift = bit32.lshift

function FastCanvas.new(Width: number, Height: number, CanvasParent: ParentType, Blur: boolean?)
	local IsUiParent = CanvasParent:IsA("GuiObject")

	local Canvas = {} -- The canvas object
	local Grid = buffer.create(Width * Height * 4) -- Local pixel grid containing RGBA values
	local CurrentClearRGBA = buffer.create(4)
	local ClearingGrid = buffer.create(Width * Height * 4) -- For Canvas:Clear()

	local Origin = Vector2.zero
	local Resolution = Vector2.new(Width, Height)

	-- Local functions
	local function GetGridIndex(X, Y)
		return (X + (Y - 1) * Width) * 4 - 4
	end

	-- Initialise buffers
	buffer.fill(Grid, 0, 255)
	buffer.fill(ClearingGrid, 0, 255)

	buffer.writeu8(CurrentClearRGBA, 0, 255)
	buffer.writeu8(CurrentClearRGBA, 1, 255)
	buffer.writeu8(CurrentClearRGBA, 2, 255)
	buffer.writeu8(CurrentClearRGBA, 3, 255)
	-- Create gui objects

	local EditableImage = AssetService:CreateEditableImage({Size = Resolution})

	if not EditableImage then
		repeat
			warn("Failed to create Canvas due to EditableImage memory limit being hit! Retrying in 5 seconds...")
			EditableImage = AssetService:CreateEditableImage({Size = Resolution})
			task.wait(5)
		until EditableImage
	end

	local CanvasFrame
	local AspectRatio

	if IsUiParent then
		CanvasFrame = Instance.new("ImageLabel")
		CanvasFrame.Name = "FastCanvas"
		CanvasFrame.BackgroundTransparency = 1
		CanvasFrame.ClipsDescendants = true
		CanvasFrame.Size = UDim2.fromScale(1, 1)
		CanvasFrame.Position = UDim2.fromScale(0.5, 0.5)
		CanvasFrame.AnchorPoint = Vector2.new(0.5, 0.5)

		if not Blur then
			CanvasFrame.ResampleMode = Enum.ResamplerMode.Pixelated
		end

		AspectRatio = Instance.new("UIAspectRatioConstraint")
		AspectRatio.AspectRatio = Width / Height
		AspectRatio.Parent = CanvasFrame

		CanvasFrame.ImageContent = Content.fromObject(EditableImage)
		CanvasFrame.Parent = CanvasParent
	else
		assert(CanvasParent:IsA("MeshPart"), CanvasParent.ClassName .. " is currently not supported as a canvas parent!")
		CanvasParent.TextureContent = Content.fromObject(EditableImage)
	end

	-- Properties [READ ONLY]
	Canvas.ImageLabel = CanvasFrame
	Canvas.Image = EditableImage
	Canvas.Width, Canvas.Height = Width, Height


	-- Pixel methods
	
	--[[
		A simple way to set a pixel colour on the canvas.
		
		For faster alternatives, try;
		- <code>Canvas:SetRGB()</code>
		- <code>Canvas:SetPixel()</code>
	]]
	function Canvas:SetColor3(X: number, Y: number, Colour: Color3)
		local Index = GetGridIndex(X, Y)
		buffer.writeu8(Grid, Index, Colour.R * 255)
		buffer.writeu8(Grid, Index + 1, Colour.G * 255)
		buffer.writeu8(Grid, Index + 2, Colour.B * 255)
	end
	
	-- Sets a pixels RGB value on the canvas
	function Canvas:SetRGB(X: number, Y: number, R: number, G: number, B: number)
		local Index = GetGridIndex(X, Y)
		buffer.writeu8(Grid, Index, R * 255)
		buffer.writeu8(Grid, Index + 1, G * 255)
		buffer.writeu8(Grid, Index + 2, B * 255)
	end
	
	-- Sets a pixels RGBA value on the canvas
	function Canvas:SetRGBA(X: number, Y: number, R: number, G: number, B: number, A: number)
		buffer.writeu32(Grid, GetGridIndex(X, Y), bit32bor(
			bit32lshift(A * 255, 24),
			bit32lshift(B * 255, 16),
			bit32lshift(G * 255, 8),
			R * 255
		)) 
	end
	
	-- Sets the alpha value of a pixel on the canvas
	function Canvas:SetAlpha(X: number, Y: number, Alpha: number)
		buffer.writeu8(Grid, GetGridIndex(X, Y) + 3, Alpha * 255)
	end
	
	function Canvas:SetU32(X: number, Y: number, Value: number)
		buffer.writeu32(Grid, GetGridIndex(X, Y), Value)
	end

	-- Pixel fetch methods

	function Canvas:GetRGB(X: number, Y: number): (number, number, number)
		local Index = GetGridIndex(X, Y)

		return buffer.readu8(Grid, Index) / 255, buffer.readu8(Grid, Index + 1) / 255, buffer.readu8(Grid, Index + 2) / 255
	end
	
	function Canvas:GetRGBA(X: number, Y: number): (number, number, number)
		local Index = GetGridIndex(X, Y)

		return buffer.readu8(Grid, Index) / 255, buffer.readu8(Grid, Index + 1) / 255, buffer.readu8(Grid, Index + 2) / 255, buffer.readu8(Grid, Index + 2) / 255
	end
	
	function Canvas:GetU32(X: number, Y: number): number
		return buffer.readu32(Grid, GetGridIndex(X, Y))
	end

	function Canvas:GetColor3(X: number, Y: number): Color3
		local Index = GetGridIndex(X, Y)

		return Color3.new(buffer.readu8(Grid, Index) / 255, buffer.readu8(Grid, Index + 1) / 255, buffer.readu8(Grid, Index + 2) / 255)
	end

	function Canvas:GetAlpha(X: number, Y: number): number
		local Index = GetGridIndex(X, Y)

		return buffer.readu8(Grid, Index + 3) / 255
	end

	-- Canvas methods

	function Canvas:SetGrid(PixelArray: {number})
		for i, Value in pairs(PixelArray) do
			buffer.writeu8(Grid, i - 1, Value * 255)
		end
	end

	function Canvas:SetBuffer(Buffer: buffer)
		buffer.copy(Grid, 0, Buffer)
	end

	function Canvas:GetGrid(): {number}
		local ReturnArray = {}

		for i = 1, Width * Height * 4 do
			ReturnArray[i] = buffer.readu8(Grid, i - 1) / 255
		end

		return ReturnArray
	end

	function Canvas:GetBuffer(): buffer
		local ReturnBuffer = buffer.create(Width * Height * 4)
		buffer.copy(ReturnBuffer, 0, Grid)

		return ReturnBuffer
	end

	function Canvas:SetClearRGBA(R, G, B, A)
		R *= 255
		G *= 255
		B *= 255
		A *= 255

		buffer.writeu8(CurrentClearRGBA, 0, R)
		buffer.writeu8(CurrentClearRGBA, 1, G)
		buffer.writeu8(CurrentClearRGBA, 2, B)
		buffer.writeu8(CurrentClearRGBA, 3, A)

		for i = 0, Width * Height * 4 - 1, 4 do
			buffer.writeu32(ClearingGrid, i, buffer.readu32(CurrentClearRGBA, 0))
		end
	end

	function Canvas:Clear()
		buffer.copy(Grid, 0, ClearingGrid, 0)
	end

	function Canvas:Render()
		EditableImage:WritePixelsBuffer(Origin, Resolution, Grid)
	end

	function Canvas:Resize(NewWidth, NewHeight)	
		Width, Height = NewWidth, NewHeight
		Resolution = Vector2.new(NewWidth, NewHeight)
		EditableImage:Destroy()

		EditableImage = AssetService:CreateEditableImage({Size = Resolution})

		CanvasFrame.ImageContent = Content.fromObject(EditableImage)

		self.Width, self.Height = NewWidth, NewHeight

		if AspectRatio then
			AspectRatio.AspectRatio = NewWidth / NewHeight
		end

		-- Initialise buffers

		Grid = buffer.create(NewWidth * NewHeight * 4)
		ClearingGrid = buffer.create(NewWidth * NewHeight * 4)

		buffer.fill(Grid, 0, 255)

		self:SetClearRGBA(
			buffer.readu8(CurrentClearRGBA, 0) / 255,
			buffer.readu8(CurrentClearRGBA, 1) / 255,
			buffer.readu8(CurrentClearRGBA, 2) / 255,
			buffer.readu8(CurrentClearRGBA, 3) / 255
		)

		self:Clear()
	end

	function Canvas:Destroy()
		if CanvasFrame then
			CanvasFrame:Destroy()
		end
		if EditableImage then
			EditableImage:Destroy()
		end
		Grid = nil
		Canvas = nil
	end

	return Canvas
end

return FastCanvas