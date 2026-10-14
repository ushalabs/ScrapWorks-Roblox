-- SCRAPWORKS DEMO v1 | session-only scrap collection and refinery
-- Everything stays inside this imported model. No external modules or asset IDs.
local Players = game:GetService("Players")
local Demo = script.Parent
local Nodes = Demo:WaitForChild("ScrapNodes")
local Refinery = Demo:WaitForChild("Refinery")
local Terminal = Refinery:WaitForChild("SellTerminal")

local CAPACITY = 5
local RESPAWN_SECONDS = 8
local PRICES = { Steel = 15, Copper = 25, Circuit = 40 }

local function notify(player, message)
    player:SetAttribute("SW_Notice", message)
    player:SetAttribute("SW_NoticeVersion", (player:GetAttribute("SW_NoticeVersion") or 0) + 1)
end

local function getCash(player)
    local stats = player:FindFirstChild("leaderstats")
    return stats and stats:FindFirstChild("Cash")
end

local function setup(player)
    if player:GetAttribute("SW_DemoReady") then return end
    player:SetAttribute("SW_DemoReady", true)
    player:SetAttribute("SW_Carry", 0)
    player:SetAttribute("SW_CarryValue", 0)
    player:SetAttribute("SW_Notice", "Welcome! Collect 5 scraps, then use the refinery.")
    player:SetAttribute("SW_NoticeVersion", 1)

    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then
        leaderstats = Instance.new("Folder")
        leaderstats.Name = "leaderstats"
        leaderstats.Parent = player
    end
    local cash = leaderstats:FindFirstChild("Cash")
    if not cash then
        cash = Instance.new("IntValue")
        cash.Name = "Cash"
        cash.Value = 0
        cash.Parent = leaderstats
    end

    task.spawn(function()
        local gui = player:WaitForChild("PlayerGui", 15)
        local template = Demo:FindFirstChild("ScrapworksHUD")
        if gui and template and not gui:FindFirstChild("ScrapworksHUD") then
            template:Clone().Parent = gui
        end
    end)
end

Players.PlayerAdded:Connect(setup)
for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(setup, player)
end

local function withinRange(player, part, maxDistance)
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    return root ~= nil and (root.Position - part.Position).Magnitude <= maxDistance
end

for _, node in ipairs(Nodes:GetChildren()) do
    if node:IsA("Model") then
        local core = node:FindFirstChild("Core")
        if core and core:IsA("BasePart") then
            local kind = string.match(node.Name, '^Scrap_(%a+)_') or "Steel"
            local price = PRICES[kind] or 15
            local prompt = Instance.new("ProximityPrompt")
            prompt.Name = "CollectScrap"
            prompt.ObjectText = kind .. " Scrap (+$" .. tostring(price) .. ")"
            prompt.ActionText = "Collect"
            prompt.KeyboardKeyCode = Enum.KeyCode.E
            prompt.HoldDuration = 0.3
            prompt.MaxActivationDistance = 9
            prompt.RequiresLineOfSight = false
            prompt.Parent = core

            local busy = false
            local appearance = {}
            for _, obj in ipairs(node:GetDescendants()) do
                if obj:IsA("BasePart") then
                    appearance[obj] = { obj.Transparency, obj.CanCollide }
                end
            end

            prompt.Triggered:Connect(function(player)
                if busy or not withinRange(player, core, 12) then return end
                setup(player)
                local carrying = player:GetAttribute("SW_Carry") or 0
                if carrying >= CAPACITY then
                    notify(player, "Bag full (5/5)! Sell at the cyan refinery terminal.")
                    return
                end
                busy = true
                player:SetAttribute("SW_Carry", carrying + 1)
                player:SetAttribute("SW_CarryValue", (player:GetAttribute("SW_CarryValue") or 0) + price)
                notify(player, "Collected " .. kind .. " scrap! +$" .. tostring(price) .. " sale value")

                prompt.Enabled = false
                for part, old in pairs(appearance) do
                    if part.Parent then
                        part.Transparency = 1
                        part.CanCollide = false
                    end
                end
                task.delay(RESPAWN_SECONDS, function()
                    for part, old in pairs(appearance) do
                        if part.Parent then
                            part.Transparency = old[1]
                            part.CanCollide = old[2]
                        end
                    end
                    if prompt.Parent then prompt.Enabled = true end
                    busy = false
                end)
            end)
        end
    end
end

local sellPrompt = Instance.new("ProximityPrompt")
sellPrompt.Name = "SellScrap"
sellPrompt.ObjectText = "SCRAP REFINERY"
sellPrompt.ActionText = "PROCESS & SELL"
sellPrompt.KeyboardKeyCode = Enum.KeyCode.E
sellPrompt.HoldDuration = 0.5
sellPrompt.MaxActivationDistance = 12
sellPrompt.RequiresLineOfSight = false
sellPrompt.Parent = Terminal
sellPrompt.Triggered:Connect(function(player)
    if not withinRange(player, Terminal, 16) then return end
    setup(player)
    local count = player:GetAttribute("SW_Carry") or 0
    if count <= 0 then
        notify(player, "No scrap in your bag — collect some first!")
        return
    end
    local value = player:GetAttribute("SW_CarryValue") or 0
    local cash = getCash(player)
    if not cash then return end
    cash.Value += value
    player:SetAttribute("SW_Carry", 0)
    player:SetAttribute("SW_CarryValue", 0)
    notify(player, "REFINED " .. tostring(count) .. " SCRAP • +$" .. tostring(value) .. " CASH!")
end)

local function signOn(part, caption, accent)
    local gui = Instance.new("SurfaceGui")
    gui.Name = "MachineSignage"
    gui.Face = Enum.NormalId.Back
    gui.LightInfluence = 0
    gui.PixelsPerStud = 45
    gui.AlwaysOnTop = false
    gui.Parent = part
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1,1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.TextColor3 = accent
    label.TextStrokeColor3 = Color3.fromRGB(7,20,25)
    label.TextStrokeTransparency = .15
    label.Text = caption
    label.Parent = gui
end
local mainSign = Refinery:FindFirstChild("RefinerySign")
if mainSign then signOn(mainSign,"SCRAP REFINERY",Color3.fromRGB(73,235,217)) end
local intro = Demo:FindFirstChild("Environment")
if intro then
    local hangar = intro:FindFirstChild("HangarBackWall")
    if hangar then signOn(hangar,"SCRAPWORKS  |  SALVAGE BAY",Color3.fromRGB(255,210,108)) end
end
print("[Scrapworks demo] Loaded successfully: 9 scrap nodes, refinery, per-player HUD, session cash.")
