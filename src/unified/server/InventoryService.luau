-- Phase 1 / per-player material quantities. Session only; no DataStore yet.
local Inventory = {}
local items = {}
local Config = require(script.Parent.Config)
local function update(player)
    local data = items[player]
    if not data then return end
    local n, val = 0, 0
    for _, kind in ipairs(Config.MaterialOrder) do
        local qty = data[kind] or 0
        n += qty
        val += qty * Config.Materials[kind].Price
        player:SetAttribute("SW1_" .. kind, qty)
    end
    player:SetAttribute("SW1_Carry", n)
    player:SetAttribute("SW1_Value", val)
    player:SetAttribute("SW1_Capacity", Config.BagCapacity)
end
function Inventory.Init(player)
    if items[player] then return end
    local data = {}
    for _, kind in ipairs(Config.MaterialOrder) do data[kind] = 0 end
    items[player] = data
    update(player)
end
function Inventory.TryAdd(player, kind)
    if player:GetAttribute("SW3_Loading") then return false,"Loading your factory..." end
    if not Config.Materials[kind] then return false, "Unknown scrap type" end
    Inventory.Init(player)
    if Inventory.Total(player) >= Config.BagCapacity then
        return false, "BAG FULL! Visit the cyan refinery terminal."
    end
    items[player][kind] += 1
    update(player)
    return true
end
function Inventory.Total(player)
    local data = items[player]
    if not data then return 0 end
    local total = 0
    for _, kind in ipairs(Config.MaterialOrder) do total += data[kind] or 0 end
    return total
end
function Inventory.GetValue(player)
    local data = items[player]
    if not data then return 0 end
    local value = 0
    for _, kind in ipairs(Config.MaterialOrder) do
        value += (data[kind] or 0) * Config.Materials[kind].Price
    end
    return value
end
function Inventory.SellAll(player)
    local data = items[player]
    if not data then return 0, 0 end
    local qty = Inventory.Total(player)
    local value = Inventory.GetValue(player)
    for _, kind in ipairs(Config.MaterialOrder) do data[kind] = 0 end
    update(player)
    return qty, value
end

-- Phase 3: atomic, non-yielding raw-material recipe consumption.
function Inventory.Count(player, kind)
    Inventory.Init(player)
    return (items[player] and items[player][kind]) or 0
end
function Inventory.CanConsume(player, ingredients)
    Inventory.Init(player)
    for kind,amount in pairs(ingredients) do
        if not Config.Materials[kind] or type(amount)~="number" or amount<0 or amount%1~=0 then return false end
        if (items[player][kind] or 0)<amount then return false end
    end
    return true
end
function Inventory.Consume(player, ingredients)
    if not Inventory.CanConsume(player,ingredients) then return false end
    for kind,amount in pairs(ingredients) do items[player][kind]-=amount end
    update(player)
    return true
end
function Inventory.Export(player)
    Inventory.Init(player)
    local record={}
    for _,kind in ipairs(Config.MaterialOrder) do record[kind]=items[player][kind] or 0 end
    return record
end
function Inventory.Import(player,record)
    Inventory.Init(player)
    if type(record)~="table" then return false end
    local clean={};local total=0
    for _,kind in ipairs(Config.MaterialOrder) do
        local q=record[kind]
        if type(q)~="number" or q~=q or q<0 then q=0 end
        q=math.floor(math.min(q,Config.BagCapacity))
        clean[kind]=q;total+=q
    end
    if total>Config.BagCapacity then return false end
    items[player]=clean;update(player)
    return true
end

function Inventory.Release(player) items[player] = nil end
return Inventory
