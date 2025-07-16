--[[
	@Author: Spynaz
	@Description: Enables dragging on GuiObjects. Supports both mouse and touch.
	
	For instructions on how to use this module, go to this link:
	https://devforum.roblox.com/t/simple-module-for-creating-draggable-gui-elements/230678
--]]

local Camera = workspace.CurrentCamera

local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local currentlyDragging = false

local TopBarSize = GuiService:GetGuiInset()
local ViewportBoundDistance = 15

local DraggableObject 		= {}
DraggableObject.__index 	= DraggableObject

-- Sets up a new draggable object
function DraggableObject.new(Object)
	local self 			= {}
	self.Object			= Object
	self.DragStarted	= nil
	self.DragEnded		= nil
	self.Dragged		= nil
	self.Dragging		= false

	setmetatable(self, DraggableObject)

	return self
end

-- Enables dragging
function DraggableObject:Enable()
	local object			= self.Object
	local dragInput			= nil
	local dragStart			= nil
	local startPos			= nil
	local preparingToDrag	= false
	
	local function IsOnTop()
		local MouseLocation = UserInputService:GetMouseLocation()
		MouseLocation -= TopBarSize

		local BasePlrGui: BasePlayerGui = object:FindFirstAncestorWhichIsA("BasePlayerGui")

		if not BasePlrGui then return false end

		local Objects = BasePlrGui:GetGuiObjectsAtPosition(MouseLocation.X, MouseLocation.Y)

		return Objects[#Objects] == object
	end

	-- Updates the element
	local function update(input)
		local delta = UserInputService:GetMouseLocation() - dragStart
		local Bound = 25
		
		local newPosition = UDim2.fromOffset(
			math.clamp(startPos.X + delta.X, Bound - object.AbsoluteSize.X, Camera.ViewportSize.X - Bound), 
			math.clamp(startPos.Y + delta.Y, Bound - object.AbsoluteSize.Y - TopBarSize.Y, Camera.ViewportSize.Y - Bound - TopBarSize.Y)
		)
		
		object.Position = newPosition

		return newPosition
	end

	self.InputBegan = object.InputBegan:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch and not currentlyDragging) and IsOnTop() then
			currentlyDragging = true
			preparingToDrag = true

			local connection 
			connection = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End and (self.Dragging or preparingToDrag) then
					self.Dragging = false
					connection:Disconnect()

					if self.DragEnded and not preparingToDrag then
						self.DragEnded()
					end

					currentlyDragging = false
					preparingToDrag = false
				end
			end)
		end
	end)

	self.InputChanged = object.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	self.InputChanged2 = UserInputService.InputChanged:Connect(function(input)
		if object.Parent == nil then
			self:Disable()
			return
		end

		if preparingToDrag then
			preparingToDrag = false

			if self.DragStarted then
				self.DragStarted()
			end

			self.Dragging	= true
			dragStart 		= UserInputService:GetMouseLocation()
			startPos 		= object.AbsolutePosition
		end

		if input == dragInput and self.Dragging then
			local newPosition = update(input)

			if self.Dragged then
				self.Dragged(newPosition)
			end
		end
	end)
end

-- Disables dragging
function DraggableObject:Disable()
	self.InputBegan:Disconnect()
	self.InputChanged:Disconnect()
	self.InputChanged2:Disconnect()

	if self.Dragging then
		self.Dragging = false

		if self.DragEnded then
			self.DragEnded()
		end
	end
end

return DraggableObject