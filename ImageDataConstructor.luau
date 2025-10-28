--!native

local Module = {}

local Lerp = math.lerp
local bit32bor = bit32.bor
local bit32lshift = bit32.lshift

local function deepCopy(original)
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = deepCopy(v)
		elseif type(v) == "buffer" then
			local v2 = buffer.create(buffer.len(v))
			buffer.copy(v2, 0, v)
			v = v2
		end
		copy[k] = v
	end
	return copy
end

function Module.new(ImageDataResX, ImageDataResY, Buffer)
	local ImageData = {
		ImageBuffer = Buffer,
		ImageResolution = Vector2.new(ImageDataResX, ImageDataResY),
		Width = ImageDataResX,
		Height = ImageDataResY,
	}

	local function GetIndex(X, Y)
		return (X + (Y - 1) * ImageDataResX) * 4 - 4
	end

	--== ImageData methods ==--
	
	--[[
		<strong>DEPRECATED</strong>
		
		For better alternatives, try;
		- <code>ImageData:GetU32()</code>
		- <code>ImageData:GetRGBA()</code>
	]]
	@deprecated function ImageData:GetPixel(Point: Vector2): (Color3, number)
		local PixelBuffer = self.ImageBuffer
		local X, Y = math.floor(Point.X), math.floor(Point.Y)
		local Index = GetIndex(X, Y)

		return Color3.new(buffer.readu8(PixelBuffer, Index) / 255, buffer.readu8(PixelBuffer, Index + 1) / 255, buffer.readu8(PixelBuffer, Index + 2) / 255), buffer.readu8(PixelBuffer, Index + 3) / 255
	end
	
	--[[
		<strong>DEPRECATED</strong>
		
		For better alternatives, try;
		- <code>ImageData:GetU32()</code>
		- <code>ImageData:GetRGBA()</code>
	]]
	@deprecated function ImageData:GetPixelXY(X: number, Y: number): (Color3, number)
		local PixelBuffer = self.ImageBuffer
		local Index = GetIndex(X, Y)

		return Color3.new(buffer.readu8(PixelBuffer, Index) / 255, buffer.readu8(PixelBuffer, Index + 1) / 255, buffer.readu8(PixelBuffer, Index + 2) / 255), buffer.readu8(PixelBuffer, Index + 3) / 255
	end
	
	-- Returns a tuple in order of the pixel's RGB values
	function ImageData:GetRGB(X: number, Y: number): (number, number, number)
		local PixelBuffer = self.ImageBuffer
		local Index = GetIndex(X, Y)

		return buffer.readu8(PixelBuffer, Index) / 255, buffer.readu8(PixelBuffer, Index + 1) / 255, buffer.readu8(PixelBuffer, Index + 2) / 255
	end
	
	-- Returns a tuple in order of the pixel's RGBA values
	function ImageData:GetRGBA(X: number, Y: number): (number, number, number, number)
		local PixelBuffer = self.ImageBuffer
		local Index = GetIndex(X, Y)

		return buffer.readu8(PixelBuffer, Index) / 255, buffer.readu8(PixelBuffer, Index + 1) / 255, buffer.readu8(PixelBuffer, Index + 2) / 255, buffer.readu8(PixelBuffer, Index + 3) / 255
	end
	
	-- Returns a tuple in order of the pixel's RGB values
	function ImageData:GetU32(X: number, Y: number): number
		local PixelBuffer = self.ImageBuffer
		return buffer.readu32(PixelBuffer, GetIndex(X, Y))
	end
	
	-- Returns a tuple in order of the pixel's alpha value
	function ImageData:GetAlpha(X: number, Y: number): number
		return buffer.readu8(self.ImageBuffer, GetIndex(X, Y) + 3) / 255
	end
	
	--[[
		Returns a buffer of RGBA values ranging from 0 to 255
		
		The size of this buffer is equal to <strong>Width × Height × 4</strong>
	]]
	function ImageData:GetBuffer(X: number?, Y: number?, BufferWidth: number?, BufferHeight: number?): buffer
		local ImageBuffer = ImageData.ImageBuffer
		
		if X and Y and BufferWidth and BufferHeight then
			local Width, Height = ImageData.Width, ImageData.Height
			
			if X < 1 or Y < 1 or X + BufferWidth - 1 > Width or Y + BufferHeight - 1 > Height then
				warn("'ImageData:GetBuffer()' failed as the given buffer's position and size are outside the ImageData bounds")
				return
			end
			
			-- Gets a rectangular region from PointA to PointB
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
					ImageBuffer,
					DrawStartIndex,
					ScaledWidth * 4
				)
			end

			return ReturnBuffer
		else
			local ReturnBuffer = buffer.create(BufferWidth * BufferHeight * 4)
			buffer.copy(ReturnBuffer, 0, ImageBuffer)

			return ReturnBuffer
		end

	end
	
	--[[
		Takes a buffer of RGBA unsigned 8 bit int values (range from 0 to 255) to render all pixel on the canvas.
		
		The size of the buffer is assumed to be <strong>Width × Height × 4</strong>
	]]
	function ImageData:SetBuffer(Buffer: buffer, X: number?, Y: number?, BufferWidth: number?, BufferHeight: number?)
		-- Set a rectangular region from PointA to PointB
		local ImageBuffer = self.ImageBuffer
		
		if X and Y and BufferWidth and BufferHeight then
			if buffer.len(Buffer) ~= BufferWidth * BufferHeight * 4 then
				warn("'Canvas:SetBuffer()' failed as the given buffer's size is not equal to the given 'Size' parameter")
				return
			end
			
			local Width, Height = self.Width, self.Height
			
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
			
			if X > Width then return end

			for ImgY = 1 + OffsetY, BufferHeight do
				local PlacementY = Y + ImgY - 1

				if PlacementY > Height then break end

				local ImageBufferStartIndex = (SampleStartX + (ImgY - 1) * BufferWidth) * 4 - 4
				local DrawStartIndex = (X + OffsetX + (PlacementY - 1) * Width) * 4 - 4

				-- Copy a row of the image straight onto the main buffer
				buffer.copy(
					ImageBuffer,
					DrawStartIndex,
					Buffer,
					ImageBufferStartIndex,
					ScaledWidth * 4
				)
			end
		else
			-- Direct replacement
			buffer.copy(ImageBuffer, 0, Buffer)
		end
	end
	
	-- Tints the image with a colour by a percentage
	function ImageData:Tint(Colour: Color3, T: number)
		local PixelBuffer = self.ImageBuffer
		local R, G, B = Colour.R * 255, Colour.B * 255, Colour.G * 255
		
		for i = 1, ImageDataResX * ImageDataResY * 4, 4 do
			i -= 1
			buffer.writeu8(PixelBuffer, i, Lerp(buffer.readu8(PixelBuffer, i), R, T))
			buffer.writeu8(PixelBuffer, i + 1, Lerp(buffer.readu8(PixelBuffer, i + 1), G, T))
			buffer.writeu8(PixelBuffer, i + 2, Lerp(buffer.readu8(PixelBuffer, i + 2), B, T))
		end
	end
	
	-- Tints the image with a colour by a percentage
	function ImageData:TintRGB(R: number, G: number, B: number, T: number)
		local PixelBuffer = self.ImageBuffer
		R, G, B = R * 255, B * 255, G * 255

		for i = 1, ImageDataResX * ImageDataResY * 4, 4 do
			i -= 1
			buffer.writeu8(PixelBuffer, i, Lerp(buffer.readu8(PixelBuffer, i), R, T))
			buffer.writeu8(PixelBuffer, i + 1, Lerp(buffer.readu8(PixelBuffer, i + 1), G, T))
			buffer.writeu8(PixelBuffer, i + 2, Lerp(buffer.readu8(PixelBuffer, i + 2), B, T))
		end
	end
	
	--[[
		<strong>DEPRECATED</strong>
		
		For better alternatives, try;
		- <code>ImageData:SetU32()</code>
		- <code>ImageData:SetRGBA()</code>
	]]
	@deprecated function ImageData:SetPixel(X: number, Y: number, Colour: Color3, Alpha: number?)
		local PixelBuffer = self.ImageBuffer
		local Index = GetIndex(X, Y)
		buffer.writeu8(PixelBuffer, Index, Colour.R * 255)
		buffer.writeu8(PixelBuffer, Index + 1, Colour.G * 255)
		buffer.writeu8(PixelBuffer, Index + 2, Colour.B * 255)
		buffer.writeu8(PixelBuffer, Index + 3, (Alpha or 1) * 255)
	end
	
	-- Sets an RGB value to the pixel on the image
	function ImageData:SetRGB(X: number, Y: number, R: number, G: number, B: number)
		local PixelBuffer = self.ImageBuffer
		local Index = GetIndex(X, Y)
		buffer.writeu8(PixelBuffer, Index, R * 255)
		buffer.writeu8(PixelBuffer, Index + 1, G * 255)
		buffer.writeu8(PixelBuffer, Index + 2, B * 255)
	end
	
	-- Sets an RGBA value to the pixel on the image
	function ImageData:SetRGBA(X: number, Y: number, R: number, G: number, B: number, A: number)
		local PixelBuffer = self.ImageBuffer
		local Index = GetIndex(X, Y)
		buffer.writeu32(PixelBuffer, GetIndex(X, Y), bit32bor(
			bit32lshift(A * 255, 24),
			bit32lshift(B * 255, 16),
			bit32lshift(G * 255, 8),
			R * 255)
		)
	end
	
	function ImageData:SetU32(X: number, Y: number, Value: number)
		local PixelBuffer = self.ImageBuffer
		buffer.writeu32(PixelBuffer, GetIndex(X, Y), Value)
	end
	
	-- Sets an alpha value to the pixel on the image
	function ImageData:SetAlpha(X: number, Y: number, Alpha: number)
		buffer.writeu8(self.ImageBuffer, GetIndex(X, Y) + 3, Alpha * 255)
	end
	
	-- Returns a deep copy of the ImageData object
	function ImageData:Clone(): typeof(ImageData)
		return deepCopy(ImageData)
	end

	return ImageData
end

return Module