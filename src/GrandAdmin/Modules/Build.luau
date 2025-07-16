local Build = {
	Sign = function(PlacementCFrame, Text)
		local Model = Instance.new("Model")
		Model.Name = "Sign"
		
		local SignHead = Instance.new("Part", Model)
		SignHead.Anchored = true
		SignHead.Color = Color3.fromRGB(165, 160, 143)
		SignHead.Material = Enum.Material.Wood
		SignHead.Size = Vector3.new(4, 2.2, 0.3)
		SignHead.Parent = Model
		
		local SignPost = SignHead:Clone()
		SignPost.Size = Vector3.new(0.6, 5.6, 0.3)
		SignPost.Color = Color3.fromRGB(136, 132, 118)
		SignPost.Parent = Model
		
		local SurfaceGui = Instance.new("SurfaceGui")
		SurfaceGui.Face = Enum.NormalId.Back
		SurfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		SurfaceGui.PixelsPerStud = 50
		SurfaceGui.Adornee = SignHead
		SurfaceGui.Parent = SignHead
		
		local TextLabel = Instance.new("TextLabel")
		TextLabel.Name = "SignText"
		TextLabel.Size = UDim2.fromScale(1, 1)
		TextLabel.BackgroundTransparency = 1
		TextLabel.Font = Enum.Font.PatrickHand
		TextLabel.TextColor3 = Color3.new(0, 0, 0)
		TextLabel.TextScaled = true
		TextLabel.TextWrapped = true
		
		SignHead.CFrame = PlacementCFrame * CFrame.new(0, 0.5, 0)
		SignPost.CFrame = PlacementCFrame * CFrame.new(0, -1, -0.3)
		
		TextLabel.Text = Text
		TextLabel.Parent = SurfaceGui
		
		return Model
	end,
}

return Build
