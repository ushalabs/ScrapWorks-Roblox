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
function Inventory.Release(player) items[player] = nil end
return Inventory
