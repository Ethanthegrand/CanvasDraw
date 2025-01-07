--!native

--[[
	================== CanvasDraw ===================
	
	Created by: Ethanthegrand (@Ethanthegrand14)
	
	Last updated: 7/01/2025
	Version: 4.13.1
	
	Learn how to use the module here: https://devforum.roblox.com/t/1624633
	Detailed API Documentation: https://devforum.roblox.com/t/2017699
	
	DUE TO EDITABLEIMAGE USAGE LIMITS; IN ORDER TO USE, YOU MUST BE:
	- 13+
	- ID-verified
	
	ENABLE IN 'GAME SETTINGS > SECURITY > ALLOW MESH / IMAGE APIS' IF
	YOU MEET THESE REQUIREMENTS.
	
	Read more here: https://devforum.roblox.com/t/3267293
	
	Copyright © 2022 - 2025 | CanvasDraw
]]

--[[
	============== QUICK API REFERENCE ==============

	CanvasDraw Functions:
	
	   - CanvasDraw.new(Parent, Resolution, CanvasColour?, Blur?) : Canvas
	      * Constructs and returns a canvas class/object.
	      * The parent can be the following: 
	        GuiObject (such as Frame) or MeshPart
	
	   - CanvasDraw.GetImageData(SaveObject, SlowLoad) : ImageData [YIELDS?]
	      * Reads the selected SaveObject's compressed ImageData and returns a readable ImageData object
	      * When SlowLoad is set to true, this method will yield and slowly decompress the SaveObject
	        to avoid large lag spikes on the client with large images
	      
	   - CanvasDraw.GetImageDataFromTextureId(TextureId, MaxWidth?, MaxHeight?) : ImageData? [YIELDS]
	      * Loads the selected roblox texture asset and returns an ImageData class if succeeded.
	      * This method will yield as it uses AssetService!
	      * The optional 'MaxWidth' and 'MaxHeight' parameters will rescale the image 
	        to fit within your limits while maining the correct aspect ratio.
	      * NOTE: Currently, this method will not return ImageData if the user or place does not own the
	        requested asset, or AssetService errors in some other way.
	      
	   - CanvasDraw.CreateBlankImageData(Width, Height) : ImageData
	      * Creates and returns a new blank ImageData object
	      
	   - CanvasDraw.CreateSaveObject(ImageData) : Instance
	      * Returns a physical save object (a folder instance) containing compressed ImageData.
	      * This instance can be stored anywhere in your place and can be loaded into CanvasDraw.
		  * Intended for plugin use.
		  * NOTE: The provided ImageData has to be 256x256 or under!
		  
	   - CanvasDraw.CreateSaveObjectFromPixels(PixelArray, Width, Height) : Instance
	      * Same as 'CanvasDraw.CreateSaveObject', but takes an array of RGBA values with
	        a width and height parameter.
	      * Intended for plugin use.
		  * NOTE: The width and height has to be 256x256 or under!
		  
	   - CanvasDraw.CompressImageData(ImageData) : CompressedImageData
	      * Returns a compressed image in the form of a very small table which takes advantage 
	        of buffers and JSON encoding.
	      * Very useful with datastores.
	      * NOTE: Large images may cause slight lag spikes
	      
	   - CanvasDraw.DecompressImageData(CompressedImageData) : ImageData
	      * Decompresses the CompressedImageData object, and converts it back to
	        the original ImageData object.
	      * Very useful with datastores.
	      * NOTE: Large images may cause slight lag spikes
	      
	CanvasDraw Properties:
	
	   - CanvasDraw.BlendingModes : table
	      * Enums for the canvas property 'AlphaBlendingMode'
	      * Current values are:
	        > Normal  | 0
		    > Replace | 1
	
	Canvas Properties:
	
	   - AlphaBlendingMode : number
	      * Allows for shapes, images and certain draw methods to blend with the canvas transparency differently.
	      * This property can be set with 'CanvasDraw.BlendingModes'
	      * Defaults to 'CanvasDraw.BlendingModes.Normal' or '0'
		
	   - OutputWarnings : boolean
	      * Determines whether any warning messages will appear in the output if something is out of place 
	        or not working correctly according to the canvas.
	      * Defaults to true.
	   
	   - AutoRender : boolean
	      * Determines whether the canvas will automatically update and render the pixels on the canvas every frame.
	      * Set this property to false and call the Canvas:Render() method to manually update and render the canvas.
	      * Use Canvas.AutoRenderFpsLimit to set a refresh limit when enabled.
	      * Defaults to true.
	      
	   - AutoRenderFpsLimit : number
	      * The FPS limit for the AutoRender property on the canvas.
	      * Defaults to 0 (No limit).
	      
	   - Canvas.GridTransparency : number
	      * Sets the pixel grid overlay from 0 to 1.
	      * Set to 1 to disable/hide (Disabled by default)
	      
	   - Canvas.EditableImage : EditableImage
	      * The EditableImage instance that the canvas is currently using.
	   
	   - Canvas.CanvasColour : Color3 [READ ONLY]
	      * The default background colour of the generated canvas.
	   
	   - Canvas.Resolution : Vector2 [READ ONLY]
	      * The current resolution of the canvas.
	      
	   - Canvas.CurrentResX : number [READ ONLY]
	      * The current width of the canvas.
	      
	   - Canvas.CurrentResY : number [READ ONLY]
	      * The current height of the canvas.
	      
	  
	  
	Canvas Drawing Methods:
	
	   - Canvas:SetGrid(PixelArray)
	      * Sets the canvas pixels with an array of RGBA values
	      * NOTE: The size of the array has to be equal to: Width * Height * 4
	      
	   - Canvas:SetBuffer(PixelBuffer)
	      * Sets the canvas pixels with a buffer of RGBA values
	      * NOTE: The size of the buffer has to be equal to: Width * Height * 4
		
	   - Canvas:FillRGBA(R, G, B, A)
	   - Canvas:Fill(Colour, Alpha)
	      * Replaces every pixel on the canvas with a colour
	   
	   - Canvas:Clear()
	      * Replaces every current pixel on the canvas with the canvas colour
	
	   - Canvas:FloodFill(Point, Colour, Alpha?) : {Vector2}
	   - Canvas:FloodFillXY(X, Y, Colour, Alpha?)
	      * This function will fill an area of pixels on the canvas of the specific colour that your point is on.
	      * An array will also be returned containing all pixel points that were used to fill with.
	      * NOTE: This function is not very fast! Do not use for real-time engines
	   
	   - Canvas:SetPixel(X, Y, Colour)
	   - Canvas:SetRGB(X, Y, R, G, B)
	   - Canvas:SetRGBA(X, Y, R, G, B, A)
	   - Canvas:SetAlpha(X, Y, Alpha)
	      * Places a pixel on the canvas
	      
	   - Canvas:DrawLine(PointA, PointB, Colour, Thickness?, RoundedCaps?)
	   - Canvas:DrawLineXY(X1, Y1, X2, Y2, Colour, Thickness?, RoundedCaps?)
	      * Draws a simple pixel line from two points on the canvas.
	      
	   - Canvas:DrawCircle(Point, Radius, Colour, Alpha?, Fill?)
	   - Canvas:DrawCircleXY(X, Y, Radius, Colour, Alpha?, Fill?)
	      * Draws a circle at a desired point with a set radius and colour.
	  
	   - Canvas:DrawRectangle(PointA, PointB, Colour, Alpha?, Fill?)
	   - Canvas:DrawRectangleXY(X1, Y1, X2, Y2, Colour, Alpha?, Fill?)
	      * Draws a simple rectangle shape from point A (top left) to point B (bottom right).
	  
	   - Canvas:DrawTriangle(PointA, PointB, PointC, Colour, Fill?)
	   - Canvas:DrawTriangleXY(X1, Y1, X2, Y2, X3, Y3, Colour, Fill?)
	      * Draws a plain triangle from three points on the canvas.
	  
	   - Canvas:DrawImage(ImageData, Point?, Scale?, TransparencyEnabled?)
	   - Canvas:DrawImageXY(ImageData, X?, Y?, ScaleX?, ScaleY?, TransparencyEnabled?)
	      * Draws an image to the canvas from ImageData with optional scaling.
	      * Supports alpha blending when the 'TransparencyEnabled' parameter is set to true.
	      
	   - Canvas:SetBufferFromImage(ImageData)
	      * A super fast alternative to <code>Canvas:DrawImage()</code>, but without transformations
		  * This method draws an image to the canvas using very little computational power.
		  * NOTE: The image's resolution has to be the same as the canvas' resolution.
	      
	   - Canvas:DrawRotatedImage(ImageData, Angle, Point?, PivotPoint?, Scale?)
	   - Canvas:DrawRotatedImageXY(ImageData, Angle, X?, Y?, PivotX?, PivotY?, ScaleX?, ScaleY?)
	      * Draws a rotated image to the canvas with a given angle with a pivoting point.
	        a pivot of (0, 0) will draw and rotate the image from the top left, and a pivot point of (1, 1)
	        will do it from the bottom right corner.
	        
	   - Canvas:DrawImageRect(ImageData, Point, RectOffset, RectSize, Scale?, FlipX?, FlipY?)
	   - Canvas:DrawImageRectXY(ImageData, X, Y, RectOffsetX, RectOffsetY, RectSizeX, RectSizeY, ScaleX?, ScaleY?, FlipX?, FlipY?)
	      * Draws an image to the canvas with a rect offset and rect size properties.
	      * RectSize and RectOffset are in pixels.
	      * Intended for image cropping or use with spritesheets.
	      * FlipX and FlipY can be used to flip your sprite. 
	        Great for tile-based character animations.
	     
	   - Canvas:DrawTexturedTriangle(PointA, PointB, PointC, UV1, UV2, UV3, ImageData, Brightness?)
	   - Canvas:DrawTexturedTriangleXY(X1, Y1, X2, Y2, X3, Y3, U1, V1, U2, V2, U3, V3, ImageData, Brightness?)
	      * Draws a textured triangle at three points from a given ImageData and UV coordinates.
	      * UV coordinates range from a scale of 0 to 1 for each axis. 
	        (0, 0 is top left, and 1, 1 is bottom right)
	      * Intended for 3D rendering or 2D textured polygons.
	      * Supports transparency, but not alpha blending.
	     
	   - Canvas:DrawDistortedImage(PointA, PointB, PointC, PointD, ImageData, Brightness?)
	   - Canvas:DrawDistortedImageXY(X1, Y1, X2, Y2, X3, Y3, X4, Y4, ImageData, Brightness?)
	      * Draws a four point textured quad/plane which can be scaled dynamically
	      * This can be used for 3D rendering or rotating, stretching, skewing or warping 2D images.
	      * Supports transparency, but not alpha blending.
	     
	   - Canvas:DrawText(Text, Point, Colour, FontName?, Alignment?, Scale?, Wrap?, Spacing?)
	   - Canvas:DrawTextXY(Text, X, Y, Colour, FontName?, Alignment?, Scale?, Wrap?, Spacing?)
	      * Draws text to the canvas with a bitmap font. 
	      * Great for having pixel-perfect text.
	      * Great for debugging.
	      * There are currently 7 fonts that can be used which can be found in the 
	        'Fonts' folder under the main module:
	            - 3x6
	            - Atari
	            - Codepage
	            - CodepageLarge
	            - GrandCD
	            - Monogram
	            - Round
	
	 
	Canvas Fetch Methods:
	
	   - Canvas:GetPixel(Point) : Color3
	   - Canvas:GetPixelXY(X, Y) : Color3
	   - Canvas:GetRGB(X, Y) : number, number, number
	   - Canvas:GetRGBA(X, Y) : number, number, number, number
	   - Canvas:GetAlpha(X, Y) : number
	      * Returns the chosen pixel from the canvas
	   
	   - Canvas:GetCirclePoints(Point, Radius, Fill) : {Vector2}
	   - Canvas:GetLinePoints(PointA, PointB, Thickness, RoundedCaps) : {Vector2}
	   - Canvas:GetRectanglePoints(PointA, PointB, Fill) : {Vector2}
	   - Canvas:GetTrianglePoints(PointA, PointB, PointC, Fill) : {Vector2}
	     * Returns an array of canvas pixel points from a shape
	   
	   - Canvas:GetGrid() : {number}
	      * Returns all the pixels on the canvas in the form of an RGBA array
	      
	    - Canvas:GetBuffer() : buffer
	      * Returns all the pixels on the canvas in the form of an RGBA buffer
	   
	   - Canvas:GetMousePoint() : Vector2? [CLIENT/PLUGIN ONLY]
	      * If the user's mouse is within the canvas, a canvas point (Vector2) will be returned
	        Otherwise, nothing will be returned (nil)
	      * NOTE: This function is only compatible with 'ScreenGui' and 'SurfaceGui'
	      
	   - Canvas:ViewportToCanvasPoint() : Vector2 [CLIENT/PLUGIN ONLY]
	      * This method will take a Vector2 screen position, and return a canvas pixel point.
	      * This does not take into account the GUI inset.
	      * NOTE: This is only compatible with 'ScreenGui'
	      
	   - Canvas:MouseIsOnTop() : boolean [CLIENT/PLUGIN ONLY]
	      * Returns true if the user's mouse is only on top of the canvas gui element.
	      * Will return false if the user's mouse in on top of a different gui element that's 
	        layered above the canvas, or if the mouse location is outside the canvas entirely.
	      * Useful for mouse inputs with canvas.
	   
	   - Canvas:CreateImageDataFromCanvas(PointA?, PointB?) : ImageData
	      * Returns an ImageData class/table from the canvas pixels from PointA to PointB or the whole canvas.
	        
	        
	ImageData Properties:
	
	   - ImageData.Width : number [READ ONLY]
	      * The width of the image in pixels.
	   
	   - ImageData.Height : number [READ ONLY]
	      * The height of the image in pixels.
	   
	   - ImageData.ImageResolution : Vector2 [READ ONLY]
	     * A vector of the width and height of the image in pixels.
	     
	   - ImageData.ImageBuffer : buffer [READ ONLY]
	      * The buffer object that stores the pixels for the image.
	      
	   
	Other Canvas Methods:
	
	   - Canvas:SetClearRGBA(R, G, B, A)
	      * Changes the clearing colour that is used when calling 'Canvas:Clear()'
	
	   - Canvas:Resize(NewResolution)
	      * Resizes the canvas to a new desired resolution
	      * NOTE: All contents will be cleared. 
	        If you want to scale the canvas content, you will have to redraw 
	        the image after resizing
	      
	   - Canvas:Destroy()
	      * Destroys the canvas and all data related
	      
	   - Canvas:Render()
	      * Manually update/render the canvas (if Canvas.AutoRender is set to 'false')
	
	Canvas Events:
	
	   - Canvas.OnRendered(DeltaTime)
	      * Fires whenever the canvas renders automatically.
	      * Canvas.AutoRenderFpsLimit will affect this event
	      * This event will never fire automatically if 'Canvas.AutoRender' is set to 'false'
	      

]]

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local AssetService = game:GetService("AssetService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

-- Modules
local FastCanvas = require(script:WaitForChild("FastCanvas")) -- Credits to BoatBomber
local StringCompressor = require(script:WaitForChild("StringCompressor")) -- Credits to 1waffle1 and BoatBomber
local FontsFolder = script:WaitForChild("Fonts")
local VectorFuncs = require(script:WaitForChild("VectorFuncs")) -- Credits to Krystaltinan
local ImageDataConstructor = require(script:WaitForChild("ImageDataConstructor"))
local SaveObjectReader = require(script:WaitForChild("SaveObjectReader"))

local CanvasDraw = {}

-- Read only
CanvasDraw.BlendingModes = {
	Normal = 0,
	Replace = 1
}

-- These variables are only accessed by this module [DO NOT EDIT!]
local SaveObjectResolutionLimit = Vector2.new(1024, 1024)
local ChunkLimit = 120000 -- Ensures our strings will stay under 200 KB

local GridTextures = {
	Small = "rbxassetid://15840244068",
	Large = "rbxassetid://15464832180"
}

-- Micro optimisations
local TableInsert = table.insert
local RoundN = math.round
local Vector2New = Vector2.new
local CeilN = math.ceil
local FloorN = math.floor
local ClampN = math.clamp

--== BUILT-IN FUNCTIONS ==--

local function Swap(A, B)
	return B, A
end

local function GetRange(A, B)
	if A > B then
		return CeilN(A - B), -1
	else
		return CeilN(B - A), 1
	end
end

local function RoundPoint(Point)
	return Vector2New(CeilN(Point.X), CeilN(Point.Y))
end

local function PointToPixelIndex(Point, Resolution)
	return CeilN(Point.X) + (CeilN(Point.Y) - 1) * Resolution.X
end

local function XYToPixelIndex(X, Y, ResolutionX)
	return X + (Y - 1) * ResolutionX
end

local function Lerp(A, B, T)
	return A + (B - A) * T
end

type ParentType = GuiObject | MeshPart

--== MODULE FUCNTIONS ==--

-- Canvas functions

--[[
	Creates and returns a new canvas object that can be parented to either a GuiObject, or a MeshPart.
	
	Resolution limit is currently 1024x1024
]]
function CanvasDraw.new(Parent: ParentType, Resolution: Vector2?, CanvasColour: Color3?, Blur: boolean?)
	local Canvas = {
		-- Modifyable properties
		OutputWarnings = true,
		AutoRender = true,
		GridTransparency = 1,
		GridColour = Color3.new(1, 1, 1),
		AutoRenderFpsLimit = 0,
		AlphaBlendingMode = 0,
		
		-- Read only
		Resolution = Vector2New(100, 100),

		-- DEPRECATRED
		Updated = RunService.Heartbeat,
	}

	local LastFrameTime = os.clock()
	local LastFrame = os.clock()


	--==<< Interal Functions >>==--

	local function OutputWarn(Message)
		if Canvas.OutputWarnings then
			warn("(!) CanvasDraw Module Warning: '" .. Message .. "'")
		end
	end

	local UiFrameMode = Parent:IsA("GuiObject")
	Canvas.IsUiFrame = UiFrameMode

	--==<< Canvas Set-up >>==--

	-- Parameter defaults
	if CanvasColour then
		Canvas.CanvasColour = CanvasColour 
	else
		if UiFrameMode then
			Canvas.CanvasColour = Parent.BackgroundColor3
		else
			Canvas.CanvasColour = Color3.new(1, 1, 1)
		end
	end

	if Resolution then
		Canvas.Resolution = Resolution
		Canvas.CurrentResX = Resolution.X
		Canvas.CurrentResY = Resolution.Y
	else
		Canvas.CurrentResX = 100
		Canvas.CurrentResY = 100
		Resolution = Vector2New(100, 100)
	end

	-- Create the canvas
	local ResX = Canvas.CurrentResX
	local ResY = Canvas.CurrentResY

	local InternalCanvas = FastCanvas.new(ResX, ResY, Parent, Blur)

	Canvas.CurrentCanvasFrame = Parent

	local CanvasR, CanvasG, CanvasB = Canvas.CanvasColour.R, Canvas.CanvasColour.G, Canvas.CanvasColour.B

	-- Set the grid with a default colour
	InternalCanvas:SetClearRGBA(CanvasR, CanvasG, CanvasB, 1)
	InternalCanvas:Clear()

	InternalCanvas:Render()

	Canvas.EditableImage = InternalCanvas.Image
	Canvas.InternalCanvas = InternalCanvas

	local GridImage

	-- Create grid overlay
	if UiFrameMode then
		GridImage = Instance.new("ImageLabel")
		GridImage.Size = UDim2.fromScale(1, 1)
		GridImage.ScaleType = Enum.ScaleType.Tile
		GridImage.TileSize = UDim2.fromScale(1 / Resolution.X, 1 / Resolution.Y)

		if Resolution.Y > 50 then
			GridImage.Image = GridTextures.Large
		else
			GridImage.Image = GridTextures.Small
		end

		GridImage.Name = "GridOverlay"
		GridImage.ImageTransparency = 1
		GridImage.BackgroundTransparency = 1
		GridImage.Parent = Parent:WaitForChild("FastCanvas")
	end

	-- Create custom events
	local EventsFolder = Instance.new("Folder")
	EventsFolder.Name = "Events"
	EventsFolder.Parent = Parent

	local OnRenderedBindable = Instance.new("BindableEvent")
	OnRenderedBindable.Name = "OnRenderedEvent"
	OnRenderedBindable.Parent = EventsFolder

	-- Canvas events

	Canvas.OnRendered = OnRenderedBindable.Event

	-- Auto render

	Canvas.AutoUpdateConnection = RunService.Heartbeat:Connect(function(DeltaTime)

		-- FpsLimit
		if InternalCanvas and Canvas.AutoRender then
			local Sum = LastFrame + (1 / Canvas.AutoRenderFpsLimit)
			local Clock = os.clock()

			local Difference = math.min(Clock - Sum, 0.2)

			if Difference > 0 or Canvas.AutoRenderFpsLimit == 0 then
				LastFrame = Clock - Difference
				Canvas:Render()
			end
		end

		-- Backwards compatability for deprecated properties
		if Canvas.AutoUpdate then
			Canvas.AutoRender = true
		end
	end)
	
	-- Helper functions
	
	local function DrawSimpleLine(X1: number, Y1: number, X2: number, Y2: number, Colour: Color3, Alpha: number?)
		X1, Y1 = CeilN(X1), CeilN(Y1)
		X2, Y2 = CeilN(X2), CeilN(Y2)

		local R, G, B = Colour.R, Colour.G, Colour.B
		local BlendingMode = Canvas.AlphaBlendingMode
		local ResX, ResY = Canvas.CurrentResX, Canvas.CurrentResY
		
		local ColourBuffer = buffer.create(4)
		buffer.writeu8(ColourBuffer, 0, R * 255)
		buffer.writeu8(ColourBuffer, 1, G * 255)
		buffer.writeu8(ColourBuffer, 2, B * 255)
		buffer.writeu8(ColourBuffer, 3, Alpha * 255)

		local ColourU32 = buffer.readu32(ColourBuffer, 0)

		local sx, sy, dx, dy

		if X1 < X2 then
			sx = 1
			dx = X2 - X1
		else
			sx = -1
			dx = X1 - X2
		end

		if Y1 < Y2 then
			sy = 1
			dy = Y2 - Y1
		else
			sy = -1
			dy = Y1 - Y2
		end

		local err, e2 = dx-dy, nil

		local function PlotPixel()
			if X1 <= ResX and Y1 <= ResY and X1 > 0 and Y1 > 0 then
				if BlendingMode == 0 and Alpha > 0 then -- Normal
					local ColR = R
					local ColG = G 
					local ColB = B 
					
					if Alpha < 1 then
						local BgR, BgG, BgB = InternalCanvas:GetRGB(X1, Y1)

						ColR = Lerp(BgR, R, Alpha)
						ColG = Lerp(BgG, G, Alpha)
						ColB = Lerp(BgB, B, Alpha)
					end

					InternalCanvas:SetRGB(X1, Y1, ColR, ColG, ColB)
				elseif BlendingMode == 1 then -- Replace
					InternalCanvas:SetU32(X1, Y1, ColourU32)
				end
			end
		end

		-- Start point
		--PlotPixel()

		while not(X1 == X2 and Y1 == Y2) do
			e2 = err + err
			if e2 > -dy then
				err -= dy
				X1 += sx
			end
			if e2 < dx then
				err += dx
				Y1 += sy
			end
			PlotPixel()
		end
	end


	--============================================================================================================--
	--====  <<   Canvas API   >>   ================================================================================--
	--============================================================================================================--

	--==<< Canvas Methods >>==--

	--[[
		Resizes the canvas to a new desired resolution
	]]
	function Canvas:Resize(NewResolution: Vector2)
		InternalCanvas:Resize(NewResolution.X, NewResolution.Y)

		Resolution = NewResolution
		GridImage.TileSize = UDim2.fromScale(1 / NewResolution.X, 1 / NewResolution.Y)

		self.Resolution = NewResolution
		self.CurrentResX = NewResolution.X
		self.CurrentResY = NewResolution.Y
		ResX = NewResolution.X
		ResY = NewResolution.Y
	end

	-- Destroys the canvas
	function Canvas:Destroy()
		InternalCanvas:Destroy()
		self.InternalCanvas = nil
		self.CurrentCanvasFrame = nil
		self.AutoUpdateConnection:Disconnect()
		EventsFolder:Destroy()
	end
	
	-- Changes the canvas's internal ImageLabel to either have the resample mode set to blur, or pixelated	
	function Canvas:SetBlur(Enabled: boolean)
		if UiFrameMode then
			InternalCanvas.ImageLabel.ResampleMode = (Enabled and Enum.ResamplerMode.Default) or Enum.ResamplerMode.Pixelated
		else
			OutputWarn("Canvas:SetBlur() is currently only avaialable for canvases parented to a GuiObject!")
		end
		
	end

	-- Fills the whole canvas with a colour
	function Canvas:FillRGBA(R: number, G: number, B: number, A: number)
		local Width, Height = self.CurrentResX, self.CurrentResY
		
		local FillBuffer = buffer.create(Width * Height * 4)
		local ColourBuffer = buffer.create(Width * Height * 4)
		
		buffer.writeu8(ColourBuffer, 0, R * 255)
		buffer.writeu8(ColourBuffer, 1, G * 255)
		buffer.writeu8(ColourBuffer, 2, B * 255)
		buffer.writeu8(ColourBuffer, 3, A * 255)

		for i = 0, Width * Height * 4 - 1, 4 do
			buffer.writeu32(FillBuffer, i, buffer.readu32(ColourBuffer, 0))
		end
		
		InternalCanvas:SetBuffer(FillBuffer)
	end
	
	function Canvas:Fill(Colour: Color3, Alpha: number?)
		local R, G, B, A = Colour.R, Colour.G, Colour.B, Alpha or 1
		Canvas:FillRGBA(R, G, B, A)
	end


	--[[
		Clears the canvas and replaces all pixels with the canvas clearing colour.
		This method is much faster than Canvas:Fill()
				
		Use <code>Canvas:SetClearRGBA()</code> to change the colour used
	]]
	function Canvas:Clear()
		InternalCanvas:Clear()
	end

	-- Sets the RGBA values used for the <code>Canvas:Clear()</code> method
	function Canvas:SetClearRGBA(R: number, G: number, B: number, A: number)
		if UiFrameMode then
			self.CanvasColour = Color3.new(R, G, B)
		end
		InternalCanvas:SetClearRGBA(R, G, B, A)
	end

	--[[
		Manually renders any drawn contents to the canvas.
		
		Is intended to be used when <code>Canvas.AutoRender</code> is set to false
	]]
	function Canvas:Render()
		local Clock = os.clock()
		InternalCanvas:Render()

		if UiFrameMode then
			GridImage.ImageColor3 = self.GridColour
			GridImage.ImageTransparency = self.GridTransparency
		end

		OnRenderedBindable:Fire(Clock - LastFrameTime)
		LastFrameTime = Clock
	end

	--==<< Fetch Methods >>==--

	--[[ 
		Returns the Color3 value of the pixel on the canvas
		
		<strong>PLEASE NOTE:</strong> This method is the slowest way of fetching a pixel!
		Consider using <code>Canvas:GetRGB()</code> or <code>Canvas:GetPixel()</code>
	]]
	function Canvas:GetPixel(Point: Vector2): Color3
		Point = RoundPoint(Point)

		local X = Point.X
		local Y = Point.Y

		if X > 0 and Y > 0 and X <= self.CurrentResX and Y <= self.CurrentResY then
			return InternalCanvas:GetColor3(X, Y)
		end
	end
	
	-- Internal pixel fetch methods
	Canvas.GetPixelXY = InternalCanvas.GetColor3
	Canvas.GetRGB = InternalCanvas.GetRGB
	Canvas.GetRGBA = InternalCanvas.GetRGBA
	Canvas.GetAlpha = InternalCanvas.GetAlpha
	Canvas.GetU32 = InternalCanvas.GetU32

	--[[
		Returns an array of RGBA values ranging from 0 to 1
		
		The size of this array is equal to <strong>Width × Height × 4</strong>
	]]
	function Canvas:GetGrid(): {number}
		return InternalCanvas:GetGrid()
	end

	--[[
		Returns a buffer of RGBA values ranging from 0 to 255
		
		The size of this buffer is equal to <strong>Width × Height × 4</strong>
	]]
	function Canvas:GetBuffer(): buffer
		return InternalCanvas:GetBuffer()
	end

	--[[
		Returns either a Vector2 pixel point value relative to the canvas from the client’s mouse position, or nil if the mouse isn’t within the canvas.
		
		<em>[ CLIENT/PLUGIN ONLY ]</em>
	]]
	function Canvas:GetMousePoint(): Vector2?
		if UiFrameMode and (RunService:IsClient() or RunService:IsStudio()) then
			local MouseLocation = UserInputService:GetMouseLocation()

			local CanvasFrameSize = self.CurrentCanvasFrame.AbsoluteSize
			local FastCanvasFrameSize = self.CurrentCanvasFrame.FastCanvas.AbsoluteSize
			local CanvasPosition = self.CurrentCanvasFrame.AbsolutePosition

			local SurfaceGui = Parent:FindFirstAncestorOfClass("SurfaceGui")

			if not SurfaceGui and UiFrameMode then
				-- ScreenGui
				local GuiInset = GuiService:GetGuiInset()
				local MousePoint = MouseLocation - GuiInset - CanvasPosition

				local TransformedPoint = (MousePoint / FastCanvasFrameSize) -- Normalised

				TransformedPoint *= self.Resolution -- Canvas space

				-- Make sure everything is aligned when the canvas is at different aspect ratios
				local RatioDifference = Vector2New(CanvasFrameSize.X / FastCanvasFrameSize.X, CanvasFrameSize.Y / FastCanvasFrameSize.Y) - Vector2New(1, 1)
				TransformedPoint -= (RatioDifference / 2) * self.Resolution

				local RoundX = math.ceil(TransformedPoint.X)
				local RoundY = math.ceil(TransformedPoint.Y)

				TransformedPoint = Vector2.new(RoundX, RoundY)

				-- If the point is within the canvas, return it.
				if TransformedPoint.X > 0 and TransformedPoint.Y > 0 and TransformedPoint.X <= self.CurrentResX and TransformedPoint.Y <= self.CurrentResY then
					return TransformedPoint
				end
			else
				-- SurfaceGui
				local Part = SurfaceGui.Adornee or SurfaceGui:FindFirstAncestorWhichIsA("BasePart") 
				local Camera = workspace.CurrentCamera

				local FastCanvasFrame = Parent:FindFirstChild("FastCanvas")

				if Part and FastCanvasFrame then
					local Params = RaycastParams.new()
					Params.FilterType = Enum.RaycastFilterType.Include
					Params.FilterDescendantsInstances = {Part}

					local UnitRay = Camera:ViewportPointToRay(MouseLocation.X, MouseLocation.Y)

					local Result = workspace:Raycast(UnitRay.Origin, UnitRay.Direction * 1000, Params)

					if Result then
						local Normal = Result.Normal
						local IntersectionPos = Result.Position

						if VectorFuncs.normalVectorToFace(Part, Normal) ~= SurfaceGui.Face then
							return
						end

						-- Credits to @Krystaltinan for some of this code
						local hitCF = CFrame.lookAt(IntersectionPos, IntersectionPos + Normal)

						local topLeftCorners = VectorFuncs.getTopLeftCorners(Part)
						local topLeftCFrame = topLeftCorners[SurfaceGui.Face]

						local hitOffset = topLeftCFrame:ToObjectSpace(hitCF)

						local ScreenPos = Vector2.new(
							math.abs(hitOffset.X), 
							math.abs(hitOffset.Y)
						)

						-- Ensure the calculations work for all faces
						if SurfaceGui.Face == Enum.NormalId.Front or SurfaceGui.Face == Enum.NormalId.Back then
							-- Gives us as screenPos value between (-0.5, -0.5) to (0.5, 0.5)
							ScreenPos -= Vector2.new(Part.Size.X / 2, Part.Size.Y / 2)
							ScreenPos /= Vector2.new(Part.Size.X, Part.Size.Y)
						else
							return -- Other faces don't seem to work for now
						end

						local PositionalOffset
						local AspectRatioDifference = FastCanvasFrameSize / CanvasFrameSize
						local SurfaceGuiSizeDifference = SurfaceGui.AbsoluteSize / CanvasFrameSize

						-- Move origin to top left (will result in new screen pos values between 0 and 1 for each axis)
						local PosFixed = ScreenPos + Vector2.new(0.5, 0.5)

						-- Convert normals to SurfaceGui space
						local GuiSize = SurfaceGui.AbsoluteSize
						ScreenPos = PosFixed * GuiSize
						ScreenPos -= CanvasPosition

						local TransformedPoint = (ScreenPos / FastCanvasFrameSize) -- Normalised

						TransformedPoint *= self.Resolution -- Canvas space

						-- Make sure everything is aligned when the canvas is at different aspect ratios
						local RatioDifference = Vector2New(CanvasFrameSize.X / FastCanvasFrameSize.X, CanvasFrameSize.Y / FastCanvasFrameSize.Y) - Vector2New(1, 1)
						TransformedPoint -= (RatioDifference / 2) * self.Resolution

						TransformedPoint = RoundPoint(TransformedPoint)

						-- If the point is within the canvas, return it.
						if TransformedPoint.X > 0 and TransformedPoint.Y > 0 and TransformedPoint.X <= self.CurrentResX and TransformedPoint.Y <= self.CurrentResY then
							return TransformedPoint
						else
							return nil
						end
					end
				end	
			end
		elseif not UiFrameMode then
			OutputWarn("'GetMousePoint()' is currently only available for canvases parented to GuiObjects!")
		else
			OutputWarn("Failed to get point from mouse (you cannot use this function on the server. Please call this function from a client script).")
		end
	end

	--[[
		Returns a transformed Vector2 pixel point value relative to the canvas from a Vector2 screen/viewport pixel position.
		
		<em>[ CLIENT/PLUGIN ONLY ]</em>
	]]
	function Canvas:ViewportToCanvasPoint(Position: Vector2): Vector2
		if UiFrameMode and (RunService:IsClient() or RunService:IsStudio()) then
			local CanvasFrameSize = self.CurrentCanvasFrame.AbsoluteSize
			local FastCanvasFrameSize = self.CurrentCanvasFrame.FastCanvas.AbsoluteSize
			local CanvasPosition = self.CurrentCanvasFrame.AbsolutePosition

			local SurfaceGui = Parent:FindFirstAncestorOfClass("SurfaceGui")

			if not SurfaceGui and UiFrameMode then
				-- ScreenGui
				local MousePoint = Position - CanvasPosition

				local TransformedPoint = (MousePoint / FastCanvasFrameSize) -- Normalised

				TransformedPoint *= self.Resolution -- Canvas space

				-- Make sure everything is aligned when the canvas is at different aspect ratios
				local RatioDifference = Vector2New(CanvasFrameSize.X / FastCanvasFrameSize.X, CanvasFrameSize.Y / FastCanvasFrameSize.Y) - Vector2New(1, 1)
				TransformedPoint -= (RatioDifference / 2) * self.Resolution

				return Vector2New(CeilN(TransformedPoint.X), CeilN(TransformedPoint.Y))
			else
				-- SurfaceGui
				OutputWarn("'ViewportToCanvasPoint()' is not only supported for ScreenGui!")
			end
		elseif not UiFrameMode then
			OutputWarn("'ViewportToCanvasPoint()' is currently only available for canvases parented to GuiObjects in a ScreenGui!")
		else
			OutputWarn("Failed to execute 'Canvas:ViewportToCanvasPoint()' (you cannot use this function on the server. Please call this function from a client script).")
		end
	end

	--[[
		Returns <strong>true</strong> if the user’s mouse is only <strong>on top of the canvas gui element</strong>.
		
		Will return <strong>false</strong> if the user’s mouse in on top of a different gui element that is
		layered above the canvas, or if the mouse location is outside the canvas entirely
	]]
	function Canvas:MouseIsOnTop(): boolean
		if not UiFrameMode then
			OutputWarn("'MouseIsOnTop()' is currently only available for canvases parented to GuiObjects!")
			return
		end

		local MouseLocation = UserInputService:GetMouseLocation()
		local GuiInset = GuiService:GetGuiInset()

		MouseLocation -= GuiInset

		local BasePlrGui: BasePlayerGui = Parent:FindFirstAncestorWhichIsA("BasePlayerGui")

		if not BasePlrGui then return false end

		local Objects = BasePlrGui:GetGuiObjectsAtPosition(MouseLocation.X, MouseLocation.Y)

		if Objects[1] == GridImage then -- GridImage is the highest layered gui element
			return true
		else
			return false
		end
	end
	
	
	--==<< Canvas Shape Point Fetch Methods >>==--
	
	function Canvas:GetTrianglePoints(PointA: Vector2, PointB: Vector2, PointC: Vector2, Fill: boolean?): {Vector2}
		local X1, Y1 = CeilN(PointA.X), CeilN(PointA.Y)
		local X2, Y2 = CeilN(PointB.X), CeilN(PointB.Y)
		local X3, Y3 = CeilN(PointC.X), CeilN(PointC.Y)
		
		local ReturnPoints = {}
		
		if not (Fill or type(Fill) == "nil") then
			-- Bresenham triangle outlines
			local function InsertPoints(...)
				local PointsTable = {...}
				for i, Table in ipairs(PointsTable) do
					for i, Point in ipairs(Table) do
						table.insert(ReturnPoints, Point)
					end
				end
			end
			
			InsertPoints(Canvas:GetLinePoints(PointA, PointB), Canvas:GetLinePoints(PointB, PointC), Canvas:GetLinePoints(PointC, PointA))
			
			return ReturnPoints
		end

		-- Sort vertices by Y-coordinate (and X-coordinate if tied)
		if Y2 < Y1 or (Y2 == Y1 and X2 < X1) then
			X1, Y1, X2, Y2 = X2, Y2, X1, Y1
		end
		if Y3 < Y1 or (Y3 == Y1 and X3 < X1) then
			X1, Y1, X3, Y3 = X3, Y3, X1, Y1
		end
		if Y3 < Y2 or (Y3 == Y2 and X3 < X2) then
			X2, Y2, X3, Y3 = X3, Y3, X2, Y2
		end

		-- Precompute clipping bounds
		local YMin = math.max(1, Y1)
		local YMax = math.min(self.CurrentResY, Y3)

		local function Plotline(ax, bx, Y)
			if ax > bx then
				ax, bx = bx, ax
			end

			-- Pre-clipped scanline bounds
			local StartX = math.max(1, ax)
			local EndX = math.min(self.CurrentResX, bx)


			for X = StartX, EndX do
				TableInsert(ReturnPoints, Vector2New(X, Y))
			end

		end

		local OrigX3, OrigX2, OrigX1 = X3, X2, X1
		local OrigY1, OrigY3 = Y1, Y3

		local function FillTopTriangle(X1, Y1, X2, Y2, X3, Y3)
			local invslope1 = (X2 - X1) / (Y2 - Y1)
			local invslope2 = (X3 - X1) / (Y3 - Y1)

			local curx1 = X1
			local curx2 = X1

			for scanlineY = math.max(Y1, YMin), math.min(Y2 - 1, YMax) do
				local ax = RoundN(curx1)
				local bx = RoundN(curx2)
				Plotline(ax, bx, scanlineY)
				curx1 += invslope1
				curx2 += invslope2
			end
		end

		local function FillBottomTriangle(X1, Y1, X2, Y2, X3, Y3)
			local invslope1 = (X3 - X1) / (Y3 - Y1)
			local invslope2 = (X3 - X2) / (Y3 - Y2)

			local curx1 = X1
			local curx2 = X2

			if invslope1 >= math.huge or invslope1 ~= invslope1 then
				invslope1 = 0
				invslope2 = 0

				if OrigY1 == OrigY3 then
					curx1 = OrigX1
				else
					curx1 = OrigX2
				end

				curx2 = OrigX3
			end

			for scanlineY = math.max(Y2, YMin), math.min(Y3, YMax) do
				local ax = RoundN(curx1)
				local bx = RoundN(curx2)
				Plotline(ax, bx, scanlineY)
				curx1 += invslope1
				curx2 += invslope2
			end
		end

		-- Fill triangle
		local X4 = X1 + (Y2 - Y1) / (Y3 - Y1) * (X3 - X1)

		FillTopTriangle(X1, Y1, X2, Y2, X4, Y2)
		FillBottomTriangle(X2, Y2, X4, Y2, X3, Y3)
		
		return ReturnPoints
	end
	
	function Canvas:GetLinePoints(PointA: Vector2, PointB: Vector2, Thickness: number?, RoundedCaps: boolean?): {Vector2}
		local X1, Y1 = CeilN(PointA.X), CeilN(PointA.Y)
		local X2, Y2 = CeilN(PointB.X), CeilN(PointB.Y)
		
		local ResX, ResY = self.CurrentResX, self.CurrentResY

		local DrawnPointsArray = {}

		if not Thickness or Thickness < 1 then
			local sx, sy, dx, dy

			if X1 < X2 then
				sx = 1
				dx = X2 - X1
			else
				sx = -1
				dx = X1 - X2
			end

			if Y1 < Y2 then
				sy = 1
				dy = Y2 - Y1
			else
				sy = -1
				dy = Y1 - Y2
			end

			local err, e2 = dx-dy, nil

			local function PlotPixel()
				if X1 <= ResX and Y1 <= ResY and X1 > 0 and Y1 > 0 then -- Clipping
					TableInsert(DrawnPointsArray, Vector2New(X1, Y1))
				end

			end

			-- Start point
			PlotPixel()

			while not (X1 == X2 and Y1 == Y2) do
				e2 = err + err
				if e2 > -dy then
					err -= dy
					X1 += sx
				end
				if e2 < dx then
					err += dx
					Y1 += sy
				end

				PlotPixel()
			end

			return DrawnPointsArray
		else -- Custom polygon based thick line
			RoundedCaps = RoundedCaps or type(RoundedCaps) == "nil" -- Ensures if the parameter is empty, its on be default

			local RawRot = math.atan2(X1 - X2, Y1 - Y2) -- Use distances between each axis
			local Theta = RawRot

			local PiHalf = math.pi / 2

			-- Ensure we get an angle that measures up to 360 degrees (also avoids negative numbers)
			if RawRot < 0 then
				Theta = math.pi * 2 + RawRot
			end

			local Diameter = 1 + (Thickness * 2)
			local Rounder = (math.pi * 1.5) / Diameter

			if RoundedCaps then
				Theta = math.round(Theta / Rounder) * Rounder -- Avoids strange behaviours for the triangle points for the end circles
			end

			-- Start polygon points
			local StartCornerX1 = math.round(X1 + math.sin(Theta + PiHalf) * Thickness)
			local StartCornerY1 = math.round(Y1 + math.cos(Theta + PiHalf) * Thickness)

			local StartCornerX2 = math.round(X1 + math.sin(Theta - PiHalf) * Thickness)
			local StartCornerY2 = math.round(Y1 + math.cos(Theta - PiHalf) * Thickness)

			-- End polygon points
			local EndCornerX1 = math.round(X2 + math.sin(Theta + PiHalf) * Thickness)
			local EndCornerY1 = math.round(Y2 + math.cos(Theta + PiHalf) * Thickness)

			local EndCornerX2 = math.round(X2 + math.sin(Theta - PiHalf) * Thickness)
			local EndCornerY2 = math.round(Y2 + math.cos(Theta - PiHalf) * Thickness)

			-- Draw 2 triangles at the start and end corners
			local TrianglePointsA = Canvas:GetTrianglePoints(
				Vector2New(StartCornerX1, StartCornerY1), Vector2New(StartCornerX2, StartCornerY2), Vector2New(EndCornerX1, EndCornerY1), true
			)
			local TrianglePointsB = Canvas:GetTrianglePoints(
				Vector2New(StartCornerX2, StartCornerY2), Vector2New(EndCornerX1, EndCornerY1), Vector2New(EndCornerX2, EndCornerY2), true
			)
			
			local function InsertPoints(...)
				local PointsTable = {...}
				for i, Table in ipairs(PointsTable) do
					for i, Point in ipairs(Table) do
						table.insert(DrawnPointsArray, Point)
					end
				end
			end

			-- Draw rounded caps
			if RoundedCaps then
				local CirclePointsA = Canvas:GetCirclePoints(Vector2New(X1, Y1), Thickness, true)
				local CirclePointsB = Canvas:GetCirclePoints(Vector2New(X2, Y2), Thickness, true)
				InsertPoints(CirclePointsA)
				InsertPoints(CirclePointsB)
			end

			InsertPoints(TrianglePointsA)
			InsertPoints(TrianglePointsB)
		end

		return DrawnPointsArray
	end
	
	function Canvas:GetRectanglePoints(PointA: Vector2, PointB: Vector2, Fill: boolean?): {Vector2}
		local X1, Y1 = CeilN(PointA.X), CeilN(PointA.Y)
		local X2, Y2 = CeilN(PointB.X), CeilN(PointB.Y)
		
		local ReturnPoints = {}

		if Y2 < Y1 then
			Y1, Y2 = Swap(Y1, Y2)
		end

		if X2 < X1 then
			X1, X2 = Swap(X1, X2)
		end

		-- Clipped coordinates
		local StartX = math.max(X1, 1)
		local StartY = math.max(Y1, 1)

		local RangeX = math.abs(X2 - X1) + X1
		local RangeY = math.abs(Y2 - Y1) + Y1

		RangeX = math.min(RangeX, self.CurrentResX)
		RangeY = math.min(RangeY, self.CurrentResY)

		local function InsertPoints(...)
			local PointsTable = {...}
			for i, Table in ipairs(PointsTable) do
				for i, Point in ipairs(Table) do
					table.insert(ReturnPoints, Point)
				end
			end
		end

		if Fill or type(Fill) == "nil" then
			-- Fill every pixel
			for PlotX = StartX, RangeX do
				for PlotY = StartY, RangeY do
					table.insert(ReturnPoints, Vector2.new(PlotX, PlotY))
				end
			end
		else
			-- Just draw the outlines (using solid rectangles)
			local TopLine = Canvas:GetRectanglePoints(Vector2New(X1, Y1), Vector2New(X2, Y1), true)
			local BottomLine = Canvas:GetRectanglePoints(Vector2New(X1, Y2), Vector2New(X2, Y2), true)

			local LeftLine = Canvas:GetRectanglePoints(Vector2New(X1, Y1), Vector2New(X1, Y2), true)
			local RightLine = Canvas:GetRectanglePoints(Vector2New(X2, Y1), Vector2New(X2, Y2), true)

			InsertPoints(TopLine, BottomLine, LeftLine, RightLine)
		end

		return ReturnPoints
	end
	
	function Canvas:GetCirclePoints(Point: Vector2, Radius: number, Fill: boolean?): {Vector2}
		local X, Y = CeilN(Point.X), CeilN(Point.Y)
		
		local PointsArray = {}

		-- Draw the circle
		local dx, dy, err = Radius, 0, 1 - Radius
		local ResX, ResY = self.CurrentResX, self.CurrentResY

		local function CreatePixelForCircle(X, Y)
			if X < 1 or Y < 1 or X > ResX or Y > ResY then return end
			TableInsert(PointsArray, Vector2New(X, Y))
		end

		local function CreateLineForCircle(XA, YA, XB, YB)
			-- Rectangles have built in clipping
			local Line = Canvas:GetRectanglePoints(Vector2New(XA, YA), Vector2New(XB, YB), true)

			for i, Point in pairs(Line) do
				TableInsert(PointsArray, Point)
			end
		end

		if Fill or type(Fill) == "nil" then
			while dx >= dy do -- Filled circle
				CreateLineForCircle(X + dx, Y + dy, X - dx, Y + dy)
				CreateLineForCircle(X + dx, Y - dy, X - dx, Y - dy)
				CreateLineForCircle(X + dy, Y + dx, X - dy, Y + dx)
				CreateLineForCircle(X + dy, Y - dx, X - dy, Y - dx)

				dy = dy + 1
				if err < 0 then
					err = err + 2 * dy + 1
				else
					dx, err = dx - 1, err + 2 * (dy - dx) + 1
				end
			end
		else
			while dx >= dy do -- Circle outline
				CreatePixelForCircle(X + dx, Y + dy)
				CreatePixelForCircle(X - dx, Y + dy)
				CreatePixelForCircle(X + dx, Y - dy)
				CreatePixelForCircle(X - dx, Y - dy)
				CreatePixelForCircle(X + dy, Y + dx)
				CreatePixelForCircle(X - dy, Y + dx)
				CreatePixelForCircle(X + dy, Y - dx)
				CreatePixelForCircle(X - dy, Y - dx)

				dy = dy + 1
				if err < 0 then
					err = err + 2 * dy + 1
				else
					dx, err = dx - 1, err + 2 * (dy - dx) + 1
				end
			end
		end

		return PointsArray
	end

	--==<< Canvas Image Data Methods >>==--

	--[[
		Creates and returns an ImageData object from Point A to Point B on the canvas
	]]
	function Canvas:CreateImageDataFromCanvas(PointA: Vector2?, PointB: Vector2?)
		-- Set the default points to be the whole canvas corners
		PointA = PointA or Vector2New(1, 1)
		PointB = PointB or self.Resolution

		return ImageDataConstructor.new(self.CurrentResX, self.CurrentResY, InternalCanvas:GetBuffer())
	end

	--[[
		Draws an image to the canvas.
		
		Set <strong>TransparencyEnabled</strong> to false to disable alpha blending.
		
		Use <code>Canvas:SetBufferFromImage()</code> for a super performant alternative.
	]]
	function Canvas:DrawImageXY(ImageData: {}, X: number?, Y: number?, ScaleX: number?, ScaleY: number?, TransparencyEnabled: boolean?)
		X = X or 1
		Y = Y or 1
		ScaleX = ScaleX or 1
		ScaleY = ScaleY or 1

		local ImageResolutionX = ImageData.Width
		local ImageResolutionY = ImageData.Height

		local ScaledImageResX = ImageResolutionX * ScaleX
		local ScaledImageResY = ImageResolutionY * ScaleY
		
		local BlendingMode = self.AlphaBlendingMode

		local StartX = 1
		local StartY = 1

		local function GetPixelIndex(X, Y)
			return (X + (Y - 1) * ImageResolutionX) * 4 - 3
		end

		-- Clipping
		if X < 1 then
			StartX = -X + 2
		end
		if Y < 1 then
			StartY = -Y + 2
		end
		if X + ScaledImageResX - 1 > self.CurrentResX then
			ScaledImageResX -= (X + ScaledImageResX - 1) - self.CurrentResX
		end
		if Y + ScaledImageResY - 1 > self.CurrentResY then
			ScaledImageResY -= (Y + ScaledImageResY - 1) - self.CurrentResY
		end

		if not (TransparencyEnabled or type(TransparencyEnabled) == "nil") then
			if ScaleX == 1 and ScaleY == 1 then
				-- Draw normal image with no transparency and no scale adjustments (most optimal)
				for ImgX = StartX, ScaledImageResX do
					local PlacementX = X + ImgX - 1

					for ImgY = StartY, ScaledImageResY do
						local PlacementY = Y + ImgY - 1

						InternalCanvas:SetU32(PlacementX, PlacementY, ImageData:GetU32(ImgX, ImgY))
					end
				end
			else
				-- Draw normal image with no transparency with scale adjustments (pretty optimal)
				for ImgX = StartX, ScaledImageResX do
					local SampleX = CeilN(ImgX / ScaleX)
					local PlacementX = X + ImgX - 1

					for ImgY = StartY, ScaledImageResY do
						local SampleY = CeilN(ImgY / ScaleY)
						local PlacementY = Y + ImgY - 1

						InternalCanvas:SetU32(PlacementX, PlacementY, ImageData:GetU32(SampleX, SampleY))
					end
				end
			end	
		else
			-- Draw image with transparency (more expensive)
			for ImgX = StartX, ScaledImageResX do
				local SampleX = CeilN(ImgX / ScaleX)
				local PlacementX = X + ImgX - 1

				for ImgY = StartY, ScaledImageResY do
					local SampleY = CeilN(ImgY / ScaleY)
					local PlacementY = Y + ImgY - 1
					
					if BlendingMode == 0 then -- Normal
						local ImgR, ImgG, ImgB, ImgA = ImageData:GetRGBA(SampleX, SampleY)
						
						if ImgA == 0 then -- No need to do any calculations for completely transparent pixels
							continue
						end

						if ImgA < 1 then
							local BgR, BgG, BgB = InternalCanvas:GetRGB(PlacementX, PlacementY)
							
							ImgR = Lerp(BgR, ImgR, ImgA)
							ImgG = Lerp(BgG, ImgG, ImgA)
							ImgB = Lerp(BgB, ImgB, ImgA)
						end
						
						InternalCanvas:SetRGB(PlacementX, PlacementY, ImgR, ImgG, ImgB)
					elseif BlendingMode == 1 then -- Replace
						InternalCanvas:SetU32(PlacementX, PlacementY, ImageData:GetU32(SampleX, SampleY))
					end
				end
			end
		end
	end

	--[[
		Draws an image to the canvas.
		
		Set <strong>TransparencyEnabled</strong> to false to disable alpha blending.
		
		Use <code>Canvas:SetBufferFromImage()</code> for a super performant alternative.
	]]
	function Canvas:DrawImage(ImageData: {}, Point: Vector2?, Scale: Vector2?, TransparencyEnabled: boolean?)
		Point = Point or Vector2.new(1, 1)
		Scale = Scale or Vector2.new(1, 1)

		Point = RoundPoint(Point)

		Canvas:DrawImageXY(ImageData, Point.X, Point.Y, Scale.X, Scale.Y, TransparencyEnabled)
	end
	
	--[[
	    A super fast alternative to <code>Canvas:DrawImage()</code>, but without transformation
	
		This method draws an image to the canvas using very little computational power.
		
		<strong>NOTE:</strong> The image's resolution has to be the same as the canvas' resolution.
	]]
	function Canvas:SetBufferFromImage(ImageData: {})
		if ImageData.Width == self.CurrentResX and ImageData.Height == self.CurrentResY then
			Canvas:SetBuffer(ImageData.ImageBuffer)
		else
			OutputWarn("Failed to execute Canvas:SetBufferFromImage(). The image's resolution does not match the canvas resolution!")
		end
	end


	---==<< Draw Methods >>==--

	--[[
		Fills an area on the canvas of the specific colour chosen with a flood fill algorithm.
		
		This works the same way as a paint bucket tool would on a program like <strong>MS Paint</strong>
	]]
	function Canvas:FloodFill(Point: Vector2, Colour: Color3, Alpha: number?)
		Canvas:FloodFillXY(Point.X, Point.Y, Colour, Alpha)
	end

	--[[
		Fills an area on the canvas of the specific colour chosen with a flood fill algorithm.
		
		This works the same way as a paint bucket tool would on a program like <strong>MS Paint</strong>
	]]
	function Canvas:FloodFillXY(X: number, Y: number, Colour: Color3, Alpha: number?) -- Optimised by @DukeAunarky
		X, Y = CeilN(X), CeilN(Y)
		local canvasWidth, canvasHeight = self.CurrentResX, self.CurrentResY

		if X < 1 or Y < 1 or X > canvasWidth or Y > canvasHeight then return end

		local OrigR, OrigG, OrigB = self:GetRGB(X, Y)
		local ColR, ColG, ColB = Colour.R, Colour.G, Colour.B
		Alpha = Alpha or 1

		if OrigR == ColR and OrigG == ColG and OrigB == ColB then return end

		-- Whoohoo to Buffers!
		-- Create a buffer for seen pixels (1 byte per pixel)
		local seenBuffer = buffer.create(canvasWidth * canvasHeight)

		-- Preallocate queue buffer
		-- This gets increased dynamically if there's more canvas to fill
		local maxQueueSize = canvasWidth * canvasHeight * 2
		local queueBuffer = buffer.create(maxQueueSize * 2 * 4) -- 2 values (X, Y) per queue entry, 4 bytes per number

		-- Insert the first point into the queue
		buffer.writei32(queueBuffer, 0, X)
		buffer.writei32(queueBuffer, 4, Y)

		-- Create a buffer for vectorOffsets instead of Vector2s (8 signed ints: 0, -1, 1, 0, 0, 1, -1, 0)
		local vectorBuffer = buffer.create(8 * 4)
		-- vectorUp
		buffer.writei32(vectorBuffer, 0, 0); buffer.writei32(vectorBuffer, 4, -1);
		-- vectorRight
		buffer.writei32(vectorBuffer, 8, 1); buffer.writei32(vectorBuffer, 12, 0);
		-- vectorDown
		buffer.writei32(vectorBuffer, 16, 0); buffer.writei32(vectorBuffer, 20, 1);
		-- vectorLeft
		buffer.writei32(vectorBuffer, 24, -1); buffer.writei32(vectorBuffer, 28, 0);

		local queueStart, queueEnd = 0, 1
		local BlendingMode = self.AlphaBlendingMode

		while queueStart < queueEnd do
			local offset = queueStart * 8
			local currentPointX = buffer.readi32(queueBuffer, offset)
			local currentPointY = buffer.readi32(queueBuffer, offset + 4)
			queueStart += 1

			if currentPointX > 0 and currentPointY > 0 and currentPointX <= canvasWidth and currentPointY <= canvasHeight then
				local key = currentPointX + (currentPointY - 1) * canvasWidth

				if buffer.readu8(seenBuffer, key - 1) == 0 then
					local R, G, B = InternalCanvas:GetRGB(currentPointX, currentPointY)

					if R == OrigR and G == OrigG and B == OrigB then
						if BlendingMode == 0 and Alpha ~= 0 then -- Normal blending
							local SetR, SetG, SetB = ColR, ColG, ColB

							if Alpha ~= 1 then
								local BgR, BgG, BgB = InternalCanvas:GetRGB(currentPointX, currentPointY)
								SetR = Lerp(BgR, ColR, Alpha)
								SetG = Lerp(BgG, ColG, Alpha)
								SetB = Lerp(BgB, ColB, Alpha)
							end

							InternalCanvas:SetRGB(currentPointX, currentPointY, SetR, SetG, SetB)
						elseif BlendingMode == 1 then -- Replace mode
							InternalCanvas:SetRGBA(currentPointX, currentPointY, ColR, ColG, ColB, Alpha)
						end

						-- Mark as seen
						buffer.writeu8(seenBuffer, key - 1, 1)

						-- We'll allocate more buffer space if the queueSize exceeds what we initially gave it.
						-- This tends to happen whenever a large empty canvas is FloodFilled.
						if queueEnd >= maxQueueSize then
							local newQueueBuffer = buffer.create((maxQueueSize * 2) * 2 * 4)
							buffer.copy(newQueueBuffer, 0, queueBuffer, 0, maxQueueSize * 2 * 4)
							queueBuffer = newQueueBuffer
							maxQueueSize = maxQueueSize * 2
						end

						if queueEnd < maxQueueSize then
							for i = 0, 3 do
								local vectorX = buffer.readi32(vectorBuffer, i * 8)
								local vectorY = buffer.readi32(vectorBuffer, i * 8 + 4)
								local nextX = currentPointX + vectorX
								local nextY = currentPointY + vectorY

								-- Only write to the queue if within bounds
								if queueEnd < maxQueueSize then
									buffer.writei32(queueBuffer, queueEnd * 8, nextX)
									buffer.writei32(queueBuffer, queueEnd * 8 + 4, nextY)
									queueEnd += 1
								end
							end
						else
							-- Guess that wasn't enough!
							OutputWarn("FloodFill: Queue buffer overflow prevented.")
							break
						end
					end
				end
			end
		end
	end
	
	-- Set pixel methods
	Canvas.SetPixel = InternalCanvas.SetColor3
	Canvas.SetRGB = InternalCanvas.SetRGB
	Canvas.SetRGBA = InternalCanvas.SetRGBA
	Canvas.SetAlpha = InternalCanvas.SetAlpha
	Canvas.SetU32 = InternalCanvas.SetU32

	--[[
		Takes an array of RGBA values (ranging from 0 to 1) to render all pixel on the canvas.
		
		The size of the array is assumed to be <strong>Width × Height × 4</strong>
	]]
	function Canvas:SetGrid(PixelArray: {number})
		return InternalCanvas:SetGrid(PixelArray)
	end

	--[[
		Takes a buffer of RGBA unsigned 8 bit int values (range from 0 to 255) to render all pixel on the canvas.
		
		The size of the buffer is assumed to be <strong>Width × Height × 4</strong>
	]]
	function Canvas:SetBuffer(PixelBuffer: buffer)
		return InternalCanvas:SetBuffer(PixelBuffer)
	end


	-- Draws a circle with a radius to the canvas from the middle
	function Canvas:DrawCircle(Point: Vector2, Radius: number, Colour: Color3, Alpha: number?, Fill: boolean?)
		Canvas:DrawCircleXY(Point.X, Point.Y, Radius, Colour, Alpha, Fill)
	end

	-- Draws a circle with a radius to the canvas from the middle
	function Canvas:DrawCircleXY(X: number, Y: number, Radius: number, Colour: Color3, Alpha: number?, Fill: boolean?)
		local ColR, ColG, ColB = Colour.R, Colour.G, Colour.B
		X, Y = CeilN(X), CeilN(Y)
		
		-- Backwards compatability for pre 4.12 versions
		if type(Alpha) == "boolean" then
			Fill = Alpha
			Alpha = 1
		end
		
		Alpha = Alpha or 1
		
		local BlendingMode = self.AlphaBlendingMode
		
		local ResX, ResY = self.CurrentResX, self.CurrentResY
		
		local ColourBuffer = buffer.create(4)
		buffer.writeu8(ColourBuffer, 0, ColR * 255)
		buffer.writeu8(ColourBuffer, 1, ColG * 255)
		buffer.writeu8(ColourBuffer, 2, ColB * 255)
		buffer.writeu8(ColourBuffer, 3, Alpha * 255)
		
		local ColourU32 = buffer.readu32(ColourBuffer, 0)

		-- Draw the circle

		local function CreatePixelForCircle(DrawX, DrawY)
			if DrawX > ResX or DrawY > ResY or DrawX < 1 or DrawY < 1 then
				return -- Clip
			end
			
			if BlendingMode == 0 and Alpha > 0 then -- Normal
				local R = ColR
				local G = ColG
				local B = ColB
				
				if Alpha < 1 then
					local BgR, BgG, BgB = InternalCanvas:GetRGB(DrawX, DrawY)

					R = Lerp(BgR, R, Alpha)
					G = Lerp(BgG, G, Alpha)
					B = Lerp(BgB, B, Alpha)
				end

				InternalCanvas:SetRGB(DrawX, DrawY, R, G, B)
			elseif BlendingMode == 1 then -- Replace
				InternalCanvas:SetU32(DrawX, DrawY, ColourU32)
			end
		end

		local function CreateLineForCircle(EndX, StartX, Y)
			-- Rectangles have built in clipping
			self:DrawRectangleXY(StartX, Y, EndX, Y, Colour, Alpha, true)
		end

		if Fill or type(Fill) == "nil" then
			-- Iterate over each row of the bounding box
			for y = -Radius, Radius do
				local rowY = Y + y
				-- Determine the horizontal extent of the circle at this y position
				local HorizontalRadius = math.sqrt(Radius * Radius - y * y + Radius / 2)
				
				local startX = math.ceil(-HorizontalRadius) -- Round up to avoid gaps
				local endX = math.floor(HorizontalRadius)  -- Round down to avoid gaps
			
				CreateLineForCircle(X + startX, X + endX, rowY)
			end
		else
			local dx, dy, err = Radius, 0, 1 - Radius
			
			while dx >= dy do -- Circle outline
				if dy ~= 0 then
					CreatePixelForCircle(X + dx, Y + dy)
					CreatePixelForCircle(X - dx, Y + dy)
				end
				
				--if dy ~= dx then
				CreatePixelForCircle(X + dx, Y - dy)
				CreatePixelForCircle(X - dx, Y - dy)
				CreatePixelForCircle(X + dy, Y + dx)
				CreatePixelForCircle(X + dy, Y - dx)
				--end
				
				if dy ~= 0 then
					CreatePixelForCircle(X - dy, Y + dx)
					CreatePixelForCircle(X - dy, Y - dx)
				end
				
		

				dy = dy + 1
				if err < 0 then
					err = err + 2 * dy + 1
				else
					dx, err = dx - 1, err + 2 * (dy - dx) + 1
				end
			end
		end
	end

	-- Draws a simple rectangle from PointA to PointB
	function Canvas:DrawRectangle(PointA: Vector2, PointB: Vector2, Colour: Color3, Alpha: number?, Fill: boolean?)
		Canvas:DrawRectangleXY(PointA.X, PointA.Y, PointB.X, PointB.Y, Colour, Alpha, Fill)
	end

	-- Draws a simple rectangle from PointA to PointB
	function Canvas:DrawRectangleXY(X1: number, Y1: number, X2: number, Y2: number, Colour: Color3, Alpha: number?, Fill: boolean?)
		local ColR, ColG, ColB = Colour.R, Colour.G, Colour.B

		local BlendingMode = self.AlphaBlendingMode
		
		-- Backwards compatability for pre 4.12 versions
		if type(Alpha) == "boolean" then
			Fill = Alpha
			Alpha = 1
		end

		Alpha = Alpha or 1

		X1, Y1 = CeilN(X1), CeilN(Y1)
		X2, Y2 = CeilN(X2), CeilN(Y2)

		if Y2 < Y1 then
			Y1, Y2 = Swap(Y1, Y2)
		end

		if X2 < X1 then
			X1, X2 = Swap(X1, X2)
		end

		-- Clipped coordinates
		local StartX = math.max(X1, 1)
		local StartY = math.max(Y1, 1)

		local RangeX = math.abs(X2 - X1) + X1
		local RangeY = math.abs(Y2 - Y1) + Y1

		RangeX = math.min(RangeX, self.CurrentResX)
		RangeY = math.min(RangeY, self.CurrentResY)

		if Fill or type(Fill) == "nil" then
			-- Fill every pixel
			if BlendingMode == 0 then -- Normal
				if Alpha < 1 then
					-- Alpha blend fill
					for PlotX = StartX, RangeX do
						for PlotY = StartY, RangeY do
							local R = ColR
							local G = ColG
							local B = ColB

							if Alpha < 1 then
								local BgR, BgG, BgB = InternalCanvas:GetRGB(PlotX, PlotY)

								R = Lerp(BgR, R, Alpha)
								G = Lerp(BgG, G, Alpha)
								B = Lerp(BgB, B, Alpha)
							end

							InternalCanvas:SetRGB(PlotX, PlotY, R, G, B)
						end
					end
				else
					-- Fast fill
					for PlotX = StartX, RangeX do
						for PlotY = StartY, RangeY do
							InternalCanvas:SetRGB(PlotX, PlotY, ColR, ColG, ColB)
						end
					end
				end
			elseif BlendingMode == 1 then -- Replace
				local ColourBuffer = buffer.create(4)
				buffer.writeu8(ColourBuffer, 0, ColR * 255)
				buffer.writeu8(ColourBuffer, 1, ColG * 255)
				buffer.writeu8(ColourBuffer, 2, ColB * 255)
				buffer.writeu8(ColourBuffer, 3, Alpha * 255)

				local ColourU32 = buffer.readu32(ColourBuffer, 0)
				
				for PlotX = StartX, RangeX do
					for PlotY = StartY, RangeY do
						InternalCanvas:SetU32(PlotX, PlotY, ColourU32)
					end
				end
			end
		else
			-- Just draw the outlines (using solid rectangles)
			Canvas:DrawRectangleXY(X1, Y1, X2, Y1, Colour, Alpha, true)
			Canvas:DrawRectangleXY(X1, Y2, X2, Y2, Colour, Alpha, true)

			Canvas:DrawRectangleXY(X1, Y1, X1, Y2, Colour, Alpha, true)
			Canvas:DrawRectangleXY(X2, Y1, X2, Y2, Colour, Alpha, true)
		end
	end

	-- Draws a 3 point triangle from PointA to PointB to PointC
	function Canvas:DrawTriangle(PointA: Vector2, PointB: Vector2, PointC: Vector2, Colour: Color3, Alpha: number?, Fill: boolean?)
		Canvas:DrawTriangleXY(PointA.X, PointA.Y, PointB.X, PointB.Y, PointC.X, PointC.Y, Colour, Alpha, Fill)
	end

	-- Draws a 3 point triangle from PointA to PointB to PointC
	function Canvas:DrawTriangleXY(X1: number, Y1: number, X2: number, Y2: number, X3: number, Y3: number, Colour: Color3, Alpha: number?, Fill: boolean?)
		X1, Y1 = CeilN(X1), CeilN(Y1)
		X2, Y2 = CeilN(X2), CeilN(Y2)
		X3, Y3 = CeilN(X3), CeilN(Y3)

		local ColR, ColG, ColB = Colour.R, Colour.G, Colour.B

		-- Backwards compatability for pre 4.12 versions
		if type(Alpha) == "boolean" then
			Fill = Alpha
			Alpha = 1
		end
		
		Alpha = Alpha or 1

		local BlendingMode = self.AlphaBlendingMode

		if not (Fill or type(Fill) == "nil") then
			-- Bresenham triangle outlines
			DrawSimpleLine(X1, Y1, X2, Y2, Colour, Alpha)
			DrawSimpleLine(X2, Y2, X3, Y3, Colour, Alpha)
			DrawSimpleLine(X3, Y3, X1, Y1, Colour, Alpha)
			return
		end

		local ColourBuffer = buffer.create(4)
		buffer.writeu8(ColourBuffer, 0, ColR * 255)
		buffer.writeu8(ColourBuffer, 1, ColG * 255)
		buffer.writeu8(ColourBuffer, 2, ColB * 255)
		buffer.writeu8(ColourBuffer, 3, Alpha * 255)

		local ColourU32 = buffer.readu32(ColourBuffer, 0)

		local R, G, B = Colour.R, Colour.G, Colour.B

		-- Sort vertices by Y-coordinate (and X-coordinate if tied)
		if Y2 < Y1 or (Y2 == Y1 and X2 < X1) then
			X1, Y1, X2, Y2 = X2, Y2, X1, Y1
		end
		if Y3 < Y1 or (Y3 == Y1 and X3 < X1) then
			X1, Y1, X3, Y3 = X3, Y3, X1, Y1
		end
		if Y3 < Y2 or (Y3 == Y2 and X3 < X2) then
			X2, Y2, X3, Y3 = X3, Y3, X2, Y2
		end

		-- Precompute clipping bounds
		local YMin = math.max(1, Y1)
		local YMax = math.min(self.CurrentResY, Y3)

		local function Plotline(ax, bx, Y)
			if ax > bx then
				ax, bx = bx, ax
			end

			-- Pre-clipped scanline bounds
			local StartX = math.max(1, ax)
			local EndX = math.min(self.CurrentResX, bx)

			if BlendingMode == 0 then -- Normal
				if Alpha > 0 then
					if Alpha < 1 then
						-- Blend
						for X = StartX, EndX do
							local R = ColR
							local G = ColG
							local B = ColB

							if Alpha < 1 then
								local BgR, BgG, BgB = InternalCanvas:GetRGB(X, Y)

								R = Lerp(BgR, R, Alpha)
								G = Lerp(BgG, G, Alpha)
								B = Lerp(BgB, B, Alpha)
							end

							InternalCanvas:SetRGB(X, Y, R, G, B)
						end
					else
						-- No need to do complicated blending
						for X = StartX, EndX do
							InternalCanvas:SetRGB(X, Y, R, G, B)
						end
					end

				end

			elseif BlendingMode == 1 then -- Replace
				for X = StartX, EndX do
					InternalCanvas:SetU32(X, Y, ColourU32)
				end
			end

		end
		
		local OrigX3, OrigX2, OrigX1 = X3, X2, X1
		local OrigY1, OrigY3 = Y1, Y3

		local function FillTopTriangle(X1, Y1, X2, Y2, X3, Y3)
			local invslope1 = (X2 - X1) / (Y2 - Y1)
			local invslope2 = (X3 - X1) / (Y3 - Y1)

			local curx1 = X1
			local curx2 = X1

			for scanlineY = math.max(Y1, YMin), math.min(Y2 - 1, YMax) do
				local ax = RoundN(curx1)
				local bx = RoundN(curx2)
				Plotline(ax, bx, scanlineY)
				curx1 += invslope1
				curx2 += invslope2
			end
		end

		local function FillBottomTriangle(X1, Y1, X2, Y2, X3, Y3)
			local invslope1 = (X3 - X1) / (Y3 - Y1)
			local invslope2 = (X3 - X2) / (Y3 - Y2)
			
			local curx1 = X1
			local curx2 = X2
			
			-- Prevent inf or nan numbers
			if invslope1 >= math.huge or invslope1 ~= invslope1 then
				invslope1 = 0
				invslope2 = 0
				
				if OrigY1 == OrigY3 then
					curx1 = OrigX1
				else
					curx1 = OrigX2
				end
				
				curx2 = OrigX3
			end
			
			for scanlineY = math.max(Y2, YMin), math.min(Y3, YMax) do
				local ax = RoundN(curx1)
				local bx = RoundN(curx2)
				Plotline(ax, bx, scanlineY)
				curx1 += invslope1
				curx2 += invslope2
			end
		end

		-- Fill triangle
		local X4 = X1 + (Y2 - Y1) / (Y3 - Y1) * (X3 - X1)
		
		FillTopTriangle(X1, Y1, X2, Y2, X4, Y2)
		FillBottomTriangle(X2, Y2, X4, Y2, X3, Y3)
	end


	--[[
		Draws a 3 point textured triangle with UV offset values
		
		The UV values range from 0 to 1
		
		Built for simple and fast 3D graphics rendering
	]]
	function Canvas:DrawTexturedTriangleXY(
		X1: number, Y1: number, X2: number, Y2: number, X3: number, Y3: number,
		U1: number, V1: number, U2: number, V2: number, U3: number, V3: number,
		ImageData, Brightness: number?
	)
		local TexResX, TexResY = ImageData.Width, ImageData.Height
		local BlendingMode = Canvas.AlphaBlendingMode

		if Y2 < Y1 then
			Y1, Y2 = Swap(Y1, Y2)
			X1, X2 = Swap(X1, X2)
			U1, U2 = Swap(U1, U2)
			V1, V2 = Swap(V1, V2)
		end

		if Y3 < Y1 then
			Y1, Y3 = Swap(Y1, Y3)
			X1, X3 = Swap(X1, X3)
			U1, U3 = Swap(U1, U3)
			V1, V3 = Swap(V1, V3)
		end

		if Y3 < Y2 then
			Y2, Y3 = Swap(Y2, Y3)
			X2, X3 = Swap(X2, X3)
			U2, U3 = Swap(U2, U3)
			V2, V3 = Swap(V2, V3)
		end

		if Y3 == Y1 then
			Y3 += 1
		end

		Brightness = Brightness or 1

		local dy1 = Y2 - Y1
		local dx1 = X2 - X1
		local dv1 = V2 - V1
		local du1 = U2 - U1

		local dy2 = Y3 - Y1
		local dx2 = X3 - X1
		local dv2 = V3 - V1
		local du2 = U3 - U1

		local TexU, TexV = 0, 0

		local dax_step, dbx_step = 0, 0
		local du1_step, dv1_step = 0, 0
		local du2_step, dv2_step = 0, 0

		dax_step = dx1 / math.abs(dy1)
		dbx_step = dx2 / math.abs(dy2)

		du1_step = du1 / math.abs(dy1)
		dv1_step = dv1 / math.abs(dy1)

		du2_step = du2 / math.abs(dy2)
		dv2_step = dv2 / math.abs(dy2)

		local function Plotline(ax, bx, tex_su, tex_eu, tex_sv, tex_ev, Y, IsBot)
			if ax > bx then
				ax, bx = Swap(ax, bx)
				tex_su, tex_eu = Swap(tex_su, tex_eu)
				tex_sv, tex_ev = Swap(tex_sv, tex_ev)
			end

			local ScanlineLength = bx - ax
			if ScanlineLength == 0 then return end -- Avoid divide-by-zero

			-- Calculate UV increments per pixel
			local Step = 1 / ScanlineLength
			local du = (tex_eu - tex_su) * Step
			local dv = (tex_ev - tex_sv) * Step

			-- Clip X right
			if bx > self.CurrentResX then
				ScanlineLength = self.CurrentResX - ax
			end

			-- Clip X left
			local StartOffsetX = 0
			local t = 0

			if ax < 1 then	
				StartOffsetX = -(ax - 1)
				t = Step * StartOffsetX
			end

			-- Initialize UV coordinates with offset
			TexU = tex_su + t * (tex_eu - tex_su)
			TexV = tex_sv + t * (tex_ev - tex_sv)

			TexU = TexU * TexResX + 1
			TexV = TexV * TexResY + 1

			du *= TexResX
			dv *= TexResY

			-- Main loop to draw pixels across the scanline

			if Brightness < 1 then
				-- Adjust brightness loop
				for j = StartOffsetX, ScanlineLength do
					local SampleX = ClampN(FloorN(TexU), 1, TexResX)
					local SampleY = ClampN(FloorN(TexV), 1, TexResY)
					
					local DrawX = ax + j

					local R, G, B, A = ImageData:GetRGBA(SampleX, SampleY)
					
					if Brightness < 1 then
						R *= Brightness
						G *= Brightness
						B *= Brightness
					end
					
					if BlendingMode == 0 then -- Normal
						local R, G, B, A = ImageData:GetRGBA(SampleX, SampleY)

						if A > 0 then
							InternalCanvas:SetRGB(DrawX, Y, R, G, B)
						end

					elseif BlendingMode == 1 then -- Replace
						InternalCanvas:SetU32(DrawX, Y, ImageData:GetU32(SampleX, SampleY))
					end

					-- Increment UV values
					TexU += du
					TexV += dv
				end
			else
				-- Normal render loop
				for j = StartOffsetX, ScanlineLength do
					local SampleX = ClampN(FloorN(TexU), 1, TexResX)
					local SampleY = ClampN(FloorN(TexV), 1, TexResY)

					local DrawX = ax + j

					if BlendingMode == 0 then -- Normal
						local R, G, B, A = ImageData:GetRGBA(SampleX, SampleY)
						
						if A > 0 then
							InternalCanvas:SetRGB(DrawX, Y, R, G, B)
						end
						
					elseif BlendingMode == 1 then -- Replace
						InternalCanvas:SetU32(DrawX, Y, ImageData:GetU32(SampleX, SampleY))
					end

					-- Increment UV values
					TexU += du
					TexV += dv
				end
			end


		end

		-- Clip Y top
		local YStart = 1

		if Y1 < 1 then
			YStart = 1 - Y1
		end

		-- Clip Y top
		local TopYDist = math.min(Y2 - Y1, self.CurrentResY - Y1)

		-- Draw top triangle
		for i = YStart, TopYDist do
			--task.wait(1)
			local ax = RoundN(X1 + i * dax_step)
			local bx = RoundN(X1 + i * dbx_step)

			-- Start values
			local tex_su = U1 + i * du1_step
			local tex_sv = V1 + i * dv1_step

			-- End values
			local tex_eu = U1 + i * du2_step
			local tex_ev = V1 + i * dv2_step

			-- Scan line
			Plotline(ax, bx, tex_su, tex_eu, tex_sv, tex_ev, Y1 + i)
		end

		dy1 = Y3 - Y2
		dx1 = X3 - X2
		dv1 = V3 - V2
		du1 = U3 - U2

		dax_step = dx1 / math.abs(dy1)
		dbx_step = dx2 / math.abs(dy2)

		du1_step, dv1_step = 0, 0

		du1_step = du1 / math.abs(dy1)
		dv1_step = dv1 / math.abs(dy1)

		-- Draw bottom triangle

		-- Clip Y bottom
		local BottomYDist = math.min(Y3 - Y2, self.CurrentResY - Y2)

		local YStart = 0

		if Y2 < 1 then
			YStart = 1 - Y2
		end

		for i = YStart, BottomYDist do
			i = Y2 + i
			--task.wait(1)
			local ax = RoundN(X2 + (i - Y2) * dax_step)
			local bx = RoundN(X1 + (i - Y1) * dbx_step)

			-- Start values
			local tex_su = U2 + (i - Y2) * du1_step
			local tex_sv = V2 + (i - Y2) * dv1_step

			-- End values
			local tex_eu = U1 + (i - Y1) * du2_step
			local tex_ev = V1 + (i - Y1) * dv2_step

			Plotline(ax, bx, tex_su, tex_eu, tex_sv, tex_ev, i, true)
		end
	end

	--[[
		Draws a 3 point textured triangle with UV offset values
		
		The UV values range from 0 to 1
		
		Built for simple and fast 3D graphics rendering
	]]
	function Canvas:DrawTexturedTriangle(
		PointA: Vector2, PointB: Vector2, PointC: Vector2, 
		UV1: Vector2, UV2: Vector2, UV3: Vector2, 
		ImageData: {}, Brightness: number?
	)

		-- Convert to intergers
		local X1, X2, X3 = CeilN(PointA.X), CeilN(PointB.X), CeilN(PointC.X)
		local Y1, Y2, Y3 = CeilN(PointA.Y), CeilN(PointB.Y), CeilN(PointC.Y)

		Canvas:DrawTexturedTriangleXY(
			X1, Y1, X2, Y2, X3, Y3,
			UV1.X, UV1.Y, UV2.X, UV2.Y, UV3.X, UV3.Y,
			ImageData, Brightness
		)
	end

	--[[
		Draws a 4 point textured image with affine transformation
		
		Distortion may be present at skewed angles
	]]
	function Canvas:DrawDistortedImageXY(X1, Y1, X2, Y2, X3, Y3, X4, Y4, ImageData: {}, Brightness: number?)
		Canvas:DrawTexturedTriangleXY(
			X1, Y1, X2, Y2, X3, Y3,
			0, 0, 1, 0, 1, 1,
			ImageData, Brightness
		)
		Canvas:DrawTexturedTriangleXY(
			X1, Y1, X4, Y4, X3, Y3,
			0, 0, 0, 1, 1, 1,
			ImageData, Brightness
		)
	end

	--[[
		Draws a 4 point textured image with affine transformation
		
		Distortion may be present at skewed angles
	]]
	function Canvas:DrawDistortedImage(PointA: Vector2, PointB: Vector2, PointC: Vector2, PointD: Vector2, ImageData: {}, Brightness: number?)
		Canvas:DrawDistortedImageXY(
			PointA.X, PointA.Y, PointB.X, PointB.Y, PointC.X, PointC.Y, PointD.X, PointD.Y,
			ImageData, Brightness
		)
	end

	--[[
		Draws an advanced image with rotation and pivoting properties
	]]
	function Canvas:DrawRotatedImageXY(ImageData: {}, Angle: number, X: number?, Y: number?, 
		PivotX: number?, PivotY: number?, ScaleX: number?, ScaleY: number?)

		X = X or 1
		Y = Y or 1
		PivotX = PivotX or 0
		PivotY = PivotY or 0
		ScaleX = ScaleX or 1
		ScaleY = ScaleY or 1

		local ImageSizeX, ImageSizeY = ImageData.Width * ScaleX, ImageData.Height * ScaleY

		X -= PivotX * ImageSizeX
		Y -= PivotY * ImageSizeY

		local PivotX = X + (PivotX * ImageSizeX)
		local PivotY = Y + (PivotY * ImageSizeY)

		local CosTheta, SinTheta = math.cos(Angle), math.sin(Angle)

		local function RotatePoint(X, Y)
			-- Rotation maths
			local RotX = (CosTheta * (X - PivotX) - SinTheta * (Y - PivotY) + PivotX)
			local RotY = (SinTheta * (X - PivotX) + CosTheta * (Y - PivotY) + PivotY)

			return math.floor(RotX), math.floor(RotY)
		end

		local X1, Y1 = RotatePoint(X, Y)
		local X2, Y2 = RotatePoint(X + ImageSizeX, Y)
		local X3, Y3 = RotatePoint(X + ImageSizeX, Y + ImageSizeY)
		local X4, Y4 = RotatePoint(X, Y + ImageSizeY)

		Canvas:DrawDistortedImageXY(X1, Y1, X2, Y2, X3, Y3, X4, Y4, ImageData)
	end

	--[[
		Draws an advanced image with rotation and pivoting properties
	]]
	function Canvas:DrawRotatedImage(ImageData: {}, Angle: number, Point: Vector2?, PivotPoint: Vector2?, Scale: Vector2?)
		Point = Point or Vector2New(1, 1)
		PivotPoint = PivotPoint or Vector2New(0, 0)
		Scale = Scale or Vector2New(1, 1)

		Canvas:DrawRotatedImageXY(ImageData, Angle, Point.X, Point.Y, PivotPoint.X, PivotPoint.Y, Scale.X, Scale.Y)
	end

	--[[
		Draws an image with rect size and rect offset properties. Behaves much like ImageLabel's rect properties.
		
		RectOffset and RectSize are in pixels relative to the image
	]]
	function Canvas:DrawImageRectXY(ImageData: {}, X: number, Y: number, 
		RectOffsetX: number, RectOffsetY: number, RectSizeX: number, RectSizeY: number, 
		ScaleX: number?, ScaleY: number?, FlipX: boolean?, FlipY: boolean?
	) -- Contributed by @DukeAunarky

		ScaleX = ScaleX or 1
		ScaleY = ScaleY or 1

		X, Y = CeilN(X), CeilN(Y)
		RectOffsetX, RectOffsetY = FloorN(RectOffsetX), FloorN(RectOffsetY)
		RectSizeX, RectSizeY = CeilN(RectSizeX), CeilN(RectSizeY)

		local ImageSizeX, ImageSizeY = ImageData.Width, ImageData.Height
		local ImageScaledSizeX, ImageScaledSizeY = math.floor(ImageSizeX * ScaleX), math.floor(ImageSizeY * ScaleY)

		-- Scale and interpolation values
		local SU, SV = (1 / ImageScaledSizeX) * RectSizeX, (1 / ImageScaledSizeY) * RectSizeY

		local StartX = X
		local EndX = X + ImageScaledSizeX - 1

		local StartY = Y
		local EndY = Y + ImageScaledSizeY - 1

		-- Clipping end
		EndX = math.min(EndX, self.CurrentResX)
		EndY = math.min(EndY, self.CurrentResY)

		local SampleXStart = FlipX and (RectOffsetX + RectSizeX) or (RectOffsetX + 1)
		local SampleYStart = FlipY and (RectOffsetY + RectSizeY) or (RectOffsetY + 1)

		local SampleXStep = FlipX and -SU or SU
		local SampleYStep = FlipY and -SV or SV

		-- Clipping start
		if StartX < 1 then
			SampleXStart += SampleXStep * -(StartX - 1)
		end

		if StartY < 1 then
			SampleYStart += SampleYStep * -(StartY - 1)
		end

		StartX = math.max(1, StartX)
		StartY = math.max(1, StartY)

		local SampleX = SampleXStart
		
		local BlendingMode = Canvas.AlphaBlendingMode

		-- Main draw loop
		for DrawX = StartX, EndX do
			local SampleY = SampleYStart
			local RoundSampleX

			if FlipX then
				RoundSampleX = CeilN(SampleX)
			else
				RoundSampleX = FloorN(SampleX)
			end

			for DrawY = StartY, EndY do
				local RoundSampleY

				if FlipY then
					RoundSampleY = CeilN(SampleY)
				else
					RoundSampleY = FloorN(SampleY)
				end

				if BlendingMode == 0 then -- Normal
					local R, G, B, A = ImageData:GetRGBA(RoundSampleX, RoundSampleY)
					
					if A == 0 then -- No need to do any calculations for completely transparent pixels
						SampleY += SampleYStep
						continue
					end

					if A < 1 then
						local BgR, BgG, BgB = InternalCanvas:GetRGB(DrawX, DrawY)
						
						R = Lerp(BgR, R, A)
						G = Lerp(BgG, G, A)
						B = Lerp(BgB, B, A)
					end

					InternalCanvas:SetRGB(DrawX, DrawY, R, G, B)
				elseif BlendingMode == 1 then -- Replace
					InternalCanvas:SetU32(DrawX, DrawY, ImageData:GetU32(RoundSampleX, RoundSampleY))
				end

				SampleY += SampleYStep
			end

			SampleX += SampleXStep
		end
	end

	--[[
		Draws an image with rect size and rect offset properties. Behaves much like ImageLabel's rect properties.
		
		RectOffset and RectSize are in pixels relative to the image
	]]
	function Canvas:DrawImageRect(ImageData: {}, Point: Vector2, ReftOffset: Vector2, RectSize: Vector2, Scale: Vector2?, 
		FlipX: boolean?, FlipY: boolean?
	)
		Scale = Scale or Vector2New(1, 1)

		Canvas:DrawImageRectXY(ImageData, Point.X, Point.Y, ReftOffset.X, ReftOffset.Y, RectSize.X, RectSize.Y, Scale.X, Scale.Y)
	end

	--[[
		Draws a line from two points on the canvas. If a thickness isn't given or is set to 0, a standard and fast bresenham line algoritm will be used.
		Otherwise, a custom triangle-based line will be drawn for the thickness with an option for round or flat ends with the 
		<strong>RoundedCaps</strong> parameter.
	]]
	function Canvas:DrawLine(PointA: Vector2, PointB: Vector2, Colour: Color3, Thickness: number?, RoundedCaps: boolean?)
		Canvas:DrawLineXY(PointA.X, PointA.Y, PointB.X, PointB.Y, Colour, Thickness, RoundedCaps)
	end

	--[[
		Draws a line from two points on the canvas. If a thickness isn't given or is set to 0, a standard and fast bresenham line algoritm will be used.
		Otherwise, a custom triangle-based line will be drawn for the thickness with an option for round or flat ends with the 
		<strong>RoundedCaps</strong> parameter.
	]]
	function Canvas:DrawLineXY(X1: number, Y1: number, X2: number, Y2: number, Colour: Color3, Thickness: number?, RoundedCaps: boolean?)
		local ColR, ColG, ColB = Colour.R, Colour.G, Colour.B
		local ResX, ResY = self.CurrentResX, self.CurrentResY

		local BlendingMode = self.AlphaBlendingMode
		
		local ColourBuffer = buffer.create(4)
		buffer.writeu8(ColourBuffer, 0, ColR * 255)
		buffer.writeu8(ColourBuffer, 1, ColG * 255)
		buffer.writeu8(ColourBuffer, 2, ColB * 255)
		buffer.writeu8(ColourBuffer, 3, 255)

		local ColourU32 = buffer.readu32(ColourBuffer, 0)

		if not Thickness or Thickness < 1 then -- Bresenham line
			X1, Y1 = CeilN(X1), CeilN(Y1)
			X2, Y2 = CeilN(X2), CeilN(Y2)

			local sx, sy, dx, dy

			if X1 < X2 then
				sx = 1
				dx = X2 - X1
			else
				sx = -1
				dx = X1 - X2
			end

			if Y1 < Y2 then
				sy = 1
				dy = Y2 - Y1
			else
				sy = -1
				dy = Y1 - Y2
			end

			local err, e2 = dx-dy, nil

			local function PlotPixel()
				if X1 <= ResX and Y1 <= ResY and X1 > 0 and Y1 > 0 then
					if BlendingMode == 0 then -- Normal
						InternalCanvas:SetRGB(X1, Y1, ColR, ColG, ColB)
					elseif BlendingMode == 1 then -- Replace
						InternalCanvas:SetU32(X1, Y1, ColourU32)
					end
				end
			end

			-- Start point
			PlotPixel()

			while not(X1 == X2 and Y1 == Y2) do
				e2 = err + err
				if e2 > -dy then
					err -= dy
					X1 += sx
				end
				if e2 < dx then
					err += dx
					Y1 += sy
				end
				PlotPixel()
			end
		else -- Custom polygon based thick line
			RoundedCaps = RoundedCaps or type(RoundedCaps) == "nil" -- Ensures if the parameter is empty, its on be default

			local RawRot = math.atan2(X1 - X2, Y1 - Y2) -- Use distances between each axis
			local Theta = RawRot

			local PiHalf = math.pi / 2

			-- Ensure we get an angle that measures up to 360 degrees (also avoids negative numbers)
			if RawRot < 0 then
				Theta = math.pi * 2 + RawRot
			end

			local Diameter = 1 + (Thickness * 2)
			local Rounder = (math.pi * 1.5) / Diameter

			if RoundedCaps then
				Theta = math.round(Theta / Rounder) * Rounder -- Avoids strange behaviours for the triangle points for the end circles
			end

			-- Start polygon points
			local StartCornerX1 = math.round(X1 + math.sin(Theta + PiHalf) * Thickness)
			local StartCornerY1 = math.round(Y1 + math.cos(Theta + PiHalf) * Thickness)

			local StartCornerX2 = math.round(X1 + math.sin(Theta - PiHalf) * Thickness)
			local StartCornerY2 = math.round(Y1 + math.cos(Theta - PiHalf) * Thickness)

			-- End polygon points
			local EndCornerX1 = math.round(X2 + math.sin(Theta + PiHalf) * Thickness)
			local EndCornerY1 = math.round(Y2 + math.cos(Theta + PiHalf) * Thickness)

			local EndCornerX2 = math.round(X2 + math.sin(Theta - PiHalf) * Thickness)
			local EndCornerY2 = math.round(Y2 + math.cos(Theta - PiHalf) * Thickness)

			-- Draw 2 triangles at the start and end corners
			Canvas:DrawTriangleXY(StartCornerX1, StartCornerY1, StartCornerX2, StartCornerY2, EndCornerX1, EndCornerY1, Colour)
			Canvas:DrawTriangleXY(StartCornerX2, StartCornerY2, EndCornerX1, EndCornerY1, EndCornerX2, EndCornerY2, Colour)

			-- Draw rounded caps
			if RoundedCaps then
				Canvas:DrawCircleXY(X1, Y1, Thickness, Colour)
				Canvas:DrawCircleXY(X2, Y2, Thickness, Colour)
			end
		end

	end

	--[[
		Draws text to the canvas with bitmap font rendering.
		
		If the text string contains '\n' a new line of text will appear under the previous line
		
		All current fonts can be found under: <strong><code>CanvasDraw > Fonts</code></strong>
		
		<strong>FontName:</strong>
		<strong>- 3x6</strong>
		<strong>- Atari</strong>
		<strong>- Codepage</strong>
		<strong>- CodepageLarge</strong>
		<strong>- GrandCD</strong>
		<strong>- Monogram</strong>
		<strong>- Round</strong>
	]]
	function Canvas:DrawTextXY(Text: string, X: number, Y: number, Colour: Color3, FontName: string?, 
		Alignment: Enum.HorizontalAlignment?, Scale: number?, Wrap: boolean?, Spacing: number?)
		
		local ColR, ColG, ColB = Colour.R, Colour.G, Colour.B
		
		local ColourBuffer = buffer.create(4)
		buffer.writeu8(ColourBuffer, 0, ColR * 255)
		buffer.writeu8(ColourBuffer, 1, ColG * 255)
		buffer.writeu8(ColourBuffer, 2, ColB * 255)
		buffer.writeu8(ColourBuffer, 3, 255)

		local ColourU32 = buffer.readu32(ColourBuffer, 0)
		
		local FontModule = FontsFolder:FindFirstChild(FontName or "3x6")

		local BitBand, BitRshift = bit32.band, bit32.rshift

		if not FontModule then
			error("(!) '" .. FontName .. "' is not a valid CanvasDraw font!")
			return
		end
		
		-- Backwards compatability for pre 4.12 versions
		if type(Alignment) == "number" then
			Spacing = Wrap
			Wrap = Scale
			Scale = Alignment
			Alignment = nil
		end

		local FontInfo = require(FontModule)
		local FontBitmap = FontInfo.Bitmap
		
		local BlendingMode = self.AlphaBlendingMode

		Spacing = Spacing or 0
		Scale = Scale or 1
		X, Y = CeilN(X), CeilN(Y)
		
		local OrigX, OrigY = X, Y

		Scale = ClampN(RoundN(Scale), 1, 50)

		local OrigCharWidth = FontInfo.CharacterSize.X
		local CharWidth = OrigCharWidth * Scale
		local CharHeight = FontInfo.CharacterSize.Y * Scale

		local CanvasResX, CanvasResY = self.CurrentResX, self.CurrentResY

		local TextLines = string.split(Text, "\n")

		for i, TextLine in pairs(TextLines) do
			X, Y = OrigX, OrigY
			
			-- Extract individual characters from string
			local Characters = {}
			for _, c in utf8.codes(TextLine) do
				table.insert(Characters, utf8.char(c))
			end
			
			local TextLineWidth = (#Characters * (CharWidth + Spacing + FontInfo.Padding)) - Spacing  -- Formula here

			if Alignment == Enum.HorizontalAlignment.Center then
				X -= RoundN(TextLineWidth / 2)
			elseif Alignment == Enum.HorizontalAlignment.Right then
				X -= RoundN(TextLineWidth)
			end

			local OffsetX = 0
			local OffsetY = (i - 1) * (CharHeight + Spacing)

			for i, Character in pairs(Characters) do
				local TextCharacter

				if FontInfo.Lower then
					TextCharacter = FontBitmap[Character:lower()]
				else
					TextCharacter = FontBitmap[Character]
				end

				if TextCharacter then
					local StartOffsetX = -(math.min(1, X + OffsetX) - 1) + 1
					local StartOffsetY = -(math.min(1, Y + OffsetY) - 1) + 1

					if OffsetX + CharWidth - 1 > CanvasResX - X + 2 then
						if Wrap or type(Wrap) == "nil" then
							OffsetY += CharHeight + Spacing
							OffsetX = 0
						--else
						--	break -- Don't write anymore text since it's outside the canvas
						end
					end

					for SampleY = StartOffsetY, CharHeight do
						local PlacementY = Y + SampleY - 1 + OffsetY

						if PlacementY > CanvasResY then
							break
						end

						SampleY = CeilN(SampleY / Scale)

						local Row = TextCharacter[SampleY]

						for SampleX = StartOffsetX, CharWidth do
							local PlacementX = X + SampleX - 1 + OffsetX

							if PlacementX > CanvasResX or PlacementX < 1 then
								continue
							end

							SampleX = CeilN(SampleX / Scale)

							if BitBand(BitRshift(Row, OrigCharWidth - SampleX), 1) == 1 then
								if BlendingMode == 0 then -- Normal
									InternalCanvas:SetRGB(PlacementX, PlacementY, ColR, ColG, ColB)
								elseif BlendingMode == 1 then -- Replace
									InternalCanvas:SetU32(PlacementX, PlacementY, ColourU32)
								end
							end
						end
					end
				end

				OffsetX += CharWidth + Spacing + FontInfo.Padding
			end
		end
	end

		--[[
		Draws text to the canvas with bitmap font rendering.
		
		If the text string contains '\n' a new line of text will appear under the previous line
		
		All current fonts can be found under: <strong><code>CanvasDraw > Fonts</code></strong>
		
		<strong>FontName:</strong>
		<strong>- 3x6</strong>
		<strong>- Atari</strong>
		<strong>- Codepage</strong>
		<strong>- CodepageLarge</strong>
		<strong>- GrandCD</strong>
		<strong>- Monogram</strong>
		<strong>- Round</strong>
	]]
	function Canvas:DrawText(Text: string, Point: Vector2, Colour: Color3, FontName: string?, 
		Alignment: Enum.HorizontalAlignment?, Scale: number?, Wrap: boolean?, Spacing: number?)
		Canvas:DrawTextXY(Text, Point.X, Point.Y, Colour, FontName, Alignment, Scale, Wrap, Spacing)
	end

	--== DEPRECATED METHODS ==--

	-- <strong>DEPRECATED</strong>. Do not use for new work!
	function Canvas:GetPixels(PointA: Vector2?, PointB: Vector2?): {Color3}
		local PixelsArray = {}

		-- Get the all pixels between PointA and PointB
		if PointA and PointB then
			local DistX, FlipMultiplierX = GetRange(PointA.X, PointB.X)
			local DistY, FlipMultiplierY = GetRange(PointA.Y, PointB.Y)

			for Y = 0, DistY do
				for X = 0, DistX do
					local Point = Vector2New(PointA.X + X * FlipMultiplierX, PointA.Y + Y * FlipMultiplierY)
					local Pixel = self:GetPixel(Point)
					if Pixel then
						TableInsert(PixelsArray, Pixel)
					end
				end
			end
		else
			-- If there isn't any points in the paramaters, then return all pixels in the canvas
			for Y = 1, self.CurrentResY do
				for X = 1, self.CurrentResX do
					local Pixel = self:GetPixelXY(X, Y)
					if Pixel then
						TableInsert(PixelsArray, Pixel)
					end
				end
			end
		end

		return PixelsArray
	end
	
	-- <strong>DEPRECATED</strong>. Do not use for new work!
	function Canvas:ClearPixels(PixelPoints: {Vector2})
		self:FillPixels(PixelPoints, self.CanvasColour)
	end

	-- <strong>DEPRECATED</strong>. Do not use for new work!
	function Canvas:FillPixels(Points: {Vector2}, Colour: Color3)
		for i, Point in pairs(Points) do
			InternalCanvas:SetColor3(Point.X, Point.Y, Colour)	
		end
	end
	
	-- <strong>DEPRECATED</strong>. Use <code>Canvas:SetRGB()</code> or <code>Canvas:SetPixel()</code> for new work!
	function Canvas:DrawPixel(Point: Vector2, Colour: Color3): Vector2
		local X = CeilN(Point.X)
		local Y = CeilN(Point.Y)

		if X > 0 and Y > 0 and X <= self.CurrentResX and Y <= self.CurrentResY then	
			InternalCanvas:SetColor3(X, Y, Colour)
			return Point	
		end
	end

	return Canvas
end


--============================================================================================================--
--====  <<   CanvasDraw Module ImageData API   >>   ===========================================================--
--============================================================================================================--

--[[
	Reads and decompresses a CanvasDraw SaveObject instance and returns an ImageData object.
	
	Set the <strong>SlowLoad</strong> parameter to true to yield your code to avoid lag spikes when reading large SaveObjects
]]
function CanvasDraw.GetImageData(SaveObject: Instance, SlowLoad: boolean?)
	local PixelArray
	local Width, Height

	-- Backwards compatability
	if SaveObject:GetAttribute("Resolution") and SaveObject:FindFirstChild("Chunk1") then
		-- Modern SaveObject (v3)
		PixelArray, Width, Height = SaveObjectReader.Read(SaveObject, SlowLoad)
	elseif SaveObject:GetAttribute("Colour") then
		-- Legacy SaveObject (v2)
		PixelArray, Width, Height = SaveObjectReader.ReadV2(SaveObject)
	elseif SaveObject:GetAttribute("ImageColours") then
		-- Legacy SaveObject (v1)
		PixelArray, Width, Height = SaveObjectReader.ReadV1(SaveObject)
	else
		error("CanvasDraw Module Error | " .. SaveObject.Name .. " is not a valid SaveObject!")
	end

	-- Convert the SaveObject into image data

	return ImageDataConstructor.new(Width, Height, PixelArray)
end

--[[
	Returns an ImageData object from a roblox image asset from an image/texture ID.
	
	This method may return nil if it fails to fetch the asset.
	
	This method will yield your code.
	
	<strong>NOTE:</strong> Currently, only texture assets owned by the creator of the place can be used.
]]
function CanvasDraw.GetImageDataFromTextureId(TextureId: string, MaxWidth: number?, MaxHeight: number?)
	local EditableImage

	local Success, ErrorMessage = pcall(function()
		EditableImage = AssetService:CreateEditableImageAsync(Content.fromUri(TextureId))
	end)

	if Success and EditableImage then
		-- Convert the EditableImage into image data
		local PixelBuffer = EditableImage:ReadPixelsBuffer(Vector2.new(0, 0), EditableImage.Size)
		local OriginalWidth, OriginalHeight = EditableImage.Size.X, EditableImage.Size.Y

		local ReferenceImage = ImageDataConstructor.new(OriginalWidth, OriginalHeight, PixelBuffer)
		local NewImageData

		EditableImage:Destroy()

		-- Rescale the image if the size is greater than the limit
		if MaxWidth and MaxHeight then
			local Scale

			-- Get scale depending on the largest axis
			if OriginalWidth > MaxWidth or OriginalHeight > MaxHeight then
				Scale = MaxWidth / OriginalWidth

				if math.floor(OriginalHeight * Scale) > MaxHeight then
					Scale = MaxHeight / OriginalHeight
				end
			end

			-- Image is larger than our limits. Rescale it
			if Scale then
				NewImageData = CanvasDraw.CreateBlankImageData(math.floor(OriginalWidth * Scale), math.floor(OriginalHeight * Scale))

				for X = 1, NewImageData.Width do
					local SampleX = math.floor((X / NewImageData.Width) * OriginalWidth)

					for Y = 1, NewImageData.Height do
						local SampleY = math.floor((Y / NewImageData.Height) * OriginalHeight)

						local R, G, B = ReferenceImage:GetRGB(SampleX, SampleY)
						local A = ReferenceImage:GetAlpha(SampleX, SampleY)

						NewImageData:SetRGB(X, Y, R, G, B)
						NewImageData:SetAlpha(X, Y, A)
					end
				end
			else
				NewImageData = ReferenceImage
			end
		else
			NewImageData = ReferenceImage
		end

		return NewImageData
	else
		warn("CanvasDraw.GetImageDataFromTextureId: ", ErrorMessage)
		return nil
	end
end

-- Creates and returns a blank ImageData object
function CanvasDraw.CreateBlankImageData(Width: number, Height: number)
	local PixelBuffer = buffer.create(Width * Height * 4)
	buffer.fill(PixelBuffer, 0, 255, Width * Height * 4)

	return ImageDataConstructor.new(Width, Height, PixelBuffer)
end

--[[
	Compresses an ImageData object and creates a CanvasDraw SaveObject instance, which can be stored in your place.
	
	<em>Intended for plugin use</em>
]]
function CanvasDraw.CreateSaveObject(ImageData): Folder
	local Chunks = {{}}

	local Width = ImageData.Width

	local RGBAIndex = 1

	-- Get all colours from image
	for Y = 1, ImageData.Height do
		for X = 1, Width do
			local Index = X + (Y - 1) * Width

			local R, G, B, A = ImageData:GetRGBA(X, Y)

			local R = math.floor(R * 255)
			local G = math.floor(G * 255)
			local B = math.floor(B * 255)
			local A = math.floor(A * 255)

			-- Chunking
			local Array = Chunks[#Chunks]

			if #Array >= ChunkLimit then -- Ensures the string will be under 200KB
				table.insert(Chunks, {})
				Array = Chunks[#Chunks]
				RGBAIndex = 1
			end

			Array[RGBAIndex] = R
			Array[RGBAIndex + 1] = G
			Array[RGBAIndex + 2] = B
			Array[RGBAIndex + 3] = A

			RGBAIndex += 4
		end
	end

	-- Create the save object
	local NewSaveObject = Instance.new("Folder")
	NewSaveObject.Name = "NewSave"

	-- Compress the pixel data
	local CompressedChunks = {}

	for i, RGBAArray in pairs(Chunks) do
		local Compressed = StringCompressor.Compress(HttpService:JSONEncode(RGBAArray))

		local ChunkString = Instance.new("StringValue", NewSaveObject)
		ChunkString.Value = Compressed
		ChunkString.Name = "Chunk" .. i
	end

	NewSaveObject:SetAttribute("Resolution", Vector2.new(ImageData.Width, ImageData.Height))

	return NewSaveObject
end

--[[
	Takes an array of RGBA number values and creates a CanvasDraw SaveObject instance, which can be stored in your place.
	
	The size of this array is assumed to be equal to <strong>Width × Height × 4</strong>
	
	<em>Intended for plugin use</em>
]]
function CanvasDraw.CreateSaveObjectFromPixels(PixelArray: {number}, Width: number, Height: number): Folder
	local Chunks = {{}}

	local RGBAIndex = 1

	-- Get all colours from image
	for Y = 1, Height do
		for X = 1, Width do
			local Index = (X + (Y - 1) * Width) * 4 - 3

			local R = math.floor(PixelArray[Index] * 255)
			local G = math.floor(PixelArray[Index + 1] * 255)
			local B = math.floor(PixelArray[Index + 2] * 255)
			local A = math.floor(PixelArray[Index + 3] * 255)

			-- Chunking
			local Array = Chunks[#Chunks]

			if #Array >= ChunkLimit then -- Ensures the string will be under 200KB
				table.insert(Chunks, {})
				Array = Chunks[#Chunks]
				RGBAIndex = 1
			end

			Array[RGBAIndex] = R
			Array[RGBAIndex + 1] = G
			Array[RGBAIndex + 2] = B
			Array[RGBAIndex + 3] = A

			RGBAIndex += 4
		end
	end

	-- Create the save object
	local NewSaveObject = Instance.new("Folder")
	NewSaveObject.Name = "NewSave"

	-- Compress the pixel data
	local CompressedChunks = {}

	for i, RGBAArray in pairs(Chunks) do
		local Compressed = StringCompressor.Compress(HttpService:JSONEncode(RGBAArray))

		local ChunkString = Instance.new("StringValue", NewSaveObject)
		ChunkString.Value = Compressed
		ChunkString.Name = "Chunk" .. i
	end

	NewSaveObject:SetAttribute("Resolution", Vector2.new(Width, Height))

	return NewSaveObject
end


-- Compresses and converts an ImageData object into a smaller datastore compatible object
function CanvasDraw.CompressImageData(ImageData)
	local PixelBuffer = ImageData.ImageBuffer
	local Width, Height = ImageData.Width, ImageData.Height

	-- Compress the pixel data
	local CompressedPixels = HttpService:JSONEncode(PixelBuffer)

	-- Create the data object
	local CompressedData = {}
	CompressedData.Pixels = CompressedPixels
	CompressedData.Width = Width
	CompressedData.Height = Height

	return CompressedData
end

-- Creates and returns an ImageData object from CompressedImageData
function CanvasDraw.DecompressImageData(CompressedImageData)
	local PixelArray = HttpService:JSONDecode(CompressedImageData.Pixels)
	local Width, Height = CompressedImageData.Width, CompressedImageData.Height

	return ImageDataConstructor.new(Width, Height, PixelArray)
end

--== DEPRECATED FUNCTIONS/METHODS/EVENTS ==--

-- <strong>DEPRECATED</strong>. Use ImageData:GetPixel() instead
function CanvasDraw.GetPixelFromImage(ImageData, Point: Vector2): (Color3, number)
	local PixelIndex = PointToPixelIndex(Point, ImageData.ImageResolution) -- Convert the point into an index for the array of colours

	local PixelColour = ImageData.ImageColours[PixelIndex]
	local PixelAlpha = ImageData.ImageAlphas[PixelIndex]

	return PixelColour, PixelAlpha
end

-- <strong>DEPRECATED</strong>. Use ImageData:GetPixelXY() instead
function CanvasDraw.GetPixelFromImageXY(ImageData, X: number, Y: number): (Color3, number)
	local PixelIndex = XYToPixelIndex(X, Y, ImageData.ImageResolution.X) -- Convert the coordinates into an index for the array of colours

	local PixelColour = ImageData.ImageColours[PixelIndex]
	local PixelAlpha = ImageData.ImageAlphas[PixelIndex]

	return PixelColour, PixelAlpha
end

-- <strong>DEPRECATED</strong>. use RunSerivce.Heartbeat instead
CanvasDraw.Updated = RunService.Heartbeat


return CanvasDraw