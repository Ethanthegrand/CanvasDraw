--!native

--[[
	FastCanvas is a simple, but very fast and efficent 
	drawing canvas with per pixel methods via EditableImage.
	
	This module was designed to be intergrated with CanvasDraw. 
	A real-time roblox pixel graphics engine.
	
	This can be used on normal GUI Frames AND Decals, Textures, MeshParts, etc

	Written by @Ethanthegrand14
	
	Created: 9/11/2023
	Last Updated: 19/09/2025
]]

local AssetService = game:GetService("AssetService")

local FastCanvas = {}

type ParentType = GuiObject | MeshPart | Decal | Texture

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

	buffer.writeu32(CurrentClearRGBA, 0, 4294967295) -- White
	-- Create gui objects

	local EditableImage = AssetService:CreateEditableImage({Size = Resolution})
	
	if not EditableImage then
		warn("Failed to create Canvas due to EditableImage memory limit being hit!")
		return nil :: typeof(Canvas)
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
	elseif CanvasParent:IsA("Decal") or CanvasParent:IsA("Texture") or CanvasParent:IsA("MeshPart") then
		CanvasParent.TextureContent = Content.fromObject(EditableImage)
	else
		error(CanvasParent.ClassName .. " is currently not supported as a canvas parent!")
	end
	
	-- Properties
	Canvas.Buffer = Grid
	
	-- Properties [READ ONLY]
	Canvas.ImageLabel = CanvasFrame
	Canvas.Image = EditableImage
	Canvas.Width, Canvas.Height = Width, Height


	-- Pixel methods
	
	--[[
		<strong>DEPRECATED</strong>
		
		For better alternatives, try;
		- <code>Canvas:SetU32()</code>
		- <code>Canvas:SetRGBA()</code>
	]]
	@deprecated function Canvas:SetColor3(X: number, Y: number, Colour: Color3)
		local Index = GetGridIndex(X, Y)
		buffer.writeu8(Grid, Index, Colour.R * 255)
		buffer.writeu8(Grid, Index + 1, Colour.G * 255)
		buffer.writeu8(Grid, Index + 2, Colour.B * 255)
	end
	
	-- Sets a pixel's RGB value on the canvas
	function Canvas:SetRGB(X: number, Y: number, R: number, G: number, B: number)
		local Index = GetGridIndex(X, Y)
		buffer.writeu8(Grid, Index, R * 255)
		buffer.writeu8(Grid, Index + 1, G * 255)
		buffer.writeu8(Grid, Index + 2, B * 255)
	end
	
	-- Sets a pixel's RGBA value on the canvas
	function Canvas:SetRGBA(X: number, Y: number, R: number, G: number, B: number, A: number)
		buffer.writeu32(Grid, GetGridIndex(X, Y), bit32bor(
			bit32lshift(A * 255, 24),
			bit32lshift(B * 255, 16),
			bit32lshift(G * 255, 8),
			R * 255)
		)
	end
	
	-- Sets the alpha value of a pixel on the canvas
	function Canvas:SetAlpha(X: number, Y: number, Alpha: number)
		buffer.writeu8(Grid, GetGridIndex(X, Y) + 3, Alpha * 255)
	end
	
	-- Sets the pixel value on the canvas by using a U32 colour value
	function Canvas:SetU32(X: number, Y: number, Value: number)
		buffer.writeu32(Grid, GetGridIndex(X, Y), Value)
	end

	-- Pixel fetch methods
	
	-- Returns the pixel value on the canvas as a tuple in order; R, G, B
	function Canvas:GetRGB(X: number, Y: number): (number, number, number)
		local Index = GetGridIndex(X, Y)

		return buffer.readu8(Grid, Index) / 255, buffer.readu8(Grid, Index + 1) / 255, buffer.readu8(Grid, Index + 2) / 255
	end
	
	-- Returns the pixel value on the canvas as a tuple in order; R, G, B, A
	function Canvas:GetRGBA(X: number, Y: number): (number, number, number, number)
		local Index = GetGridIndex(X, Y)

		return buffer.readu8(Grid, Index) / 255, buffer.readu8(Grid, Index + 1) / 255, buffer.readu8(Grid, Index + 2) / 255, buffer.readu8(Grid, Index + 3) / 255
	end
	
	-- Returns the pixel value on the canvas as a U32 number
	function Canvas:GetU32(X: number, Y: number): number
		return buffer.readu32(Grid, GetGridIndex(X, Y))
	end
	
	--[[
		<strong>DEPRECATED</strong>
		
		For better alternatives, try;
		- <code>Canvas:GetU32()</code>
		- <code>Canvas:GetRGBA()</code>
	]]
	@deprecated function Canvas:GetColor3(X: number, Y: number): Color3
		local Index = GetGridIndex(X, Y)

		return Color3.new(buffer.readu8(Grid, Index) / 255, buffer.readu8(Grid, Index + 1) / 255, buffer.readu8(Grid, Index + 2) / 255)
	end
	
	-- Returns the pixel alpha value on the canvas
	function Canvas:GetAlpha(X: number, Y: number): number
		local Index = GetGridIndex(X, Y)

		return buffer.readu8(Grid, Index + 3) / 255
	end

	-- Canvas methods
	
	--[[
		Takes a buffer of RGBA unsigned 8 bit int values (range from 0 to 255) to render all pixels on the canvas.
		
		You can also optionally use the <code>X, Y</code> and <code>BufferWidth, BufferHeight</code> parameters to also place a sized buffer region.
		
		The size of the buffer is assumed to be <strong>Width × Height × 4</strong>
	]]
	function Canvas:SetBuffer(Buffer: buffer, X: number?, Y: number?, BufferWidth: number?, BufferHeight: number?)
		-- Set a rectangular region from PointA to PointB
		if X and Y and BufferWidth and BufferHeight then
			if buffer.len(Buffer) ~= BufferWidth * BufferHeight * 4 then
				warn("'Canvas:SetBuffer()' failed as the given buffer's size is not equal to the given 'Size' parameter")
				return
			end

			local ScaledWidth = BufferWidth
			
			local OffsetY = 0
			local OffsetX = 0

			-- Clip start X
			if X < 1 then
				OffsetX = 1 + -X
				ScaledWidth -= 1 + -X
			end

			-- Clip width X
			if X + BufferWidth - 1 > Width then
				ScaledWidth -= (X + BufferWidth - 2) - Width + 1
			end

			-- Clip start Y
			if Y < 1 then
				OffsetY = 1 + -Y
			end

			local SampleStartX = 1 + OffsetX

			if SampleStartX > BufferWidth then return end

			for ImgY = 1 + OffsetY, BufferHeight do
				local PlacementY = Y + ImgY - 1

				if PlacementY > Height then break end

				local ImageBufferStartIndex = (SampleStartX + (ImgY - 1) * BufferWidth) * 4 - 4
				local DrawStartIndex = (X + OffsetX + (PlacementY - 1) * Width) * 4 - 4

				-- Copy a row of the image straight onto the main buffer
				buffer.copy(
					Grid,
					DrawStartIndex,
					Buffer,
					ImageBufferStartIndex,
					ScaledWidth * 4
				)
			end
		else
			-- Direct replacement
			buffer.copy(Grid, 0, Buffer)
		end
	end
	
	function Canvas:SetBufferLine(ColourU32, X1, X2, Y)
		if X1 > X2 then
			X1, X2 = X2, X1
		end

		-- Clipping
		X1 = math.floor(math.clamp(X1, 1, Width))
		X2 = math.floor(math.clamp(X2, 1, Width))
		Y = math.floor(math.clamp(Y, 1, Height))

		local StartIndex = (X1 + (Y - 1) * Width) * 4 - 4
		local EndIndex = (X2 + (Y - 1) * Width) * 4

		local Length = EndIndex - StartIndex
		local SizeStep = 4
		local Iterations = math.ceil(math.log(Length / 4, 2))

		Canvas:SetU32(X1, Y, ColourU32) -- Initial pixel to copy

		-- Copy until we fill the scanline
		for _ = 1, Iterations do
			local Count = math.min(SizeStep, Length - SizeStep)

			buffer.copy(Grid, StartIndex + SizeStep, Grid, StartIndex, Count)
			SizeStep += Count
		end
	end

	--[[
		Returns a buffer of RGBA values ranging from 0 to 255
		
		The size of this buffer must equal to <strong>Width × Height × 4</strong>
	]]
	function Canvas:GetBuffer(X: number?, Y: number?, BufferWidth: number?, BufferHeight: number?): buffer
		-- Gets a rectangular region from PointA to PointB
		if X and Y and BufferWidth and BufferHeight then
			local ReturnBuffer = buffer.create(BufferWidth * BufferHeight * 4)

			local ScaledWidth = BufferWidth

			local OffsetY = 0
			local OffsetX = 0

			-- Clip start X
			if X < 1 then
				OffsetX = 1 + -X
				ScaledWidth -= 1 + -X
			end

			-- Clip width X
			if X + BufferWidth - 1 > Width then
				ScaledWidth -= (X + BufferWidth - 2) - Width + 1
			end

			-- Clip start Y
			if Y < 1 then
				OffsetY = 1 + -Y
			end

			local SampleStartX = 1 + OffsetX

			if SampleStartX > BufferWidth then return end

			for ImgY = 1 + OffsetY, BufferHeight do
				local PlacementY = Y + ImgY - 1

				if PlacementY > Height then break end

				local ImageBufferStartIndex = (SampleStartX + (ImgY - 1) * BufferWidth) * 4 - 4
				local DrawStartIndex = (X + OffsetX + (PlacementY - 1) * Width) * 4 - 4

				-- Copy a row of the image straight onto the main buffer
				buffer.copy(
					ReturnBuffer,
					ImageBufferStartIndex,
					Grid,
					DrawStartIndex,
					ScaledWidth * 4
				)
			end
			
			return ReturnBuffer
		else
			local ReturnBuffer = buffer.create(Width * Height * 4)
			buffer.copy(ReturnBuffer, 0, Grid)

			return ReturnBuffer
		end
		
	end

	function Canvas:SetClearRGBA(R, G, B, A)
		local ClearColU32 = bit32bor(
			bit32lshift(A * 255, 24),
			bit32lshift(B * 255, 16),
			bit32lshift(G * 255, 8),
			R * 255
		)

		Canvas:SetBufferLine(ClearColU32, 1, Width, 1)
		
		local InitialBuffer = Canvas:GetBuffer(1, 1, Width, 1)
		local Grid = Canvas.Buffer

		for Y = 1, Height - 1 do
			buffer.copy(
				ClearingGrid,
				Y * Width * 4,
				InitialBuffer
			)
		end
	end
	
	--[[
		Clears the canvas and replaces all pixels with the canvas clearing colour.
		This method is much faster than Canvas:Fill()
				
		Use <code>Canvas:SetClearRGBA()</code> to change the colour used
	]]
	function Canvas:Clear()
		buffer.copy(Grid, 0, ClearingGrid, 0)
	end

	function Canvas:Render()
		EditableImage:WritePixelsBuffer(Origin, Resolution, Grid)
	end

	function Canvas:Resize(NewWidth, NewHeight)	
		local NewEditableImage = AssetService:CreateEditableImage({Size = Vector2.new(NewWidth, NewHeight)})
		
		if not EditableImage then
			warn("Failed to resize Canvas due to EditableImage memory limit being hit!")
			return
		end
		
		Width, Height = NewWidth, NewHeight
		Resolution = Vector2.new(NewWidth, NewHeight)

		EditableImage:Destroy()
		EditableImage = NewEditableImage

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
		
		self.Buffer = Grid
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