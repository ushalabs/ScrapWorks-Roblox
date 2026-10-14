-- Phase 3: server-side virtual production; never spawn physical items for every tick.
local Players=game:GetService("Players")
local Config=require(script.Parent.Config)
local P={};local states={};local inventory=nil;local economy=nil
local MAX_GOODS=9999
local function notice(player,message)
    if player.Parent~=Players then return end
    player:SetAttribute("SW1_Notice",message)
    player:SetAttribute("SW1_NoticeSeq",(player:GetAttribute("SW1_NoticeSeq") or 0)+1)
end
function P.Bind(phase1)
    inventory=require(phase1:WaitForChild("InventoryService"))
    economy=require(phase1:WaitForChild("EconomyService"))
end
local function refresh(player,data)
    if player.Parent~=Players then return end
    for _,id in ipairs(Config.Outputs) do player:SetAttribute("SW3_"..id,data.goods[id] or 0) end
    player:SetAttribute("SW3_Busy",data.pending~=nil)
    player:SetAttribute("SW3_Recipe",data.pending and data.pending.id or "")
    player:SetAttribute("SW3_FinishAt",data.pending and data.pending.finish or 0)
    player:SetAttribute("SW3_ContractsDone",data.contracts or 0)
    player:SetAttribute("SW3_Ready",true)
end
local function default()
    return {goods={Plate=0,Wire=0,Motor=0},contracts=0,pending=nil,started=false}
end
function P.Init(player)
    if not states[player] then states[player]=default() end
    refresh(player,states[player])
end
local function resolve(player)
    local d=states[player];if not d then return end
    if d.pending and os.time()>=d.pending.finish then
        local id=d.pending.id;local recipe=Config.Recipes[id]
        if recipe then d.goods[recipe.Output]=math.min(MAX_GOODS,(d.goods[recipe.Output] or 0)+recipe.Amount) end
        d.pending=nil
        if player.Parent==Players then notice(player,recipe and ("MANUFACTURED  +"..recipe.Amount.." "..Config.OutputNames[recipe.Output]) or "Production finished") end
        refresh(player,d)
    end
end
local function near(player,part)
    local ch=player.Character;local pivot=ch and ch:FindFirstChild("HumanoidRootPart")
    return pivot and (pivot.Position-part.Position).Magnitude<=20
end
local function canPay(d,goods)
    for id,count in pairs(goods) do
        if not table.find(Config.Outputs,id) or (d.goods[id] or 0)<count then return false end
    end
    return true
end
function P.Craft(player,id,terminal)
    if player.Parent~=Players or not near(player,terminal) then return end
    if type(id)~="string" or not Config.Recipes[id] then return end
    if player:GetAttribute("SW3_Loading") then notice(player,"Loading factory data... try again.");return end
    P.Init(player);resolve(player)
    local d=states[player];local r=Config.Recipes[id]
    if d.pending then notice(player,"A machine job is already running.");return end
    if player:GetAttribute("SW1_Processing") or (player:GetAttribute("SW2_ActiveMachine") or "")~="" then
        notice(player,"Finish the current scrap process first.");return
    end
    if not inventory.CanConsume(player,r.Raw) or not canPay(d,r.Goods) then
        notice(player,"Missing materials. Collect scrap or manufacture prerequisites.");return
    end
    -- No yields between validation and inventory deductions, so one remote cannot race another.
    if not inventory.Consume(player,r.Raw) then return end
    for good,num in pairs(r.Goods) do d.goods[good]-=num end
    d.pending={id=id,finish=os.time()+r.Seconds}
    refresh(player,d)
    notice(player,"PRODUCTION STARTED  "..Config.OutputNames[r.Output].." · "..r.Seconds.."s")
    task.delay(r.Seconds+.25,function() if player.Parent==Players and states[player]==d then resolve(player) end end)
end
function P.Deliver(player,id,terminal)
    if player.Parent~=Players or not near(player,terminal) then return end
    if type(id)~="string" then return end
    local contract=Config.Contracts[id];if not contract then return end
    if player:GetAttribute("SW3_Loading") then return end
    P.Init(player);resolve(player)
    local d=states[player]
    if not canPay(d,contract.Goods) then notice(player,"Not enough manufactured goods for this contract.");return end
    for good,num in pairs(contract.Goods) do d.goods[good]-=num end
    d.contracts+=1
    economy.Credit(player,contract.Reward)
    refresh(player,d)
    notice(player,"CONTRACT COMPLETE  +$"..contract.Reward.."  ·  "..contract.Name)
end
function P.Export(player)
    if not states[player] then return nil end
    resolve(player)
    local d=states[player]
    local goods={};for _,id in ipairs(Config.Outputs) do goods[id]=d.goods[id] end
    local pending=d.pending and {id=d.pending.id,finish=d.pending.finish} or nil
    return {goods=goods,contracts=d.contracts,pending=pending}
end
function P.Import(player,record)
    if type(record)~="table" then return false end
    P.Init(player)
    local d=states[player]
    local goods={}
    for _,id in ipairs(Config.Outputs) do
        local q=type(record.goods)=="table" and record.goods[id] or 0
        if type(q)~="number" or q~=q or q<0 then q=0 end
        goods[id]=math.floor(math.min(q,MAX_GOODS))
    end
    d.goods=goods
    local count=record.contracts
    d.contracts=(type(count)=="number" and math.floor(math.clamp(count,0,1000000))) or 0
    d.pending=nil
    local pending=record.pending
    if type(pending)=="table" and Config.Recipes[pending.id] and type(pending.finish)=="number" then
        d.pending={id=pending.id,finish=math.floor(math.min(os.time()+3600,math.max(os.time()-86400,pending.finish)))}
    end
    resolve(player);refresh(player,d)
    if d.pending then
        local remaining=math.max(0,d.pending.finish-os.time())
        task.delay(remaining+.3,function() if states[player]==d then resolve(player) end end)
    end
    return true
end
function P.Release(player) states[player]=nil end
return P
