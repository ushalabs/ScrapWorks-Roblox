-- Scrapworks Phase 2 : optional machine shop + safe non-destructive Phase 1 HUD alignment fix.
local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local player=Players.LocalPlayer
if not player then return end
local gui=script.Parent
local gameRoot=workspace:WaitForChild("SCRAPWORKS_GAME")
local root=gameRoot:WaitForChild("SCRAPWORKS_PHASE2_ADDON")
local remotes=root:WaitForChild("SW2_Remotes")
local purchase=remotes:WaitForChild("PurchaseMachine")
local config=require(root:WaitForChild("Config"))
local NAVY=Color3.fromRGB(15,29,40)
local PANEL=Color3.fromRGB(24,45,59)
local LIGHT=Color3.fromRGB(241,249,249)
local MUTED=Color3.fromRGB(156,190,200)
local CYAN=Color3.fromRGB(79,239,219)
local GOLD=Color3.fromRGB(255,207,105)
local TINTS={Compactor=Color3.fromRGB(255,205,92),Sorter=Color3.fromRGB(81,228,220),Smelter=Color3.fromRGB(249,153,94)}
local function round(frame,r)
    local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 10);c.Parent=frame
end
local function text(parent,name,txt,pos,size,font,color)
    local t=Instance.new("TextLabel")
    t.Name=name;t.BackgroundTransparency=1;t.Position=pos;t.Size=size
    t.Text=txt;t.Font=font or Enum.Font.Gotham;t.TextColor3=color or LIGHT
    t.TextSize=14;t.TextXAlignment=Enum.TextXAlignment.Left;t.TextYAlignment=Enum.TextYAlignment.Center
    t.Parent=parent;return t
end
local function action(parent,name,txt,pos,size,bg)
    local b=Instance.new("TextButton")
    b.Name=name;b.Text=txt;b.Position=pos;b.Size=size
    b.TextSize=14;b.Font=Enum.Font.GothamBold;b.TextColor3=LIGHT
    b.BorderSizePixel=0;b.BackgroundColor3=bg or PANEL
    b.AutoButtonColor=true;b.Parent=parent;round(b,10)
    return b
end

-- Bug fix: Phase1 header capacity counter extended past the inventory panel's right edge.
-- Keep existing Phase1 controller and stats; adjust only the counter and brand text.
task.spawn(function()
    local pg=player:WaitForChild("PlayerGui")
    local h=pg:WaitForChild("ScrapworksPhase1HUD",25)
    if not h then return end
    local inv=h:WaitForChild("MaterialInventory",15)
    if inv then
        local count=inv:WaitForChild("QtyText",10)
        if count then
            count.Position=UDim2.fromOffset(250,9)
            count.Size=UDim2.fromOffset(86,26)
            count.TextXAlignment=Enum.TextXAlignment.Right
            count.TextScaled=false
            count.TextSize=17
        end
    end
    local brand=h:FindFirstChild("Brand")
    local label=brand and brand:FindFirstChild("BrandText")
    if label then label.Text="SCRAPWORKS  /  FACTORY YARD" end
end)

local trigger=action(gui,"UpgradeToggle","⚙  UPGRADES",UDim2.new(1,-20,1,-22),UDim2.fromOffset(164,50),NAVY)
trigger.AnchorPoint=Vector2.new(1,1)
local stroke=Instance.new("UIStroke");stroke.Color=CYAN;stroke.Transparency=.35;stroke.Thickness=1.5;stroke.Parent=trigger
local frame=Instance.new("Frame")
frame.Name="MachineShop";frame.AnchorPoint=Vector2.new(.5,.5);frame.Position=UDim2.fromScale(.5,.5)
frame.Size=UDim2.fromOffset(570,465);frame.BackgroundColor3=NAVY;frame.BorderSizePixel=0
frame.Visible=false;frame.Parent=gui;round(frame,15)
local border=Instance.new("UIStroke");border.Color=Color3.fromRGB(83,134,147);border.Transparency=.25;border.Thickness=1.4;border.Parent=frame
local header=text(frame,"Title","MACHINE UPGRADES",UDim2.fromOffset(24,17),UDim2.fromOffset(440,34),Enum.Font.GothamBlack,CYAN)
header.TextSize=24
local subtitle=text(frame,"Subtitle","Spend CASH to unlock higher-value scrap processing.",UDim2.fromOffset(24,50),UDim2.fromOffset(470,27),Enum.Font.Gotham,MUTED)
subtitle.TextSize=13
local close=action(frame,"Close","✕",UDim2.new(1,-18,0,18),UDim2.fromOffset(37,37),Color3.fromRGB(51,68,79))
close.AnchorPoint=Vector2.new(1,0)
local line=Instance.new("Frame")
line.Position=UDim2.fromOffset(24,87);line.Size=UDim2.new(1,-48,0,1);line.BorderSizePixel=0
line.BackgroundColor3=Color3.fromRGB(68,103,119);line.Parent=frame
local cards={}
for i,id in ipairs(config.Order) do
    local info=config.Machines[id]
    local row=Instance.new("Frame")
    row.Name=id.."Card";row.Size=UDim2.new(1,-44,0,96)
    row.Position=UDim2.fromOffset(22,101+(i-1)*105)
    row.BackgroundColor3=PANEL;row.BorderSizePixel=0;row.Parent=frame;round(row,11)
    local strip=Instance.new("Frame");strip.Size=UDim2.fromOffset(5,74)
    strip.Position=UDim2.fromOffset(9,11);strip.BackgroundColor3=TINTS[id]
    strip.BorderSizePixel=0;strip.Parent=row;round(strip,3)
    local name=text(row,"MachineName",info.Name,UDim2.fromOffset(27,9),UDim2.fromOffset(285,23),Enum.Font.GothamBold,LIGHT)
    name.TextSize=17
    local desc=text(row,"Description",info.Description,UDim2.fromOffset(27,36),UDim2.fromOffset(330,20),Enum.Font.Gotham,MUTED)
    desc.TextSize=12
    local benefit=text(row,"Benefit","+"..math.floor((info.Multiplier-1)*100+.5).."% VALUE   •   "..info.Minimum.." SCRAP MIN",UDim2.fromOffset(27,62),UDim2.fromOffset(350,21),Enum.Font.GothamBold,TINTS[id])
    benefit.TextSize=12
    local buy=action(row,"Buy","$"..info.Cost,UDim2.new(1,-14,.5,0),UDim2.fromOffset(133,44),TINTS[id])
    buy.AnchorPoint=Vector2.new(1,.5)
    buy.TextColor3=NAVY
    buy.MouseButton1Click:Connect(function()purchase:FireServer(id)end)
    cards[id]={Button=buy,Info=info}
end
local footer=text(frame,"Footer","Collect scrap → Unlock a machine → Process your bag at its station.",UDim2.fromOffset(24,424),UDim2.new(1,-45,0,28),Enum.Font.Gotham,MUTED)
footer.TextSize=13
local scale=Instance.new("UIScale");scale.Name="FitScale";scale.Parent=frame
local tscale=Instance.new("UIScale");tscale.Name="ToggleScale";tscale.Parent=trigger
local function fit()
    local cam=workspace.CurrentCamera
    if not cam then return end
    local v=cam.ViewportSize
    scale.Scale=math.clamp(math.min((v.X-24)/570,(v.Y-24)/465),.55,1)
    tscale.Scale=math.clamp(math.min(v.X/1100,v.Y/690),.72,1)
end
if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fit)
end
fit()
local function refresh()
    for idx,id in ipairs(config.Order) do
        local x=cards[id]
        local owned=player:GetAttribute("SW2_Own_"..id)==true
        local required=idx>1 and player:GetAttribute("SW2_Own_"..config.Order[idx-1])~=true
        local button=x.Button
        if owned then
            button.Text="✓ OWNED";button.BackgroundColor3=Color3.fromRGB(63,103,86);button.TextColor3=LIGHT
        elseif required then
            button.Text="LOCKED";button.BackgroundColor3=Color3.fromRGB(69,78,91);button.TextColor3=Color3.fromRGB(181,195,204)
        else
            button.Text="$"..x.Info.Cost;button.BackgroundColor3=TINTS[id];button.TextColor3=NAVY
        end
        button.Active=not (owned or required)
        button.AutoButtonColor=not (owned or required)
    end
end
for _,id in ipairs(config.Order) do player:GetAttributeChangedSignal("SW2_Own_"..id):Connect(refresh) end
refresh()
local function setVisible(value)
    frame.Visible=value
    trigger.Text=value and "✕  CLOSE" or "⚙  UPGRADES"
end
trigger.MouseButton1Click:Connect(function()setVisible(not frame.Visible)end)
close.MouseButton1Click:Connect(function()setVisible(false)end)
-- UI only; purchases are validated by the server.
