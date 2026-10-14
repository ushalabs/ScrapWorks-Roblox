-- Scrapworks Phase3: compact, responsive manufacturing interface.
-- This template LocalScript is cloned into PlayerGui by Phase3Bootstrap.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local player=Players.LocalPlayer
local root=workspace:WaitForChild("SCRAPWORKS_GAME",30)
if not root then return end
local factory=root:WaitForChild("ManufacturingV1",20)
local config=require(factory:WaitForChild("Config"))
local remotes=factory:WaitForChild("Remotes")
local craft=remotes:WaitForChild("Craft")
local deliver=remotes:WaitForChild("Deliver")
local pg=player:WaitForChild("PlayerGui")
if pg:FindFirstChild("SW3_Interface") then return end
local gui=Instance.new("ScreenGui")
gui.Name="SW3_Interface";gui.IgnoreGuiInset=false;gui.ResetOnSpawn=false;gui.DisplayOrder=12;gui.Parent=pg
local C={bg=Color3.fromRGB(11,24,36),panel=Color3.fromRGB(23,42,57),light=Color3.fromRGB(36,60,75),cyan=Color3.fromRGB(70,229,219),gold=Color3.fromRGB(255,197,85),text=Color3.fromRGB(243,250,252),muted=Color3.fromRGB(170,196,205),ok=Color3.fromRGB(100,212,145),warn=Color3.fromRGB(248,151,92)}
local function ui(typeName,name,parent)
  local x=Instance.new(typeName);x.Name=name;x.Parent=parent;return x
end
local function corners(x,rad)
  local r=ui("UICorner","Round",x);r.CornerRadius=UDim.new(0,rad or 12)
end
local function stroke(x,col,t)
  local s=ui("UIStroke","Outline",x);s.Color=col or C.cyan;s.Transparency=t or .65;s.Thickness=1.2
end
local function label(parent,name,value,pos,sz,fontSize,color,bold)
  local x=ui("TextLabel",name,parent);x.BackgroundTransparency=1;x.Text=value;x.Position=pos;x.Size=sz
  x.TextColor3=color or C.text;x.Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham
  x.TextSize=fontSize or 14;x.TextWrapped=true;x.TextXAlignment=Enum.TextXAlignment.Left
  return x
end
local function button(parent,name,value,pos,sz,col)
  local x=ui("TextButton",name,parent);x.Text=value;x.Position=pos;x.Size=sz;x.TextColor3=C.text
  x.Font=Enum.Font.GothamBold;x.TextSize=14;x.BackgroundColor3=col or C.light;x.AutoButtonColor=true
  x.BorderSizePixel=0;corners(x,10);return x
end
local toggle=button(gui,"ProductionToggle","PRODUCTION",UDim2.new(1,-24,1,-130),UDim2.fromOffset(158,46),C.bg)
toggle.AnchorPoint=Vector2.new(1,1);stroke(toggle,C.cyan,.26)
local panel=ui("Frame","ProductionPanel",gui)
panel.BackgroundColor3=C.bg;panel.BorderSizePixel=0
panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.fromScale(.5,.49)
panel.Size=UDim2.fromOffset(672,486);panel.Visible=false;corners(panel,17);stroke(panel,C.cyan,.29)
local grad=ui("UIGradient","BackGradient",panel)
grad.Color=ColorSequence.new(Color3.fromRGB(23,48,60),C.bg);grad.Rotation=105
label(panel,"Title","SCRAPWORKS / MANUFACTURING",UDim2.fromOffset(20,16),UDim2.fromOffset(540,29),22,C.cyan,true)
local close=button(panel,"Close","X",UDim2.new(1,-18,0,16),UDim2.fromOffset(38,34),C.light)
close.AnchorPoint=Vector2.new(1,0)
label(panel,"Hint","Go to the factory production terminal to start jobs and deliver contracts.",UDim2.fromOffset(20,51),UDim2.new(1,-40,0,25),13,C.muted,false)
local status=label(panel,"JobStatus","NO ACTIVE JOB",UDim2.fromOffset(20,79),UDim2.new(1,-40,0,26),14,C.gold,true)
local raw=label(panel,"MaterialsLine","",UDim2.fromOffset(20,112),UDim2.new(1,-40,0,24),12,C.muted,false)
local product=label(panel,"ProductsLine","",UDim2.fromOffset(20,135),UDim2.new(1,-40,0,26),14,C.text,true)
local recipeTab=button(panel,"RecipeTab","RECIPES",UDim2.fromOffset(20,173),UDim2.fromOffset(146,35),C.light)
local contractTab=button(panel,"ContractTab","CONTRACTS",UDim2.fromOffset(176,173),UDim2.fromOffset(146,35),C.light)
local rowHolder=ui("Frame","Rows",panel)
rowHolder.BackgroundTransparency=1;rowHolder.Position=UDim2.fromOffset(20,222);rowHolder.Size=UDim2.new(1,-40,0,205)
local footer=label(panel,"Footer","Server-authoritative production • Manufacturing is separate from scrap selling.",UDim2.fromOffset(20,446),UDim2.new(1,-40,0,28),12,C.muted,false)
local rows={}
for i=1,3 do
 local row=ui("Frame","Row"..i,rowHolder);row.Size=UDim2.new(1,0,0,62);row.Position=UDim2.fromOffset(0,(i-1)*70)
 row.BorderSizePixel=0;row.BackgroundColor3=C.panel;corners(row,11)
 local title=label(row,"Name","",UDim2.fromOffset(14,7),UDim2.new(1,-170,0,24),15,C.text,true)
 local info=label(row,"Ingredients","",UDim2.fromOffset(14,31),UDim2.new(1,-172,0,23),12,C.muted,false)
 local act=button(row,"Action","BUILD",UDim2.new(1,-12,.5,0),UDim2.fromOffset(138,39),C.light)
 act.AnchorPoint=Vector2.new(1,.5)
 rows[i]={title=title,info=info,action=act,kind=nil,mode=nil}
 act.MouseButton1Click:Connect(function()
   local rowData=rows[i]
   if rowData.kind and rowData.mode=="recipe" then craft:FireServer(rowData.kind) end
   if rowData.kind and rowData.mode=="contract" then deliver:FireServer(rowData.kind) end
 end)
end
local mode="recipe"
local function goodsText(tab)
 local ar={}
 for k,v in pairs(tab) do table.insert(ar,tostring(v).." "..(config.OutputNames[k] or k)) end
 table.sort(ar);return table.concat(ar," + ")
end
local function rawText(tab)
 local ar={};for k,v in pairs(tab) do table.insert(ar,tostring(v).." "..k)end;table.sort(ar);return table.concat(ar," + ")
end
local function refresh()
 raw.Text=string.format("RAW: Steel %d     Copper %d     Circuit %d",player:GetAttribute("SW1_Steel") or 0,player:GetAttribute("SW1_Copper") or 0,player:GetAttribute("SW1_Circuit") or 0)
 product.Text=string.format("GOODS: Plates %d   |   Wires %d   |   Motors %d",player:GetAttribute("SW3_Plate") or 0,player:GetAttribute("SW3_Wire") or 0,player:GetAttribute("SW3_Motor") or 0)
 recipeTab.BackgroundColor3=mode=="recipe" and C.cyan or C.light
 contractTab.BackgroundColor3=mode=="contract" and C.gold or C.light
 recipeTab.TextColor3=mode=="recipe" and C.bg or C.text
 contractTab.TextColor3=mode=="contract" and C.bg or C.text
 for i,row in ipairs(rows) do
   local id=(mode=="recipe" and config.RecipeOrder or config.ContractOrder)[i]
   row.kind=id;row.mode=mode
   if mode=="recipe" then
      local r=config.Recipes[id]
      local ing=rawText(r.Raw)
      if next(r.Goods) then ing=ing.." + "..goodsText(r.Goods) end
      row.title.Text=r.Name
      row.info.Text=ing.."  •  "..r.Seconds.." sec"
      row.action.Text="START JOB"
      row.action.BackgroundColor3=C.light
      row.action.TextColor3=C.text
   else
      local c=config.Contracts[id]
      row.title.Text=c.Name
      row.info.Text=goodsText(c.Goods)
      row.action.Text="+$"..c.Reward
      row.action.BackgroundColor3=C.light
      row.action.TextColor3=C.gold
   end
 end
end
recipeTab.MouseButton1Click:Connect(function()mode="recipe";refresh()end)
contractTab.MouseButton1Click:Connect(function()mode="contract";refresh()end)
local function open(value)
 panel.Visible=value
 toggle.Text=value and "CLOSE PRODUCTION" or "PRODUCTION"
 if value then refresh() end
end
toggle.MouseButton1Click:Connect(function()open(not panel.Visible)end)
close.MouseButton1Click:Connect(function()open(false)end)
local terminal=factory:WaitForChild("ProductionTerminal"):WaitForChild("MainConsole")
task.spawn(function()
  local prompt=terminal:WaitForChild("ProductionAccess",20)
  if prompt then prompt.Triggered:Connect(function()open(true)end) end
end)
for _,key in ipairs({"SW1_Steel","SW1_Copper","SW1_Circuit","SW3_Plate","SW3_Wire","SW3_Motor","SW3_Recipe","SW3_Busy"}) do
 player:GetAttributeChangedSignal(key):Connect(refresh)
end
local panelScale=ui("UIScale","ResponsiveScale",panel)
local toggleScale=ui("UIScale","ToggleScale",toggle)
local function fit()
 local cam=workspace.CurrentCamera;if not cam then return end
 local v=cam.ViewportSize
 panelScale.Scale=math.clamp(math.min((v.X-24)/672,(v.Y-32)/486),.45,1)
 toggleScale.Scale=math.clamp(math.min(v.X/900,v.Y/580),.7,1)
end
if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fit) end
fit()
local last=0
RunService.Heartbeat:Connect(function(dt)
 last+=dt
 if last<.35 then return end
 last=0
 if player:GetAttribute("SW3_Busy") then
   local t=math.max(0,(player:GetAttribute("SW3_FinishAt") or 0)-os.time())
   local key=player:GetAttribute("SW3_Recipe") or ""
   local r=config.Recipes[key]
   status.Text="BUILDING "..(r and config.OutputNames[r.Output] or "product").."  •  "..t.."s remaining"
   status.TextColor3=C.cyan
 else
   status.Text="MACHINERY READY  •  Contracts completed: "..(player:GetAttribute("SW3_ContractsDone") or 0)
   status.TextColor3=C.ok
 end
end)
refresh()
