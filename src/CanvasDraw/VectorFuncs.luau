local Abs = math.abs

function getNormalFromPartFace(part, normalId)
	return part.CFrame:VectorToWorldSpace(Vector3.FromNormalId(normalId))
end

function normalVectorToFace(part, normalVector)
	local normalIDs = {
		Enum.NormalId.Front,
		Enum.NormalId.Back,
		Enum.NormalId.Bottom,
		Enum.NormalId.Top,
		Enum.NormalId.Left,
		Enum.NormalId.Right
	}  

	for _, normalId in ipairs(normalIDs) do
		if getNormalFromPartFace(part, normalId):Dot(normalVector) > 0.999 then
			return normalId
		end
	end

	return nil -- None found within tolerance.
end

function getTopLeftCorners(part)
	local size = part.Size
	return {
		[Enum.NormalId.Front] = part.CFrame * CFrame.new(size.X/2, size.Y/2, -size.Z/2),
		[Enum.NormalId.Back] = part.CFrame * CFrame.new(-size.X/2, size.Y/2, size.Z/2),
		[Enum.NormalId.Right] = part.CFrame * CFrame.new(size.X/2, size.Y/2, size.Z/2),
		[Enum.NormalId.Left] = part.CFrame * CFrame.new(-size.X/2, size.Y/2, -size.Z/2),
		[Enum.NormalId.Bottom] = part.CFrame * CFrame.new(size.X/2, -size.Y/2, size.Z/2),
		[Enum.NormalId.Top] = part.CFrame * CFrame.new(-size.X/2, size.Y/2, size.Z/2)
	}
end

function getRotationComponents(offset) 
	local components = {offset:GetComponents()}
	table.remove(components, 1)
	table.remove(components, 2)
	table.remove(components, 3)
	
	return components
end

return {
	["normalVectorToFace"] = normalVectorToFace,
	["getTopLeftCorners"] = getTopLeftCorners
}