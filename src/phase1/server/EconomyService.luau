-- Phase 1 / centralized cash handling. Session-only during development.
local Economy = {}
function Economy.Init(player)
    local stats = player:FindFirstChild("leaderstats")
    if not stats then
        stats = Instance.new("Folder")
        stats.Name = "leaderstats"
        stats.Parent = player
    end
    local cash = stats:FindFirstChild("Cash")
    if not cash then
        cash = Instance.new("IntValue")
        cash.Name = "Cash"
        cash.Value = 0
        cash.Parent = stats
    end
    return cash
end
function Economy.Credit(player, amount)
    if typeof(amount) ~= "number" or amount < 0 or amount % 1 ~= 0 then return false end
    local cash = Economy.Init(player)
    cash.Value += amount
    return true
end
return Economy
