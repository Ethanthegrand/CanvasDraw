--!native

local SaveObjReader = {}

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local StringCompressor = require(script.Parent:WaitForChild("StringCompressor"))

function SaveObjReader.Read(SaveObject, SlowLoad) -- v4.9.0 and above
	local Resolution = SaveObject:GetAttribute("Resolution")
	local Width, Height = Resolution.X, Resolution.Y
	
	local PixelBuffer = buffer.create(Width * Height * 4)
	local CurrentBufferIndex = 0

	-- Decompress the data
	local ChunkCount = #SaveObject:GetChildren()
	
	for i = 1, ChunkCount do
		local ChunkString = SaveObject["Chunk" .. i]
		local Array = HttpService:JSONDecode(StringCompressor.Decompress(ChunkString.Value))
		
		for j = 1, #Array do
			buffer.writeu8(PixelBuffer, CurrentBufferIndex, Array[j])
			CurrentBufferIndex += 1
		end
		
		if SlowLoad then task.wait() end
	end

	return PixelBuffer, Width, Height
end


-- Below functions are for backwards compatibility

function SaveObjReader.ReadV2(SaveObject) -- v4.4.0 to v4.8.0
	local CompressedRGB = SaveObject:GetAttribute("Colour")
	local CompressedAlpha = SaveObject:GetAttribute("Alpha")
	local Resolution = SaveObject:GetAttribute("Resolution")
	local Width, Height = Resolution.X, Resolution.Y

	-- Decompress the data
	local RGBArray = HttpService:JSONDecode(StringCompressor.Decompress(CompressedRGB))
	local AlphaArray = HttpService:JSONDecode(StringCompressor.Decompress(CompressedAlpha))
	
	local PixelBuffer = buffer.create(Width * Height * 4)
	
	for i = 1, Width * Height do
		local RGBIndex = i * 3 - 2
		local BufferIndex = i * 4 - 4
		
		buffer.writeu8(PixelBuffer, BufferIndex, RGBArray[RGBIndex])
		buffer.writeu8(PixelBuffer, BufferIndex + 1, RGBArray[RGBIndex + 1])
		buffer.writeu8(PixelBuffer, BufferIndex + 2, RGBArray[RGBIndex + 2])
		buffer.writeu8(PixelBuffer, BufferIndex + 3, AlphaArray[i])
	end

	return PixelBuffer, Width, Height
end

function SaveObjReader.ReadV1(SaveObject) -- v2.0.0 to v4.3.2
	local SaveDataImageColours = SaveObject:GetAttribute("ImageColours")
	local SaveDataImageAlphas = SaveObject:GetAttribute("ImageAlphas")
	local SaveDataImageResolution = SaveObject:GetAttribute("ImageResolution")

	-- Decompress the data
	local DecompressedSaveDataImageColours = StringCompressor.Decompress(SaveDataImageColours)
	local DecompressedSaveDataImageAlphas = StringCompressor.Decompress(SaveDataImageAlphas)

	-- Get a single pixel colour info form the data
	local PixelDataColoursString = string.split(DecompressedSaveDataImageColours, "S")
	local PixelDataAlphasString = string.split(DecompressedSaveDataImageAlphas, "S")

	local PixelBuffer = buffer.create(SaveDataImageResolution.X * SaveDataImageResolution.Y * 4)

	for i, PixelColourString in pairs(PixelDataColoursString) do
		local RGBValues = string.split(PixelColourString, ",")
		local R, G, B = table.unpack(RGBValues)
		local A = tonumber(PixelDataAlphasString[i])

		local Index = i * 4 - 4
		
		buffer.writeu8(PixelBuffer, Index, R)
		buffer.writeu8(PixelBuffer, Index + 1, G)
		buffer.writeu8(PixelBuffer, Index + 2, B)
		buffer.writeu8(PixelBuffer, Index + 3, A)
	end
	
	return PixelBuffer, SaveDataImageResolution.X, SaveDataImageResolution.Y
end

return SaveObjReader
