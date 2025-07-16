local Camera			= workspace.CurrentCamera

local BLUR_SIZE         = Vector2.new(10, 10)
local PART_SIZE         = 0.01
local PART_TRANSPARENCY = 1 - 1e-7
local START_INTENSITY	= 0.8

local Parent = script.Parent

local Gui = script.Parent:FindFirstAncestorWhichIsA("ScreenGui")

Parent:SetAttribute("BlurIntensity", START_INTENSITY)

local BLUR_OBJ = Camera:FindFirstChild("_AdminUIBlur") or Instance.new("DepthOfFieldEffect")
BLUR_OBJ.Name           = "_AdminUIBlur"
BLUR_OBJ.FarIntensity   = 0
BLUR_OBJ.NearIntensity  = Parent:GetAttribute("BlurIntensity")
BLUR_OBJ.FocusDistance  = 0.25
BLUR_OBJ.InFocusRadius  = 0
BLUR_OBJ.Enabled        = true
BLUR_OBJ.Parent         = Camera

local PartsList         = {}
local BlursList         = {}
local BlurObjects       = {}
local BlurredGui        = {}

BlurredGui.__index      = BlurredGui

function rayPlaneIntersect(planePos, planeNormal, rayOrigin, rayDirection)
	local n = planeNormal
	local d = rayDirection
	local v = rayOrigin - planePos

	local num = n.x*v.x + n.y*v.y + n.z*v.z
	local den = n.x*d.x + n.y*d.y + n.z*d.z
	local a = -num / den

	return rayOrigin + a * rayDirection, a
end

function rebuildPartsList()
	PartsList = {}
	BlursList = {}
	for blurObj, part in pairs(BlurObjects) do
		table.insert(PartsList, part)
		table.insert(BlursList, blurObj)
	end
end

function BlurredGui.new(frame, shape)
	local blurPart        = Instance.new("Part")
	blurPart.Name         = "_UIBlurPart"
	blurPart.Size         = Vector3.new(1, 1, 1) * 0.01
	blurPart.Anchored     = true
	blurPart.CanCollide   = false
	blurPart.CanQuery     = false
	blurPart.CastShadow   = false
	blurPart.CanTouch     = false
	blurPart.Material     = Enum.Material.Glass
	blurPart.Transparency = PART_TRANSPARENCY
	blurPart.Parent       = workspace.CurrentCamera

	local mesh
	if (shape == "Rectangle") then
		mesh        = Instance.new("BlockMesh")
		mesh.Parent = blurPart
	elseif (shape == "Oval") then
		mesh          = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.Sphere
		mesh.Parent   = blurPart
	end
	
	local ignoreInset = false
	local currentObj  = frame
	
	while true do
		currentObj = currentObj.Parent

		if (currentObj and currentObj:IsA("ScreenGui")) then
			ignoreInset = currentObj.IgnoreGuiInset
			break
		elseif (currentObj == nil) then
			break
		end
	end

	local new = setmetatable({
		Frame          = frame;
		Part           = blurPart;
		Mesh           = mesh;
		IgnoreGuiInset = ignoreInset;
	}, BlurredGui)

	BlurObjects[new] = blurPart
	rebuildPartsList()

	game:GetService("RunService"):BindToRenderStep("...", Enum.RenderPriority.Camera.Value + 1, function()
		blurPart.CFrame = Camera.CFrame * CFrame.new(0,0,0)
		BlurredGui.updateAll()
	end)
	return new
end

function updateGui(blurObj)
	if (not blurObj.Frame.Visible or not Gui.Enabled) then
		blurObj.Part.Transparency = 1
		return
	end
	
	BLUR_OBJ.Enabled = true
	
	local frame  = blurObj.Frame
	local part   = blurObj.Part
	local mesh   = blurObj.Mesh
	
	part.Transparency = PART_TRANSPARENCY
	
	local corner0 = frame.AbsolutePosition + BLUR_SIZE
	local corner1 = corner0 + frame.AbsoluteSize - BLUR_SIZE*2
	local ray0, ray1

	if (blurObj.IgnoreGuiInset) then
		ray0 = Camera:ViewportPointToRay(corner0.X, corner0.Y, 1)
		ray1 = Camera:ViewportPointToRay(corner1.X, corner1.Y, 1)
	else
		ray0 = Camera:ScreenPointToRay(corner0.X, corner0.Y, 1)
		ray1 = Camera:ScreenPointToRay(corner1.X, corner1.Y, 1)
	end

	local planeOrigin = Camera.CFrame.Position + Camera.CFrame.LookVector * (0.05 - Camera.NearPlaneZ)
	local planeNormal = Camera.CFrame.LookVector
	local pos0 = rayPlaneIntersect(planeOrigin, planeNormal, ray0.Origin, ray0.Direction)
	local pos1 = rayPlaneIntersect(planeOrigin, planeNormal, ray1.Origin, ray1.Direction)

	local pos0 = Camera.CFrame:PointToObjectSpace(pos0)
	local pos1 = Camera.CFrame:PointToObjectSpace(pos1)

	local size   = pos1 - pos0
	local center = (pos0 + pos1)/2

	mesh.Offset = center
	mesh.Scale  = size / PART_SIZE
end

function BlurredGui.updateAll()
	--BLUR_OBJ.NearIntensity = tonumber(Parent:GetAttribute("BlurIntensity"))
	
	for i = 1, #BlursList do
		updateGui(BlursList[i])
	end

	local cframes = table.create(#BlursList, workspace.CurrentCamera.CFrame)
	workspace:BulkMoveTo(PartsList, cframes, Enum.BulkMoveMode.FireCFrameChanged)

	--BLUR_OBJ.FocusDistance = 0.25 - Camera.NearPlaneZ
end

function BlurredGui:Destroy()
	self.Part:Destroy()
	BlurObjects[self] = nil
	rebuildPartsList()
end

BlurredGui.new(Parent, "Rectangle")

BlurredGui.updateAll()
return BlurredGui