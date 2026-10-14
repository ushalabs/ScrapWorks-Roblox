-- Scrapworks Phase 2: server-only purchases and machine processing.
-- Uses Phase 1 InventoryService/EconomyService rather than replacing existing systems.
local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local Config=require(script.Parent.Config)
local Root=script.Parent
local Upgrade={}
local inventory, economy
local processing={}
local animating={}
local function animateStation(id)
    if animating[id] then return end
    local stations=Root:FindFirstChild("MachineStations")
    local station=stations and stations:FindFirstChild(id.."_Station")
    if not station then return end
    local part=station:FindFirstChild(id=="Compactor" and "CompressionPlateUpper" or (id=="Sorter" and "ScannerRail" or "HeatWindow"))
    if not part or not part:IsA("BasePart") then return end
    animating[id]=true
    if id=="Compactor" then
        local original=part.CFrame
        TweenService:Create(part,TweenInfo.new(.3,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{CFrame=original*CFrame.new(0,-1.3,0)}):Play()
        task.delay(.38,function()
            if part.Parent then TweenService:Create(part,TweenInfo.new(.6,Enum.EasingStyle.Back),{CFrame=original}):Play() end
        end)
    elseif id=="Sorter" then
        local original=part.Color
        TweenService:Create(part,TweenInfo.new(.3),{Color=Color3.fromRGB(245,252,255)}):Play()
        task.delay(.6,function()
            if part.Parent then TweenService:Create(part,TweenInfo.new(.6),{Color=original}):Play() end
        end)
    else
        local original=part.Transparency
        TweenService:Create(part,TweenInfo.new(.4),{Transparency=0}):Play()
        task.delay(.7,function()
            if part.Parent then TweenService:Create(part,TweenInfo.new(.6),{Transparency=original}):Play() end
        end)
    end
    task.delay(1.5,function()animating[id]=nil end)
end

local function notify(player,message)
    if player.Parent~=Players then return end
    player:SetAttribute("SW1_Notice",message)
    player:SetAttribute("SW1_NoticeSeq",(player:GetAttribute("SW1_NoticeSeq") or 0)+1)
end
function Upgrade.BindPhase1(phase1)
    inventory=require(phase1:WaitForChild("InventoryService"))
    economy=require(phase1:WaitForChild("EconomyService"))
end
function Upgrade.Init(player)
    for _,id in ipairs(Config.Order) do
        local key="SW2_Own_"..id
        if player:GetAttribute(key)==nil then player:SetAttribute(key,false) end
    end
    if player:GetAttribute("SW2_ActiveMachine")==nil then player:SetAttribute("SW2_ActiveMachine","") end
    player:SetAttribute("SW2_Ready",true)
end
local function has(player,id) return player:GetAttribute("SW2_Own_"..id)==true end
function Upgrade.Purchase(player,id)
    if player.Parent~=Players or type(id)~="string" then return end
    local info=Config.Machines[id]
    if not info then return end
    if has(player,id) then notify(player,info.Name.." already unlocked!");return end
    local tier=info.Tier
    if tier>1 and not has(player,Config.Order[tier-1]) then
        notify(player,"Unlock the previous machine first.");return
    end
    local cash=economy.Init(player)
    if cash.Value<info.Cost then notify(player,"Need $"..tostring(info.Cost-cash.Value).." more to unlock "..info.Name);return end
    cash.Value-=info.Cost
    player:SetAttribute("SW2_Own_"..id,true)
    notify(player,"MACHINE UNLOCKED  •  "..info.Name.."! Visit its station in the freight annex.")
end
local function distanceOkay(player,part)
    local char=player.Character
    local root=char and char:FindFirstChild("HumanoidRootPart")
    return root and root:IsA("BasePart") and (root.Position-part.Position).Magnitude<=14
end
function Upgrade.Process(player,id,interactor)
    if player.Parent~=Players or not distanceOkay(player,interactor) then return end
    local info=Config.Machines[id];if not info then return end
    if processing[player] then notify(player,"Machine is still cooling down.");return end
    if player:GetAttribute("SW1_Processing")==true then notify(player,"Wait for the refinery to finish.");return end
    if not has(player,id) then notify(player,"Unlock "..info.Name.." from the UPGRADES menu first.");return end
    local count=inventory.Total(player)
    if count<info.Minimum then
        notify(player,"Need at least "..info.Minimum.." scrap pieces to use this machine.")
        return
    end
    -- Atomic within one server callback: no yields between SellAll and credit.
    local quantity, baseValue=inventory.SellAll(player)
    if quantity<info.Minimum or baseValue<=0 then return end
    local payout=math.floor(baseValue*info.Multiplier+.5)
    if not economy.Credit(player,payout) then
        warn("[Scrapworks Phase2] Unanticipated credit failure after consuming inventory for",player.UserId)
        return
    end
    processing[player]=true
    animateStation(id)
    player:SetAttribute("SW2_ActiveMachine",id)
    player:SetAttribute("SW2_LastSale",quantity.." items → $"..payout)
    notify(player,info.Name.."  •  "..quantity.." pieces processed  •  +$"..payout.."  ("..math.floor(info.Multiplier*100+.5).."% sale value)")
    task.delay(1.5,function()
        processing[player]=nil
        if player.Parent==Players then player:SetAttribute("SW2_ActiveMachine","") end
    end)
end
function Upgrade.Release(player) processing[player]=nil end
return Upgrade
