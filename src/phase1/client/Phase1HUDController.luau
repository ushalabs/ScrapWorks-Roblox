-- SCRAPWORKS PHASE 1 | modern material inventory HUD (client only)
local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local player=Players.LocalPlayer
local gui=script.Parent
if not player then return end
local NAVY=Color3.fromRGB(14,31,43)
local PANEL=Color3.fromRGB(21,41,54)
local CYAN=Color3.fromRGB(78,239,222)
local CREAM=Color3.fromRGB(239,247,248)
local MUTE=Color3.fromRGB(146,184,196)
local GOLD=Color3.fromRGB(255,207,112)
local materialNames={"Steel","Aluminum","Copper","Battery","Circuit","Alloy"}
local materialColors={Steel=Color3.fromRGB(190,205,216),Aluminum=Color3.fromRGB(230,237,240),Copper=Color3.fromRGB(238,150,96),Battery=Color3.fromRGB(181,144,243),Circuit=Color3.fromRGB(132,236,160),Alloy=Color3.fromRGB(255,216,109)}
local function frame(parent,name,w,h,xs,xo,ys,yo,anchor,color)
    local f=Instance.new("Frame")
    f.Name=name
    f.Size=UDim2.fromOffset(w,h)
    f.Position=UDim2.new(xs,xo,ys,yo)
    f.AnchorPoint=anchor
    f.BackgroundColor3=color or PANEL
    f.BackgroundTransparency=.035
    f.BorderSizePixel=0
    f.Parent=parent
    local c=Instance.new("UICorner")
    c.CornerRadius=UDim.new(0,12)
    c.Parent=f
    local s=Instance.new("UIStroke")
    s.Thickness=1.2
    s.Color=Color3.fromRGB(65,116,134)
    s.Transparency=.32
    s.Parent=f
    return f
end
local function label(parent,name,text,w,h,x,y,color,size,bold)
    local t=Instance.new("TextLabel")
    t.Name=name
    t.Text=text
    t.Size=UDim2.fromOffset(w,h)
    t.Position=UDim2.fromOffset(x,y)
    t.BackgroundTransparency=1
    t.TextColor3=color or CREAM
    t.TextSize=size or 15
    t.Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham
    t.TextXAlignment=Enum.TextXAlignment.Left
    t.TextYAlignment=Enum.TextYAlignment.Center
    t.Parent=parent
    return t
end
local banner=frame(gui,"Brand",296,47,0.5,0,0,20,Vector2.new(.5,0),NAVY)
local brandText=label(banner,"BrandText","SCRAPWORKS  /  PHASE 01",270,47,13,0,CYAN,18,true)
brandText.TextXAlignment=Enum.TextXAlignment.Center
local stats=frame(gui,"MaterialInventory",360,224,0,20,1,-20,Vector2.new(0,1),NAVY)
label(stats,"PanelTitle","MATERIAL INVENTORY",330,24,15,9,CYAN,13,true)
local qtyText=label(stats,"QtyText","0 / 12",100,26,265,9,CREAM,18,true)
qtyText.TextXAlignment=Enum.TextXAlignment.Right
local cashText=label(stats,"CashText","CASH   $0",260,31,15,37,GOLD,22,true)
local invGrid=Instance.new("Frame")
invGrid.Name="MaterialGrid"
invGrid.BackgroundTransparency=1
invGrid.Size=UDim2.new(1,-30,0,116)
invGrid.Position=UDim2.fromOffset(15,78)
invGrid.Parent=stats
local layout=Instance.new("UIGridLayout")
layout.CellSize=UDim2.new(.5,-5,0,34)
layout.CellPadding=UDim2.fromOffset(9,5)
layout.SortOrder=Enum.SortOrder.LayoutOrder
layout.Parent=invGrid
local rowLabels={}
for i,kind in ipairs(materialNames) do
    local pill=Instance.new("Frame")
    pill.LayoutOrder=i
    pill.BackgroundColor3=Color3.fromRGB(35,56,68)
    pill.BorderSizePixel=0
    pill.Parent=invGrid
    local c=Instance.new("UICorner")
    c.CornerRadius=UDim.new(0,7)
    c.Parent=pill
    local p=label(pill,"Name",string.upper(kind),116,32,9,0,materialColors[kind],11,true)
    local q=label(pill,"Quantity","0",29,32,125,0,CREAM,16,true)
    q.TextXAlignment=Enum.TextXAlignment.Right
    rowLabels[kind]=q
end
local footer=label(stats,"Footnote","6 materials  •  15+ salvage spots",329,22,15,194,MUTE,12,false)
local toast=frame(gui,"Toast",470,49,.5,0,1,-20,Vector2.new(.5,1),PANEL)
local toastText=label(toast,"ToastLabel","Collect scrap and process it at the refinery.",448,45,11,2,CREAM,14,true)
toastText.TextXAlignment=Enum.TextXAlignment.Center
toastText.TextWrapped=true
local progress=frame(gui,"ProcessPanel",300,57,.5,0,1,-89,Vector2.new(.5,1),NAVY)
progress.Visible=false
label(progress,"ProcessLabel","PROCESSING MATERIALS...",276,24,13,5,CYAN,13,true)
local track=Instance.new("Frame")
track.Name="Track"
track.Size=UDim2.fromOffset(276,9)
track.Position=UDim2.fromOffset(12,36)
track.BackgroundColor3=Color3.fromRGB(57,78,88)
track.BorderSizePixel=0
track.Parent=progress
local bar=Instance.new("Frame")
bar.Name="Fill"
bar.Size=UDim2.fromScale(0,1)
bar.BackgroundColor3=CYAN
bar.BorderSizePixel=0
bar.Parent=track
local c=Instance.new("UICorner") c.CornerRadius=UDim.new(1,0) c.Parent=track
local c2=Instance.new("UICorner") c2.CornerRadius=UDim.new(1,0) c2.Parent=bar
-- HUD scales down on smaller windows while staying anchored.
local screens={banner,stats,toast,progress}
local function fit()
    local camera=workspace.CurrentCamera
    if not camera then return end
    local size=camera.ViewportSize
    local scale=math.clamp(math.min(size.X/1200,size.Y/720),.64,1)
    for _,f in ipairs(screens) do
        local s=f:FindFirstChild("SW1_UIScale")
        if not s then s=Instance.new("UIScale") s.Name="SW1_UIScale" s.Parent=f end
        s.Scale=scale
    end
    if size.X < 800 then
        stats.Position=UDim2.new(0,10,1,-10)
        toast.Position=UDim2.new(.5,0,1,-10)
        progress.Position=UDim2.new(.5,0,1,-67)
    else
        stats.Position=UDim2.new(0,20,1,-20)
        toast.Position=UDim2.new(.5,0,1,-20)
        progress.Position=UDim2.new(.5,0,1,-89)
    end
end
local cam=workspace.CurrentCamera
if cam then cam:GetPropertyChangedSignal("ViewportSize"):Connect(fit) end
fit()
local function refresh()
    qtyText.Text=tostring(player:GetAttribute("SW1_Carry") or 0).." / "..tostring(player:GetAttribute("SW1_Capacity") or 12)
    for _,kind in ipairs(materialNames) do rowLabels[kind].Text=tostring(player:GetAttribute("SW1_"..kind) or 0) end
    local statsObj=player:FindFirstChild("leaderstats")
    local cash=statsObj and statsObj:FindFirstChild("Cash")
    cashText.Text="CASH   $"..tostring(cash and cash.Value or 0)
end
for _,kind in ipairs(materialNames) do player:GetAttributeChangedSignal("SW1_"..kind):Connect(refresh) end
player:GetAttributeChangedSignal("SW1_Carry"):Connect(refresh)
player:GetAttributeChangedSignal("SW1_Capacity"):Connect(refresh)
local cashConn=nil
local function attachCash(statsObj)
    if not statsObj then return end
    local function attach(v)
        if v and v.Name=="Cash" and v:IsA("IntValue") then
            if cashConn then cashConn:Disconnect() end
            cashConn=v:GetPropertyChangedSignal("Value"):Connect(refresh)
            refresh()
        end
    end
    attach(statsObj:FindFirstChild("Cash"))
    statsObj.ChildAdded:Connect(attach)
end
attachCash(player:FindFirstChild("leaderstats"))
player.ChildAdded:Connect(function(v) if v.Name=="leaderstats" then attachCash(v) end end)
local noticeSeq=0
player:GetAttributeChangedSignal("SW1_NoticeSeq"):Connect(function()
    noticeSeq+=1
    local seq=noticeSeq
    toastText.Text=player:GetAttribute("SW1_Notice") or ""
    toast.BackgroundTransparency=.035
    toastText.TextTransparency=0
    task.delay(3.4,function()
        if seq~=noticeSeq then return end
        TweenService:Create(toast,TweenInfo.new(.35),{BackgroundTransparency=.38}):Play()
        TweenService:Create(toastText,TweenInfo.new(.35),{TextTransparency=.13}):Play()
    end)
end)
local currentTween=nil
player:GetAttributeChangedSignal("SW1_Processing"):Connect(function()
    if currentTween then currentTween:Cancel(); currentTween=nil end
    local processing=player:GetAttribute("SW1_Processing")
    progress.Visible=processing==true
    bar.Size=UDim2.fromScale(0,1)
    if processing then
        currentTween=TweenService:Create(bar,TweenInfo.new(2.4,Enum.EasingStyle.Linear),{Size=UDim2.fromScale(1,1)})
        currentTween:Play()
    end
end)
refresh()
