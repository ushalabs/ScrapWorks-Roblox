-- Scrapworks Phase 2.5 CORRECTED: subtle industrial reskin only.
-- No HUD rebuilding, resizing, duplicate event listeners or purchase callbacks.
local player=game:GetService("Players").LocalPlayer
local gui=player:WaitForChild("PlayerGui",25)
if not gui then return end
local hud=gui:WaitForChild("ScrapworksPhase1HUD",25)
local upgrades=gui:WaitForChild("ScrapworksPhase2HUD",25)
if not hud or not upgrades then
    warn("[SW2.5 FIX] Waiting for prerequisite phase HUD; styling skipped")
    return
end
local teal=Color3.fromRGB(74,225,220)
local yellow=Color3.fromRGB(255,199,96)
local pale=Color3.fromRGB(232,245,249)
local bg=Color3.fromRGB(15,32,47)
local function style(frame,accent)
    if not frame or not frame:IsA("GuiObject") then return end
    frame.BackgroundColor3=bg
    local corner=frame:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
    corner.CornerRadius=UDim.new(0,12)
    corner.Parent=frame
    local stroke=frame:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
    stroke.Color=accent or teal
    stroke.Transparency=.65
    stroke.Thickness=1.15
    stroke.Parent=frame
end
local brand=hud:FindFirstChild("Brand")
if brand then
    style(brand,teal)
    local label=brand:FindFirstChild("BrandText")
    if label then label.TextColor3=teal;label.Font=Enum.Font.GothamBold end
end
local inventory=hud:FindFirstChild("MaterialInventory")
if inventory then
    style(inventory,teal)
    local ttl=inventory:FindFirstChild("PanelTitle")
    if ttl then ttl.TextColor3=teal end
    local cash=inventory:FindFirstChild("CashText")
    if cash then cash.TextColor3=yellow end
    local count=inventory:FindFirstChild("QtyText")
    if count then
        -- Phase2 already has a verified correction: keep its anchoring and size.
        count.TextColor3=pale
        count.TextXAlignment=Enum.TextXAlignment.Right
    end
end
local toast=hud:FindFirstChild("Toast")
if toast then style(toast,teal) end
local panel=hud:FindFirstChild("ProcessPanel")
if panel then style(panel,teal) end
local toggle=upgrades:FindFirstChild("UpgradeToggle")
if toggle then style(toggle,yellow);toggle.TextColor3=pale end
local shop=upgrades:FindFirstChild("MachineShop")
if shop then
    style(shop,teal)
    for _,nm in ipairs({"CompactorCard","SorterCard","SmelterCard"}) do
        local card=shop:FindFirstChild(nm)
        if card then
            card.BackgroundColor3=Color3.fromRGB(27,49,67)
            local corner=card:FindFirstChildOfClass("UICorner")
            if corner then corner.CornerRadius=UDim.new(0,10) end
        end
    end
end
print("[SW2.5 FIX] Non-destructive HUD styling applied")
