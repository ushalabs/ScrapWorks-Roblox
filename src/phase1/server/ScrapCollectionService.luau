-- Phase 1 / bind original and new scrap models to the same inventory service.
local Service = {}
local Config = require(script.Parent.Config)
local Inventory = require(script.Parent.InventoryService)
local function near(player, target, maxDist)
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    return root and (root.Position - target.Position).Magnitude <= maxDist
end
function Service.Bind(container, notify)
    local bound = 0
    for _, node in ipairs(container:GetChildren()) do
        if node:IsA("Model") then
            local core = node:FindFirstChild("Core")
            local kind = string.match(node.Name, "^Scrap_(%a+)_")
            local item = kind and Config.Materials[kind]
            if core and core:IsA("BasePart") and item then
                for _, p in ipairs(core:GetChildren()) do
                    if p:IsA("ProximityPrompt") and (p.Name == "CollectScrap" or p.Name == "SW1_Collect") then
                        p:Destroy()
                    end
                end
                local prompt = Instance.new("ProximityPrompt")
                prompt.Name = "SW1_Collect"
                prompt.ObjectText = kind .. "  |  $" .. tostring(item.Price)
                prompt.ActionText = "Collect Scrap"
                prompt.KeyboardKeyCode = Enum.KeyCode.E
                prompt.HoldDuration = 0.2
                prompt.RequiresLineOfSight = false
                prompt.MaxActivationDistance = 9
                prompt.Parent = core
                local visuals = {}
                for _, part in ipairs(node:GetDescendants()) do
                    if part:IsA("BasePart") and not string.find(part.Name, "Pad") then
                        visuals[part] = {part.Transparency, part.CanCollide}
                    end
                end
                local cooling = false
                prompt.Triggered:Connect(function(player)
                    if cooling or not near(player, core, Config.CollectionRange) then return end
                    local ok, message = Inventory.TryAdd(player, kind)
                    if not ok then notify(player, message); return end
                    cooling = true
                    prompt.Enabled = false
                    for part, old in pairs(visuals) do
                        if part.Parent then part.Transparency = 1; part.CanCollide = false end
                    end
                    notify(player, "Collected " .. kind .. "  •  +$" .. tostring(item.Price) .. " sale value")
                    task.delay(Config.ScrapRespawnSeconds, function()
                        for part, old in pairs(visuals) do
                            if part.Parent then part.Transparency = old[1]; part.CanCollide = old[2] end
                        end
                        if prompt.Parent then prompt.Enabled = true end
                        cooling = false
                    end)
                end)
                bound += 1
            end
        end
    end
    return bound
end
return Service
