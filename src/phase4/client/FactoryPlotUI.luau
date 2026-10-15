-- v0.6 Phase4: player-owned plot management. Server validates EVERY economic action.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local player=Players.LocalPlayer
local root=workspace:WaitForChild("SCRAPWORKS_GAME"):WaitForChild("FactoryPlotsV1")
local remote=root:WaitForChild("FactoryAction")
local config=require(root:WaitForChild("Config"))
local C={dark=Color3.fromRGB(10,24,37),panel=Color3.fromRGB(22,44,59),cell=Color3.fromRGB(31,59,75),text=Color3.fromRGB(245,251,252),muted=Color3.fromRGB(159,191,203),cyan=Color3.fromRGB(70,231,224),gold=Color3.fromRGB(255,205,101),ok=Color3.fromRGB(111,240,153),red=Color3.fromRGB(244,123,123)}
local function make(class,name,parent)
    local o=Instance.new(class);o.Name=name;o.Parent=parent;return o
end
local function rounded(o,rad)
    local c=make("UICorner","Corner",o);c.CornerRadius=UDim.new(0,rad or 12)
end
local function label(parent,name,text,pos,size,fontSize,color,bold)
    local l=make("TextLabel",name,parent)
    l.BackgroundTransparency=1;l.Position=pos;l.Size=size
    l.Text=text;l.TextSize=fontSize or 14;l.TextColor3=color or C.text
    l.TextXAlignment=Enum.TextXAlignment.Left;l.Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham
    return l
end
local function btn(parent,name,text,pos,size,bg)
    local b=make("TextButton",name,parent)
    b.Position=pos;b.Size=size;b.Text=text;b.TextSize=13
    b.TextColor3=C.text;b.Font=Enum.Font.GothamBold
    b.BorderSizePixel=0;b.BackgroundColor3=bg or C.cell
    b.AutoButtonColor=true;rounded(b,10)
    return b
end
local gui=make("ScreenGui","ScrapworksFactoryPlotHUD",script.Parent)
gui.ResetOnSpawn=false;gui.IgnoreGuiInset=false;gui.DisplayOrder=12
local toggle=btn(gui,"PlotToggle","MY FACTORY",UDim2.new(1,-24,1,-189),UDim2.fromOffset(158,45),C.dark)
toggle.AnchorPoint=Vector2.new(1,1)
local stroke=make("UIStroke","Outline",toggle);stroke.Color=C.gold;stroke.Thickness=1.3;stroke.Transparency=.25
local panel=make("Frame","PlotPanel",gui)
panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.fromScale(.5,.50)
panel.Size=UDim2.fromOffset(652,548);panel.BackgroundColor3=C.dark
panel.BorderSizePixel=0;panel.Visible=false;rounded(panel,18)
local outline=make("UIStroke","Outline",panel);outline.Color=C.cyan;outline.Thickness=1.5;outline.Transparency=.28
local grad=make("UIGradient","Gradient",panel);grad.Color=ColorSequence.new(Color3.fromRGB(24,49,64),C.dark);grad.Rotation=120
label(panel,"Heading","SCRAPWORKS / YOUR FACTORY",UDim2.fromOffset(20,15),UDim2.fromOffset(540,33),21,C.cyan,true)
local close=btn(panel,"Close","X",UDim2.new(1,-18,0,15),UDim2.fromOffset(39,35),C.cell);close.AnchorPoint=Vector2.new(1,0)
local plotLabel=label(panel,"PlotLabel","Assigning your plot...",UDim2.fromOffset(20,52),UDim2.new(1,-40,0,22),14,C.gold,true)
local hopper=label(panel,"Hopper","HOPPER  0 / 240",UDim2.fromOffset(20,82),UDim2.new(1,-40,0,24),15,C.text,true)
local stockLine=label(panel,"Stock","",UDim2.fromOffset(20,106),UDim2.new(1,-40,0,24),12,C.muted,false)
local goodsLine=label(panel,"Goods","",UDim2.fromOffset(20,132),UDim2.new(1,-40,0,24),12,C.muted,false)
local visit=btn(panel,"Visit","VISIT MY PLOT",UDim2.fromOffset(20,168),UDim2.fromOffset(149,39),C.cell)
local home=btn(panel,"Return","RETURN TO YARD",UDim2.fromOffset(180,168),UDim2.fromOffset(160,39),C.cell)
local deposit=btn(panel,"Deposit","DEPOSIT ALL SCRAP",UDim2.fromOffset(353,168),UDim2.fromOffset(277,39),C.panel)
local machineHeader=label(panel,"MachinesTitle","AUTOMATED PRODUCTION MACHINES",UDim2.fromOffset(20,224),UDim2.new(1,-40,0,24),14,C.cyan,true)
local rows={}
for i=1,3 do
    local frame=make("Frame","Machine"..i,panel)
    frame.BackgroundColor3=C.panel;frame.BorderSizePixel=0
    frame.Position=UDim2.fromOffset(20,256+(i-1)*76);frame.Size=UDim2.new(1,-40,0,69)
    rounded(frame,10)
    local top=label(frame,"Status","MACHINE "..i,UDim2.fromOffset(13,7),UDim2.fromOffset(234,21),14,C.text,true)
    local bottom=label(frame,"Details","",UDim2.fromOffset(13,33),UDim2.fromOffset(249,26),11,C.muted,false)
    local recipe=btn(frame,"Recipe","CYCLE RECIPE",UDim2.new(1,-281,0,14),UDim2.fromOffset(127,41),C.cell)
    local upgrade=btn(frame,"Upgrade","UPGRADE",UDim2.new(1,-145,0,14),UDim2.fromOffset(133,41),C.cell)
    rows[i]={top=top,bottom=bottom,recipe=recipe,upgrade=upgrade}
    recipe.MouseButton1Click:Connect(function()
        if player:GetAttribute("SW4_Slot"..i.."Owned")~=true then return end
        local previous=player:GetAttribute("SW4_Slot"..i.."Recipe") or "Plate"
        local pos=table.find(config.ProductionOrder,previous) or 1
        local nextId=config.ProductionOrder[(pos%#config.ProductionOrder)+1]
        remote:FireServer("recipe",i,nextId)
    end)
    upgrade.MouseButton1Click:Connect(function()
        if player:GetAttribute("SW4_Slot"..i.."Owned") then remote:FireServer("upgrade",i)
        else remote:FireServer("buy",i) end
    end)
end
local footer=label(panel,"Footer","Production uses virtual server calculations. Conveyor effects are cosmetic.",UDim2.fromOffset(20,505),UDim2.new(1,-40,0,24),12,C.muted,false)
local function refresh()
    local plot=player:GetAttribute("SW4_Plot") or 0
    plotLabel.Text=plot>0 and ("PLOT #"..plot.."  •  Owned by "..player.DisplayName) or "NO PLOT AVAILABLE IN THIS SERVER"
    hopper.Text="STORAGE HOPPER  "..(player:GetAttribute("SW4_StockTotal") or 0).." / "..config.MaxStock.."   •   Manufactured: "..(player:GetAttribute("SW4_Made") or 0)
    local raw={}
    for _,id in ipairs(config.RawTypes) do
        local v=player:GetAttribute("SW4_Stock_"..id) or 0
        if v>0 then table.insert(raw,id.." "..v) end
    end
    stockLine.Text=#raw>0 and table.concat(raw,"    /    ") or "Hopper empty. Collect scrap, visit your plot, then deposit it."
    goodsLine.Text=string.format("FINISHED GOODS: Plates %d   /   Wires %d   /   Motors %d",player:GetAttribute("SW3_Plate") or 0,player:GetAttribute("SW3_Wire") or 0,player:GetAttribute("SW3_Motor") or 0)
    local now=workspace:GetServerTimeNow()
    for i,r in ipairs(rows) do
        local prefix="SW4_Slot"..i
        local unlocked=player:GetAttribute(prefix.."Owned")==true
        local level=player:GetAttribute(prefix.."Level") or 1
        local recipe=player:GetAttribute(prefix.."Recipe") or config.SlotRecipeDefaults[i]
        local due=player:GetAttribute(prefix.."Due") or 0
        if unlocked then
            r.top.Text="MACHINE "..i.."  /  LVL "..level.."  /  "..config.Recipes[recipe].Name
            r.bottom.Text=due>now and ("ACTIVE • "..math.ceil(due-now).."s remaining") or "WAITING FOR INPUTS / OUTPUT SPACE"
            r.recipe.Text="CHANGE RECIPE"
            r.recipe.BackgroundColor3=C.cell
            r.upgrade.Text=level>=config.MaxMachineLevel and "MAX LEVEL" or ("UPGRADE $"..config.LevelUpgradePrices[level+1])
            r.upgrade.BackgroundColor3=level>=config.MaxMachineLevel and C.cell or C.panel
        else
            r.top.Text="MACHINE "..i.."  /  LOCKED"
            r.bottom.Text="Unlock for a parallel production line"
            r.recipe.Text="LOCKED";r.recipe.BackgroundColor3=C.dark
            r.upgrade.Text="BUY $"..config.SlotUnlockPrices[i]
            r.upgrade.BackgroundColor3=C.panel
        end
    end
end
local function open(value)
    panel.Visible=value;toggle.Text=value and "CLOSE FACTORY" or "MY FACTORY"
    if value then refresh() end
end
toggle.MouseButton1Click:Connect(function()open(not panel.Visible)end)
close.MouseButton1Click:Connect(function()open(false)end)
visit.MouseButton1Click:Connect(function()remote:FireServer("visit")end)
home.MouseButton1Click:Connect(function()remote:FireServer("return")end)
deposit.MouseButton1Click:Connect(function()remote:FireServer("deposit")end)
for _,id in ipairs(config.RawTypes) do player:GetAttributeChangedSignal("SW4_Stock_"..id):Connect(refresh) end
for _,a in ipairs({"SW4_Plot","SW4_Made","SW4_StockTotal","SW3_Plate","SW3_Wire","SW3_Motor"}) do player:GetAttributeChangedSignal(a):Connect(refresh) end
for i=1,3 do for _,suffix in ipairs({"Owned","Level","Recipe","Due"}) do
    player:GetAttributeChangedSignal("SW4_Slot"..i..suffix):Connect(refresh)
end end
local scale=make("UIScale","Fit",panel)
local function fit()
    local camera=workspace.CurrentCamera;if not camera then return end
    local v=camera.ViewportSize
    scale.Scale=math.clamp(math.min((v.X-18)/652,(v.Y-24)/548),.44,1)
end
if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fit) end
fit()
local elapsed=0
RunService.Heartbeat:Connect(function(dt)
    if not panel.Visible then return end
    elapsed+=dt
    if elapsed>=.7 then elapsed=0;refresh() end
end)
refresh()
