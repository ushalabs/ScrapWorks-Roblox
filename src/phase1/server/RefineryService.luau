-- Phase 1 / single authoritative sell interaction, 2.4-second processing cycle.
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Config = require(script.Parent.Config)
local Inventory = require(script.Parent.InventoryService)
local Economy = require(script.Parent.EconomyService)
local Refinery = {}
local busy = {}
local function near(player, part)
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    return root and (root.Position - part.Position).Magnitude <= Config.RefineryRange
end
function Refinery.Bind(terminal, indicators, notify)
    for _, p in ipairs(terminal:GetChildren()) do
        if p:IsA("ProximityPrompt") and (p.Name == "SellScrap" or p.Name == "SW1_Refine") then p:Destroy() end
    end
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "SW1_Refine"
    prompt.ObjectText = "SCRAP REFINERY  |  PHASE 1"
    prompt.ActionText = "PROCESS & SELL"
    prompt.HoldDuration = 0.45
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.MaxActivationDistance = 12
    prompt.RequiresLineOfSight = false
    prompt.Parent = terminal
    prompt.Triggered:Connect(function(player)
        if busy[player] or not near(player, terminal) then return end
        if Inventory.Total(player) <= 0 then notify(player, "Bag empty! Find scrap marked by glowing pads."); return end
        busy[player] = true
        player:SetAttribute("SW1_Processing", true)
        notify(player, "REFINERY ACTIVE  •  Sorting and processing materials...")
        local pulse = 0
        for _, part in ipairs(indicators:GetChildren()) do
            if part:IsA("BasePart") then
                pulse += 1
                local delayTime = (pulse - 1) * 0.13
                task.delay(delayTime, function()
                    if part.Parent then
                        TweenService:Create(part,TweenInfo.new(.3),{Color=Color3.fromRGB(67,236,209)}):Play()
                        task.delay(.9,function()
                            if part.Parent then TweenService:Create(part,TweenInfo.new(.65),{Color=Color3.fromRGB(54,80,96)}):Play() end
                        end)
                    end
                end)
            end
        end
        task.delay(Config.RefineryProcessingSeconds,function()
            busy[player] = nil
            if player.Parent ~= Players then return end
            player:SetAttribute("SW1_Processing", false)
            if not near(player, terminal) then notify(player, "Processing canceled. Stay near the terminal."); return end
            local amount, value = Inventory.SellAll(player)
            if amount <= 0 then notify(player, "Your bag is empty."); return end
            if Economy.Credit(player, value) then
                notify(player, "SALE COMPLETE  •  " .. tostring(amount) .. " pieces  •  +$" .. tostring(value))
            end
        end)
    end)
    Players.PlayerRemoving:Connect(function(player) busy[player] = nil end)
end
return Refinery
