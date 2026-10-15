-- Scrapworks Phase 4 / all economy changes, plot ownership and production are server-authoritative.
-- No physics-based conveyor products are spawned on the server.
local Players=game:GetService("Players")
local Config=require(script.Parent.Config)
local Service={}
local inventory,economy,production
local states={}
local assigned={} -- plotId -> Player
local MAX_COUNT=1000000
local function tell(p,message)
    if p.Parent~=Players then return end
    p:SetAttribute("SW1_Notice",message)
    p:SetAttribute("SW1_NoticeSeq",(p:GetAttribute("SW1_NoticeSeq") or 0)+1)
end
local function defaultSlot(i)
    return {unlocked=(i==1),level=1,recipe=Config.SlotRecipeDefaults[i],due=0}
end
local function newState(plotId)
    local hopper={}
    for _,id in ipairs(Config.RawTypes) do hopper[id]=0 end
    return {plotId=plotId,hopper=hopper,slots={defaultSlot(1),defaultSlot(2),defaultSlot(3)},made=0}
end
function Service.Bind(phase1,manufacturing)
    inventory=require(phase1:WaitForChild("InventoryService"))
    economy=require(phase1:WaitForChild("EconomyService"))
    production=require(manufacturing:WaitForChild("ProductionService"))
end
local function getPlot(id)
    return script.Parent:WaitForChild("FactoryPlots"):FindFirstChild("Plot_"..tostring(id))
end
local function renewPlot(p,d)
    local plot=getPlot(d.plotId)
    if not plot then return end
    plot:SetAttribute("OwnerUserId",p.UserId)
    plot:SetAttribute("OwnerName",p.DisplayName)
    local terminal=plot:FindFirstChild("FactoryConsole")
    local display=terminal and terminal:FindFirstChild("OwnerLabel",true)
    if display and display:IsA("TextLabel") then display.Text=p.DisplayName.."'S FACTORY" end
end
local function refresh(p,d)
    if p.Parent~=Players then return end
    p:SetAttribute("SW4_Plot",d.plotId)
    p:SetAttribute("SW4_Made",d.made)
    local total=0
    for _,kind in ipairs(Config.RawTypes) do
        local count=d.hopper[kind] or 0
        total+=count
        p:SetAttribute("SW4_Stock_"..kind,count)
    end
    p:SetAttribute("SW4_StockTotal",total)
    for i,s in ipairs(d.slots) do
        local k="SW4_Slot"..i
        p:SetAttribute(k.."Owned",s.unlocked)
        p:SetAttribute(k.."Level",s.level)
        p:SetAttribute(k.."Recipe",s.recipe)
        p:SetAttribute(k.."Due",s.due)
    end
    p:SetAttribute("SW4_Ready",true)
end
function Service.Init(p)
    if states[p] then return states[p] end
    local id
    for i=1,Config.MaxPlots do if not assigned[i] then id=i;break end end
    if not id then
        p:SetAttribute("SW4_Plot",0)
        p:SetAttribute("SW4_Ready",true)
        tell(p,"All factory plots are occupied. You can still collect and sell scrap.")
        return nil
    end
    assigned[id]=p
    states[p]=newState(id)
    renewPlot(p,states[p])
    refresh(p,states[p])
    return states[p]
end
local function ownedState(p)
    if p.Parent~=Players or p:GetAttribute("SW3_Loading") or p:GetAttribute("SW4_Ready")~=true then return nil end
    return states[p]
end
local function slot(s,i)
    local x=type(i)=="number" and math.floor(i) or 0
    if x~=i or x<1 or x>3 then return nil end
    return s.slots[x],x
end
local function readyInputs(p,d,recipe)
    for id,n in pairs(recipe.Raw) do if (d.hopper[id] or 0)<n then return false end end
    for id,n in pairs(recipe.Goods) do if production.CountGoods(p,id)<n then return false end end
    if not production.CanCreditGoods(p,recipe.Output,1) then return false end
    return true
end
local function productionSeconds(recipe,level)
    return math.max(3, math.floor(recipe.Seconds/(1+(level-1)*.45)+.5))
end
local function produce(p,d,sl)
    local recipe=Config.Recipes[sl.recipe]
    if not recipe or not readyInputs(p,d,recipe) then return false end
    -- No waits / yields: validated deductions and product credit are one server-thread operation.
    for k,n in pairs(recipe.Raw) do d.hopper[k]-=n end
    for k,n in pairs(recipe.Goods) do
        if not production.ConsumeGoods(p,k,n) then
            -- Should be unreachable due to single-threaded, no-yield validation above.
            warn("[Scrapworks Phase4] Unanticipated goods deduction failure",p.UserId,k)
            for raw,qty in pairs(recipe.Raw) do d.hopper[raw]+=qty end
            return false
        end
    end
    if not production.CreditGoods(p,recipe.Output,1) then
        warn("[Scrapworks Phase4] Product credit failed",p.UserId,recipe.Output)
        for raw,qty in pairs(recipe.Raw) do d.hopper[raw]+=qty end
        for good,qty in pairs(recipe.Goods) do production.CreditGoods(p,good,qty) end
        return false
    end
    d.made+=1
    return true
end
function Service.Tick()
    local now=workspace:GetServerTimeNow()
    for p,d in pairs(states) do
        if p.Parent==Players and not p:GetAttribute("SW3_Loading") then
            local changed=false
            for _,s in ipairs(d.slots) do
                if s.unlocked then
                    local recipe=Config.Recipes[s.recipe]
                    if s.due==0 then
                        if recipe and readyInputs(p,d,recipe) then
                            s.due=now+productionSeconds(recipe,s.level)
                            changed=true
                        end
                    elseif now>=s.due then
                        if recipe and produce(p,d,s) then
                            s.due=0
                            changed=true
                        else
                            s.due=0
                            changed=true
                        end
                    end
                end
            end
            if changed then refresh(p,d) end
        end
    end
end
function Service.Deposit(p)
    local d=ownedState(p);if not d then return end
    local plot=getPlot(d.plotId)
    local console=plot and plot:FindFirstChild("FactoryConsole")
    local char=p.Character
    local pivot=char and char:FindFirstChild("HumanoidRootPart")
    if not pivot or not console or (pivot.Position-console.Position).Magnitude>24 then
        tell(p,"Visit your own factory console to deposit scrap.");return
    end
    local bag=inventory.Export(p)
    local total=0
    for _,n in pairs(bag) do total+=n end
    if total<=0 then tell(p,"Your backpack has no scrap to deposit.");return end
    local stock=0
    for _,n in pairs(d.hopper) do stock+=n end
    if stock+total>Config.MaxStock then tell(p,"Factory storage is full ("..Config.MaxStock.." max).") return end
    if not inventory.Consume(p,bag) then tell(p,"Could not deposit scrap, retry.") return end
    for k,n in pairs(bag) do d.hopper[k]=(d.hopper[k] or 0)+n end
    refresh(p,d)
    tell(p,"Deposited "..total.." raw scrap into your factory hopper.")
end
function Service.BuySlot(p,index)
    local d=ownedState(p);if not d then return end
    local s,i=slot(d,index);if not s or i==1 then return end
    if s.unlocked then tell(p,"Machine already unlocked.") return end
    if not d.slots[i-1].unlocked then tell(p,"Unlock the previous auto-machine first.") return end
    local cost=Config.SlotUnlockPrices[i]
    local cash=economy.Init(p)
    if cash.Value<cost then tell(p,"Need $"..(cost-cash.Value).." more for auto-machine "..i) return end
    cash.Value-=cost;s.unlocked=true
    refresh(p,d)
    tell(p,"AUTO-MACHINE "..i.." UNLOCKED. Factory production expanded!")
end
function Service.UpgradeSlot(p,index)
    local d=ownedState(p);if not d then return end
    local s,i=slot(d,index);if not s or not s.unlocked then return end
    if s.level>=Config.MaxMachineLevel then tell(p,"Machine already at MAX LEVEL.")return end
    local cost=Config.LevelUpgradePrices[s.level+1]
    local cash=economy.Init(p)
    if cash.Value<cost then tell(p,"Need $"..(cost-cash.Value).." more to upgrade.") return end
    cash.Value-=cost;s.level+=1;s.due=0
    refresh(p,d)
    tell(p,"Machine "..i.." upgraded to level "..s.level)
end
function Service.SetRecipe(p,index,recipeId)
    local d=ownedState(p);if not d then return end
    local s,i=slot(d,index)
    if not s or not s.unlocked or type(recipeId)~="string" or not Config.Recipes[recipeId] then return end
    s.recipe=recipeId;s.due=0
    refresh(p,d)
    tell(p,"Machine "..i.." is now producing "..Config.Recipes[recipeId].Name)
end
function Service.Teleport(p,mode)
    local d=ownedState(p);if not d then return end
    if mode~="Plot" and mode~="Yard" then return end
    local character=p.Character
    local hum=character and character:FindFirstChildOfClass("Humanoid")
    if not character or not hum or hum.Health<=0 then return end
    local destination
    if mode=="Yard" then
        local anchor=script.Parent.Parent:FindFirstChild("SCRAPWORKS_DEMO_V1")
        anchor=anchor and anchor:FindFirstChild("ScrapworksSpawn")
        destination=anchor
    else
        local plot=getPlot(d.plotId)
        destination=plot and plot:FindFirstChild("Arrival")
    end
    if destination and destination:IsA("BasePart") then
        character:PivotTo(destination.CFrame*CFrame.new(0,4,0))
    end
end
function Service.Export(p)
    local d=states[p];if not d then return nil end
    local stock={};for _,k in ipairs(Config.RawTypes) do stock[k]=d.hopper[k] end
    local slots={}
    for i,s in ipairs(d.slots) do
        slots[i]={unlocked=s.unlocked,level=s.level,recipe=s.recipe}
    end
    return {hopper=stock,slots=slots,made=d.made}
end
function Service.Import(p,rec)
    local d=states[p];if not d or type(rec)~="table" then return false end
    local stock={};local total=0
    for _,k in ipairs(Config.RawTypes) do
        local q=type(rec.hopper)=="table" and rec.hopper[k] or 0
        if type(q)~="number" or q~=q or q<0 then q=0 end
        q=math.floor(math.min(q,Config.MaxStock))
        stock[k]=q;total+=q
    end
    if total>Config.MaxStock then warn("[Scrapworks Phase4] Rejected oversized hopper",p.UserId);return false end
    d.hopper=stock
    for i=1,3 do
        local q=type(rec.slots)=="table" and rec.slots[i] or nil
        local s=d.slots[i]
        if type(q)=="table" then
            s.unlocked=(i==1) or (q.unlocked==true and (i==2 or d.slots[i-1].unlocked))
            s.level=(type(q.level)=="number" and math.floor(math.clamp(q.level,1,Config.MaxMachineLevel))) or 1
            s.recipe=(type(q.recipe)=="string" and Config.Recipes[q.recipe] and q.recipe) or Config.SlotRecipeDefaults[i]
        end
        s.due=0
    end
    local count=rec.made
    d.made=(type(count)=="number" and math.floor(math.clamp(count,0,MAX_COUNT))) or 0
    refresh(p,d)
    return true
end
function Service.Release(p)
    local d=states[p]
    if not d then return end
    local plot=getPlot(d.plotId)
    if plot and assigned[d.plotId]==p then
        plot:SetAttribute("OwnerUserId",0)
        plot:SetAttribute("OwnerName","")
        local display=plot:FindFirstChild("OwnerLabel",true)
        if display and display:IsA("TextLabel") then display.Text="AVAILABLE FACTORY" end
    end
    if assigned[d.plotId]==p then assigned[d.plotId]=nil end
    states[p]=nil
end
return Service
