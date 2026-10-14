-- SCRAPWORKS DEMO v1 HUD | Runs only after server clones into PlayerGui
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
if not player then return end
local playerGui = player:WaitForChild("PlayerGui")

local function panel(parent, name, size, position, anchor, color, radius)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.AnchorPoint = anchor
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = color
    frame.BackgroundTransparency = .06
    frame.BorderSizePixel = 0
    frame.Parent = parent
    local corner=Instance.new("UICorner")
    corner.CornerRadius=UDim.new(0,radius)
    corner.Parent=frame
    local stroke=Instance.new("UIStroke")
    stroke.Color=Color3.fromRGB(65,124,138)
    stroke.Thickness=1.4
    stroke.Transparency=.30
    stroke.Parent=frame
    return frame
end
local function label(parent, name, text, size, pos, color, font, fontsize)
    local t=Instance.new("TextLabel")
    t.Name=name
    t.Text=text
    t.Size=size
    t.Position=pos
    t.BackgroundTransparency=1
    t.Font=font or Enum.Font.GothamBold
    t.TextColor3=color
    t.TextSize=fontsize or 18
    t.TextXAlignment=Enum.TextXAlignment.Left
    t.TextYAlignment=Enum.TextYAlignment.Center
    t.Parent=parent
    return t
end

local gui=Instance.new("ScreenGui")
gui.Name="ScrapworksHUDScreen"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=false
gui.DisplayOrder=10
gui.Parent=script.Parent

local header=panel(gui,"TopBrand",UDim2.new(0,335,0,54),UDim2.new(.5,0,0,22),Vector2.new(.5,0),Color3.fromRGB(16,31,42),12)
local h=label(header,"Title","SCRAPWORKS  /  FIELD TEST",UDim2.new(1,-34,1,0),UDim2.fromOffset(17,0),Color3.fromRGB(91,241,226),Enum.Font.GothamBlack,19)
h.TextXAlignment=Enum.TextXAlignment.Center

local stats=panel(gui,"InventoryPanel",UDim2.new(0,290,0,116),UDim2.new(0,20,1,-22),Vector2.new(0,1),Color3.fromRGB(17,27,39),14)
label(stats,"Sub","INVENTORY / DEMO v1",UDim2.new(1,-28,0,27),UDim2.fromOffset(16,10),Color3.fromRGB(129,178,193),Enum.Font.GothamBold,12)
local carried=label(stats,"Carry","SCRAP    0 / 5",UDim2.new(1,-30,0,30),UDim2.fromOffset(16,39),Color3.fromRGB(238,247,249),Enum.Font.GothamBold,22)
local cashText=label(stats,"Cash","CASH    $0",UDim2.new(1,-30,0,26),UDim2.fromOffset(16,74),Color3.fromRGB(255,210,113),Enum.Font.GothamBold,21)

local tip=panel(gui,"InfoToast",UDim2.new(0,430,0,52),UDim2.new(.5,0,1,-25),Vector2.new(.5,1),Color3.fromRGB(18,42,52),12)
local tipText=label(tip,"Message","COLLECT SCRAP  →  SELL AT THE REFINERY",UDim2.new(1,-22,1,-10),UDim2.fromOffset(11,5),Color3.fromRGB(240,253,247),Enum.Font.GothamBold,14)
tipText.TextWrapped=true
tipText.TextXAlignment=Enum.TextXAlignment.Center

local function refresh()
    carried.Text="SCRAP    " .. tostring(player:GetAttribute("SW_Carry") or 0) .. " / 5"
    local leaderstats=player:FindFirstChild("leaderstats")
    local cash=leaderstats and leaderstats:FindFirstChild("Cash")
    cashText.Text="CASH    $" .. tostring(cash and cash.Value or 0)
end
player:GetAttributeChangedSignal("SW_Carry"):Connect(refresh)
local function cashHook(child)
    if child.Name == "Cash" and child:IsA("IntValue") then
        child:GetPropertyChangedSignal("Value"):Connect(refresh)
        refresh()
    end
end
local function statsHook(statsFolder)
    for _, child in ipairs(statsFolder:GetChildren()) do cashHook(child) end
    statsFolder.ChildAdded:Connect(cashHook)
end
local currentStats=player:FindFirstChild("leaderstats")
if currentStats then statsHook(currentStats) end
player.ChildAdded:Connect(function(child)
    if child.Name == "leaderstats" then statsHook(child) end
end)

local toastId=0
local function notice()
    toastId+=1
    local mine=toastId
    local text=player:GetAttribute("SW_Notice") or "Collect scrap and sell it!"
    tipText.Text=text
    tip.BackgroundTransparency=.04
    tipText.TextTransparency=0
    task.delay(3.5,function()
        if mine~=toastId then return end
        TweenService:Create(tip,TweenInfo.new(.4),{BackgroundTransparency=.35}):Play()
        TweenService:Create(tipText,TweenInfo.new(.4),{TextTransparency=.2}):Play()
    end)
end
player:GetAttributeChangedSignal("SW_NoticeVersion"):Connect(notice)
refresh()
notice()
