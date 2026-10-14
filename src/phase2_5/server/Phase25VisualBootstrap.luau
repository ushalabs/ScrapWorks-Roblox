-- Scrapworks Phase 2.5: VISUAL-ONLY additive enhancement.
-- No cash, inventory, or purchase authority. Import under Workspace ONCE.
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local root = script.Parent
if workspace:FindFirstChild("SCRAPWORKS_PHASE25_VISUALS") ~= root then
    warn("[SW2.5] Duplicate visual package detected; only the canonical package is active")
    return
end
local original = workspace:WaitForChild("SCRAPWORKS_DEMO_V1", 25)
local phase1 = workspace:WaitForChild("SCRAPWORKS_PHASE1_ADDON", 25)
local phase2 = workspace:WaitForChild("SCRAPWORKS_PHASE2_ADDON", 25)
if not (original and phase1 and phase2) then
    warn("[SW2.5] Missing previous phase. Install Phase0, Phase1, Phase2 before Phase2.5")
    return
end

-- Scrap visuals already exist in the saved model, including in Studio's Edit view.
-- Phase1 captured its original node parts before our model was imported. We listen
-- to the authoritative SW1_Collect.Enabled state and hide/show our new models.
local salvage = root:WaitForChild("SalvageVisuals")
local containers = {original:FindFirstChild("ScrapNodes"), phase1:FindFirstChild("AdditionalScrapNodes")}
local hooked = 0
local function installNode(node)
    local visuals = salvage:FindFirstChild(node.Name)
    if not visuals then return end
    local core = node:FindFirstChild("Core")
    if not core then return end
    local prompt = core:WaitForChild("SW1_Collect", 25)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    local generic = {}
    for _, obj in ipairs(node:GetDescendants()) do
        if obj:IsA("BasePart") and obj ~= core and not string.find(obj.Name, "Pad") then
            table.insert(generic, obj)
        end
    end
    local visualParts = {}
    for _, obj in ipairs(visuals:GetDescendants()) do
        if obj:IsA("BasePart") then
            table.insert(visualParts, {part=obj, transparency=obj.Transparency})
        end
    end
    local function sync()
        local available = prompt.Enabled
        for _, obj in ipairs(generic) do
            if obj.Parent then obj.Transparency = 1; obj.CanCollide = false end
        end
        for _, item in ipairs(visualParts) do
            if item.part.Parent then
                item.part.Transparency = available and item.transparency or 1
                item.part.CanCollide = false
            end
        end
    end
    -- Run deferred after Phase1 has restored its old scrap visuals on respawn.
    prompt:GetPropertyChangedSignal("Enabled"):Connect(function()
        task.defer(sync)
    end)
    sync()
    hooked += 1
end
for _, container in ipairs(containers) do
    if container then
        for _, node in ipairs(container:GetChildren()) do
            if node:IsA("Model") then task.spawn(installNode,node) end
        end
    end
end

-- Cosmetic readouts react to existing authoritative processing attributes.
local machineDecor = root:WaitForChild("MachineVisualExtensions")
local function pulseFolder(folder, tint)
    for _,part in ipairs(folder:GetDescendants()) do
        if part:IsA("BasePart") and (string.find(part.Name,"Glow") or string.find(part.Name,"Molten") or string.find(part.Name,"Emitter")) then
            local color = part.Color
            local tween = TweenService:Create(part, TweenInfo.new(.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Color=tint})
            tween:Play()
            task.delay(.95,function()
                if part.Parent then TweenService:Create(part,TweenInfo.new(.8),{Color=color}):Play() end
            end)
        end
    end
end
local tints={Compactor=Color3.fromRGB(255,205,91),Sorter=Color3.fromRGB(70,242,223),Smelter=Color3.fromRGB(255,116,46)}
local names={Compactor="HydraulicCompactor",Sorter="OpticalSortingArray",Smelter="HighGradeInductionSmelter"}
local function setupPlayer(player)
    local pg = player:WaitForChild("PlayerGui",20)
    if pg and not pg:FindFirstChild("ScrapworksPhase25Styling") then
        local template = root:FindFirstChild("ScrapworksPhase25Styling")
        if template then template:Clone().Parent=pg end
    end
    player:GetAttributeChangedSignal("SW2_ActiveMachine"):Connect(function()
        local id=player:GetAttribute("SW2_ActiveMachine")
        local folder=id and machineDecor:FindFirstChild(names[id] or "")
        if folder then pulseFolder(folder,tints[id]) end
    end)
end
Players.PlayerAdded:Connect(function(player)task.spawn(setupPlayer,player)end)
for _,player in ipairs(Players:GetPlayers()) do task.spawn(setupPlayer,player) end
print("[SW2.5] Visual enhancement installed; linked collectible sets:",hooked)
