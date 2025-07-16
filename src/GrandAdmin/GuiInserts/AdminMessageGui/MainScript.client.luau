local TweenService = game:GetService("TweenService")

local Gui = script.Parent
local MainFrame = Gui:WaitForChild("MainFrame")

local DisplayTime = Gui:WaitForChild("DisplayTime")

local Tweeninfo = TweenInfo.new(0.5)

local AppearTweenBackground = TweenService:Create(MainFrame.Messsage, Tweeninfo, {BackgroundTransparency = 0.5})
local AppearTweenTitle = TweenService:Create(MainFrame.Title, Tweeninfo, {BackgroundTransparency = 0.5, TextTransparency = 0, TextStrokeTransparency = 0})
local AppearTweenText = TweenService:Create(MainFrame.Messsage.MainLabel, Tweeninfo, {TextTransparency = 0, TextStrokeTransparency = 0})

local DisappearTweenBackground = TweenService:Create(MainFrame.Messsage, Tweeninfo, {BackgroundTransparency = 1})
local DisappearTweenTitle = TweenService:Create(MainFrame.Title, Tweeninfo, {Transparency = 1})
local DisappearTweenText = TweenService:Create(MainFrame.Messsage.MainLabel, Tweeninfo, {TextTransparency = 1, TextStrokeTransparency = 1})

-- Main

MainFrame.Messsage.BackgroundTransparency = 1
MainFrame.Title.BackgroundTransparency = 1
MainFrame.Title.TextTransparency = 1
MainFrame.Title.TextStrokeTransparency = 1
MainFrame.Messsage.MainLabel.TextTransparency = 1
MainFrame.Messsage.MainLabel.TextStrokeTransparency = 1

Gui.Enabled = true

AppearTweenBackground:Play()
AppearTweenTitle:Play()
AppearTweenText:Play()

task.wait(DisplayTime.Value)

DisappearTweenBackground:Play()
DisappearTweenTitle:Play()
DisappearTweenText:Play()

DisappearTweenBackground.Completed:Wait()

Gui:Destroy()