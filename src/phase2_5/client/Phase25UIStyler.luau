-- Scrapworks Phase 2.5: reskins existing functional UI. No duplicate economy or purchase listeners.
local Players=game:GetService("Players")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui",20)
if not pg then return end
local hud=pg:WaitForChild("ScrapworksPhase1HUD",25)
local upgrades=pg:WaitForChild("ScrapworksPhase2HUD",25)
if not hud or not upgrades then warn("[SW2.5] Previous HUD missing; skipped style-only pass"); return end
local C={BG=Color3.fromRGB(10,22,35),PANEL=Color3.fromRGB(18,36,51),MID=Color3.fromRGB(28,49,63),CYAN=Color3.fromRGB(72,233,223),GOLD=Color3.fromRGB(255,201,95),TEXT=Color3.fromRGB(244,250,252),MUTE=Color3.fromRGB(160,189,204)}
local function frameStyle(f,r,strokeColor,gradient)
    if not f or not f:IsA("GuiObject") then return end
    f.BackgroundColor3=C.BG
    f.BackgroundTransparency=.08
    local corner=f:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
    corner.CornerRadius=UDim.new(0,r or 14)
    corner.Parent=f
    local stroke=f:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
    stroke.Color=strokeColor or C.CYAN
    stroke.Thickness=1.2
    stroke.Transparency=.58
    stroke.Parent=f
    if gradient then
        local gr=f:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient")
        gr.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(26,49,65)),ColorSequenceKeypoint.new(1,C.BG)})
        gr.Rotation=115
        gr.Parent=f
    end
end
local function decorate(parent,name,pos,size,color)
    local f=parent:FindFirstChild(name)
    if not f then f=Instance.new("Frame") f.Name=name f.BorderSizePixel=0 f.Parent=parent end
    f.Position=pos;f.Size=size;f.BackgroundColor3=color or C.CYAN
    local corner=f:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
    corner.CornerRadius=UDim.new(1,0);corner.Parent=f
    return f
end
local brand=hud:FindFirstChild("Brand")
if brand then
    frameStyle(brand,14,C.CYAN,true)
    brand.Size=UDim2.fromOffset(335,52)
    local title=brand:FindFirstChild("BrandText")
    if title then
        title.Text="SCRAPWORKS  |  INDUSTRIAL YARD"
        title.Position=UDim2.fromOffset(12,0)
        title.Size=UDim2.new(1,-24,1,0)
        title.TextSize=17
        title.Font=Enum.Font.GothamBlack
        title.TextColor3=C.CYAN
    end
    decorate(brand,"Phase25Accent",UDim2.fromOffset(16,45),UDim2.new(1,-32,0,3),C.GOLD)
end
local inventory=hud:FindFirstChild("MaterialInventory")
if inventory then
    inventory.Size=UDim2.fromOffset(386,235)
    frameStyle(inventory,15,C.CYAN,true)
    decorate(inventory,"TopAccent",UDim2.fromOffset(15,5),UDim2.new(1,-30,0,3),C.CYAN)
    local head=inventory:FindFirstChild("PanelTitle")
    if head then
        head.Text="MATERIALS  /  STORAGE"
        head.Position=UDim2.fromOffset(16,10)
        head.TextColor3=C.CYAN
        head.Font=Enum.Font.GothamBold
        head.TextSize=13
    end
    local count=inventory:FindFirstChild("QtyText")
    if count then
        count.Position=UDim2.new(1,-105,0,9)
        count.Size=UDim2.fromOffset(86,28)
        count.TextSize=17;count.TextXAlignment=Enum.TextXAlignment.Right
    end
    local cash=inventory:FindFirstChild("CashText")
    if cash then
        cash.Position=UDim2.fromOffset(16,39)
        cash.Size=UDim2.new(1,-32,0,32)
        cash.TextSize=24
        cash.TextColor3=C.GOLD
        cash.Font=Enum.Font.GothamBlack
    end
    local grid=inventory:FindFirstChild("MaterialGrid")
    if grid then
        grid.Position=UDim2.fromOffset(15,80)
        grid.Size=UDim2.new(1,-30,0,116)
        local layout=grid:FindFirstChildOfClass("UIGridLayout")
        if layout then layout.CellSize=UDim2.new(.5,-6,0,34);layout.CellPadding=UDim2.fromOffset(10,5) end
        for _,cell in ipairs(grid:GetChildren()) do
            if cell:IsA("Frame") then
                cell.BackgroundColor3=C.MID
                local qty=cell:FindFirstChild("Quantity")
                if qty then qty.Position=UDim2.new(1,-34,0,0);qty.Size=UDim2.fromOffset(25,32);qty.TextXAlignment=Enum.TextXAlignment.Right end
                local txt=cell:FindFirstChild("Name")
                if txt then txt.Position=UDim2.fromOffset(10,0);txt.Size=UDim2.new(1,-48,1,0) end
            end
        end
    end
    local footer=inventory:FindFirstChild("Footnote")
    if footer then footer.Position=UDim2.fromOffset(16,205);footer.Size=UDim2.new(1,-32,0,23);footer.Text="6 MATERIALS    •    COLLECT  /  PROCESS  /  UPGRADE";footer.TextSize=10;footer.TextColor3=C.MUTE end
end
local toast=hud:FindFirstChild("Toast")
if toast then
    frameStyle(toast,12,C.CYAN,true)
    toast.Size=UDim2.fromOffset(520,54)
    local t=toast:FindFirstChild("ToastLabel")
    if t then t.Size=UDim2.new(1,-26,1,-4);t.Position=UDim2.fromOffset(13,2);t.TextColor3=C.TEXT end
end
local progress=hud:FindFirstChild("ProcessPanel")
if progress then
    frameStyle(progress,12,C.CYAN,true)
    progress.Size=UDim2.fromOffset(330,64)
    local tr=progress:FindFirstChild("Track")
    if tr then tr.Size=UDim2.new(1,-24,0,9);tr.Position=UDim2.fromOffset(12,44) end
end
local toggle=upgrades:FindFirstChild("UpgradeToggle")
if toggle then
    frameStyle(toggle,12,C.GOLD,true)
    toggle.Size=UDim2.fromOffset(178,52)
    toggle.BackgroundColor3=C.BG
    toggle.TextColor3=C.TEXT
    toggle.TextSize=15
    toggle.Font=Enum.Font.GothamBlack
end
local shop=upgrades:FindFirstChild("MachineShop")
if shop then
    frameStyle(shop,18,C.CYAN,true)
    shop.BackgroundColor3=C.BG
    local title=shop:FindFirstChild("Title")
    if title then title.Text="UPGRADE YOUR FACTORY";title.TextSize=23;title.TextColor3=C.CYAN end
    local sub=shop:FindFirstChild("Subtitle")
    if sub then sub.Text="Unlock new stations  •  earn more per processed bag";sub.TextColor3=C.MUTE end
    for _,name in ipairs({"CompactorCard","SorterCard","SmelterCard"}) do
        local card=shop:FindFirstChild(name)
        if card then
            card.BackgroundColor3=C.MID
            local corner=card:FindFirstChildOfClass("UICorner")
            if corner then corner.CornerRadius=UDim.new(0,13) end
        end
    end
end
-- Smaller screens: rely on Phase1/Phase2 native UIScale. Styler never overrides
-- gameplay-facing values, click callbacks, or state bindings.
print("[SW2.5] Existing HUD and Upgrade Shop reskinned successfully")
