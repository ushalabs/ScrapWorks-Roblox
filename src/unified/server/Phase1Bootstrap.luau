-- SCRAPWORKS PHASE 1 | Non-destructive modular add-on for SCRAPWORKS_DEMO_V1
-- Import exactly once beside the original model under Workspace.
local Players = game:GetService("Players")
local Root = script.Parent
local GameRoot = Root.Parent
local Original = GameRoot:WaitForChild("SCRAPWORKS_DEMO_V1", 20)
if not Original then
    warn("[Scrapworks Phase1] Phase0 model missing. Import SCRAPWORKS_DEMO_V1 first.")
    return
end
-- Stop Phase0 gameplay scripts so two independent economies never run simultaneously.
local oldServer = Original:FindFirstChild("ScrapworksServer")
if oldServer and oldServer:IsA("Script") then oldServer.Disabled = true end
local oldHudTemplate = Original:FindFirstChild("ScrapworksHUD")
if oldHudTemplate and oldHudTemplate:IsA("LocalScript") then oldHudTemplate.Disabled = true end
local Config = require(Root:WaitForChild("Config"))
local Inventory = require(Root:WaitForChild("InventoryService"))
local Economy = require(Root:WaitForChild("EconomyService"))
local Collection = require(Root:WaitForChild("ScrapCollectionService"))
local Refinery = require(Root:WaitForChild("RefineryService"))

local function notify(player, message)
    player:SetAttribute("SW1_Notice", message)
    player:SetAttribute("SW1_NoticeSeq", (player:GetAttribute("SW1_NoticeSeq") or 0) + 1)
end
local function setup(player)
    if player:GetAttribute("SW1_Ready") then return end
    player:SetAttribute("SW1_Ready", true)
    Economy.Init(player)
    Inventory.Init(player)
    player:SetAttribute("SW1_Processing", false)
    local function installGui()
        local gui = player:WaitForChild("PlayerGui", 15)
        if not gui then return end
        -- Remove Phase0 HUD if its setup ran before this upgrade.
        local oldGuiScript = gui:FindFirstChild("ScrapworksHUD")
        if oldGuiScript then oldGuiScript:Destroy() end
        local oldHudScreen = gui:FindFirstChild("ScrapworksHUDScreen")
        if oldHudScreen then oldHudScreen:Destroy() end
        if not gui:FindFirstChild("ScrapworksPhase1HUD") then
            local template = Root:FindFirstChild("ScrapworksPhase1HUD")
            if template then template:Clone().Parent = gui end
        end
    end
    task.spawn(installGui)
    notify(player, "PHASE 1 ONLINE  •  Collect 6 kinds of scrap, then refine!")
end
Players.PlayerAdded:Connect(setup)
Players.PlayerRemoving:Connect(function(player) Inventory.Release(player) end)
for _,player in ipairs(Players:GetPlayers()) do task.spawn(setup,player) end

-- Remove Phase0 dynamically created prompts, regardless of script startup order.
local oldNodes = Original:FindFirstChild("ScrapNodes")
if oldNodes then
    for _,n in ipairs(oldNodes:GetDescendants()) do
        if n:IsA("ProximityPrompt") and n.Name == "CollectScrap" then n:Destroy() end
    end
end
local originalRefinery = Original:FindFirstChild("Refinery")
local terminal = originalRefinery and originalRefinery:FindFirstChild("SellTerminal")
if terminal then
    for _,n in ipairs(terminal:GetChildren()) do
        if n:IsA("ProximityPrompt") and n.Name == "SellScrap" then n:Destroy() end
    end
end
-- Open a visual corridor from the original yard to the freight annex.
local originalWorld = Original:FindFirstChild("Environment")
if originalWorld then
    for _,part in ipairs(originalWorld:GetChildren()) do
        if part:IsA("BasePart") and (part.Name == "SideBoundary" or part.Name == "FenceHorizontal" or part.Name == "FencePost") and part.Position.X > 40 then
            part.Transparency = 1
            part.CanCollide = false
        end
    end
end
if not oldNodes or not terminal then
    warn("[Scrapworks Phase1] Expected Phase0 scrap nodes/refinery are missing. Installation incomplete.")
    return
end
local nOld = Collection.Bind(oldNodes, notify)
local nNew = Collection.Bind(Root:WaitForChild("AdditionalScrapNodes"), notify)
Refinery.Bind(terminal, Root:WaitForChild("RefineryVisualEffects"), notify)

local function signage(part,caption,fg)
    local gui=Instance.new("SurfaceGui")
    gui.Name="SW1_Sign"
    gui.Face=Enum.NormalId.Front
    gui.PixelsPerStud=35
    gui.LightInfluence=0
    gui.Parent=part
    local l=Instance.new("TextLabel")
    l.BackgroundTransparency=1
    l.Size=UDim2.fromScale(1,1)
    l.Font=Enum.Font.GothamBlack
    l.TextScaled=true
    l.Text=caption
    l.TextColor3=fg
    l.TextStrokeTransparency=.2
    l.Parent=gui
end
local st=Root:FindFirstChild("FreightAnnex")
local structures=st and st:FindFirstChild("Structures")
local sg=structures and structures:FindFirstChild("SortingSign")
if sg then signage(sg,"SORTING & SALVAGE",Color3.fromRGB(94,240,222)) end
print("[Scrapworks Phase1] Upgrade active: "..tostring(nOld).." original nodes + "..tostring(nNew).." new nodes; "..tostring(#Config.MaterialOrder).." materials; bag capacity "..tostring(Config.BagCapacity))
